#!/bin/bash

set -eo pipefail

xcodebuild -project timetable.xcodeproj -scheme Presentation -destination 'platform=OS X' clean test