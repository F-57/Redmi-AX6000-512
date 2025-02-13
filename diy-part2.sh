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

# echo "CONFIG_PACKAGE_luci-i18n-autotimeset-zh-cn=y" >> .config

# Modify default IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/ImHome/g' package/base-files/files/bin/config_generate

## luci-app-adguardhome
git clone https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

## 安装前置 mosdns
rm -rf feeds/packages/lang/golang
rm -rf feeds/packages/net/mosdns
rm -rf package/feeds/packages/mosdns
rm -rf feeds/packages/net/v2ray-geodata
rm -rf package/feeds/packages/v2ray-geodata
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

## 获取隔空播放luci-app-airconnect
git clone https://github.com/sbwml/luci-app-airconnect package/airconnect

## 获取隔空播放ddns-go
git clone https://github.com/sirpdboy/luci-app-ddns-go.git package/ddns-go

git clone https://github.com/mingxiaoyu/luci-app-cloudflarespeedtest.git package/cloudflarespeedtest

## OpenClash
git clone --depth 1 https://github.com/vernesong/openclash.git OpenClash
rm -rf feeds/luci/applications/luci-app-openclash
mv OpenClash/luci-app-openclash feeds/luci/applications/luci-app-openclash

## meta core
#curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz
#tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
#chmod +x /tmp/clash >/dev/null 2>&1
#mv /tmp/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash_meta >/dev/null 2>&1

## GeoIP 数据库
#curl -sL -m 30 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o /tmp/GeoIP.dat
#mv /tmp/GeoIP.dat feeds/luci/applications/luci-app-openclash/root/etc/openclash/GeoIP.dat >/dev/null 2>&1

## GeoSite 数据库
#curl -sL -m 30 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o /tmp/GeoSite.dat
#mv -f /tmp/GeoSite.dat feeds/luci/applications/luci-app-openclash/root/etc/openclash/GeoSite.dat >/dev/null 2>&1

# 更改默认主题背景
#cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# ttyd自动登录
sed -i "s?/bin/login?/usr/libexec/login.sh?g" feeds/packages/utils/ttyd/files/ttyd.config

# 调整菜单
#sed -i 's/services/control/g' feeds/luci/applications/luci-app-eqos/root/usr/share/luci/menu.d/*.json
#sed -i 's/services/control/g' feeds/luci/applications/luci-app-nft-qos/luasrc/controller/*.lua
#sed -i 's/services/nas/g' feeds/luci/applications/luci-app-ksmbd/root/usr/share/luci/menu.d/*.json
#sed -i 's/services/vpn/g' package/luci-app-openclash/luasrc/controller/*.lua
#sed -i 's/services/vpn/g' package/luci-app-openclash/luasrc/model/cbi/openclash/*.lua
#sed -i 's/services/vpn/g' package/luci-app-openclash/luasrc/view/openclash/*.htm
#sed -i 's|admin/network|admin/control|g' package/luci-app-sqm/root/usr/share/luci/menu.d/*.json

# 修改插件名字
#replace_text() {
#  search_text="$1" new_text="$2"
#  sed -i "s/$search_text/$new_text/g" $(grep "$search_text" -rl ./ 2>/dev/null) || echo -e "\e[31mNot found [$search_text]\e[0m"
#}
#。 msgstr "MosDNS"

#replace_text "Argon 主题设置" "主题设置"
#replace_text "DDNS-Go" "DDNSGO"
#replace_text "DDNSTO 远程控制" "DDNSTO"
#replace_text "KMS 服务器" "KMS激活"
#replace_text "QoS Nftables 版" "QoS管理"
#replace_text "SQM 队列管理" "SQM管理"
#replace_text "动态 DNS" "动态DNS"
#replace_text "网络存储" "NAS"
#replace_text "解除网易云音乐播放限制" "音乐解锁"

#echo -e "\e[32m$0 [DONE]\e[0m"
