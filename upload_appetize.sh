#!/bin/bash
if ! BUILD_IOS; then
    echo "BUILD_IOS is 0";
    exit;
fi

zip -rq app ios/build/Build/Products/Debug-iphonesimulator/IosFastlaneAppetizeTest.app
curl https://$APPETIZE_TOKEN@api.appetize.io/v1/apps -F "file=@app.zip" -F "platform=ios"