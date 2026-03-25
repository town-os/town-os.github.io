#!/usr/bin/env bash
set -euo pipefail

IMAGE_URL="https://gitea.com/town-os/town-os/releases/download/2026-03-24-unstable/town-os-2026-03-24.img.bz2"

die() { echo "Error: $*" >&2; exit 1; }

# Check for required tools
for cmd in bzip2 dd lsblk curl; do
    command -v "$cmd" >/dev/null 2>&1 || die "'$cmd' is required but not found"
done

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

# Stream, decompress, and write in one pipeline
echo "Downloading and writing Town OS to $selected_device..."
echo ""
curl -fL "$IMAGE_URL" | bzip2 -dc | run_as_root dd of="$selected_device" bs=4M status=progress conv=fsync

run_as_root sync
run_as_root eject "$selected_device" 2>/dev/null || true

echo ""
echo "Done! You can safely remove $selected_device and plug it into the target machine."
