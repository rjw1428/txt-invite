#!/bin/bash

# This script runs after the flutter build step.
# It removes all files in functions/public and copies the output of the build/web directory to functions/public.

# Exit immediately if a command exits with a non-zero status.
set -e

# Print each command before executing it.
set -x

# The directory of this script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The root directory of the project.
PROJECT_ROOT="$(dirname "$DIR")"

# The directory to clear.
PUBLIC_DIR="$PROJECT_ROOT/functions/public"

# The directory to copy from.
BUILD_DIR="$PROJECT_ROOT/build/web"

# Clear the public directory.
rm -rf "$PUBLIC_DIR"/*

# Copy the build output to the public directory.
cp -r "$BUILD_DIR"/* "$PUBLIC_DIR"/
