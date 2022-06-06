.DEFAULT_GOAL := all
SHELL := /bin/bash

unameOut := $(shell uname -s)


define build_header
echo "title:$(1)"; \
echo "description:$(2)";
endef


define build_info
echo ''; \
echo "// Build Info:"; \
echo "//   Time:      $(shell date +'%Y-%m-%dT%H:%M:%S')"; \
echo "//   Workflow:  $${GITHUB_WORKFLOW}"; \
echo "//   Event:     $${GITHUB_EVENT_NAME}"; \
echo "//   Job:       $${GITHUB_JOB}:$${GITHUB_RUN_NUMBER}"; \
echo "//   Run ID:    $${GITHUB_RUN_ID}"; \
echo "//   Attempt:   $${GITHUB_RUN_ATTEMPT}"; \
echo ''; \
echo '';
endef


define lc
$(shell echo $(1) | tr '[:upper:]' '[:lower:]')
endef


# Sources
SRC_DIR=src
SRC_FILE_PREFIX=GrrBearr
SRC_FILES=$(wildcard $(SRC_DIR)/$(SRC_FILE_PREFIX)*.txt)
TRASH_LIST=$(BUILD_SRC_DIR)/$(SRC_FILE_PREFIX)Trash.txt

# Build files
BUILD_DIR=build
BUILD_SRC_DIR=$(BUILD_DIR)/src
BUILD_FILES ?=

$(BUILD_FILES): $(BUILD_SRC_DIR)

# My List
USER_LIST_TXT = $(BUILD_DIR)/$(call lc,$(SRC_FILE_PREFIX)).txt
$(USER_LIST_TXT): $(BUILD_DIR)

# Combined list
WISHLIST_TXT=$(BUILD_DIR)/wishlist.txt
$(WISHLIST_TXT): $(BUILD_DIR)

# External Sources
VOLTRON_TXT_URL = https://raw.githubusercontent.com/48klocs/dim-wish-list-sources/master/voltron.txt
VOLTRON_TXT = $(BUILD_SRC_DIR)/voltron.txt
$(VOLTRON_TXT): $(BUILD_SRC_DIR)


BUILD_FILES+=$(VOLTRON_TXT)
BUILD_FILES+=$(patsubst $(SRC_DIR)/$(SRC_FILE_PREFIX)%,$(BUILD_SRC_DIR)/$(SRC_FILE_PREFIX)%,$(SRC_FILES))


# DIRS
$(BUILD_SRC_DIR) $(BUILD_DIR): ; mkdir -p $@


# External Sources
$(VOLTRON_TXT): ; curl -Lo $@ $(VOLTRON_TXT_URL)


# Stage source files
$(BUILD_SRC_DIR)/$(SRC_FILE_PREFIX)%.txt: NOTE_PREFIX=($(SRC_FILE_PREFIX))
$(BUILD_SRC_DIR)/$(SRC_FILE_PREFIX)%.txt: $(SRC_DIR)/$(SRC_FILE_PREFIX)%.txt $(BUILD_SRC_DIR)
	( \
		cat "$<" | sed -e "s|//notes: tag|//notes: $(NOTE_PREFIX) tag|" \
	) > "$@"


# My list
$(USER_LIST_TXT): TITLE=$(SRC_FILE_PREFIX) - Wishlists
$(USER_LIST_TXT): DESC=A list of current season rolls, along with other odd rolls from previous seasons.
$(USER_LIST_TXT): $(filter $(BUILD_SRC_DIR)/$(SRC_FILE_PREFIX)%.txt,$(BUILD_FILES))
	$(info Target: $@ )
	$(info Sources: $^ )
	( $(call build_header,$(TITLE),$(DESC)) ) > $@
	( $(call build_info) ) >> $@
	( cat $(filter-out $(TRASH_LIST),$(sort $(filter %.txt,$^))) ) >> $@

	$(info Disabled trash list until they allow perks to be trashed)
	# ( cat $(sort $(filter $(TRASH_LIST),$^)) ) >> $@




# Combined Lists
$(WISHLIST_TXT): TITLE=$(SRC_FILE_PREFIX) - Wishlist Multi-list
$(WISHLIST_TXT): DESC=A combination list from voltron.txt, along with other desired rolls.
$(WISHLIST_TXT): $(filter %.txt,$(BUILD_FILES))
	$(info Target: $@ )
	$(info Sources: $^ )
	( $(call build_header,$(TITLE),$(DESC)) ) > $@
	( $(call build_info) ) >> $@
	( cat $(filter-out $(TRASH_LIST),$(sort $(filter %.txt,$^))) ) >> $@
	$(info Disabled trash list until they allow perks to be trashed)
	# ( cat $(sort $(filter $(TRASH_LIST),$^)) ) >> $@


# Combined target to force all to build 2 items
$(BUILD_DIR)/completed: $(WISHLIST_TXT) $(USER_LIST_TXT)


all: $(BUILD_DIR)/completed


clean:
	rm -f \
		$(BUILD_FILES) \
		$(WISHLIST_TXT) \
		$(USER_LIST_TXT) \
		$(BUILD_DIR)/completed
	rmdir \
		$(BUILD_SRC_DIR) \
		$(BUILD_DIR)

.PHONY: all clean clobber
