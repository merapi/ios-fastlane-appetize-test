zip app ios/build/Build/Products/Debug-iphonesimulator/IosFastlaneAppetizeTest.app -r
curl https://tok_99770edwpdk12h8u78nemra6xc@api.appetize.io/v1/apps -F "file=@app.zip" -F "platform=ios"