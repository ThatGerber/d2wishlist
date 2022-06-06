.DEFAULT_GOAL := $(WISHLIST_TXT)

SHELL := /bin/bash

unameOut := $(shell uname -s)

# Sources
SRC_DIR=src
SRC_FILES=$(wildcard $(SRC_DIR)/GrrBearr*.txt)

BUILD_DIR=build
BUILD_SRC_DIR=$(BUILD_DIR)/src


WISHLIST_TXT=$(BUILD_DIR)/wishlist.txt
$(WISHLIST_TXT): $(BUILD_DIR)


# Header info
LIST_HEADER = $(BUILD_SRC_DIR)/_header.txt
BUILD_FILES += $(LIST_HEADER)

# External Sources
VOLTRON_TXT_URL = https://raw.githubusercontent.com/48klocs/dim-wish-list-sources/master/voltron.txt
VOLTRON_TXT = $(BUILD_SRC_DIR)/voltron.txt
BUILD_FILES+=$(VOLTRON_TXT)


# DIRS
$(BUILD_SRC_DIR) $(BUILD_DIR):
	mkdir -p $@


$(LIST_HEADER): $(SRC_DIR)/_header.txt
	cp $< $@


$(VOLTRON_TXT):
	curl -Lo $@ $(VOLTRON_TXT_URL)


$(BUILD_SRC_DIR)/GrrBearr%.txt: $(SRC_DIR)/GrrBearr%.txt
	( \
		cat "$<" | sed -e "s|//notes: tag|//notes: (GrrBearr) tag|" \
	) > "$@"

BUILD_FILES+=$(patsubst $(SRC_DIR)%,$(BUILD_SRC_DIR)%,$(SRC_FILES))

$(BUILD_FILES): $(BUILD_SRC_DIR)

# My Lists
$(info Source lists: $(BUILD_FILES))
$(WISHLIST_TXT): $(LIST_HEADER) $(BUILD_FILES)
	cat $(filter %.txt,$^) > $@

clean: ; rm -f $(WISHLIST_TXT)
clobber: clean ; rm -f $(BUILD_FILES)

.PHONY: clean clobber
