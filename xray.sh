#!/bin/bash
# echo -e "Install [Yes/No](Default: Yes): \c"
# read install
# case install in
#     'No' | 'NO' | 'no' | 'N' | 'n')
#     echo "Exit"
#     exit 0
#     ;;
#     'Yes' | 'YES' | 'yes' | 'Y' | 'y')
#     echo "Install"
#     ;;
#     *)
#     echo "Install"
#     ;;
# esac

if [[ "$(uname)" == 'Linux' ]]; then
    case "$(uname -m)" in
      'i386' | 'i686')
        MACHINE='32'
        ;;
      'amd64' | 'x86_64')
        MACHINE='64'
        ;;
      'armv5tel')
        MACHINE='arm32-v5'
        ;;
      'armv6l')
        MACHINE='arm32-v6'
        grep Features /proc/cpuinfo | grep -qw 'vfp' || MACHINE='arm32-v5'
        ;;
      'armv7' | 'armv7l')
        MACHINE='arm32-v7a'
        grep Features /proc/cpuinfo | grep -qw 'vfp' || MACHINE='arm32-v5'
        ;;
      'armv8' | 'aarch64')
        MACHINE='arm64-v8a'
        ;;
      'mips')
        MACHINE='mips32'
        ;;
      'mipsle')
        MACHINE='mips32le'
        ;;
      'mips64')
        MACHINE='mips64'
        ;;
      'mips64le')
        MACHINE='mips64le'
        ;;
      'ppc64')
        MACHINE='ppc64'
        ;;
      'ppc64le')
        MACHINE='ppc64le'
        ;;
      'riscv64')
        MACHINE='riscv64'
        ;;
      's390x')
        MACHINE='s390x'
        ;;
      *)
        echo "error: The architecture is not supported."
        exit 1
        ;;
    esac
else
    echo "error: The OS is not supported."
    exit 1
fi
XRAY_FILE="Xray-linux-${MACHINE}.zip"
XRAY_URL="https://github.com/XTLS/Xray-core/releases/latest/download/${XRAY_FILE}" && rm -f /tmp/${XRAY_FILE}
XRAY_PATH="/usr/xray/"
mkdir -p ${XRAY_PATH}
down(){
wget -O /tmp/${XRAY_FILE} ${XRAY_URL}
unzip -o /tmp/${XRAY_FILE} "xray" "geoip.dat" "geosite.dat" -d ${XRAY_PATH}
if [[ -z ${PORT} ]];then
    PORT=8080
fi
cat <<EOF > ${XRAY_PATH}config.json
{
    "inbounds": [{
        "port": ${PORT},
        "protocol": "vmess",
        "settings": {
            "clients": [{
                "id": "8c35bef3-d51f-41ab-ac87-7b053410495b",
                "alterId": 64
            }]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
                "path": "/"
            }
        }
    }],
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF
echo "${XRAY_PATH}xray -c ${XRAY_PATH}config.json"
echo "echo \"nohup ${XRAY_PATH}xray -c ${XRAY_PATH}config.json >${XRAY_PATH}xray.log 2>&1 &\" >> /etc/profile"
}
if [[ ! -f ${XRAY_FILE} ]] || [[ ! -f ${XRAY_PATH}config.json ]];then
    down
fi
