#!/usr/bin/env bash

export CERTIFICATE_FILE='certificate.p12'
export WWDR_FILE='wwdr.pem'

export TEMP_PASS_CERT='passcertificate.pem'
export TEMP_PASS_KEY='passkey.pem'

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -m|--manifest)
    PATH_TO_MANIFEST="$2"
    shift # past argument
    ;;
    -d|--directory)
    CERTIFICATE_DIRECTORY="$2"
    shift # past argument
    ;;
    -t|--target)
    TARGET_FILE="$2"
    shift # past argument
    ;;
    *)
    echo -e "Unknown argument -- Usage: \n
    -t TARGET \n
    -d CRETIFICATE_DIRECTORY \n
    -m PATH_TO_MANIFEST \n"
    ;;
esac
shift # past argument or value
done

if [ -z "$PATH_TO_MANIFEST" ]; then
    echo "No manifest path provided"
    exit 1
fi

if [ -z "$TARGET_FILE" ]; then
    echo "No target file provided"
    exit 1
fi

if [ -z "$CERTIFICATE_DIRECTORY" ]; then
    echo "No certificate directory provided"
    exit 1
fi

openssl pkcs12 -in "$CERTIFICATE_DIRECTORY/$CERTIFICATE_FILE" -clcerts -nokeys -out "$CERTIFICATE_DIRECTORY/$TEMP_PASS_CERT" -passin pass:
openssl pkcs12 -in "$CERTIFICATE_DIRECTORY/$CERTIFICATE_FILE" -nocerts -out "$CERTIFICATE_DIRECTORY/$TEMP_PASS_KEY" -passin pass: -passout pass:12345
openssl smime -binary -sign -certfile "$CERTIFICATE_DIRECTORY/$WWDR_FILE" -signer "$CERTIFICATE_DIRECTORY/$TEMP_PASS_CERT" -inkey "$CERTIFICATE_DIRECTORY/$TEMP_PASS_KEY" -in $PATH_TO_MANIFEST -out $TARGET_FILE -outform DER -passin pass:12345

echo 'Generated signature'
