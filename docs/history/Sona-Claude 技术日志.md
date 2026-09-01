# Sona Claude 0.1 技术日志

> 历史项目路径：`<repo-root>`
> 原则:所有改动只在 `Sona-Claude-0.1` 这个副本上进行,不影响原版 `Sona-src-0.3.2` 及已打包的 Sona 0.3.x 产物。

---

## 2026-08-15

### 1. 建立"下一代"副本 + 改名
- 校验了 `Sona-0.3.2-源代码.zip` 解压完整性(126 个 zip 条目中 104 个是真实文件、22 个是目录条目,解压后文件数与之完全对应,确认源码无误)。
- 复制 `Sona-src-0.3.2` → `Sona-Claude-0.1`,作为独立开发副本。
- 改名相关改动:
  - `pubspec.yaml`:`version: 0.3.2+5` → `0.1.0+1`;description 加上 "Sona Claude"。
  - `lib/app.dart`:MaterialApp `title` 改为 `'Sona Claude'`。
  - `lib/features/shell/presentation/main_shell.dart`:侧边栏 Logo 文案 `'Sona'` → `'Sona Claude'`。
  - `lib/features/library/presentation/pages/home_page.dart`:首页标题文案同上。
  - `lib/features/player/application/player_controller.dart`:播放器内部 `PlayerConfiguration.title` 同上。
  - `windows/runner/main.cpp`:窗口标题 `L"Sona"` → `L"Sona Claude"`。
  - `windows/runner/Runner.rc`:`ProductName`、`FileDescription` 同步改为 "Sona Claude"(`InternalName`/`OriginalFilename`/包名 `sonar_vault` 暂未动,涉及改动面较大,后续如需再改)。
  - `android/app/src/main/AndroidManifest.xml`:`android:label` 改为 "Sona Claude"。

### 2. 用户反馈收集(待实施 / 待评估)
详见项目内 [NOTES_TODO.md](../../../Documents/Codex/2026-08-14/new-chat-4/outputs/Sona-Claude-0.1/NOTES_TODO.md),摘要:

**本轮要改(基于截图反馈)**
1. 音量弹窗改为半透明悬浮控件,去掉大白框。
2. MV 播放页 "..." 菜单里的"更换全局背景"和右上角独立按钮功能重复,删掉菜单里那份。
3. "解除MV配对"后应平滑过渡为纯 MP3 播放视图,补过渡动画、修显示细节。
4. 弹出菜单/信息卡在浅色背景下太淡 → 改为毛玻璃(液态玻璃)效果 + 加边框。
5. "批量管理"从弹窗改为就地在歌曲列表行首加勾选框,顶部显示"已选 N 首",直接操作取消收藏/收藏/加入歌单。
6. 侧边栏"常用歌单"加折叠/展开,并加"选择显示哪些歌单"的配置项。
7. 侧边栏 Logo 排版("Sona"/"YOUR MUSIC"大小写混杂)重新设计;曲库统计卡片补边框。

**记录的想法(暂不实施)**
- 播放次数统计 + 听歌排行(周榜/月榜/总榜),先做本地版。
- 云同步可行性:账号密码 + 头像/ID + 播放数据 + 歌单 + 设置上云,初步评估为可行但工作量大(需要账号系统、同步协议、冲突合并策略),建议先做本地统计 + JSON 备份导入导出打基础。

### 3. 代码定位(已完成)
定位到了每一处 UI 对应的源码文件(音量滑块、MV 页菜单、批量管理弹窗、侧边栏、首页统计卡片、播放次数字段等),确认 `Track.playCount` 字段和 SQLite `play_count` 列已存在、播放时会自增,无需新建字段。

### 4. 本轮 UI 改动实施(基于截图反馈,全部完成)

