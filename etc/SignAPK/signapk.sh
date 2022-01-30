#!/usr/bin/env -S bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Generate your own keystore:
# keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-alias

# install dependencies
deps_ok=$(dpkg-query -W zipalign apksigner)
if [ ! $? = 0 ]
then
    sudo apt install -y apksigner zipalign
fi

set -e

rm -f ${SCRIPT_DIR}/../../app/build/outputs/apk/prod/release/xDrip-unsigned-aligned.apk

zipalign -v -p 4 ${SCRIPT_DIR}/../../app/build/outputs/apk/prod/release/app-prod-release-unsigned.apk \
    ${SCRIPT_DIR}/../../app/build/outputs/apk/prod/release/xDrip-unsigned-aligned.apk

apksigner sign --ks-pass "pass:xDrip+" --ks ${SCRIPT_DIR}/release-key.jks \
    --out xDrip-$(git describe --tags --always)-release.apk \
    ${SCRIPT_DIR}/../../app/build/outputs/apk/prod/release/xDrip-unsigned-aligned.apk
