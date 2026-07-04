#!/bin/bash

git clone --depth=1 https://github.com/pymumu/openwrt-smartdns -b master package/custom/smartdns
git clone --depth=1 https://github.com/pymumu/luci-app-smartdns -b master package/custom/luci-app-smartdns
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall -b main package/custom/openwrt-passwall
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages -b main package/custom/passwall-packages
git clone --depth=1 https://github.com/tty228/luci-app-wechatpush -b master package/custom/luci-app-wechatpush
git clone --depth=1 https://github.com/brvphoenix/wrtbwmon -b master package/custom/bwmon
git clone --depth=1 https://github.com/hubbylei/luci-theme-bootstrap-mod package/custom/luci-theme-bootstrap-mod
git clone --depth=1 https://github.com/hubbylei/libxcrypt -b main package/custom/libxcrypt
git clone --depth=1 https://github.com/coolsnowwolf/lede -b master  package/custom/lede
git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go -b main package/custom/app-ddns-go
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang
cp -rf package/custom/openwrt-passwall/luci-app-passwall package/custom/
rm -rf package/custom/openwrt-passwall
cp -rf package/custom/passwall-packages/* package/custom/
rm -rf package/custom/passwall-packages
cp -rf package/custom/bwmon/wrtbwmon package/custom/
rm -rf package/custom/bwmon
cp -rf package/custom/lede/package/network/services/dnsmasq package/custom/
rm -rf package/custom/lede
rm -rf package/network/services/dnsmasq
cp -rf package/custom/app-ddns-go/luci-app-ddns-go package/custom/
cp -rf package/custom/app-ddns-go/ddns-go package/custom/
rm -rf package/custom/app-ddns-go

del_data=$(ls package/custom)
for data in ${del_data}
do
    isdel=$(find feeds -name "${data}")
    if [ -f ${isdel}/Makefile ];then
        rm -rf ${isdel}
        echo "Deleted ${isdel}"
    fi
done

sed -i "s/DISTRIB_REVISION='.*'/DISTRIB_REVISION='R"$(date "+%y.%m.%d")"'/g" package/lean/default-settings/files/zzz-default-settings
sed -i "s/DISTRIB_DESCRIPTION='.*'/DISTRIB_DESCRIPTION='LEDE '/g" package/lean/default-settings/files/zzz-default-settings
sed -i "/DISTRIB_DESCRIPTION=.*/a\sed -i '/OPENWRT_RELEASE/d' \/usr\/lib\/os-release\necho 'OPENWRT_RELEASE=\"LEDE R"$(date "+%y.%m.%d")"\"' >> \/usr\/lib\/os-release" package/lean/default-settings/files/zzz-default-settings
sed -i 's/By Lienol/(default)/g' package/custom/luci-theme-bootstrap-mod/Makefile
sed -i '/sed -r -i/a\\tsed -i "s,#Port 22,Port 22,g" $(1)\/etc\/ssh\/sshd_config\n\tsed -i "s,#ListenAddress 0.0.0.0,ListenAddress 0.0.0.0,g" $(1)\/etc\/ssh\/sshd_config\n\tsed -i "s,#PermitRootLogin prohibit-password,PermitRootLogin yes,g" $(1)\/etc\/ssh\/sshd_config' feeds/packages/net/openssh/Makefile
sed -i 's/;Listen = 0.0.0.0:1688/Listen = 0.0.0.0:1688/g' feeds/packages/net/vlmcsd/files/vlmcsd.ini

GEOIP_VER=$(echo -n `curl -sL -H "${AUTH}" https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest | jq -r .tag_name`)
GEOIP_HASH=$(echo -n `curl -sL -H "${AUTH}" https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$GEOIP_VER/geoip.dat.sha256sum | awk '{print $1}'`)
GEOSITE_VER=${GEOIP_VER}
GEOSITE_HASH=$(echo -n `curl -sL -H "${AUTH}" https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$GEOSITE_VER/geosite.dat.sha256sum | awk '{print $1}'`)
sed -i '/HASH:=/d' package/custom/v2ray-geodata/Makefile
sed -i 's/Loyalsoldier\/geoip/Loyalsoldier\/v2ray-rules-dat/g' package/custom/v2ray-geodata/Makefile
sed -i 's/GEOIP_VER:=.*/GEOIP_VER:='"$GEOIP_VER"'/g' package/custom/v2ray-geodata/Makefile
sed -i '/FILE:=$(GEOIP_FILE)/a\ HASH:='"$GEOIP_HASH"'' package/custom/v2ray-geodata/Makefile
sed -i 's/GEOSITE_VER:=.*/GEOSITE_VER:='"$GEOSITE_VER"'/g' package/custom/v2ray-geodata/Makefile
sed -i '/FILE:=$(GEOSITE_FILE)/a\ HASH:='"$GEOSITE_HASH"'' package/custom/v2ray-geodata/Makefile
sed -i 's/URL:=https:\/\/www.v2fly.org/URL:=https:\/\/github.com\/Loyalsoldier\/v2ray-rules-dat/g' package/custom/v2ray-geodata/Makefile

SMARTDNS_JSON=$(curl -sL -H "${AUTH}" https://api.github.com/repos/pymumu/smartdns/commits | jq .[0])
SMARTDNS_VER=$(echo -n `echo ${SMARTDNS_JSON} | jq .commit.committer.date | awk -F "T" '{print $1}' | sed 's/\"//g' | sed 's/\-/\./g'`)
SMARTDNS_SHA=$(echo -n `echo ${SMARTDNS_JSON} | jq .sha | sed 's/\"//g'`)
sed -i '/PKG_MIRROR_HASH:=/d' package/custom/smartdns/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"${SMARTDNS_VER}"'/g' package/custom/smartdns/Makefile
sed -i 's/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:='"${SMARTDNS_SHA}"'/g' package/custom/smartdns/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"${SMARTDNS_VER}"'/g' package/custom/luci-app-smartdns/Makefile

FRP_VER=$(curl -sL --retry 5 -H "${AUTH}" https://api.github.com/repos/fatedier/frp/releases/latest | jq -r .name | sed 's/v//g')
curl -sL -H "${AUTH}" --retry 5 -o /tmp/frp-${FRP_VER}.tar.gz https://codeload.github.com/fatedier/frp/tar.gz/v${FRP_VER}?
FRP_PKG_HASH=$(sha256sum /tmp/frp-${FRP_VER}.tar.gz | awk '{print $1}')
rm -rf /tmp/frp-${FRP_VER}.tar.gz
curl -skL -o feeds/packages/net/frp/Makefile https://github.com/openwrt/packages/raw/refs/heads/master/net/frp/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='${FRP_VER}'/g' feeds/packages/net/frp/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:='${FRP_PKG_HASH}'/g' feeds/packages/net/frp/Makefile