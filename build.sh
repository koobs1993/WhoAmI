#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting build process for WhoAmI...${NC}"

# Clean build directory
echo -e "${YELLOW}Cleaning build directory...${NC}"
rm -rf build/
rm -f build.log errors.log warnings.log

# Build for iOS
echo -e "${YELLOW}Building for iOS...${NC}"
xcodebuild \
    -scheme "WhoAmI" \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' \
    -configuration Debug \
    build 2>&1 | tee build.log

# Extract errors and warnings
echo -e "${YELLOW}Analyzing build output...${NC}"

# Find errors (including linker errors)
grep -i "error:" build.log > errors.log
grep -i "ld: error" build.log >> errors.log
grep -i "fatal error" build.log >> errors.log
grep -i "failed" build.log | grep -v "warning: failed" >> errors.log

# Find warnings
grep -i "warning:" build.log > warnings.log

# Count errors and warnings
error_count=$(wc -l < errors.log)
warning_count=$(wc -l < warnings.log)

# Display summary
echo -e "\n${YELLOW}Build Summary:${NC}"
if [ $error_count -gt 0 ]; then
    echo -e "${RED}Found ${error_count} errors:${NC}"
    cat errors.log
else
    echo -e "${GREEN}No errors found!${NC}"
fi

if [ $warning_count -gt 0 ]; then
    echo -e "\n${YELLOW}Found ${warning_count} warnings:${NC}"
    cat warnings.log
else
    echo -e "${GREEN}No warnings found!${NC}"
fi

# Set exit code
if [ $error_count -gt 0 ]; then
    exit 1
else
    exit 0
fi 