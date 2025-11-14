#!/bin/bash

# This script runs unit tests for individual RTL modules
# Usage: ./tb/doitunittests.sh [sc|pp]  (run from RISC-V root directory)
#   sc  - Run single-cycle unit tests
#   pp  - Run pipelined unit tests
#   (no args) - Run both

# Constants (assumes called from RISC-V root)
PROJECT_ROOT="$(pwd)"
SC_TEST_FOLDER="${PROJECT_ROOT}/tb/tests/sc_unit_tests"
PP_TEST_FOLDER="${PROJECT_ROOT}/tb/tests/pp_unit_tests"
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

# Variables
passes=0
fails=0
current_branch=""
switched_branch=false

# Function to determine RTL folder
get_rtl_folder() {
    local test_type=$1

    if [ "$test_type" == "Single-Cycle" ]; then
        if [ -d "${PROJECT_ROOT}/rtl/single-cycle" ]; then
            echo "${PROJECT_ROOT}/rtl/single-cycle"
        elif git rev-parse --verify single_cycle &>/dev/null; then
            echo "BRANCH:single_cycle"
        else
            echo "${PROJECT_ROOT}/rtl"
        fi
    else
        if [ -d "${PROJECT_ROOT}/rtl/pipelined-plus-cache" ]; then
            echo "${PROJECT_ROOT}/rtl/pipelined-plus-cache"
        else
            echo "${PROJECT_ROOT}/rtl"
        fi
    fi
}

# Function to switch git branch if needed
switch_branch() {
    local rtl_folder=$1

    if [[ "$rtl_folder" == BRANCH:* ]]; then
        local target_branch="${rtl_folder#BRANCH:}"
        current_branch=$(git branch --show-current)

        echo "${YELLOW}Switching to branch '$target_branch'...${RESET}"

        if ! git checkout "$target_branch" &>/dev/null; then
            echo "${RED}ERROR: Failed to switch to branch '$target_branch'${RESET}"
            return 1
        fi

        switched_branch=true
        echo "${PROJECT_ROOT}/rtl"
        return 0
    fi

    echo "$rtl_folder"
    return 0
}

# Function to restore original branch
restore_branch() {
    if [ "$switched_branch" = true ] && [ -n "$current_branch" ]; then
        echo ""
        echo "${YELLOW}Restoring branch '$current_branch'...${RESET}"
        git checkout "$current_branch" &>/dev/null
    fi
}

# Function to run tests
run_tests() {
    local test_folder=$1
    local test_type=$2

    if [ ! -d "$test_folder" ]; then
        echo "${YELLOW}Warning: $test_folder does not exist. Skipping.${RESET}"
        return
    fi

    local test_files=(${test_folder}/*_tb.cpp)

    if [ ${#test_files[@]} -eq 0 ] || [ ! -e "${test_files[0]}" ]; then
        echo "${YELLOW}No test files found in $test_folder${RESET}"
        return
    fi

    local rtl_folder_raw=$(get_rtl_folder "$test_type")
    local rtl_folder=$(switch_branch "$rtl_folder_raw")

    if [ $? -ne 0 ]; then
        return
    fi

    echo "${BLUE}======================================${RESET}"
    echo "${BLUE}Running $test_type Unit Tests${RESET}"
    echo "${BLUE}RTL Location: $rtl_folder${RESET}"
    echo "${BLUE}======================================${RESET}"

    for test_file in "${test_files[@]}"; do
        local filename=$(basename "$test_file")
        local module_name="${filename%_tb.cpp}"

        echo ""
        echo "${BLUE}Testing module: ${module_name}${RESET}"

        local rtl_file="${rtl_folder}/${module_name}.sv"

        if [ ! -f "$rtl_file" ]; then
            echo "${RED}  ERROR: RTL file not found: $rtl_file${RESET}"
            ((fails++))
            continue
        fi

        rm -rf obj_dir

        verilator -Wall --trace \
                  -cc ${rtl_file} \
                  --exe ${test_file} \
                  -y ${rtl_folder} \
                  --prefix "Vdut" \
                  -o Vdut \
                  -LDFLAGS "-lgtest -lgtest_main -lpthread" \
                  2>&1 | grep -v "Wno-fatal"

        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            echo "${RED}  FAIL: Verilator compilation failed${RESET}"
            ((fails++))
            continue
        fi

        make -j -C obj_dir/ -f Vdut.mk > /dev/null 2>&1

        if [ $? -ne 0 ]; then
            echo "${RED}  FAIL: Make build failed${RESET}"
            ((fails++))
            continue
        fi

        ./obj_dir/Vdut

        if [ $? -eq 0 ]; then
            echo "${GREEN}  PASS: ${module_name}${RESET}"
            ((passes++))
        else
            echo "${RED}  FAIL: ${module_name}${RESET}"
            ((fails++))
        fi
    done
}

# Trap to restore branch on exit
trap restore_branch EXIT

# Main execution
if [ $# -eq 0 ]; then
    run_tests "$SC_TEST_FOLDER" "Single-Cycle"
    restore_branch
    switched_branch=false
    run_tests "$PP_TEST_FOLDER" "Pipelined"
elif [ "$1" == "sc" ]; then
    run_tests "$SC_TEST_FOLDER" "Single-Cycle"
elif [ "$1" == "pp" ]; then
    run_tests "$PP_TEST_FOLDER" "Pipelined"
else
    echo "${RED}Invalid argument: $1${RESET}"
    echo "Usage: ./tb/doitunittests.sh [sc|pp]"
    exit 1
fi

# Cleanup
rm -rf obj_dir

# Summary
echo ""
echo "${BLUE}======================================${RESET}"
echo "${BLUE}Test Summary${RESET}"
echo "${BLUE}======================================${RESET}"

total=$((passes + fails))

if [ $total -eq 0 ]; then
    echo "${YELLOW}No tests were run.${RESET}"
    exit 0
fi

echo "Total tests: $total"
echo "${GREEN}Passed: $passes${RESET}"
echo "${RED}Failed: $fails${RESET}"

if [ $fails -eq 0 ]; then
    echo ""
    echo "${GREEN}========================================${RESET}"
    echo "${GREEN}SUCCESS! All tests passed!${RESET}"
    echo "${GREEN}========================================${RESET}"
    exit 0
else
    echo ""
    echo "${RED}========================================${RESET}"
    echo "${RED}FAILURE! $fails test(s) failed.${RESET}"
    echo "${RED}========================================${RESET}"
    exit 1
fi

