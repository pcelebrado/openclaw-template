#!/bin/sh
set -eu

DATA_ROOT="${SFTPGO_DATA_ROOT:-/data/sftpgo}"
SRV_DIR="${DATA_ROOT}/srv"
LIB_DIR="${DATA_ROOT}/lib"

mkdir -p "${SRV_DIR}" "${LIB_DIR}"

if [ -d /srv/sftpgo ] && [ ! -L /srv/sftpgo ]; then
  if [ -z "$(ls -A "${SRV_DIR}" 2>/dev/null || true)" ]; then
    cp -a /srv/sftpgo/. "${SRV_DIR}/" 2>/dev/null || true
  fi
  rm -rf /srv/sftpgo
fi

if [ -d /var/lib/sftpgo ] && [ ! -L /var/lib/sftpgo ]; then
  if [ -z "$(ls -A "${LIB_DIR}" 2>/dev/null || true)" ]; then
    cp -a /var/lib/sftpgo/. "${LIB_DIR}/" 2>/dev/null || true
  fi
  rm -rf /var/lib/sftpgo
fi

ln -s "${SRV_DIR}" /srv/sftpgo
ln -s "${LIB_DIR}" /var/lib/sftpgo

exec sftpgo serve
