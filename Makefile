IMAGE_NAME ?= quay.io/town/installer
RC_TAG     := rc.$(shell date -u +%Y-%m-%d)

serve:
	bun run astro dev --host 0.0.0.0

installer-image:
	@test -f town-os.img.bz2 || { echo "town-os.img.bz2 not found next to Dockerfile" >&2; exit 1; }
	podman build -t $(IMAGE_NAME):latest -t $(IMAGE_NAME):$(RC_TAG) .

installer-push: installer-image
	podman push $(IMAGE_NAME):latest
	podman push $(IMAGE_NAME):$(RC_TAG)

.PHONY: serve installer-image installer-push
