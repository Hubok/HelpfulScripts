#!/bin/bash

### HOWTO
### sudo ./install_gcs.sh <version>
###
### This script attempts to download the EXACT release
### from GitHub directly, and will fail if the format changes.
###
### Created by Hubok, submit issues below:
### github-maint@hubok.net


if [[ $EUID > 0 ]]; then
    echo "Please rerun this script as root."
    exit 1
fi

if [[ ! $1 ]]; then
    echo "Usage: sudo ./install_gcs.sh <version>"
    exit 2
fi

if ! type wget &> /dev/null; then
    echo "Please install wget."
    exit 3
fi

if ! type tar &> /dev/null; then
    echo "Please install tar."
    exit 4
fi

if ! type ar &> /dev/null; then
    echo "Please install binutils."
    exit 5
fi

function cleanup_on_exit {
    cd $PWD_PREV
    rm -rf /tmp/$TMP_PATH
}

if [[ -d "/opt/gcs" ]]; then
    rm -rf /opt/gcs
fi

PWD_PREV=$PWD

TMP_PATH_EXISTS=0
while [[ $TMP_PATH_EXISTS -eq 0 ]]; do
    TMP_PATH="/tmp/install_gcs_"
    TMP_PATH+=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 32 | head -n 1)
    if [[ ! -d "$TMP_PATH" ]]; then
        mkdir -p $TMP_PATH
        TMP_PATH_EXISTS=1
    fi
done

cd $TMP_PATH

if ! wget -O gcs.deb "https://github.com/richardwilkes/gcs/releases/download/v$1/gcs_$1-1_amd64.deb"; then
    cleanup_on_exit
    echo "Version not found or issue downloading file."
    exit 6
fi

ar x gcs.deb
tar -xf data.tar.xz

cp -r opt /
echo -e "[Desktop Entry]\nName=GURPS Character Sheet\nExec=env _JAVA_OPTIONS= /opt/gcs/bin/GCS\nIcon=/opt/gcs/lib/GCS.png\nType=Application\nCategories=Game\nVersion=$1" > /usr/share/applications/gcs.desktop

cleanup_on_exit
exit
