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
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

# 安装前置 mosdns 5.3.1
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang
# 删除冲突
rm -rf feeds/packages/net/mosdns
rm -rf package/feeds/packages/mosdns
rm -rf feeds/packages/net/v2ray-geodata
rm -rf package/feeds/packages/v2ray-geodata
# 获取MosDNSluci-app-mosdns
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
# 获取隔空播放luci-app-airconnect
git clone https://github.com/sbwml/luci-app-airconnect package/airconnect
# 获取定时设置luci-app-autotimeset
#git clone https://github.com/sirpdboy/luci-app-autotimeset package/luci-app-autotimeset
# EQS网速控制
#git clone https://github.com/sirpdboy/luci-app-eqosplus package/luci-app-eqosplus
# 获取家长控制luci-app-parentcontrol
#git clone https://github.com/sirpdboy/luci-app-parentcontrol package/luci-app-parentcontrol
# 让局域网客户端访问不同子网的AP或光猫
#git clone https://github.com/Turing-China/luci-app-ap-modem package/luci-app-ap-modem
# ---------------------------------------------------------------
## OpenClash
# git clone -b v0.45.141-beta --depth=1 https://github.com/vernesong/openclash.git OpenClash
git clone --depth 1 https://github.com/vernesong/openclash.git OpenClash
rm -rf feeds/luci/applications/luci-app-openclash
mv OpenClash/luci-app-openclash feeds/luci/applications/luci-app-openclash
# ---------------------------------------------------------------

# ##------------- meta core ---------------------------------
#curl -sL -m 30 --retry 2 https://github.com/MetaCubeX/mihomo/releases/download/v1.18.8/mihomo-linux-arm64-v1.18.8.gz -o /tmp/clash_meta.tar.gz
#tar zxvf /tmp/clash_meta.tar.gz -C /tmp >/dev/null 2>&1
#chmod +x /tmp/clash >/dev/null 2>&1
#mv /tmp/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core >/dev/null 2>&1
# ##---------------------------------------------------------

# ##-------------- GeoIP 数据库 -----------------------------
#curl -sL -m 30 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o /tmp/GeoIP.dat
#mv /tmp/GeoIP.dat feeds/luci/applications/luci-app-openclash/root/etc/openclash/GeoIP.dat >/dev/null 2>&1
# ##---------------------------------------------------------

# ##-------------- GeoSite 数据库 ---------------------------
#curl -sL -m 30 --retry 2 https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o /tmp/GeoSite.dat
#mv -f /tmp/GeoSite.dat feeds/luci/applications/luci-app-openclash/root/etc/openclash/GeoSite.dat >/dev/null 2>&1
# ##---------------------------------------------------------
