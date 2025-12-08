# Flutter 安装指南

## 问题说明

如果遇到 `'flutter' 不是内部或外部命令` 的错误，说明 Flutter 未安装或未添加到系统 PATH 环境变量中。

---

## Windows 安装步骤

### 1. 下载 Flutter SDK

1. 访问 Flutter 官网：https://flutter.dev/docs/get-started/install/windows
2. 下载最新的 Flutter SDK（推荐稳定版）
3. 解压到合适的位置，例如：`C:\src\flutter`
   - **注意**：不要解压到需要管理员权限的目录（如 `C:\Program Files\`）
   - **注意**：路径中不要包含空格或特殊字符

### 2. 添加到 PATH 环境变量

#### 方法一：通过系统设置（推荐）

1. 右键点击"此电脑" → "属性"
2. 点击"高级系统设置"
3. 点击"环境变量"
4. 在"用户变量"或"系统变量"中找到 `Path`，点击"编辑"
5. 点击"新建"，添加 Flutter bin 目录路径，例如：`C:\src\flutter\bin`
6. 点击"确定"保存所有更改

#### 方法二：通过命令行（临时）

```cmd
setx PATH "%PATH%;C:\src\flutter\bin"
```

**注意**：需要重新打开命令行窗口才能生效。

### 3. 验证安装

打开新的命令行窗口（重要：必须重新打开），运行：

```cmd
flutter --version
```

如果显示版本信息，说明安装成功。

### 4. 运行 Flutter Doctor

检查 Flutter 环境配置：

```cmd
flutter doctor
```

根据输出信息安装缺失的依赖：
- **Android Studio**：用于 Android 开发
- **VS Code**：可选，用于代码编辑
- **Chrome**：用于 Web 开发测试

### 5. 安装 Android Studio（Android 开发必需）

1. 下载并安装 Android Studio：https://developer.android.com/studio
2. 打开 Android Studio，完成初始设置
3. 安装 Android SDK：
   - Tools → SDK Manager
   - 选择 Android SDK Platform 和 Android SDK Build-Tools
   - 点击 Apply 安装
4. 配置 Android 模拟器（可选）：
   - Tools → Device Manager
   - 创建虚拟设备

### 6. 接受 Android 许可协议

```cmd
flutter doctor --android-licenses
```

按 `y` 接受所有许可协议。

## 快速验证

安装完成后，在项目目录运行：

```cmd
cd C:\github\FlutterDemo
flutter pub get
flutter doctor
```

## 常见问题

### 问题 1：命令仍然无法识别

**解决方案**：
1. 确认已重新打开命令行窗口
2. 检查 PATH 是否正确添加
3. 确认 Flutter 安装路径正确

### 问题 2：需要管理员权限

**解决方案**：
- 将 Flutter 安装到用户目录，如 `C:\Users\你的用户名\flutter`
- 或使用管理员权限运行命令行

### 问题 3：网络问题（下载依赖慢）

**解决方案**：
- 配置国内镜像（推荐）：
  ```cmd
  setx PUB_HOSTED_URL "https://pub.flutter-io.cn"
  setx FLUTTER_STORAGE_BASE_URL "https://storage.flutter-io.cn"
  ```
- 重新打开命令行窗口

## 安装完成后

1. 运行 `flutter pub get` 安装项目依赖
2. 运行 `flutter pub run build_runner build --delete-conflicting-outputs` 生成代码
3. 运行 `flutter run` 启动项目

---

## Linux 安装步骤

### 1. 下载 Flutter SDK

1. 访问 Flutter 官网：https://flutter.dev/docs/get-started/install/linux
2. 下载最新的 Flutter SDK（推荐稳定版）
3. 解压到合适的位置，例如：`~/development/flutter`
   - **注意**：路径中不要包含空格或特殊字符

### 2. 添加到 PATH 环境变量

编辑 `~/.bashrc` 或 `~/.zshrc` 文件：

```bash
export PATH="$PATH:$HOME/development/flutter/bin"
```

然后重新加载配置：

```bash
source ~/.bashrc
# 或
source ~/.zshrc
```

### 3. 安装 Linux 开发工具链

根据 `flutter doctor` 的输出，安装缺失的依赖：

```bash
sudo apt update
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev
```

### 4. 验证安装

运行以下命令验证：

```bash
flutter --version
flutter doctor
```

### 5. 安装 Android Studio（Android 开发必需，可选）

如果需要 Android 开发，请安装 Android Studio：

1. 下载并安装 Android Studio：https://developer.android.com/studio
2. 打开 Android Studio，完成初始设置
3. 安装 Android SDK：
   - Tools → SDK Manager
   - 在 SDK Tools 标签页中，确保勾选：
     - Android SDK Command-line Tools (latest)
     - Android SDK Build-Tools
     - Android SDK Platform-Tools
   - 选择 Android SDK Platform（选择需要的 API 级别）
   - 点击 Apply 安装
4. 配置 Android SDK 路径（如果安装到自定义位置）：

```bash
flutter config --android-sdk ~/Android/Sdk
# 或使用自定义路径
flutter config --android-sdk /path/to/android/sdk
```

### 6. 安装 cmdline-tools（如果 flutter doctor 提示缺失）

如果 `flutter doctor` 显示 cmdline-tools 组件缺失，可以通过以下方式安装：

**方法一：通过 Android Studio**
- 打开 Android Studio → Tools → SDK Manager
- 在 SDK Tools 标签页中勾选 "Android SDK Command-line Tools (latest)"
- 点击 Apply 安装

**方法二：通过命令行**
```bash
# 假设 Android SDK 在 ~/Android/Sdk
~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager --install "cmdline-tools;latest"
```

### 7. 接受 Android 许可协议（如果安装了 Android SDK）

```bash
flutter doctor --android-licenses
```

按 `y` 接受所有许可协议。如果命令失败，请确保已正确安装 cmdline-tools（见步骤 6）。

## Linux 常见问题

### 问题 1：缺少 Linux toolchain 依赖

如果 `flutter doctor` 显示缺少以下工具：
- `clang++`
- `CMake`
- `ninja`
- `pkg-config`

**解决方案**：

```bash
sudo apt update
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev
```

### 问题 2：Android SDK 未找到

**解决方案**：
1. 安装 Android Studio 并配置 Android SDK
2. 或使用 `flutter config --android-sdk` 指定 SDK 路径

### 问题 3：cmdline-tools 组件缺失

如果 `flutter doctor` 显示 `cmdline-tools component is missing`：

**解决方案**：

1. 找到 Android SDK 路径（通常在 `~/Android/Sdk` 或 `$ANDROID_HOME`）
2. 使用 sdkmanager 安装 cmdline-tools：

```bash
# 如果已设置 ANDROID_HOME
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --install "cmdline-tools;latest"

