# syntax=docker/dockerfile:1
#
# Town OS USB installer image.
#
# The final image has a single layer containing the compressed installer
# image at /town-os.img.bz2. install.sh pulls this image and streams that
# file through bzip2 into dd on the target USB device.
#
# Place town-os.img.bz2 next to this Dockerfile before building.
#
# Build: docker build -t quay.io/town/installer:latest .
# Push:  docker push quay.io/town/installer:latest

FROM scratch
COPY town-os.img.bz2 /town-os.img.bz2
# Dummy CMD so `docker create` (used by install.sh to stream the file
# back out via `docker cp`) does not fail with "no command specified".
# The container is never started.
CMD ["/town-os.img.bz2"]
