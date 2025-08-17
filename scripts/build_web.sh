#!/bin/bash

# This script builds the Flutter web project and then runs the post_build.sh script.

# Exit immediately if a command exits with a non-zero status.
set -e

# Print each command before executing it.
set -x

# The directory of this script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# The root directory of the project.
PROJECT_ROOT="$(dirname "$DIR")"

# Run the flutter build command.
flutter build web

# Run the post_build.sh script.
"$DIR/post_build.sh"
