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
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 安装隔空播放luci-app-airconnect
git clone https://github.com/sbwml/luci-app-airconnect package/airconnect

# 安装vnt组网
git clone https://github.com/lmq8267/luci-app-vnt.git package/vnt

# 安装lucky
git clone https://github.com/sirpdboy/luci-app-lucky package/lucky

# 进阶设置
git clone https://github.com/sirpdboy/luci-app-advancedplus package/luci-app-advancedplus

# DNS助手
git clone https://github.com/kongfl888/openwrt-my-dnshelper package/openwrt-my-dnshelper

# 安装tailscale组网
sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile
git clone https://github.com/asvow/luci-app-tailscale package/luci-app-tailscale

# 安装 OpenClash
git clone --depth 1 https://github.com/vernesong/openclash.git OpenClash
rm -rf feeds/luci/applications/luci-app-openclash
mv OpenClash/luci-app-openclash feeds/luci/applications/luci-app-openclash

CORE_DIR="feeds/luci/applications/luci-app-openclash/root/etc/openclash/core"
CORE_FILE="$CORE_DIR/clash_meta"
TEMP_FILE="/tmp/clash-meta.gz"
UNZIPPED_FILE="/tmp/clash-meta"

mkdir -p "$CORE_DIR"

# 获取最新 Mihomo 版本
LATEST_VERSION=$(curl -sL https://api.github.com/repos/MetaCubeX/mihomo/releases/latest | grep '"tag_name"' | cut -d '"' -f 4)
DOWNLOAD_URL="https://github.com/MetaCubeX/mihomo/releases/download/$LATEST_VERSION/mihomo-linux-arm64-$LATEST_VERSION.gz"

# 下载 Mihomo 内核
echo "正在下载 Mihomo 内核：$LATEST_VERSION"
curl -sL --retry 3 --retry-delay 5 -m 30 "$DOWNLOAD_URL" -o "$TEMP_FILE"

if [ ! -s "$TEMP_FILE" ]; then
    echo "Mihomo 内核下载失败！"
    exit 1
fi

gunzip -f "$TEMP_FILE"

if [ ! -f "$UNZIPPED_FILE" ]; then
    echo "解压失败！"
    exit 1
fi

chmod +x "$UNZIPPED_FILE"
mv "$UNZIPPED_FILE" "$CORE_FILE"
chmod +x "$CORE_FILE"
echo "Mihomo 内核已成功下载并配置到 $CORE_FILE"

# 下载 OpenClash GeoIP 数据库
GEOIP_FILE="feeds/luci/applications/luci-app-openclash/root/etc/openclash/GeoIP.dat"
curl -sL --retry 3 --retry-delay 5 -m 30 "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat" -o "/tmp/GeoIP.dat"

if [ -s "/tmp/GeoIP.dat" ]; then
    mv -f "/tmp/GeoIP.dat" "$GEOIP_FILE"
    echo "GeoIP 数据库更新成功！"
else
    echo "GeoIP 数据库下载失败！"
fi

# 下载 OpenClash GeoSite 数据库
GEOSITE_FILE="feeds/luci/applications/luci-app-openclash/root/etc/openclash/GeoSite.dat"
curl -sL --retry 3 --retry-delay 5 -m 30 "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat" -o "/tmp/GeoSite.dat"

if [ -s "/tmp/GeoSite.dat" ]; then
    mv -f "/tmp/GeoSite.dat" "$GEOSITE_FILE"
    echo "GeoSite 数据库更新成功！"
else
    echo "GeoSite 数据库下载失败！"
fi

# 修复Coremark编译失败
sed -i 's/mkdir/mkdir -p/g' feeds/packages/utils/coremark/Makefile

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

echo -e "\nmsgid \"Tailscale\"" >> package/luci-app-tailscale/po/zh_Hans/tailscale.po
echo -e "msgstr \"虚拟组网\"" >> package/luci-app-tailscale/po/zh_Hans/tailscale.po

echo -e "\nmsgid \"WireGuard\"" >> feeds/luci/applications/luci-app-wireguard/po/zh_Hans/wireguard.po
echo -e "msgstr \"异地组网\"" >> feeds/luci/applications/luci-app-wireguard/po/zh_Hans/wireguard.po

echo -e "\nmsgid \"AList\"" >> package/feeds/luci/luci-app-alist/po/zh_Hans/alist.po
echo -e "msgstr \"聚合网盘\"" >> package/feeds/luci/luci-app-alist/po/zh_Hans/alist.po

# 更改菜单
sed -i 's/vpn/services/g' package/vnt/luci-app-vnt/luasrc/controller/*.lua
sed -i 's/vpn/services/g' package/vnt/luci-app-vnt/luasrc/view/vnt/*.htm

sed -i 's/services/network/g' package/mtk/applications/luci-app-eqos-mtk/root/usr/share/luci/menu.d/luci-app-eqos.json

# 修改argon主题字体和颜色
sed -i "/font-weight:/ { /important/! { /\/\*/! s/:.*/: var(--font-weight);/ } }" $(find package/feeds/luci/luci-theme-argon -type f -iname "*.css")
sed -i "s/primary '.*'/primary '#B0C4DE'/; s/'0.2'/'0.5'/; s/'none'/'bing'/; s/'600'/'normal'/" package/luci-app-advancedplus/root/etc/config/argon

# 软件包与配置
# echo "CONFIG_PACKAGE_luci-theme-design=y" >> .config
echo "CONFIG_PACKAGE_luci-app-ttyd=y" >> .config
echo "CONFIG_PACKAGE_luci-app-alist=y" >> .config
echo "CONFIG_PACKAGE_luci-app-openclash=y" >> .config
echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> .config
echo "CONFIG_PACKAGE_luci-app-lucky=y" >> .config
echo "CONFIG_PACKAGE_luci-app-airconnect=y" >> .config
echo "CONFIG_PACKAGE_luci-app-advancedplus=y" >> .config
echo "CONFIG_PACKAGE_luci-app-wireguard=y" >> .config
echo "CONFIG_PACKAGE_luci-app-my-dnshelper=y" >> .config
echo "CONFIG_PACKAGE_https-dns-proxy=y" >> .config
echo "CONFIG_PACKAGE_luci-app-dockerman=y" >> .config
