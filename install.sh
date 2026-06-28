#!/usr/bin/env bash
set -euo pipefail

# Raspberry Pi: RPI=1 (env) or --rpi (arg) writes the native-boot Raspberry Pi
# image (Pi 4/400/CM4, Pi 5/CM5) instead of the standard PC image. The Pi image is
# always 64-bit Arm regardless of THIS machine's architecture, so it pulls a fixed
# release-aarch64-rpi tag and requests the arm64 platform (so podman doesn't balk
# when you flash the SD card / USB / NVMe from an x86_64 laptop).
RPI="${RPI:-}"
for _arg in "$@"; do
    case "$_arg" in
        --rpi) RPI=1 ;;
    esac
done

if [ -n "$RPI" ]; then
    DEFAULT_TAG="release-aarch64-rpi"
    PLATFORM_OPT="linux/arm64"
else
    DEFAULT_TAG="release-$(uname -m)"
    PLATFORM_OPT=""
fi
INSTALLER_IMAGE="${TOWN_OS_INSTALLER_IMAGE:-quay.io/town/installer:${DEFAULT_TAG}}"
IMAGE_PATH="/town-os.img.bz2"

die() { echo "Error: $*" >&2; exit 1; }

# Check for required tools
for cmd in bzip2 dd lsblk podman tar; do
    command -v "$cmd" >/dev/null 2>&1 || die "'$cmd' is required but not found"
done

# Verify podman is usable by the current user (not just installed)
if ! podman info >/dev/null 2>&1; then
    die "Podman is installed but not functioning. Check 'podman info' for details."
fi

