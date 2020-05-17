#!/bin/bash
set -e

PUBSPEC_YAML_PATH="${project_location}/pubspec.yaml"
PUBSPEC_LOCK_PATH="${project_location}/pubspec.lock"

if [[ ! -f ${PUBSPEC_YAML_PATH} ]]
then
	echo "No pubspec file found at path: ${PUBSPEC_YAML_PATH}"
	exit 1
fi

# example pubspec.yaml:
# ---
# environment:
#   sdk: ">=2.2.2 <3.0.0"
#   flutter: ^1.17.1

EXTRACTED_FLUTTER_PUBSPEC_YAML_VERSION=`perl -n -e '/flutter:\D*(\d+.\d+.\d+)/ && print $1' ${PUBSPEC_YAML_PATH}`
if [[ ! -z "$EXTRACTED_FLUTTER_PUBSPEC_YAML_VERSION" ]]; then
    echo "Found minimum Flutter version requirement in pubspec.yaml: ${EXTRACTED_FLUTTER_PUBSPEC_YAML_VERSION}"
    EXTRACTED_FLUTTER_PUBSPEC_VERSION=${EXTRACTED_FLUTTER_PUBSPEC_YAML_VERSION}
else
    echo "Warning: No version requirement found in ${PUBSPEC_YAML_PATH}!"
fi

# example pubspec.lock:
# ----
# sdks:
#   dart: ">=2.7.0 <3.0.0"
#   flutter: ">=1.17.1 <2.0.0"

if [[ -f ${PUBSPEC_LOCK_PATH} ]]; then
    EXTRACTED_FLUTTER_PUBSPEC_LOCK_VERSION=`perl -n -e '/flutter:\D*(\d+.\d+.\d+)/ && print $1' ${PUBSPEC_LOCK_PATH}`
    if [[ ! -z "$EXTRACTED_FLUTTER_PUBSPEC_LOCK_VERSION" ]]; then
        echo "Found minimum Flutter version requirement in pubspec.lock: ${EXTRACTED_FLUTTER_PUBSPEC_LOCK_VERSION}"
        EXTRACTED_FLUTTER_PUBSPEC_VERSION=${EXTRACTED_FLUTTER_PUBSPEC_LOCK_VERSION}
    else
        echo "Warning: No version requirement found in ${PUBSPEC_LOCK_PATH}!"
    fi
else
    echo "Warning: No pubspec.lock file found at ${PUBSPEC_LOCK_PATH}!"
fi

if [[ -z "$EXTRACTED_FLUTTER_PUBSPEC_VERSION" ]]; then
    echo "Error: No minimum Flutter version requirement was found!"
    exit 2
fi

envman add --key FLUTTER_PUBSPEC_YAML_VERSION --value ${EXTRACTED_FLUTTER_PUBSPEC_YAML_VERSION}
envman add --key FLUTTER_PUBSPEC_LOCK_VERSION --value ${EXTRACTED_FLUTTER_PUBSPEC_LOCK_VERSION}
envman add --key FLUTTER_PUBSPEC_VERSION --value ${EXTRACTED_FLUTTER_PUBSPEC_VERSION}
