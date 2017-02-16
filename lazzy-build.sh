#!/bin/bash

red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
bwhite='\033[1;37m'
byellow='\033[1;33m'
bred='\033[1;31m'
NC='\033[0m'

PRINT=false
DEPLOY=false

for i in "$@"
do
case $i in
    -h|--help)
    echo "Usage: lazzy-build [-h|--help] [-wot|--without-tests] [-r|--release]
                   [[-d|--deploy] [--ip=IP] [--path=INSTALL_PATH]]
                   [--print] CONFIG [PROJECT]"
    exit 0
    ;;
    -wot|--without-tests)
    TESTS="-DQI_WITH_TESTS=OFF -DWITH_TESTS=OFF"
    shift # past argument=value
    ;;
    -r|--release)
    RELEASE="--release"
    shift # past argument=value
    ;;
    --print)
    PRINT=true
    shift # past argument=value
    ;;
    -d|--deploy)
    DEPLOY=true
    shift # past argument=value
    ;;
    --ip=*)
    LOCAL_NAO_IP="${i#*=}"
    shift # past argument=value
    ;;
    --path=*)
    INSTALL_PATH="${i#*=}"
    shift # past argument=value
    ;;
    *)
            # unknown option
    ;;
esac
done
if $PRINT; then
    echo -e "${bwhite}qibuild configure ${RELEASE} ${TESTS} -c $1 -j2 $2${NC}"
    echo -e "${bwhite}qibuild make -c $1 -j4 -J2 $2${NC}"
    if $DEPLOY; then
        echo -e "${bwhite}qibuild deploy -c $1 --url nao@$LOCAL_NAO_IP:$INSTALL_PATH $2${NC}"
    fi
    exit 0
fi
if [[ -n $1 ]]; then
    if $DEPLOY; then
        if [ -z "$LOCAL_NAO_IP" ]; then
            echo -e "\n${bred}Option --ip needed. Will not perform the deploy.${NC}"
            exit 2
        elif [[ -z "$INSTALL_PATH" ]]; then
            echo -e "\n${bred}Option --path needed. Will not perform the deploy.${NC}"
            exit 2
        fi
        qibuild configure $RELEASE $TESTS -c $1 -j2 $2
        qibuild make -c $1 -j4 -J2 $2
        qibuild deploy -c $1 --url nao@$LOCAL_NAO_IP:$INSTALL_PATH $2
    else
        qibuild configure $RELEASE $TESTS -c $1 -j2 $2
        qibuild make -c $1 -j4 -J2 $2
    fi
fi
