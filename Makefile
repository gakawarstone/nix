.PHONY: check clean switch update

CONFIGURATION ?= gklaptop
HARDWARE_CONFIG := hosts/$(CONFIGURATION)/hardware-configuration.nix

check:
	@test -f "$(HARDWARE_CONFIG)" || { \
		echo "Missing $(HARDWARE_CONFIG)"; \
		echo "Copy the generated hardware configuration from the NixOS target first."; \
		exit 1; \
	}
	nix flake check --no-build

clean:
	sudo nix-collect-garbage --delete-old
	sudo nix store optimise

switch:
	sudo nixos-rebuild switch --flake ".#$(CONFIGURATION)"
	@if command -v dotfiles-install >/dev/null; then \
		dotfiles-install; \
	else \
		echo "dotfiles-install is not enabled for $(CONFIGURATION); skipping."; \
	fi

update:
	nix flake update
