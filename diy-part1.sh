#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
git clone https://github.com/pymumu/openwrt-smartdns package/custom/smartdns
git clone https://github.com/pymumu/luci-app-smartdns -b lede package/custom/luci-app-smartdns
git clone https://github.com/Openwrt-Passwall/openwrt-passwall -b main package/custom/luci-app-passwall
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages -b main package/custom/openwrt-passwall
git clone https://github.com/tty228/luci-app-wechatpush -b openwrt-18.06 package/custom/luci-app-serverchan
git clone https://github.com/hubbylei/luci-theme-bootstrap-mod package/custom/luci-theme-bootstrap-mod
