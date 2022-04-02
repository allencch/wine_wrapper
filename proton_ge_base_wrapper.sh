#!/bin/bash

# Proton GE7

# Usage:
# Create another script
#
# export _BASE_PATH="$HOME/GE-Proton7-10"
# sh "./proton_ge_base_wrapper.sh" "$@"


_PROTON_GE="${_BASE_PATH}/proton"
_PROTON_GE_DIR="${_BASE_PATH}/files"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="/tmp"

_WINEDLLOVERRIDES=""
CALL_WINETRICKS=false
CALL_CONSOLE=false
CALL_SHUTDOWN=false
CALL_REBOOT=false
CALL_KILL=false
CALL_WINEBOOT=false
CALL_WINE=false
ARGS=()

if [ "$#" -le "1" ] ; then
    echo -e "Usage: proton_ge_wrapper.sh -p <wineprefix> -v <version> arguments ..."
    exit
fi

while [ "$1" != "" ]; do
    case $1 in
        -p | --prefix)
            shift
            _WINEPREFIX="$1"
            ;;
        --shutdown)
            CALL_SHUTDOWN=true
            ;;
        --reboot)
            CALL_REBOOT=true
            ;;
        --kill)
            CALL_KILL=true
            ;;
        --wineboot)
            CALL_WINEBOOT=true
            ;;
        --winetricks)
            CALL_WINETRICKS=true
            ;;
        --wine)
            CALL_WINE=true
            ;;
        --dll)
            shift
            _WINEDLLOVERRIDES+=";$1"
            ;;
        *)
            ARGS+=("$1")
    esac
    shift
done

if [ ! -d "$_WINEPREFIX" ]; then
    mkdir -p "$_WINEPREFIX"
fi
export STEAM_COMPAT_DATA_PATH="$_WINEPREFIX"
export _PROTON_DIR="$_PROTON_GE_DIR"
export _PROTON="$_PROTON_GE"

export WINEDLLOVERRIDES="$_WINEDLLOVERRIDES"

function setup_env() {
    export WINEPREFIX="$_WINEPREFIX/pfx"
    export PATH="$_PROTON_DIR/bin:$PATH"
    export LD_LIBRARY_PATH="$_PROTON_DIR/lib:$_PROTON_DIR/lib64:$LD_LIBRARY_PATH"
    export WINEDLLPATH="$_PROTON_DIR/lib/wine/fakedlls:$_PROTON_DIR/lib64/wine/fakedlls"
    export WINEDEBUG=fixme-all
}


if [ "$CALL_WINETRICKS" = true ]; then
    setup_env
    winetricks "${ARGS[@]}"
elif [ "$CALL_WINE" = true ]; then
    setup_env
    "$_PROTON_DIR/bin/wine" "${ARGS[@]}"
elif [ "$CALL_SHUTDOWN" = true ]; then
    "$_PROTON" run wineboot -s
elif [ "$CALL_REBOOT" = true ]; then
    "$_PROTON" run wineboot -r
elif [ "$CALL_KILL" = true ]; then
    "$_PROTON" run wineserver -k
elif [ "$CALL_WINEBOOT" = true ]; then
    "$_PROTON" run wineboot "${ARGS[@]}"
else
    "$_PROTON" run "${ARGS[@]}"
fi
