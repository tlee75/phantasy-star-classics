#!/usr/bin/env bash

INPUT_APK_NAME=${1-phantasy-star-classics-6-4-0.apk}

if [ ! -f "${INPUT_APK_NAME}" ]; then
  echo "APK not found: ${INPUT_APK_NAME}"
  exit 1
fi

REQUIRED_CMDS=("apktool" "xmlstarlet" "openssl" "apksigner")
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: $cmd is not installed or not in PATH."
    exit 1
  fi
done

OUTPUT_APK_NAME=phantasy-star-classics-6-4-0-patched.apk
MANIFEST=./psc_source/AndroidManifest.xml

apktool d "$INPUT_APK_NAME" -o psc_source

xmlstarlet ed --inplace \
  -d "//uses-permission[@android:name='com.google.android.c2dm.permission.RECEIVE']" \
  -d "//uses-permission[@android:name='com.google.android.providers.gsf.permission.READ_GSERVICES']" \
  -d "//uses-permission[@android:name='com.google.android.gms.permission.AD_ID']" \
  -d "//meta-data[@android:name='com.google.android.gms.games.APP_ID']" \
  -d "//meta-data[@android:name='com.google.android.gms.version']" \
  -d "//activity[@android:name='com.google.games.bridge.NativeBridgeActivity']" \
  -d "//activity[@android:name='com.google.games.bridge.GenericResolutionActivity']" \
  "$MANIFEST"

apktool b --use-aapt2 psc_source -o "$OUTPUT_APK_NAME"

openssl genrsa -out temp_key.pem 2048

openssl pkcs8 -topk8 -inform PEM -outform DER -nocrypt -in temp_key.pem -out private_key.pk8

openssl req -new -x509 -key temp_key.pem -out public_cert.pem -outform DER -days 10000 -subj "/CN=CustomKey/O=CustomKey/C=US"

apksigner sign --v4-signing-enabled false --key private_key.pk8 --cert public_cert.pem "$OUTPUT_APK_NAME"

apksigner verify --verbose "$OUTPUT_APK_NAME"

rm private_key.pk8 public_cert.pem temp_key.pem