# 或使用完整路径（替换为你的实际路径）
~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager --install "cmdline-tools;latest"
```

如果 cmdline-tools 目录不存在，需要先下载：

```bash
# 创建目录
mkdir -p ~/Android/Sdk/cmdline-tools
cd ~/Android/Sdk/cmdline-tools

# 下载并解压 cmdline-tools（替换为最新版本号）
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-*_latest.zip
mv cmdline-tools latest

# 然后安装
latest/bin/sdkmanager --install "cmdline-tools;latest"
```

### 问题 4：Android license 状态未知

如果 `flutter doctor` 显示 `Android license status unknown`：

**解决方案**：

运行以下命令接受所有 Android 许可协议：

```bash
flutter doctor --android-licenses
```

按 `y` 接受所有许可协议。如果遇到问题，可能需要先安装 cmdline-tools（见问题 3）。

### 问题 5：网络问题（下载依赖慢）

**解决方案**：
- 配置国内镜像（推荐）：
  ```bash
  export PUB_HOSTED_URL="https://pub.flutter-io.cn"
  export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
  ```
- 将上述命令添加到 `~/.bashrc` 或 `~/.zshrc` 使其永久生效

## 快速验证

安装完成后，在项目目录运行：

```bash
cd ~/Documents/github/FlutterDemo
flutter pub get
flutter doctor
```

## 参考资源

- Flutter 官方文档：https://flutter.dev/docs
- Flutter 中文网：https://flutter.cn
- Flutter 社区：https://flutter.dev/community
- Linux 安装指南：https://flutter.dev/docs/get-started/install/linux

