# 斐讯 N1 / x86_64 OpenWrt 固件

本项目使用 GitHub Actions 编译 Lean 的 OpenWrt 源码，同时产出两个版本：

- **N1 版**：编 `armsr/armv8` 的 rootfs，再用 ophub 的打包动作封装成斐讯 N1（S905D）刷机镜像。
- **x86 版**：编 `x86/64 Generic` 的 EFI 组合镜像，可直接在 VMware / Hyper-V / 实体机上跑。

**[下载最新固件](https://github.com/muge1976/Cloud-N1-OpenWrt/releases/latest)** · [N1 构建记录](https://github.com/muge1976/Cloud-N1-OpenWrt/actions/workflows/cloud-n1-openwrt.yaml) · [x86 构建记录](https://github.com/muge1976/Cloud-N1-OpenWrt/actions/workflows/build-x86.yml)

## 编译方式

- **定时编译**　每周日北京时间 16:00 触发（上游无更新时自动跳过）。
- **推送编译**　向 `main` 推送对 `script.sh`、`config.sh`（或 `config-x86.sh`）、`.github/workflows/` 下文件或 `files/` 下文件的修改时触发。
- **手动编译**　在 Actions 页面分别进入 **Cloud N1 OpenWrt** / **Build x86 OpenWrt**，点击 **Run workflow**。手动触发不受"上游无更新"限制，一定会编。

## 构建记录保留规则

保留最近 3 个 Release 和最近 3 次成功构建记录。连续失败时，保留每次失败的日志供排查。下一次构建成功后，自动清理此前已结束的失败或取消记录。

## 固件配置

| 项目 | N1 版 | x86 版 |
| --- | --- | --- |
| 编译目标 | `armsr/armv8` → 打包成 `s905d` | `x86/64 Generic`（含 EFI 镜像） |
| 默认管理地址 | `http://192.168.2.3` | `http://192.168.2.3` |
| 默认账号密码 | `root` / `password` | `root` / `password` |
| root 分区 | 2048 MB | 2048 MB |
| 默认主题 | `luci-theme-argon` | `luci-theme-argon` |

> 为什么是 `192.168.2.3`：现实中 `192.168.2.2` 已被另一台设备占用，固件默认地址特意避开。

完整编译选项见 [config.sh](config.sh)（N1）与 [config-x86.sh](config-x86.sh)（x86）。

## 插件清单

两个版本使用同一套插件清单，取自现网在用固件（103 个 luci-app、共 1056 个包），经 Lean 源码树 + feeds 实跑 `make defconfig` 逐项核对后写入：

- **N1 版**：请求 739 项，实留 **737** 项
- **x86 版**：请求 756 项，实留 **754** 项

仅有两个包因 Lean 源码已全面转向 nftables / fw4 而不再提供，属签名替换（功能由 `firewall4`、`miniupnpd-nftables` 继承），不影响使用：

- `firewall`（旧 iptables 版本，已由 `firewall4` 取代）
- `miniupnpd-iptables`（已由 nft 版本取代）

覆盖的主要功能：Docker 与容器管理、OpenClash、PassWall / PassWall2、SSR-Plus、MosDNS、SmartDNS、Adblock、Lucky、OpenList、CloudDrive2、DDNS 全家桶、Samba4、NFS、qBittorrent、Transmission、frpc/frps、ZeroTier、Tailscale、KCP、Xray/Sing-box、Nginx、PHP8、Python3、Node、LXC、Netdata、ttyd、磁盘管理（diskman）、内网穿透（nps/npc）、游戏加速（UU/奇游）、打印服务等。

<details>
<summary>第三方安装源</summary>

- `fw876/helloworld`（ssr-plus 及其内核）
- `kenzok8/small-package`（lucky / openlist / clouddrive2 等）
- `kenzok8/openwrt-packages`（passwall 依赖、主题、部分 luci 应用）

</details>

<details>
<summary>界面说明</summary>

- 固件不再内置"固件定制 / 电报TG群"这类第三方作者的外链入口——那些是旧固件作者自己加的，Lean 源码本身没有。
- N1 版保留 `luci-app-amlogic`（Amlogic 服务），其中"在线下载更新"默认仓库已指向本仓库 `muge1976/Cloud-N1-OpenWrt`，可直接从 Release 拉取新固件。
- 默认主题为 `luci-theme-argon`，无需再手动切换。

</details>

## 界面预览

<details>
<summary>查看 OpenWrt 管理界面截图</summary>

![OpenWrt 管理界面](snapshot.png)

</details>

## 更新日志

- 20261126 双版本并存（N1 + x86_64）；插件清单按现网固件全量带入（N1 737 项 / x86 754 项）；默认 IP 改为 `192.168.2.3`；root 分区提升到 2048 MB；默认主题改为 `luci-theme-argon`，移除第三方 `opentomcat` 主题（该主题在新版 LuCI 下会报模板缺失导致白屏）；Amlogic 在线更新仓库指向本仓库；新增 `kenzok8/small-package`、`kenzok8/openwrt-packages` 安装源
- 20261123 默认 IP 改为 192.168.2.2、root 默认密码 password、分区提升到 1GB；集成 OpenClash / SmartDNS / Adblock / diskman / tailscale；Release 保留数改为 3
- 20260515 修改打包脚本，获取实际内核版本，输出到 release 说明
- 20250424 修正底层编译环境 `Ubuntu 20.04` 弃用造成的编译错误
- 20250303 修正 `actions/upload-artifact` 版本升级造成的编译错误
- 20240224 更新配置
- 20231129 更新内核版本 6.1.63，删除失效的插件
- 20231015 更新内核版本 6.1.57，集成 `PassWall`
- 20231013 更新截图
- 20231009 更新内核版本 6.1.56
- 20230915 修正 Github Action 空间不足导致的打包失败，更新内核版本 6.1.52
- 20230619 修正 Github Action 空间不足导致的打包失败，更新内核版本 6.1.34
- 20230525 更新配置
- 20230523 更新配置
- 20230211 修正 `set-output` 有效性造成的编译错误，更新内核版本 6.1.10
- 20230118 更新内核版本 6.1.6
- 20221031 更新内核版本 6.0.6
- 20220917 更新配置
- 20220814 更新内核版本 5.19.1
- 20220731 更新内核版本 5.18.15
- 20220620 更新内核版本 5.18.5
- 20220509 更新配置，更新内核版本 5.17.5
- 20220428 添加自动打包命令，生成刷机固件
- 20220427 更新配置，Release 默认保留3个
- 20220426 更新依赖安装命令，更新配置
- 20210827 更新配置，具体功能见截图
- 20210210 修正源码更新造成的编译错误，集成 `docker`。脚本文件调整
- 20201124 修正 `set-env` 有效性造成的编译错误
- 20200926 修正 `openclash` 编译错误
- 20200727 `docker` 兼容性造成编译错误，暂不集成

## 致谢

- OpenWrt 源码来自 [Lean 的 LEDE 项目](https://github.com/coolsnowwolf/lede)。
- 云编译脚本参考 [P3TERX 的 Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)。
- 固件打包使用 [ophub/flippy-openwrt-actions](https://github.com/ophub/flippy-openwrt-actions)。
