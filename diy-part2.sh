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

#修改默认IP地址 修改默认主机名
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")

#修改中文显示
#sed -i 's/auto/zh_cn/g' feeds/luci/modules/luci-base/root/etc/uci-defaults/luci-base

# WIFI 配置
WIFI_FILE="./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
WIFI_SSID="Ax6000"
WIFI_PASS="cw010203"
if [ -f "$WIFI_FILE" ]; then
    sed -i "s/ImmortalWrt/$WIFI_SSID/g" $WIFI_FILE
    sed -i "s/encryption=.*/encryption='sae-mixed'/g" $WIFI_FILE
    # 修正追加 Key 的逻辑，确保格式正确
    sed -i "/set wireless.default_\${dev}.encryption='sae-mixed'/a \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ set wireless.default_\${dev}.key='$WIFI_PASS'" $WIFI_FILE
fi

# ttyd自动登录
sed -i "s?/bin/login?/usr/libexec/login.sh?g" feeds/packages/utils/ttyd/files/ttyd.config

# 修改upnp服务地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" feeds/luci/applications/luci-app-upnp/htdocs/luci-static/resources/view/upnp/upnp.js

# 512布局 (Redmi AX6000 专用)
DTS_FILE="target/linux/mediatek/files-5.4/arch/arm64/boot/dts/mediatek/mt7986a-xiaomi-redmi-router-ax6000.dts"
[ -f "$DTS_FILE" ] && sed -i 's/reg = <0x600000 0x6e00000>/reg = <0x600000 0x1ea00000>/' $DTS_FILE

# --- 插件集成 ---
# 注意：GitHub Actions 环境下建议增加 --depth 1 提高拉取速度
git clone --depth 1 https://github.com/SAENE/luci-theme-design package/luci-theme-design
git clone --depth 1 https://github.com/sirpdboy/luci-theme-kucat package/luci-theme-kucat
git clone --depth 1 https://github.com/sirpdboy/luci-app-kucat-config package/luci-app-kucat-config
git clone --depth 1 https://github.com/sirpdboy/luci-app-advanced package/luci-app-advanced
git clone --depth 1 https://github.com/F-57/luci-app-adguardhome package/luci-app-adguardhome
git clone --depth 1 https://github.com/sbwml/luci-app-openlist2 package/openlist
git clone --depth 1 https://github.com/sbwml/luci-app-airconnect package/airconnect
git clone --depth 1 https://github.com/sirpdboy/luci-app-lucky package/lucky

# Golang 与 MosDNS (特殊处理)
rm -rf feeds/packages/lang/golang
git clone --depth 1 https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang
rm -rf feeds/packages/net/v2ray-geodata feeds/packages/net/mosdns
git clone --depth 1 https://github.com/sbwml/luci-app-mosdns -b openwrt-21.02 package/mosdns
git clone --depth 1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# OpenClash
git clone --depth 1 https://github.com/vernesong/openclash.git OpenClash
rm -rf feeds/luci/applications/luci-app-openclash
mv OpenClash/luci-app-openclash feeds/luci/applications/luci-app-openclash
rm -rf OpenClash

# 更改菜单名字
# 定义一个快捷函数：参数1是文件路径，参数2是原始文字，参数3是目标文字
change_name() {
    local file=$1
    local id=$2
    local str=$3
    if [ -f "$file" ]; then
        # 匹配 msgid 后的下一行 msgstr 并进行替换
        sed -i "/msgid \"$id\"/{n;s/msgstr \".*\"/msgstr \"$str\"/}" "$file"
        echo "已修改 $id 为 $str"
    else
        echo "跳过：未找到文件 $file"
    fi
}

# KuCat Config -> 主题设置
change_name "package/luci-app-kucat-config/po/zh_Hans/kucat-config.po" "KuCat Config" "主题设置"
# OpenClash -> 科学上网
change_name "feeds/luci/applications/luci-app-openclash/po/zh-cn/openclash.zh-cn.po" "OpenClash" "科学上网"
# MosDNS -> 转发分流
change_name "package/mosdns/luci-app-mosdns/po/zh_Hans/mosdns.po" "MosDNS" "转发分流"
# UPnP -> 即插即用
change_name "feeds/luci/applications/luci-app-upnp/po/zh_Hans/upnp.po" "UPnP" "即插即用"
# Lucky -> 大吉大利
change_name "package/lucky/luci-app-lucky/po/zh_Hans/lucky.po" "Lucky" "大吉大利"
# OpenList -> 聚合网盘
change_name "package/openlist/luci-app-openlist2/po/zh_Hans/openlist2.po" "OpenList" "聚合网盘"
# Docker -> 容器
change_name "package/feeds/luci/luci-app-dockerman/po/zh_Hans/dockerman.po" "Docker" "容器"

# 移动 eQOS 菜单位置
[ -f "package/mtk/applications/luci-app-eqos-mtk/root/usr/share/luci/menu.d/luci-app-eqos.json" ] && \
sed -i 's/services/network/g' package/mtk/applications/luci-app-eqos-mtk/root/usr/share/luci/menu.d/luci-app-eqos.json

# 预置编译选项 (写入 .config)
cat >> .config <<EOF
CONFIG_PACKAGE_luci-theme-design=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-autoreboot=y
CONFIG_PACKAGE_luci-app-mwan3=y
CONFIG_PACKAGE_luci-app-syncdial=y
CONFIG_PACKAGE_luci-app-advanced=y
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_luci-app-mosdns=y
CONFIG_PACKAGE_luci-app-adguardhome=y
CONFIG_PACKAGE_luci-app-lucky=y
CONFIG_PACKAGE_luci-app-airconnect=y
CONFIG_PACKAGE_luci-app-openlist2=y
EOF

# 修复 Coremark 编译失败
sed -i 's/\tmkdir/\tmkdir -p/g' feeds/packages/utils/coremark/Makefile
