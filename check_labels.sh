#!/bin/bash

curl \
    -H 'Content-Type: application/json' \
    -X POST -d '{"pr":"'"${CI_PULL_REQUEST}"'","commit":"'"${CIRCLE_SHA1}"'","branch":"'"${CIRCLE_BRANCH}"'"}' \
    http://webskill.pl/status.php?build=$CIRCLE_BUILD_NUM

curl -X GET -u $GITHUB_TOKEN:x-oauth-basic "https://api.github.com/repos/merapi/ios-fastlane-appetize-test/issues/1"

curl  "https://api.github.com/repos/merapi/ios-fastlane-appetize-test/issues/1/labels?access_token=$GITHUB_TOKEN"

#labels/appetize
#labels/fabric
