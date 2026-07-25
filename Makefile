.PHONY: check deploy update

CONFIGURATION ?= vmnix
HARDWARE_CONFIG := hosts/$(CONFIGURATION)/hardware-configuration.nix

check:
	@test -f "$(HARDWARE_CONFIG)" || { \
		echo "Missing $(HARDWARE_CONFIG)"; \
		echo "Copy the generated hardware configuration from the NixOS target first."; \
		exit 1; \
	}
	nix flake check --no-build

deploy: check
	@test -n "$(TARGET_HOST)" || { \
		echo "Usage: make deploy TARGET_HOST=user@host"; \
		exit 1; \
	}
	nix run .#nixos-rebuild -- switch \
		--flake ".#$(CONFIGURATION)" \
		--target-host "$(TARGET_HOST)" \
		--sudo

update:
	nix flake update
