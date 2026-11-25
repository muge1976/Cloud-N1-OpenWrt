# x86_64 固件：已就绪、只差一步

## 已完成并已推送
- `config-x86.sh`（commit 43fa3da）：目标 x86/64 Generic，插件清单与 N1 版完全一致
  （openclash / adblock / smartdns / diskman / tailscale / htop / 三套主题），
  根分区 1024MB，出 BIOS 和 EFI 两个 combined 镜像。
- `.github/workflows/build-x86.yml`（本地已写好、YAML 校验通过）：负责编译 + 出 Release。

## 卡点
GitHub 拒绝写入 `.github/workflows/` 下的文件，API 与 git push 都一样：
`refusing to allow a Personal Access Token to create or update workflow ... without 'workflow' scope`
现有令牌 `ghp_HejC...` 只有 `repo` 权限。

## 解法（二选一）
1. 新生成一个 classic token，勾上 **repo + workflow**，贴给我 → 我直接推 + 触发编译（约 1 小时出包）。
2. 你在网页上手动建文件：仓库 → Add file → Create new file → 路径填
   `.github/workflows/build-x86.yml`，把我给的内容粘进去 → Commit changes（提交到 main 会自动触发）。
