#!/usr/bin/dash

HOSTURL="https://dbeaver.io/files"
VERSION="23.1.3"
ARCH="amd64"
TMP="/tmp"

wget $HOSTURL/$VERSION/dbeaver-ce_${VERSION}_${ARCH}.deb -O $TMP/dbeaver-ce_${VERSION}_${ARCH}.deb

if [ -f "${TMP}/dbeaver-ce_${VERSION}_${ARCH}.deb" ]; then
    dpkg -i ${TMP}/dbeaver-ce_${VERSION}_${ARCH}.deb && rm -f ${TMP}/dbeaver-ce_${VERSION}_${ARCH}.deb
else
    echo "File not found."
fi
