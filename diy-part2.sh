#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)

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

# ttyd自动登录
sed -i "s?/bin/login?/usr/libexec/login.sh?g" feeds/packages/utils/ttyd/files/ttyd.config

# 修改upnp服务地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" feeds/luci/applications/luci-app-upnp/htdocs/luci-static/resources/view/upnp/upnp.js

# 512布局
sed -i 's/reg = <0x600000 0x6e00000>/reg = <0x600000 0x1ea00000>/' target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek/mt7986a-xiaomi-redmi-router-ax6000.dts

# Theme
git clone https://github.com/SAENE/luci-theme-design package/luci-theme-design

# 安装 mosdns
rm -rf feeds/packages/lang/golang
rm -rf feeds/packages/net/mosdns
rm -rf package/feeds/packages/mosdns
rm -rf feeds/packages/net/v2ray-geodata
rm -rf package/feeds/packages/v2ray-geodata
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 安装 luci-app-openlist2 
git clone https://github.com/sbwml/luci-app-openlist2 package/openlist

# 安装隔空播放luci-app-airconnect
git clone https://github.com/sbwml/luci-app-airconnect package/airconnect

# 安装lucky
git clone https://github.com/sirpdboy/luci-app-lucky package/lucky

# adguardhome
git clone https://github.com/F-57/luci-app-adguardhome1 package/luci-app-adguardhome

# 安装 OpenClash
git clone --depth 1 https://github.com/vernesong/openclash.git OpenClash
rm -rf feeds/luci/applications/luci-app-openclash
mv OpenClash/luci-app-openclash feeds/luci/applications/luci-app-openclash

# 安装 luci-app-cloudflared
git clone https://github.com/F-57/luci-app-cloudflared package/luci-app-cloudflared

# 修复Coremark编译失败
sed -i 's/mkdir/mkdir -p/g' feeds/packages/utils/coremark/Makefile

# 更改菜单名字
#echo -e "\nmsgid \"OpenClash\"" >> feeds/luci/applications/luci-app-openclash/po/zh-cn/openclash.zh-cn.po
#echo -e "msgstr \"科学上网\"" >> feeds/luci/applications/luci-app-openclash/po/zh-cn/openclash.zh-cn.po

#echo -e "\nmsgid \"MosDNS\"" >> package/mosdns/luci-app-mosdns/po/zh_Hans/mosdns.po
#echo -e "msgstr \"转发分流\"" >> package/mosdns/luci-app-mosdns/po/zh_Hans/mosdns.po

#echo -e "\nmsgid \"UPnP\"" >> feeds/luci/applications/luci-app-upnp/po/zh_Hans/upnp.po
#echo -e "msgstr \"即插即用\"" >> feeds/luci/applications/luci-app-upnp/po/zh_Hans/upnp.po

#echo -e "\nmsgid \"Lucky\"" >> package/lucky/luci-app-lucky/po/zh_Hans/lucky.po
#echo -e "msgstr \"大吉大利\"" >> package/lucky/luci-app-lucky/po/zh_Hans/lucky.po

#echo -e "\nmsgid \"OpenList\"" >> package/openlist/luci-app-openlist2/po/zh_Hans/openlist2.po
#echo -e "msgstr \"聚合网盘\"" >> package/openlist/luci-app-openlist2/po/zh_Hans/openlist2.po

#echo -e "\nmsgid \"WireGuard\"" >> feeds/luci/applications/luci-app-wireguard/po/zh_Hans/wireguard.po
#echo -e "msgstr \"异地组网\"" >> feeds/luci/applications/luci-app-wireguard/po/zh_Hans/wireguard.po

#echo -e "\nmsgid \"Docker\"" >> package/feeds/luci/luci-app-dockerman/po/zh_Hans/dockerman.po
#echo -e "msgstr \"容器\"" >> package/feeds/luci/luci-app-dockerman/po/zh_Hans/dockerman.po

#echo -e "\nmsgid \"SmartDNS\"" >> feeds/luci/applications/luci-app-smartdns/po/zh_Hans/smartdns.po
#echo -e "msgstr \"优选DNS\"" >> feeds/luci/applications/luci-app-smartdns/po/zh_Hans/smartdns.po

# 更改菜单
sed -i 's/services/network/g' package/mtk/applications/luci-app-eqos-mtk/root/usr/share/luci/menu.d/luci-app-eqos.json

# 软件包与配置
echo "CONFIG_CCACHE=y" >> .config
echo "CONFIG_PACKAGE_luci-theme-design=y" >> .config
echo "CONFIG_PACKAGE_luci-app-ttyd=y" >> .config
#echo "CONFIG_PACKAGE_luci-app-openlist2=y" >> .config
echo "CONFIG_PACKAGE_luci-app-openclash=y" >> .config
echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> .config
echo "CONFIG_PACKAGE_luci-app-adguardhome=y" >> .config
#echo "CONFIG_PACKAGE_luci-app-lucky=y" >> .config
#echo "CONFIG_PACKAGE_luci-app-airconnect=y" >> .config
echo "CONFIG_PACKAGE_luci-app-cloudflared=y" >> .config
echo "CONFIG_PACKAGE_luci-app-autoreboot=y" >> .config