# Find USB block devices by checking if the sysfs device path goes through a USB bus
find_usb_devices() {
    local devices=()
    for block in /sys/block/*; do
        local name
        name=$(basename "$block")

        # Skip non-disk devices (loop, ram, etc.)
        case "$name" in
            loop*|ram*|dm-*|sr*|zram*) continue ;;
        esac

        # Resolve the device path and check if it passes through a USB controller
        local devpath
        devpath=$(readlink -f "$block/device" 2>/dev/null) || continue
        [[ "$devpath" == */usb*/* ]] || continue

        devices+=("/dev/$name")
    done
    printf '%s\n' "${devices[@]}"
}

echo ""
echo "Scanning for USB devices..."
echo ""

mapfile -t usb_devices < <(find_usb_devices)

if [ ${#usb_devices[@]} -eq 0 ]; then
    die "No USB block devices found. Make sure your USB drive is plugged in and recognized by the system."
fi

echo "Available USB devices:"
echo ""
for i in "${!usb_devices[@]}"; do
    dev="${usb_devices[$i]}"
    name=$(basename "$dev")
    size=$(lsblk -dpno SIZE "$dev" 2>/dev/null | xargs)
    model=$(lsblk -dpno MODEL "$dev" 2>/dev/null | xargs)
    vendor=$(cat "/sys/block/$name/device/vendor" 2>/dev/null | xargs)
    serial=$(lsblk -dpno SERIAL "$dev" 2>/dev/null | xargs)

    label="$dev  ${size:-unknown size}"
    [ -n "$vendor" ] && label="$label  $vendor"
    [ -n "$model" ] && label="$label $model"
    [ -n "$serial" ] && label="$label  [$serial]"

    echo "  [$((i + 1))] $label"
done
echo ""
read -rp "Select a device [1-${#usb_devices[@]}]: " choice </dev/tty

if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#usb_devices[@]} ]; then
    selected_device="${usb_devices[$((choice - 1))]}"
else
    die "Invalid selection"
fi

# Validate the device
[ -b "$selected_device" ] || die "'$selected_device' is not a valid block device"

# Guard against a device too small for the image. The UNCOMPRESSED Town OS image
# is a few GB — larger than the compressed download — so an undersized stick
# fills up and dd fails partway with ENOSPC *after* already wiping the device.
# Reject obviously-too-small media up front (before the destructive write). This
# is a conservative floor, not the exact image size; override with
# MIN_DEVICE_BYTES. lsblk reads the size from sysfs, so no root is needed here.
MIN_DEVICE_BYTES="${MIN_DEVICE_BYTES:-3000000000}"
device_bytes=$(lsblk -bdno SIZE "$selected_device" 2>/dev/null | head -1 | xargs)
[ -n "$device_bytes" ] || device_bytes=0
if [ "$device_bytes" -lt "$MIN_DEVICE_BYTES" ]; then
    die "$selected_device is too small ($((device_bytes / 1000 / 1000)) MB). Town OS needs at least $((MIN_DEVICE_BYTES / 1000 / 1000)) MB — use a 4 GB+ drive (override the floor with MIN_DEVICE_BYTES)."
fi

# Confirm
device_info=$(lsblk -dpno NAME,SIZE,MODEL "$selected_device" 2>/dev/null || echo "$selected_device")
echo ""
echo "WARNING: This will DESTROY ALL DATA on $selected_device"
echo "  $device_info"
echo ""
read -rp "Type 'yes' to continue: " confirm </dev/tty
[ "$confirm" = "yes" ] || die "Aborted"

# Determine if we need sudo
run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        die "This script must be run as root or sudo must be available"
    fi
}

# Get sudo credentials up front so the password prompt doesn't conflict with pipes
if [ "$(id -u)" -ne 0 ]; then
    echo ""
    echo "Root access is required to write to $selected_device."
    sudo -v || die "Failed to obtain root access"
fi

# Unmount any mounted partitions on the device
echo ""
echo "Unmounting partitions on $selected_device..."
for part in "${selected_device}"*; do
    if mountpoint -q "$part" 2>/dev/null || mount | grep -q "^$part "; then
        run_as_root umount "$part" 2>/dev/null || true
    fi
done

# Pull the installer image. Its single layer contains the compressed
# USB image at $IMAGE_PATH.
echo ""
echo "Pulling $INSTALLER_IMAGE..."
podman pull ${PLATFORM_OPT:+--platform "$PLATFORM_OPT"} "$INSTALLER_IMAGE" || die "Failed to pull $INSTALLER_IMAGE"

# Create a throwaway container so we can stream the file out via podman cp
# without loading the whole image into memory or a temp file.
container_id=$(podman create ${PLATFORM_OPT:+--platform "$PLATFORM_OPT"} "$INSTALLER_IMAGE")
trap 'podman rm "$container_id" >/dev/null 2>&1 || true' EXIT

# podman cp emits a tar stream on stdout; tar -xO extracts its single
# entry back to stdout so bzip2 and dd can consume it directly.
echo ""
echo "Writing Town OS to $selected_device..."
echo "(progress below shows the uncompressed image size, which is larger than the download)"
echo ""
# Run dd + the final flush + eject in a SINGLE root shell. Two reasons:
#   1. The write can take several minutes on slow USB/SD media, easily exceeding
#      sudo's credential timeout. If sync/eject were separate `sudo` calls after
#      dd, they'd silently re-prompt for a password on /dev/tty — invisible under
#      `curl | bash` — and the script would appear to hang *after* the data was
#      already written. One sudo invocation avoids that re-auth window entirely.
#   2. `dd conv=fsync` (and the sync) block while gigabytes of write-back cache
#      flush to slow media, sitting at ~100% with no output. The message makes
#      that expected instead of looking frozen.
# `set -e` inside the subshell ensures a dd failure (e.g. ENOSPC) still aborts —
# otherwise the trailing `eject || true` would mask it and we'd print "Done!".
podman cp "$container_id:$IMAGE_PATH" - \
    | tar -xO \
    | bzip2 -dc \
    | run_as_root bash -c '
        set -e
        dd of="$1" bs=4M status=progress conv=fsync
        echo
        echo "Flushing buffers to the device (can take a few minutes on slow USB/SD cards)..."
        sync
        eject "$1" 2>/dev/null || true
    ' _ "$selected_device"

echo ""
echo "Done! You can safely remove $selected_device and plug it into the target machine."
