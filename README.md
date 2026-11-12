# 影音播放器（Flutter 原生）

安卓 **APK** + Windows **原生桌面（.exe）** 前端，对接 Instabox `media-api` v0.1。  
**不是** Web / PWA / 套壳浏览器。

## 环境

- Flutter stable（本仓库开发机 SDK：`/home/box/sdk/flutter`）
- 后端：`https://66bb3bd8arf4.hostc.app`（需能访问 Instabox 所在机器；真机不要用对方电脑的 127.0.0.1）

## 配置 Token / Base URL

**不要**把真实 Token 写进可公开提交的源码。

1. 复制示例并填入本地配置（已 gitignore）：

```bash
cp config/dev.json.example config/dev.json
# 编辑 config/dev.json：baseUrl、apiToken
```

2. 或在应用内「我的」页填写并保存（写入 SharedPreferences）。

3. 或启动时注入：

```bash
flutter run -d windows --dart-define=API_BASE_URL=https://66bb3bd8arf4.hostc.app --dart-define=API_TOKEN=你的token
flutter run -d android --dart-define=API_BASE_URL=http://内网IP:8787 --dart-define=API_TOKEN=你的token
```

开发 Token 源文件：后端仓库 `/workspace/media-api/docs/DEV_TOKEN.txt`（勿外泄）。

## 运行

```bash
export PATH="/home/box/sdk/flutter/bin:$PATH"
cd /workspace/media_player

# Windows 原生桌面
flutter run -d windows

# 安卓真机 / 模拟器（安装原生 APK 到设备）
flutter run -d android

# 仅打安卓 APK（可安装的原生包）
flutter build apk --debug
# 产物：build/app/outputs/flutter-apk/app-debug.apk

# Windows 发行版
flutter build windows
```

## 功能壳

- 底部导航：片库 / 搜索 / 我的（设置）
- 片库：封面、标题、时长；点击进入沉浸式播放页
- 播放：`GET /play` → 直链流；media_kit；约 15 秒上报进度
- 设置：Base URL + Bearer Token

## 包名

- Android `applicationId`：`xyz.hengshang.media_player`
- 应用名：影音播放器

## 本机已验证

- `flutter analyze`：无问题
- `flutter test`：通过
- 对 `media-api` 的列表 /play 冒烟：OK（冒烟测试片）
- `flutter build apk --debug`：已产出  
  `build/app/outputs/flutter-apk/app-debug.apk`（原生 APK，含 media_kit 原生库，约 186MB）

### SDK（本 Bot 电脑）

```bash
export JAVA_HOME=/home/box/sdk/jdk-17
export ANDROID_SDK_ROOT=/home/box/sdk/android
export PATH="$JAVA_HOME/bin:/home/box/sdk/flutter/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
```

Windows `.exe` 需在 Windows 主机上执行 `flutter build windows`（Linux 交叉编译不适用）。
