.DEFAULT_GOAL := build

SHELL := /bin/bash

unameOut := $(shell uname -s)

WISHLIST_TXT = wishlist.txt

SRC_DIR = src

SRCS = $(SRC_DIR)/voltron.txt

# Sources
VOLTRON_TXT = https://raw.githubusercontent.com/48klocs/dim-wish-list-sources/master/voltron.txt

$(SRC_DIR)/voltron.txt:
	wget -O $@ $(VOLTRON_TXT)

# DIM List
sed_file := src/GrrBearrS17.txt
sed_lookup := s|//notes: tag|//notes: (GrrBearr) tag|

$(WISHLIST_TXT): $(SRC_DIR)/_header.txt $(wildcard $(SRC_DIR)/*.txt) $(SRCS)
ifeq ($(findstring Darwin,$(unameOut)), Darwin)
	sed -i '' -e "$(sed_lookup)" "$(sed_file)";
else
	sed -i -e "$(sed_lookup)" "$(sed_file)";
endif
	cat $^ > $@


build: $(WISHLIST_TXT)

clean: ; rm -f $(WISHLIST_TXT) $(SRCS)

.PHONY: build clean
