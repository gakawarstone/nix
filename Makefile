.PHONY: check clean switch update

CONFIGURATION ?= gklaptop
HARDWARE_CONFIG := hosts/$(CONFIGURATION)/hardware-configuration.nix
BUILD_OPTIONS_gklaptop := --max-jobs 2 --cores 2
BUILD_OPTIONS := $(BUILD_OPTIONS_$(CONFIGURATION))

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
	sudo nixos-rebuild switch --install-bootloader --flake ".#$(CONFIGURATION)" $(BUILD_OPTIONS)

update:
	nix flake update
	$(MAKE) switch
