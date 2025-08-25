@echo off
chcp 65001 >nul
title 微信并发多开启动器 - by 一坨肉

setlocal enabledelayedexpansion

echo.
echo ⚡ 正在扫描微信安装路径，请稍候...

set "wechat_path="
set "drives="

REM =======================
REM 获取所有本地磁盘
REM 优先用 fsutil（Win7+ 都有），
REM 如果失败则回退到 wmic（某些老系统需要）
REM =======================

REM 尝试 fsutil
for /f "tokens=2,*" %%a in ('fsutil fsinfo drives 2^>nul') do (
    for %%d in (%%b) do (
        set "drive=%%d"
        REM 去掉最后的反斜杠 C:\ → C
        set "drive=!drive:\=!"
        set "drives=!drives! !drive!"
    )
)

REM 如果 fsutil 没取到，则用 wmic
if not defined drives (
    for /f "skip=1 tokens=1" %%d in ('wmic logicaldisk where "DriveType=3" get DeviceID 2^>nul') do (
        if not "%%d"=="" (
            set "drives=!drives! %%d"
        )
    )
)

REM =======================
REM 支持的路径（包含 WeChat 和 Weixin）
REM =======================
set "paths[0]=Tencent\WeChat\WeChat.exe"
set "paths[1]=Tencent\Weixin\Weixin.exe"
set "paths[2]=Weixin\Weixin.exe"
set "paths[3]=Program Files\Tencent\WeChat\WeChat.exe"
set "paths[4]=Program Files\Tencent\Weixin\Weixin.exe"
set "paths[5]=Program Files (x86)\Tencent\WeChat\WeChat.exe"
set "paths[6]=Program Files (x86)\Tencent\Weixin\Weixin.exe"
set "paths[7]=Program Files\Weixin\Weixin.exe"
set "paths[8]=Program Files (x86)\Weixin\Weixin.exe"

REM =======================
REM 扫描所有盘符和路径
REM =======================
for %%d in (%drives%) do (
    for /L %%i in (0,1,8) do (
        set "fullpath=%%d\!paths[%%i]!"
        if exist "!fullpath!" (
            set "wechat_path=!fullpath!"
            goto :found
        )
    )
)

REM =======================
REM 未找到微信
REM =======================
echo.
echo ❌ 未找到微信程序！
echo.
echo 请检查是否安装在常见路径，如：
echo   D:\Program Files\Tencent\Weixin\Weixin.exe
echo.
echo 💖 本工具由「一坨肉」专属定制
echo.
pause
exit /b 1

REM =======================
REM 找到微信
REM =======================
:found
echo.
echo ✅ 找到微信："%wechat_path%"
echo.

:input_loop
set /p "count=请输入要启动的实例数量 (1-9): "

REM ✅ 修复后的验证方式（兼容性更强）
echo %count%| findstr "^[1-9]$" >nul
if errorlevel 1 (
    echo ⚠️  请输入 1~9 的数字！
    goto input_loop
)

set /a num=%count%

echo.
echo 💥 正在并发启动 %num% 个微信实例（天下武功无坚不摧唯快不破）...
echo.

REM 🔥 核心：并发启动，不加 delay，不加 -multi
for /L %%i in (1,1,%num%) do (
    start "" "%wechat_path%"
)

echo.
echo ✅ 所有启动命令已并发发出！
echo    如果成功，将弹出 %num% 个独立登录窗口。
echo.
echo 💬 by 一坨肉 · 科学多开
echo.
pause
