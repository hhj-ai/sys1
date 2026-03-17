# Copyright 2023 Sycuricon Group
# Author: Phantom (phantom@zju.edu.cn)

ROOT 		:= $(CURDIR)
MAIN_TEX	:= $(ROOT)/main
TEX_SRC		:= $(shell find $(ROOT) -name "*.tex" -o -name "*.bib")
BUILD_DIR	:= $(ROOT)/build
OUT_PDF		:= $(BUILD_DIR)/main.pdf

.PHONY: all clean

all: $(OUT_PDF)

$(OUT_PDF): $(TEX_SRC)
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	latexmk -shell-escape -synctex=1 -interaction=nonstopmode -file-line-error -pdf -output-directory=$(BUILD_DIR) $(MAIN_TEX)

clean:
	rm -rf $(BUILD_DIR)
