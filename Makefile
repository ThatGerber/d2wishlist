.DEFAULT_GOAL := all
SHELL := /bin/bash


unameOut := $(shell uname -s)


define build_header
echo "title:$(BUILD_TITLE)"; \
echo "description:$(BUILD_DESC)";
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
echo "//   Result:    $${GITHUB_SERVER_URL}/$${GITHUB_REPOSITORY}/actions/runs/$${GITHUB_RUN_ID}"; \
echo ''; \
echo '';
endef


# Adds tags to a list using a python script
add_tags_exe=exe/add_tags_to_list.sh


# Convert string to lowercase
define lc
$(shell echo $(1) | tr '[:upper:]' '[:lower:]')
endef


# Clean targets
CLEAN_FILES ?=
CLEAN_DIRS ?=


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

CLEAN_DIRS += $(BUILD_DIR)
CLEAN_DIRS += $(BUILD_SRC_DIR)
CLEAN_FILES += $(BUILD_FILES)


# Combined Build target
TARGET_FILE = $(BUILD_DIR)/completed
CLEAN_FILES += $(TARGET_FILE)


# My List
USER_LIST_TXT = $(BUILD_DIR)/$(call lc,$(SRC_FILE_PREFIX)).txt
$(USER_LIST_TXT): $(BUILD_DIR)
$(TARGET_FILE): $(USER_LIST_TXT)
CLEAN_FILES += $(USER_LIST_TXT)


# Combined list
WISHLIST_TXT=$(BUILD_DIR)/wishlist.txt
$(WISHLIST_TXT): $(BUILD_DIR)
$(TARGET_FILE): $(WISHLIST_TXT)
CLEAN_FILES += $(WISHLIST_TXT)


# External Sources
VOLTRON_TXT_URL = https://raw.githubusercontent.com/48klocs/dim-wish-list-sources/master/voltron.txt
VOLTRON_TXT = $(BUILD_SRC_DIR)/voltron.txt
$(VOLTRON_TXT): $(BUILD_SRC_DIR)
CLEAN_FILES += $(VOLTRON_TXT)

BUILD_FILES+=$(VOLTRON_TXT)
BUILD_FILES+=$(patsubst $(SRC_DIR)/$(SRC_FILE_PREFIX)%,$(BUILD_SRC_DIR)/$(SRC_FILE_PREFIX)%,$(SRC_FILES))


# DIRS
$(BUILD_SRC_DIR) $(BUILD_DIR): ; mkdir -p $@


# Combined target to force all to build 2 items
$(TARGET_FILE): ; touch $@;


# External Sources
$(VOLTRON_TXT): ; curl -Lo $@ $(VOLTRON_TXT_URL)


# Stage source files
$(BUILD_SRC_DIR)/$(SRC_FILE_PREFIX)%.txt: NOTE_PREFIX=($(SRC_FILE_PREFIX))
$(BUILD_SRC_DIR)/$(SRC_FILE_PREFIX)%.txt: $(SRC_DIR)/$(SRC_FILE_PREFIX)%.txt $(BUILD_SRC_DIR)
	$(info [$@] Source: $^)
	( \
		cat "$(filter %.txt,$<)" | \
			sed -e "s|//notes: tag|//notes: $(NOTE_PREFIX) tag|" \
	) > "$@"


# # # # # # # # # # # # # # #
# Creating my roll list
$(USER_LIST_TXT): BUILD_TITLE=$(SRC_FILE_PREFIX) - Wishlists
$(USER_LIST_TXT): BUILD_DESC=A list of current season rolls, along with other odd rolls from previous seasons.
$(USER_LIST_TXT): $(filter $(BUILD_SRC_DIR)/$(SRC_FILE_PREFIX)%.txt,$(BUILD_FILES))
	$(info [$@] Sources: $^)
	( \
		$(call build_header) \
		$(call build_info) \
		cat $(filter-out $(TRASH_LIST),$(sort $(filter %.txt,$^))); \
	) > $@
ifdef $(INCLUDE_TRASH_LIST)
	( cat $(sort $(filter $(TRASH_LIST),$^)) ) >> $@
else
	$(info [$@] [INFO] Disabled trash list until they allow perks to be trashed)
endif
	# $(add_tags_exe) "$@"


# # # # # # # # # # # # # # #
# Creating Combined roll list
$(WISHLIST_TXT): BUILD_TITLE=$(SRC_FILE_PREFIX) - Wishlist Multi-list
$(WISHLIST_TXT): BUILD_DESC=A combination list from voltron.txt, along with other desired rolls.
$(WISHLIST_TXT): $(filter %.txt,$(BUILD_FILES))
	$(info [$@] Sources: $^)
	( \
		$(call build_header) \
		$(call build_info) \
		cat $(filter-out $(TRASH_LIST),$(sort $(filter %.txt,$^))); \
	) > $@
ifdef $(INCLUDE_TRASH_LIST)
	( cat $(sort $(filter $(TRASH_LIST),$^)) ) >> $@
else
	$(info [$@] [INFO] Disabled trash list until they allow perks to be trashed)
endif


all: $(TARGET_FILE)


clean:
	rm -f $(CLEAN_FILES);
	rmdir $(shell for w in $(CLEAN_DIRS); do echo $$w; done | sort -r);


.PHONY: all clean
