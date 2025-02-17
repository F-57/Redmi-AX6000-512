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


# 修改ip
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate
# 修改名称
sed -i "s/hostname='.*'/hostname='CaoWrt'/g" package/base-files/files/bin/config_generate
# 修改 WiFi
# sed -i "s/ImmortalWrt-2.4G/Mr.C/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
# sed -i "s/ImmortalWrt-5G/Me/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

# ttyd自动登录
sed -i "s?/bin/login?/usr/libexec/login.sh?g" feeds/packages/utils/ttyd/files/ttyd.config

# Theme
git clone https://github.com/sirpdboy/luci-theme-kucat package/luci-theme-kucat -b js

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

## OpenClash
git clone --depth 1 https://github.com/vernesong/openclash.git OpenClash
rm -rf feeds/luci/applications/luci-app-openclash
mv OpenClash/luci-app-openclash feeds/luci/applications/luci-app-openclash

# 一键配置拨号
git clone https://github.com/caiweill/luci-app-netwizard package/luci-app-netwizard
# 进阶设置
git clone https://github.com/sirpdboy/luci-app-advancedplus package/luci-app-advancedplus
# 定时设置
git clone https://github.com/sirpdboy/luci-app-autotimeset package/luci-app-autotimeset

# 更改菜单
#sed -i 's/services/vpn/g' package/feeds/luci/luci-app-openclash/luasrc/controller/*.lua
#sed -i 's/services/vpn/g' package/feeds/luci/luci-app-openclash/luasrc/*.lua
#sed -i 's/services/vpn/g' package/feeds/luci/luci-app-openclash/luasrc/model/cbi/openclash/*.lua
#sed -i 's/services/vpn/g' package/feeds/luci/luci-app-openclash/luasrc/view/openclash/*.htm

# 更改菜单名字
#echo -e "\nmsgid \"VPN\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
#echo -e "msgstr \"魔法\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po

# 软件包与配置
# 上网时间控制 应用过滤 网络唤醒 定时设置 网络限速
# echo "CONFIG_PACKAGE_luci-app-accesscontrol=y" >> .config
# echo "CONFIG_PACKAGE_luci-app-appfilter=y" >> .config
echo "CONFIG_PACKAGE_luci-app-wol=y" >> .config
# echo "CONFIG_PACKAGE_luci-app-autotimeset=y" >> .config
echo "CONFIG_PACKAGE_luci-app-eqos-mtk=y" >> .config

# echo "CONFIG_PACKAGE_luci-app-alist=y" >> .config
#echo "CONFIG_PACKAGE_luci-app-netwizard=y" >> .config
echo "CONFIG_PACKAGE_luci-app-ttyd=y" >> .config
echo "CONFIG_PACKAGE_luci-app-ramfree=y" >> .config
echo "CONFIG_PACKAGE_luci-app-msd_lite=y" >> .config
echo "CONFIG_PACKAGE_luci-app-syncdial=y" >> .config
echo "CONFIG_PACKAGE_luci-app-ddns-go=y" >> .config
echo "CONFIG_PACKAGE_luci-app-socat=y" >> .config
echo "CONFIG_PACKAGE_luci-app-openclash=y" >> .config
echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> .config
echo "CONFIG_PACKAGE_luci-app-airconnect=y" >> .config
echo "CONFIG_PACKAGE_luci-app-advancedplus=y" >> .config
echo "CONFIG_PACKAGE_luci-theme-kucat=y" >> .config
