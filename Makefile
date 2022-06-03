.DEFAULT_GOAL := build

SHELL := /bin/bash

WISHLIST_TXT = wishlist.txt

SRC_DIR = src

SRCS = $(SRC_DIR)/voltron.txt

# Sources
VOLTRON_TXT = https://raw.githubusercontent.com/48klocs/dim-wish-list-sources/master/voltron.txt

$(SRC_DIR)/voltron.txt:
	curl -slo $@ $(VOLTRON_TXT)

# DIM List

$(WISHLIST_TXT): $(wildcard $(SRC_DIR)/*.txt)
	cat $^ > $@


build: $(WISHLIST_TXT)

clean: ; rm -f $(WISHLIST_TXT)

.PHONY: build clean
