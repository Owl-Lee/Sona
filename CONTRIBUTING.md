# Contributing to Sona

[English](#english) · [简体中文](#简体中文)

## English

Thank you for helping improve Sona. The project welcomes focused bug fixes,
tests, documentation, accessibility improvements, and well-scoped features.

### Before opening a change

1. Search existing issues and pull requests.
2. Open an issue before large UI, database, cloud-schema, or playback changes.
3. Keep local media, account data, signing material, and credentials out of the
   repository.

### Local setup

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

Android development also requires a configured Android SDK. AcoustID and
Supabase client configuration can be supplied with `--dart-define` or
`--dart-define-from-file`; see `.env.example`. Never use a service-role key in
the client.

### Pull requests

- Keep each pull request focused and explain its user-visible effect.
- Add or update tests for behavior changes.
- Include before/after screenshots for visual changes, using demo data only.
- Preserve the English-first, Chinese-parallel documentation structure.
- Run `flutter analyze` and `flutter test` before requesting review.
- Use clear commit subjects such as `fix: ...`, `feat: ...`, or `docs: ...`.

By contributing, you agree that your contribution is licensed under the MIT
License used by this repository.

---

## 简体中文

感谢你帮助改进 Sona。项目欢迎范围清晰的缺陷修复、测试、文档、无障碍
改进和功能提交。

### 开始修改前

1. 先搜索已有 Issue 与 Pull Request。
2. 大型 UI、数据库、云端结构或播放链路修改请先创建 Issue 讨论。
3. 不得提交本地媒体、账号数据、签名材料或任何凭据。

### 本地环境

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

Android 开发还需要配置 Android SDK。AcoustID 与 Supabase 客户端配置可通过
`--dart-define` 或 `--dart-define-from-file` 传入，示例见 `.env.example`；客户端
绝不能使用 service-role key。

### Pull Request 要求

- 每个 Pull Request 聚焦一个主题，并说明对用户可见的影响。
- 行为变化应新增或更新测试。
- 视觉修改请附前后对比图，并且只使用演示数据。
- 文档保持英文优先、中文完整对照。
- 请求审查前运行 `flutter analyze` 与 `flutter test`。
- 提交标题使用清晰前缀，例如 `fix:`、`feat:` 或 `docs:`。

提交贡献即表示你同意按照本仓库的 MIT License 授权该贡献。
