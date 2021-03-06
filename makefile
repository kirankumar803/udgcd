# makefile for building samples for udgcd
# author: S. Kramm, 2015
# see https://github.com/skramm/udgcd
# Linux only, probably.

COLOR_1=-e "\e[1;33m"
COLOR_2=-e "\e[1;34m"
COLOR_OFF="\e[0m"

# don't delete intermediate files
.SECONDARY:

# disable implicit rules
.SUFFIXES:

#--------------------------------
# general compiler flags
# -Wno-unused-result is to avoid the warning on call to std::system() when calling dot (see void CallDot() )
CFLAGS = -std=c++0x -Wall -O2 -Iinclude -Wno-unused-result

ifeq "$(PRINT_STEPS)" "Y"
	CFLAGS += -DUDGCD_PRINT_STEPS
endif

SHELL=/bin/bash

# files and folders
APP=udgcd.hpp
HEADERS=$(wildcard $(SRC_DIR)/*.h*)
BIN_DIR=bin
SRC_DIR=.
OBJ_DIR=obj

SRC_FILES = $(wildcard $(SRC_DIR)/*.cpp)
OBJ_FILES = $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(SRC_FILES))
EXEC_FILES = $(patsubst $(SRC_DIR)/%.cpp,$(BIN_DIR)/%,$(SRC_FILES))

# default target
all: $(EXEC_FILES)
	@echo "- Done target $@"

run: all
	$(addsuffix ;,$(EXEC_FILES))

run5: bin/sample_5
	@echo "running $<"
	$<

show: $(SRC_FILES)
	@echo SRC_FILES=$(SRC_FILES)
	@echo OBJ_FILES=$(OBJ_FILES)
	@echo EXEC_FILES=$(EXEC_FILES)

doc:
	doxygen doxyfile 1>$(OBJ_DIR)/doxygen_stdout.txt 2>$(OBJ_DIR)/doxygen_stderr.txt

clean:
	-rm $(OBJ_DIR)/*
	-rm *.layout

cleanall: clean cleandoc
	-rm $(EXEC_FILES)

cleandoc:
	-rm -r html/*
	-rmdir html

diff:
	git diff --color-words | aha > $(OBJ_DIR)/diff.html
	xdg-open $(OBJ_DIR)/diff.html

# needs 'sudo'
install:
	-cp $(APP) /usr/local/include/$(APP)

# generic compile rule
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp $(HEADERS) makefile
	@echo $(COLOR_2) " - Compiling app file $<." $(COLOR_OFF)
	$(L)$(CXX) -o $@ -c $< $(CFLAGS)

# linking
$(BIN_DIR)/%: $(OBJ_DIR)/%.o
	@echo $(COLOR_1) " - Link demo $@." $(COLOR_OFF)
	$(L)$(CXX) -o $@ -s $<  $(LDFLAGS)

