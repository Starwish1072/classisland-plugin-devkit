# ClassIsland 插件开发环境配置

一键检测 / 安装 **ClassIsland 插件**开发所需环境，并自动定位 ClassIsland 安装目录。

## 需要哪些环境

| 组件 | 用途 | 必需 | 版本 |
|---|---|---|---|
| Windows 10/11 x64 | 目标平台 | 必需 | — |
| .NET 8 SDK | 编译插件（ClassIsland 基于 .NET 8 + Avalonia 11） | 必需 | 8.0.x |
| ClassIsland 2.1.x | 提供编译引用 DLL（ClassIsland.Core / Avalonia.* / SkiaSharp / Edge_tts_sharp 等）与运行环境 | 必需 | 2.1.x |
| Git | 拉代码 / 发版 | 推荐 | 任意 |
| Node.js LTS | 给「批改邦」Electron 的 app.asar 打 hook 补丁 | 按需 | 18+ |
| Python 3 + edge-tts | 插件里的 Edge TTS 语音通道 | 按需 | 3.9+ |

> 只用系统讲述人（SAPI）时不需要 Python；VoiceHub 类转写需你自备接口。

## 快速开始

```bat
:: 只检测，不安装
环境配置.bat check

:: 检测 + 自动安装缺失项（winget）
环境配置.bat
```

脚本流程：

1. 检测 **.NET 8 SDK**（缺失则 winget 安装 Microsoft.DotNet.SDK.8）
2. 检测 **Git**（缺失则安装 Git.Git）
3. 检测 **Node.js LTS**（缺失则安装 OpenJS.NodeJS.LTS）
4. 检测 **Python 3** 与 **edge-tts**（缺失则安装 / pip 安装）
5. 定位 **ClassIsland**：依次尝试环境变量 `CLASSISLAND_DIR` → `C:\classisland` → `%LOCALAPPDATA%\ClassIsland`
6. 校验编译所需 DLL，写出 `classisland.env`

## 输出文件

`classisland.env`（自动生成，已 gitignore）：

```ini
CLASSISLAND_DIR=C:\classisland
CLASSISLAND_APP=C:\classisland\app-2.1.0.1-0
```

把 `CLASSISLAND_APP` 填进 csproj：

```xml
<Reference Include="ClassIsland.Core">
  <HintPath>C:\classisland\app-2.1.0.1-0\ClassIsland.Core.dll</HintPath>
  <Private>false</Private>
</Reference>
```

## 常见问题

**找不到 ClassIsland？** 设置环境变量后重跑：

```bat
set CLASSISLAND_DIR=D:\你的\ClassIsland
环境配置.bat check
```

**winget 装完命令还找不到？** 新装的工具要重开终端刷新 PATH。

**编译报找不到 Avalonia / SkiaSharp？** 说明 `CLASSISLAND_APP` 指错，确认该目录里直接有 `ClassIsland.Core.dll`（有的版本装到 `app-<ver>` 子目录）。

**pip 装 edge-tts 慢？** 用镜像：`python -m pip install edge-tts -i https://pypi.tuna.tsinghua.edu.cn/simple`

## 许可证

MIT

Starwish1072 ©2026

## 作者

Starwish1072

Cammile•James（同一人）
