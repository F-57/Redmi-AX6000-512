#!/bin/bash

WRT_IP="10.0.0.1"

WRT_NAME="AX6000"

CFG_FILE="./package/base-files/files/bin/config_generate"

#修改immortalwrt.lan关联IP

sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")

#修改默认IP地址 修改默认主机名

sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE

sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

WIFI_FILE="./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"

WIFI_SSID="Ax6000"

WIFI_PASS="cw010203"

#修改WIFI名称 修改WIFI加密 修改WIFI密码

sed -i "s/ImmortalWrt/$WIFI_SSID/g" $WIFI_FILE

sed -i "s/encryption=.*/encryption='sae-mixed'/g" $WIFI_FILE

sed -i "/set wireless.default_\${dev}.encryption='sae-mixed'/a \\\t\t\t\t\t\set wireless.default_\${dev}.key='$WIFI_PASS'" $WIFI_FILE

#安装误删argon2
./scripts/feeds install node-argon2
