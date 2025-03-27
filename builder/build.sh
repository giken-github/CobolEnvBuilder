#!/bin/sh
##########################################################################
# UNIX-COBOL 実習環�?構築スクリプト for devcontainer
# Copyright (C) 2022-2023 SystemGiken Co.Ltd,
#
# GnuCOBOL、各種プリプロセ�?サ、ソートツールをサーバにインスト�?�ルします�?
#
# 動作環�?:
#   Ubuntu 22.04
##########################################################################
set -eu

SCRIPT_DIR=$(cd $(dirname $0); pwd)
BUILD_DIR=$(mktemp -d)
BUILD_LOG_FILE=${SCRIPT_DIR}/build.log
#
GNUCOBOL_VER="3.2"
GNUCOBOL_SRC_PKG="gnucobol-${GNUCOBOL_VER}.tar.gz"
OCESQL_SRC_PKG="Open-COBOL-ESQL-1.3.tar.gz"
GCCT_SRC_PKG="gnucobol-contributions.tar.gz"
#
GNUCOBOL_SRC_URL="https://jaist.dl.sourceforge.net/project/gnucobol/gnucobol/${GNUCOBOL_VER}/${GNUCOBOL_SRC_PKG}"
#

cd "${SCRIPT_DIR}"
echo "Start Building : $(date)" >${BUILD_LOG_FILE}

echo "Generate ja_JP.SJIS locale ... "
{
    echo "ja_JP.SJIS SHIFT_JIS" >> /etc/locale.gen
    locale-gen
}

# パッケージをインスト�?�ルする�?
echo "Installing required packages ..."
{
    apt-get -y update && \
    apt-get -y install curl gcc g++ bison flex make autoconf \
                       libgmp-dev libdb-dev libpq-dev libxml2-dev \
                       libjson-c-dev unixodbc-dev odbc-postgresql
} >>"${BUILD_LOG_FILE}" 2>&1

cd "${BUILD_DIR}"

## GnuCobol をビルドしてインスト�?�ル
if [ ! -f "${SCRIPT_DIR}/${GNUCOBOL_SRC_PKG}" ]; then
    echo "Downloading GnuCOBOL Source package ..."
    curl -sSL -o "${BUILD_DIR}/${GNUCOBOL_SRC_PKG}" "${GNUCOBOL_SRC_URL}"
else
    echo "Use local GnuCOBOL source package."
    cp -f "${SCRIPT_DIR}/${GNUCOBOL_SRC_PKG}" "${BUILD_DIR}/${GNUCOBOL_SRC_PKG}"
fi
echo "Building and installing GnuCOBOL ..."
mkdir gnucobol
tar xf "${BUILD_DIR}/${GNUCOBOL_SRC_PKG}" --strip-components 1 -C gnucobol
(
    cd gnucobol
    ./configure
    make -j
    make install
    ldconfig

) >>"${BUILD_LOG_FILE}" 2>&1
echo "Done."


## Open COBOL ESQL をビルドしてインスト�?�ル
if [ ! -f "${SCRIPT_DIR}/${OCESQL_SRC_PKG}" ]; then
    echo "Downloading OpenCOBOL-ESQL source package ..."
    OCESQL_SRC_URL="https://github.com/opensourcecobol/Open-COBOL-ESQL/archive/refs/tags/v1.3.tar.gz"
    curl -sSL -o "${BUILD_DIR}/${OCESQL_SRC_PKG}" "${OCESQL_SRC_URL}"
else
    echo "Use local OpenCOBOL-ESQL source package ..."
    cp -f "${SCRIPT_DIR}/${OCESQL_SRC_PKG}" "${BUILD_DIR}/${OCESQL_SRC_PKG}"
fi


echo "Building and installing OpenCOBOL-ESQL pre-processor ..."
mkdir ocesql
tar xzf "${BUILD_DIR}/${OCESQL_SRC_PKG}" --strip-components 1 -C ocesql
(
    cd ocesql

    export CPPFLAGS="-I/usr/include/postgresql"

    ./configure
    make -j
    make install
    install -m 755 -d /usr/local/ocesql/copy
    install -m 644 -t /usr/local/ocesql/copy copy/sqlca.cbl
    ldconfig

) >>"${BUILD_LOG_FILE}" 2>&1
echo "Done."


if [ ! -f "${SCRIPT_DIR}/${GCCT_SRC_PKG}" ]; then
    echo "*** Please check to uploaded 'gnucobol-contributions.tar.gz'."
    echo "*** Note: gnucobol contribution tools are hosting on berrow URL."
    echo "***       https://sourceforge.net/p/gnucobol/contrib/HEAD/tree/"
    exit 1
fi

cp -f "${SCRIPT_DIR}/${GCCT_SRC_PKG}" "${BUILD_DIR}/${GCCT_SRC_PKG}"
mkdir gcct
tar xzf "${BUILD_DIR}/${GCCT_SRC_PKG}" --strip-components 1 -C gcct

echo "Building and installing esqlOC pre-processor ..."
(
    cd gcct/esql
    ./autogen.sh
    ./configure
    make -j
    make install
    ldconfig

) >>"${BUILD_LOG_FILE}" 2>&1
echo "Done."

echo "Building and installing GCSORT ..."
(
    cd gcct/tools/GCSORT
    make -j
    install -m 755 -t /usr/local/bin gcsort
) >>"${BUILD_LOG_FILE}" 2>&1
echo "Done."

echo "Cleaning up ..."
rm -rf "${BUILD_DIR}"

echo "End Building : $(date)" >> ${BUILD_LOG_FILE}

echo "Successsful built environment."