- **音量弹窗**(`lib/features/player/presentation/now_playing_page.dart` `_PlayerVolumeButton`):把默认 `Dialog` 白框改成黑色半透明 + `BackdropFilter` 模糊 + 细边框的悬浮小胶囊(60×220),文字/图标改白色以适配深色玻璃底。
- **去重菜单项**(同文件 `_showMoreMenu`):删掉"..."菜单里的"更换全局背景"(与右上角独立按钮重复),同时删掉"解除 MV 配对"里强制切回唱片模式的那行代码。
- **MV 未配对显示**(同文件 `_MvStage`):解除配对后不再自动跳转视图,停留在 MV 页展示"还没有配对 MV"占位符;给"视频 ↔ 占位符"切换包了一层 `AnimatedSwitcher`(320ms 淡入淡出 + 轻微缩放),不再是生硬的条件渲染。
- **弹窗液态玻璃 + 边框**(同文件,新增 `_GlassSheet` 组件):`BackdropFilter` 模糊 + 72% 不透明白底 + 90% 不透明白色描边 + 阴影,套在"更换背景""更多菜单"两个 bottom sheet 外面,解决浅色背景下看不清边界的问题。
- **批量管理重做**(`lib/features/library/presentation/pages/library_page.dart`):删掉原来的 `_BatchManageDialog`(`AlertDialog` 弹窗),改成点"批量管理"进入就地选择模式——`_DesktopTrackList`/`_MobileTrackList` 每行前面变成勾选框,列表上方出现新组件 `_SelectionBar`("已选 N 首" + 全选/取消收藏/收藏/加入歌单/取消,直接操作,不再单开一层弹窗)。
- **常用歌单折叠 + 可配置**(`lib/features/shell/presentation/main_shell.dart`):`_DesktopSidebar` 从无状态组件改成有状态组件,"常用歌单"标题栏加了展开/收起按钮(`AnimatedCrossFade` 过渡)和一个设置按钮,点开后弹出 `_PlaylistPickerDialog` 勾选要显示哪些歌单(**注意:这个选择目前只存在内存里,没有持久化,重启应用会重置成默认前 5 个**,后续要记住选择需要加一层本地存储)。
- **字体/排版**:侧边栏 Logo(`_Brand`)"Sona Claude / YOUR MUSIC" 调整了字号、字重、字间距层级,加了图标区细描边;首页三张统计卡片(`_QuickLibrary`)补上了边框,解决浅色背景下"看不清边界"的问题。
- **播放次数显示**(`lib/features/library/presentation/pages/home_page.dart` `_RecentList`):复用已有的 `Track.playCount` 字段,在首页"最近播放"每行副标题里加上"播放 N 次"。

### 5. 遗留 / 待跟进(见项目内 `NOTES_TODO.md`)
- 常用歌单选择未持久化,需要时再加本地存储。
- "听歌排行"(周榜/月榜/总榜)**尚未实现**——现有数据库只有累计 `play_count` + `last_played_at`,算不出真正的周榜/月榜,需要新增一张带时间戳的播放事件日志表,属于数据库 schema 改动,建议单独一轮做完后专门跑一遍验证。
- 云同步(账号密码 + 头像 ID + 播放数据 + 歌单 + 设置上云)目前只是可行性分析,未动工,详见 `NOTES_TODO.md`。
- **这台机器没装 Flutter/Dart 工具链**,以上改动全部是纯代码编辑,没有跑过 `flutter analyze`/`flutter run` 验证,需要你本地拉起来跑一下确认没有编译错误、实际效果符合预期。

### 6. 编译环境搭建 + 首次编译出 exe

- 本机装了 **Flutter SDK 3.47.0**(`C:\src\flutter`,git clone stable 分支)。
- 发现本机 E 盘其实早就有 **Visual Studio Community 2026**(桌面 C++ 组件齐全),另外又装了一份 Visual Studio 2022 Build Tools(冗余但无害)。
- `flutter analyze` 跑过,**无报错**。
- 第一次 `flutter build windows` 在 `outputs\Sona-Claude-0.1` 原路径下失败:路径太深,`media_kit_libs_windows_video` 插件的中间文件超过 Windows 260 字符路径限制(`MSB3491`)。**没有改系统的长路径注册表设置**,而是把项目拷到短路径 `C:\SonaClaude` 重新编译。
- 拷贝时把之前 `flutter pub get`/`flutter analyze` 生成的 `windows\flutter\ephemeral` 符号链接也拷过去了,导致第二次编译报 `PathExistsException`(符号链接冲突)。清掉 `windows\flutter\ephemeral`、`.dart_tool`、`build` 后重新编译,**成功**。
- **产物路径**:`C:\SonaClaude\build\windows\x64\runner\Release\sonar_vault.exe`
- 已启动验证进程正常运行,没有闪退。

### 打开方式
双击 `C:\SonaClaude\build\windows\x64\runner\Release\sonar_vault.exe`,或者把整个 `Release` 文件夹复制到别处分发(和原版 `Sona-Windows-0.3.2` 文件夹是同一种"文件夹+exe"形态,依赖的 dll 都在同一目录下,不能只拷 exe)。

**注意**:以后源码改动都在 `outputs\Sona-Claude-0.1` 里做(那是主副本),`C:\SonaClaude` 只是编译产物存放点。每次改完源码想出新 exe,需要把 `outputs\Sona-Claude-0.1\lib`(及改动的其它文件)同步到 `C:\SonaClaude`,再重新 `flutter build windows`。

---

## 后续更新方式
每完成一批改动,在本文件下方追加新的日期小节,记录:改了哪个文件、改了什么、为什么改。

---

## 2026-08-22：Sona 0.5.0 数据安全、性能与正式发布收口

### 本轮完成

