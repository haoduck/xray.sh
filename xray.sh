#!/bin/bash
echo -e "Install [Yes/No](Default: Yes): \c"
read install
case install in
    'No' | 'NO' | 'no' | 'N' | 'n')
    echo "Exit"
    exit 0
    ;;
    'Yes' | 'YES' | 'yes' | 'Y' | 'y')
    echo "Install"
    ;;
    *)
    echo "Install"
    ;;
esac

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
XRAY_URL="https://github.com/XTLS/Xray-core/releases/latest/download/${XRAY_FILE}"
XRAY_PATH="/usr/xray/"
mkdir -p ${XRAY_PATH}
wget -O /tmp/${XRAY_FILE} ${XRAY_URL}
unzip -o /tmp/${XRAY_FILE} "xray" "geoip.dat" "geosite.dat" -d ${XRAY_PATH}
cat <<EOF > ${XRAY_PATH}config.json
{
  "inbounds": [{
    "port": 9000,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "1eb6e917-774b-4a84-aff6-b058577c60a5",
          "alterId": 0
        }
      ]
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }]
}
EOF
echo "${XRAY_PATH}xray -c ${XRAY_PATH}config.json"
echo "echo \"nohup ${XRAY_PATH}xray -c ${XRAY_PATH}config.json >${XRAY_PATH}xray.log 2>&1 &\" >> /etc/profile"
