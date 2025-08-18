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
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

del_data="
feeds/luci/applications/luci-app-serverchan
feeds/packages/net/dns2socks
feeds/packages/net/ipt2socks
feeds/packages/net/microsocks
feeds/packages/net/pdnsd-alt
feeds/packages/net/smartdns
feeds/packages/net/v2ray-geodata
target/linux/generic/pending-5.4/680-NET-skip-GRO-for-foreign-MAC-addresses.patch
"

for data in ${del_data};
do
    if [[ -d ${data} || -f ${data} ]];then
        rm -rf ~/${DEVICE}/${data}
        echo "Deleted ${data}"
    fi
done

sed -i 's/OpenWrt/LEDE/g' package/lean/default-settings/files/zzz-default-settings
sed -i '/--to-ports 53/d' package/lean/default-settings/files/zzz-default-settings
sed -i 's/By Lienol/(default)/g' package/custom/luci-theme-bootstrap-mod/Makefile
sed -i '/sed -r -i/a\\tsed -i "s,#Port 22,Port 22,g" $(1)\/etc\/ssh\/sshd_config\n\tsed -i "s,#ListenAddress 0.0.0.0,ListenAddress 0.0.0.0,g" $(1)\/etc\/ssh\/sshd_config\n\tsed -i "s,#PermitRootLogin prohibit-password,PermitRootLogin yes,g" $(1)\/etc\/ssh\/sshd_config' feeds/packages/net/openssh/Makefile
sed -i 's/luci-theme-bootstrap /luci-theme-bootstrap-mod /g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap /luci-theme-bootstrap-mod /g' feeds/luci/collections/luci-nginx/Makefile
sed -i 's/luci-theme-bootstrap /luci-theme-bootstrap-mod /g' feeds/luci/collections/luci-ssl-nginx/Makefile
sed -i 's/;Listen = 0.0.0.0:1688/Listen = 0.0.0.0:1688/g' feeds/packages/net/vlmcsd/files/vlmcsd.ini

GEOIP_VER=$(echo -n `curl -sL https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest | jq -r .tag_name`)
GEOIP_HASH=$(echo -n `curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$GEOIP_VER/geoip.dat.sha256sum | awk '{print $1}'`)
GEOSITE_VER=$GEOIP_VER
GEOSITE_HASH=$(echo -n `curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$GEOSITE_VER/geosite.dat.sha256sum | awk '{print $1}'`)
sed -i '/HASH:=/d' package/custom/openwrt-passwall/v2ray-geodata/Makefile
sed -i 's/Loyalsoldier\/geoip/Loyalsoldier\/v2ray-rules-dat/g' package/custom/openwrt-passwall/v2ray-geodata/Makefile
sed -i 's/GEOIP_VER:=.*/GEOIP_VER:='"$GEOIP_VER"'/g' package/custom/openwrt-passwall/v2ray-geodata/Makefile
sed -i '/FILE:=$(GEOIP_FILE)/a\ HASH:='"$GEOIP_HASH"'' package/custom/openwrt-passwall/v2ray-geodata/Makefile
sed -i 's/GEOSITE_VER:=.*/GEOSITE_VER:='"$GEOSITE_VER"'/g' package/custom/openwrt-passwall/v2ray-geodata/Makefile
sed -i '/FILE:=$(GEOSITE_FILE)/a\ HASH:='"$GEOSITE_HASH"'' package/custom/openwrt-passwall/v2ray-geodata/Makefile
sed -i 's/URL:=https:\/\/www.v2fly.org/URL:=https:\/\/github.com\/Loyalsoldier\/v2ray-rules-dat/g' package/custom/openwrt-passwall/v2ray-geodata/Makefile

SMARTDNS_VER=$(echo -n `curl -sL https://api.github.com/repos/pymumu/smartdns/commits | jq .[0].commit.committer.date | awk -F "T" '{print $1}' | sed 's/\"//g' | sed 's/\-/\./g'`)
SMARTDNS_SHA=$(echo -n `curl -sL https://api.github.com/repos/pymumu/smartdns/commits | jq .[0].sha | sed 's/\"//g'`)
sed -i '/PKG_MIRROR_HASH:=/d' package/custom/smartdns/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"${SMARTDNS_VER}"'/g' package/custom/smartdns/Makefile
sed -i 's/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:='"${SMARTDNS_SHA}"'/g' package/custom/smartdns/Makefile
sed -i 's/..\/..\/lang\/rust\/rust-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/rust\/rust-package.mk/g' package/custom/smartdns/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"${SMARTDNS_VER}"'/g' package/custom/luci-app-smartdns/Makefile
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' package/custom/luci-app-smartdns/Makefile