- **云端安全**：加入 30 天回收站、即时撤销、恢复和仅所有者可执行的永久删除；Storage 删除只清理孤立对象。生产库已经执行 `202608220001` 与 `202608220002`。
- **完整备份与恢复**：增加流式 `.sonabackup`，包含 SQLite 曲库、歌曲/MV 和受管理图片；逐文件 SHA-256 校验、私有 staging、冷启动原子恢复及恢复前数据库回退。自动快照只保存轻量数据库与图片状态，完整迁移必须使用手动备份。
- **歌曲资料可控**：支持手动编辑歌名、歌手、专辑和封面；AI/声纹校准与手动修改均写入逐曲历史，可安全逐步撤销。
- **播放与并发稳定性**：播放控制、媒体源切换、云删除和备份恢复均串行化；修复快速切歌、切换队列、删除当前 MV、重复恢复和云端操作竞态。自动回归包含十万次固定种子队列状态机和大量故障注入。
- **性能**：新增完整特效、节能特效、关闭动态特效三档；联动动画帧率、粒子、实时模糊、图片解码预算、唱片动画和 Windows 视频输出。Profile 结果显示换肤后内存会回落到稳定平台，没有持续泄漏证据；Windows 基础原生占用仍需后续拆分分析。
- **手机端**：恢复 Android 硬件视频路径，加入通知权限的非阻塞请求；真机自动门禁覆盖冷启动、后台、媒体会话、低内存回调和无清数据重启。蓝牙、真实来电、十分钟熄屏和厂商省电仍需人工验收。
- **正式发布工程**：Android 改用永久 RSA 4096 签名；Windows 提供安装器和便携包；CI/Release 工作流校验版本、签名、包结构、SHA-256 和敏感信息。Windows 暂无 Authenticode，可能显示 Unknown publisher。
- **公开资料**：GitHub README、Release Note、开发文档和官网均采用英文优先、完整中英双语；官网支持桌面、平板和手机响应式布局。

### 发布结果

- 公开仓库：`https://github.com/Owl-Lee/Sona-Player`
- 0.5.0 Release：`https://github.com/Owl-Lee/Sona-Player/releases/tag/v0.5.0`
- 官网：`https://sona.yanbaoli.me/`
- 发布附件：Windows 安装器、Windows x64 便携包、Android APK，以及三份对应的 SHA-256 文件。

### 仍需人工完成

详见 `docs/testing/MOBILE_PLAYER_TEST_PLAN.md`。人工项集中在蓝牙实体耳机、真实来电、十分钟熄屏/后台播放、厂商省电、Windows Profile 长时间观察、测试账号云回收站和完整备份的跨安装恢复。

## 2026-08-24：本机曲库单向镜像云端

- 普通“立即同步”继续保持双向合并，新增独立的“以本机覆盖云端”入口，电脑端和手机端共用同一安全流程。
- 执行前只读比较本机内容哈希与云端活动/回收站记录，并明确预览：待上传、待恢复、待移入回收站、保持不变，以及超过 50 MB 的新增文件数量。
- 用户二次确认后，云端存在但本机不存在的歌曲只移入 30 天回收站；本机存在但云端已回收的歌曲会恢复；随后复用幂等同步流程上传本机新增歌曲并更新资料。整个过程不删除任何本机文件。
- 镜像准备阶段的回收/恢复操作按空间和曲目 ID 双重限定并校验返回行；排除哈希只集中写入一次，中断后可从新预览安全重试。
- 新增纯函数差异规划器及回归测试，覆盖上传、恢复、回收、保持不变、超限文件和“不触碰与本机无关的既有回收站项目”。新增状态和确认文案均提供简体、繁体与英文。
- 验证：`flutter analyze --no-pub` 无问题；云镜像、回收站、后端消息码和发布安全相关测试共 16 项全部通过。

## 2026-08-31：开发分支整理与交付前门禁

- 收口四组尚未发布的改动：本机曲库单向镜像云端、动态特效选项卡等高布局、设置页备份刷新按钮玻璃化，以及带撤销操作的云回收站提示自动收起。
- 云镜像继续遵守“先预览、再确认、后执行”，云端多余歌曲只进入 30 天回收站，不删除本机文件；新增纯函数规划器与覆盖上传、恢复、回收、保持不变、超限文件的回归测试。
- Flutter 新版中带 `SnackBarAction` 的提示默认永久驻留；相关提示现在显式设置 `persist: false`，在保留撤销窗口的同时按 6/8 秒自动关闭。
- `flutter analyze --no-pub`：无问题；`flutter test --no-pub`：126/126 通过。
- Windows Release 已在功能实现阶段成功重建并启动。Android Release 在本机因 Java/Gradle 的 Windows 回环连接异常而未完成；JDK 25 与临时官方 JDK 21 均复现，发布下一版本前必须通过 CI 或修复后的本机构建环境重新验证 APK。
- 本次只整理并提交开发代码与文档，不修改 `0.5.0+2080` 版本号，不更新公开 `v0.5.0` Release。
