PREFIX ?= $(HOME)/.local

IMAGE ?= mistral-vibe:latest

SHARE_DIR := $(PREFIX)/share/mistral-vibe-container
BIN_DIR := $(PREFIX)/bin
BIN := $(BIN_DIR)/vibe

FILES := vibe build.sh Containerfile packages.txt sudoers environment

.PHONY: install uninstall clean

install:
	@mkdir -p $(SHARE_DIR)
	@cp -p $(FILES) $(SHARE_DIR)/
	@mkdir -p $(BIN_DIR)
	@ln -sf $(SHARE_DIR)/vibe $(BIN)
	@echo "Installed files to $(SHARE_DIR)"
	@echo "Installed shortcut $(BIN) -> $(SHARE_DIR)/vibe"

uninstall:
	@rm -rf $(SHARE_DIR)
	@rm -f $(BIN)
	@echo "Removed $(SHARE_DIR) and $(BIN)"

clean:
	@if podman image exists $(IMAGE); then \
		podman image rm $(IMAGE); \
		echo "Removed image $(IMAGE)"; \
	else \
		echo "Image $(IMAGE) not found, nothing to do"; \
	fi
