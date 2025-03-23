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

#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/10.0.0.1/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/10.0.0.1/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='AX6000'/g" $CFG_FILE

WIFI_FILE="./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
#修改WIFI名称
sed -i "s/ImmortalWrt/AX6000/g" $WIFI_FILE
修改WIFI加密
sed -i "s/encryption=.*/encryption='psk-mixed'/g" $WIFI_FILE
#修改WIFI密码
sed -i "/set wireless.default_\${dev}.encryption='psk-mixed'/a \\\t\t\t\t\t\set wireless.default_\${dev}.key='cw010203'" $WIFI_FILE

# ttyd自动登录
sed -i "s?/bin/login?/usr/libexec/login.sh?g" feeds/packages/utils/ttyd/files/ttyd.config

# Theme
git clone https://github.com/SAENE/luci-theme-design package/luci-theme-design

# 安装 mosdns
rm -rf feeds/packages/lang/golang
rm -rf feeds/packages/net/mosdns
rm -rf package/feeds/packages/mosdns
rm -rf feeds/packages/net/v2ray-geodata
rm -rf package/feeds/packages/v2ray-geodata
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 安装隔空播放luci-app-airconnect
git clone https://github.com/sbwml/luci-app-airconnect package/airconnect

# 安装 OpenClash
git clone --depth 1 https://github.com/vernesong/openclash.git OpenClash
rm -rf feeds/luci/applications/luci-app-openclash
mv OpenClash/luci-app-openclash feeds/luci/applications/luci-app-openclash

# 安装vnt组网
git clone https://github.com/lmq8267/luci-app-vnt.git package/vnt

# 安装lucky
git clone https://github.com/sirpdboy/luci-app-lucky package/lucky

# 进阶设置
git clone https://github.com/sirpdboy/luci-app-advancedplus package/luci-app-advancedplus

# 更改菜单名字
echo -e "\nmsgid \"OpenClash\"" >> feeds/luci/applications/luci-app-openclash/po/zh-cn/openclash.zh-cn.po
echo -e "msgstr \"科学上网\"" >> feeds/luci/applications/luci-app-openclash/po/zh-cn/openclash.zh-cn.po

echo -e "\nmsgid \"MosDNS\"" >> package/mosdns/luci-app-mosdns/po/zh_Hans/mosdns.po
echo -e "msgstr \"转发分流\"" >> package/mosdns/luci-app-mosdns/po/zh_Hans/mosdns.po

echo -e "\nmsgid \"UPnP\"" >> feeds/luci/applications/luci-app-upnp/po/zh_Hans/upnp.po
echo -e "msgstr \"即插即用\"" >> feeds/luci/applications/luci-app-upnp/po/zh_Hans/upnp.po

#echo -e "\nmsgid \"Internet Access Schedule Control\"" >> feeds/luci/applications/luci-app-accesscontrol/po/zh_Hans/mia.po
#echo -e "msgstr \"上网时间\"" >> feeds/luci/applications/luci-app-accesscontrol/po/zh_Hans/mia.po

echo -e "\nmsgid \"Lucky\"" >> package/lucky/luci-app-lucky/po/zh_Hans/lucky.po
echo -e "msgstr \"大吉大利\"" >> package/lucky/luci-app-lucky/po/zh_Hans/lucky.po

#echo -e "\nmsgid \"Tailscale\"" >> package/luci-app-tailscale/po/zh_Hans/tailscale.po
#echo -e "msgstr \"路由隧道\"" >> package/luci-app-tailscale/po/zh_Hans/tailscale.po

echo -e "\nmsgid \"WireGuard\"" >> feeds/luci/applications/luci-app-wireguard/po/zh_Hans/wireguard.po
echo -e "msgstr \"异地组网\"" >> feeds/luci/applications/luci-app-wireguard/po/zh_Hans/wireguard.po

echo -e "\nmsgid \"AList\"" >> package/feeds/luci/luci-app-alist/po/zh_Hans/alist.po
echo -e "msgstr \"聚合网盘\"" >> package/feeds/luci/luci-app-alist/po/zh_Hans/alist.po

# 更改菜单
sed -i 's/vpn/services/g' package/vnt/luci-app-vnt/luasrc/controller/*.lua
sed -i 's/vpn/services/g' package/vnt/luci-app-vnt/luasrc/view/vnt/*.htm

sed -i 's/services/network/g' package/mtk/applications/luci-app-eqos-mtk/root/usr/share/luci/menu.d/luci-app-eqos.json

# 软件包与配置
echo "CONFIG_PACKAGE_luci-theme-design=y" >> .config
echo "CONFIG_PACKAGE_luci-app-ttyd=y" >> .config
echo "CONFIG_PACKAGE_luci-app-alist=y" >> .config
echo "CONFIG_PACKAGE_luci-app-openclash=y" >> .config
echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> .config
echo "CONFIG_PACKAGE_luci-app-lucky=y" >> .config
echo "CONFIG_PACKAGE_luci-app-airconnect=y" >> .config
echo "CONFIG_PACKAGE_luci-app-advancedplus=y" >> .config
echo "CONFIG_PACKAGE_luci-app-wireguard=y" >> .config
