.DEFAULT_GOAL := all
SHELL := /bin/bash


unameOut := $(shell uname -s)

# Sources
SRC_DIR=src
SRC_FILES=$(wildcard $(SRC_DIR)/GrrBearr*.txt)

BUILD_DIR=build
BUILD_SRC_DIR=$(BUILD_DIR)/src
BUILD_FILES ?=

$(BUILD_FILES): $(BUILD_SRC_DIR)

# My List
GRRBEARR_TXT = $(BUILD_DIR)/grrbearr.txt
$(GRRBEARR_TXT): $(BUILD_DIR)

# Combined list
WISHLIST_TXT=$(BUILD_DIR)/wishlist.txt
$(WISHLIST_TXT): $(BUILD_DIR)

# External Sources
VOLTRON_TXT_URL = https://raw.githubusercontent.com/48klocs/dim-wish-list-sources/master/voltron.txt
VOLTRON_TXT = $(BUILD_SRC_DIR)/voltron.txt


# DIRS
$(BUILD_SRC_DIR) $(BUILD_DIR):
	mkdir -p $@


BUILD_FILES+=$(BUILD_SRC_DIR)/_header.txt
$(BUILD_SRC_DIR)/_header.txt: $(SRC_DIR)/_header.txt $(BUILD_SRC_DIR)
	cp $< $@


BUILD_FILES+=$(VOLTRON_TXT)
$(VOLTRON_TXT):
	curl -Lo $@ $(VOLTRON_TXT_URL)


BUILD_FILES+=$(patsubst $(SRC_DIR)/GrrBearr%,$(BUILD_SRC_DIR)/GrrBearr%,$(SRC_FILES))
$(BUILD_SRC_DIR)/GrrBearr%.txt: $(SRC_DIR)/GrrBearr%.txt $(BUILD_SRC_DIR)
	( cat "$<" | sed -e "s|//notes: tag|//notes: (GrrBearr) tag|" ) > "$@"


# My List
$(GRRBEARR_TXT): $(BUILD_DIR)
$(GRRBEARR_TXT): $(LIST_HEADER) $(filter $(BUILD_SRC_DIR)/GrrBearr%.txt,$(BUILD_FILES))
	$(info Target: $@ )
	$(info Sources: $^ )
	cat $(filter %.txt,$^) > $@

# Combined Lists
$(WISHLIST_TXT): $(BUILD_DIR)
$(WISHLIST_TXT): $(LIST_HEADER) $(filter %.txt,$(BUILD_FILES))
	$(info Target: $@ )
	$(info Sources: $^ )
	cat $(filter %.txt,$^) > $@

$(BUILD_DIR)/completed: $(WISHLIST_TXT) $(GRRBEARR_TXT)

all: $(BUILD_DIR)/completed

clean:
	rm -f \
		$(BUILD_FILES) \
		$(WISHLIST_TXT) \
		$(GRRBEARR_TXT) \
		$(BUILD_DIR)/completed
	rmdir \
		$(BUILD_SRC_DIR) \
		$(BUILD_DIR)

.PHONY: all clean clobber
