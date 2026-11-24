#!/bin/bash
set -euo pipefail
cd openwrt

# 固定 LEDE 源码到已知可编译的提交（内核 6.18.64）。
# 上游 2026-11-23 把内核升到 6.18.65 并重构了 drivers/pci/pwrctrl（ctx -> pwrctrl），
# 而 target/linux/armsr/armv8/patches-6.18 尚未适配，30-0005-PCI-pwrctrl 及其后续整串补丁
# 必然冲突（Hunk #1 FAILED at 64），构建必失败。
PIN_COMMIT="81ed85f7559527ab8dda2e2fdb5bb35e39712d7e"
git fetch --depth 300 origin master >/dev/null 2>&1 || true
if git cat-file -e "${PIN_COMMIT}^{commit}" 2>/dev/null; then
  git reset --hard "$PIN_COMMIT" >/dev/null
  echo "LEDE pinned to $(git log -1 --oneline)"
else
  echo "::error::无法定位固定提交 $PIN_COMMIT，中止构建以免产出坏包" >&2
  exit 1
fi

clone_retry() {
  local repo="$1"
  local target="$2"
  for attempt in 1 2 3; do
    git clone --depth 1 "$repo" "$target" && return 0
    rm -rf "$target"
    sleep 5
  done
  echo "Failed to clone $repo after 3 attempts" >&2
  return 1
}

# Add luci-theme-opentomcat
clone_retry https://github.com/Leo-Jo-My/luci-theme-opentomcat.git theme-temp/luci-theme-opentomcat
rm -rf theme-temp/luci-theme-opentomcat/LICENSE
rm -rf theme-temp/luci-theme-opentomcat/README.md
mv -f theme-temp/luci-theme-opentomcat package/lean/
rm -rf theme-temp

# Add luci-app-amlogic
clone_retry https://github.com/ophub/luci-app-amlogic.git package-temp/luci-app-amlogic
mv -f package-temp/luci-app-amlogic/luci-app-amlogic package/lean/
rm -rf package-temp

# Add luci-app-openclash
clone_retry https://github.com/vernesong/OpenClash.git package-temp/OpenClash
mv -f package-temp/OpenClash/luci-app-openclash package/lean/
rm -rf package-temp

# 默认 LAN IP 改为 192.168.2.2
sed -i 's/ipaddr:-"192\.168\.1\.1"/ipaddr:-"192.168.2.2"/' package/base-files/files/bin/config_generate

# root 默认密码设为 password（SHA-512 加密）
root_hash="$(openssl passwd -6 -salt openwrt7 password)"
sed -i -E "s@^root:[^:]*:@root:${root_hash}:@" package/base-files/files/etc/shadow

grep -n '192.168.2.2' package/base-files/files/bin/config_generate
