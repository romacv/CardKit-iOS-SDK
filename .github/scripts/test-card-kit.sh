#!/bin/bash

set -eo pipefail

xcodebuild -workspace CardKit.xcworkspace \
            -scheme CardKit \
            -destination platform=iOS\ Simulator,OS=14.4,name=iPhone\ 12 \
            clean test | xcpretty