.DEFAULT_GOAL := all
ROOT := $(CURDIR)
VZ200_DIR := ports/vz200
VZ200_BUILD_DIR := build/vz200
LOCAL_SJASMPLUS := $(ROOT)/.tools/sjasmplus/bin/sjasmplus
SYSTEM_SJASMPLUS := $(shell command -v sjasmplus 2>/dev/null)
SJASMPLUS ?= $(if $(wildcard $(LOCAL_SJASMPLUS)),$(LOCAL_SJASMPLUS),$(SYSTEM_SJASMPLUS))
VZ200_BINARY := $(VZ200_BUILD_DIR)/sixies-vz200.bin
VZ200_SNAPSHOT := $(VZ200_BUILD_DIR)/SIXIES.VZ
GENERATED := $(VZ200_DIR)/asm/title_frames.asm $(VZ200_DIR)/asm/title_stars.asm \
	$(VZ200_DIR)/asm/high_score_mascot.asm $(VZ200_DIR)/asm/game_over_frame.asm \
	$(VZ200_DIR)/asm/presents_frame.asm

.PHONY: all vz200 setup-vz200-dev run-vz200
all vz200: $(VZ200_SNAPSHOT)
setup-vz200-dev:
	./scripts/setup-vz200-dev.sh
$(VZ200_BUILD_DIR):
	mkdir -p "$@"
$(VZ200_DIR)/asm/title_frames.asm: $(VZ200_DIR)/assets/title-master.png scripts/convert-vz200-title.py
	python3 scripts/convert-vz200-title.py "$<" "$@"
$(VZ200_DIR)/asm/title_stars.asm: $(wildcard $(VZ200_DIR)/assets/title-stars/*.png) scripts/convert-vz200-title-stars.py
	python3 scripts/convert-vz200-title-stars.py "$(VZ200_DIR)/assets/title-stars" "$@"
$(VZ200_DIR)/asm/high_score_mascot.asm: $(VZ200_DIR)/assets/high-score-mascot-master.png scripts/convert-vz200-high-score-mascot.py
	python3 scripts/convert-vz200-high-score-mascot.py "$<" "$@"
$(VZ200_DIR)/asm/game_over_frame.asm: $(VZ200_DIR)/assets/game-over-master.png scripts/convert-vz200-game-over.py
	python3 scripts/convert-vz200-game-over.py "$<" "$@"
$(VZ200_DIR)/asm/presents_frame.asm: $(VZ200_DIR)/assets/presents-master.png scripts/convert-vz200-presents.py
	python3 scripts/convert-vz200-presents.py "$<" "$@"
$(VZ200_BINARY): $(wildcard $(VZ200_DIR)/asm/*.asm) $(GENERATED) | $(VZ200_BUILD_DIR)
	@if [ -z "$(SJASMPLUS)" ]; then echo "Run make setup-vz200-dev first." >&2; exit 1; fi
	"$(SJASMPLUS)" --nologo "$(VZ200_DIR)/asm/sixies.asm"
$(VZ200_SNAPSHOT): $(VZ200_BINARY) scripts/package-vz200.py
	python3 scripts/package-vz200.py "$<" "$@" --name SIXIES --load-address 0x7AE9
run-vz200: $(VZ200_SNAPSHOT)
	bash scripts/run-vz200.sh "$(abspath $(VZ200_SNAPSHOT))"
