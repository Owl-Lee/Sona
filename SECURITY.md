# Security Policy

[English](#english) · [简体中文](#简体中文)

## English

### Supported versions

Security fixes target the latest public release and the current `main` branch.
Older preview builds may require upgrading before a fix can be applied.

### Reporting a vulnerability

Do not open a public issue for an unpatched vulnerability, exposed credential,
authorization bypass, or data-loss path. Use GitHub's **Report a
vulnerability** form in the repository Security tab so the maintainer can
respond privately.

Please include the affected version, platform, reproduction steps, expected
and actual behavior, and the smallest safe proof of concept. Never attach real
music libraries, database exports, signing files, passwords, or access tokens.

### Security boundaries

- Sona is local-first, but optional account and cloud-sync features communicate
  with Supabase.
- Supabase publishable keys are client identifiers, not server secrets. Access
  control must be enforced by Row Level Security and guarded database functions.
- Supabase service-role keys, database passwords, Android signing material, and
  AcoustID application keys must be supplied outside source control.
- Exported `.sonabackup` files may contain media and local settings and are not
  encrypted; users must store them securely.

---

## 简体中文

### 支持范围

安全修复以最新公开版本和当前 `main` 分支为目标。较早的预览版本可能需要先
升级，才能获得修复。

### 报告安全问题

未修复漏洞、凭据暴露、权限绕过或数据丢失问题不要提交公开 Issue。请使用仓库
Security 页面中的 **Report a vulnerability** 私密报告入口。

报告应包含受影响版本、平台、复现步骤、预期/实际行为和最小安全复现。不要上传
真实曲库、数据库导出、签名文件、密码或访问令牌。

### 安全边界

- Sona 本地优先；可选账号与云同步功能会连接 Supabase。
- Supabase publishable key 是客户端标识，不是服务端密钥；权限必须由 RLS 和
  受保护的数据库函数执行。
- Supabase service-role key、数据库密码、Android 签名材料和 AcoustID 应用 key
  必须在源码仓库外提供。
- `.sonabackup` 可能包含媒体和本地设置，目前不加密，用户必须妥善保存。
