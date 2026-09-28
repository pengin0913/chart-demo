@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 支援的圖檔副檔名清單
set "EXTS=*.png *.jpg *.jpeg *.bmp *.gif *.webp"

:MENU
cls
echo ==================================================
echo [目前目錄下的圖檔列表]
echo ==================================================
set "FOUND=0"
for %%F in (%EXTS%) do (
    if exist "%%F" (
        echo   %%F
        set "FOUND=1"
    )
)

if "!FOUND!"=="0" (
    echo 目前目錄下沒有找到任何圖檔。
    echo ==================================================
    pause
    exit /b
)
echo ==================================================
echo.
echo 請選擇功能：
echo   (1) 更改字串名字："字串1" 取代成 "字串2"
echo   (2) 數字檔名增減：所有純數字檔名加或減數字 (例: +3 或 -3)
echo   (Q) 離開程式
echo --------------------------------------------------
set /p "CHOICE=請輸入選項 [1, 2, Q]: "

if /i "%CHOICE%"=="1" goto REPLACE_TEXT
if /i "%CHOICE%"=="2" goto SHIFT_NUMBERS
if /i "%CHOICE%"=="Q" exit /b
goto MENU

:: ==================================================
:: 功能 1：字串取代
:: ==================================================
:REPLACE_TEXT
echo.
set /p "SEARCH_STR=請輸入欲取代的舊字串: "
if "%SEARCH_STR%"=="" (
    echo [錯誤] 舊字串不得為空！
    pause
    goto MENU
)
set /p "REPLACE_STR=請輸入欲換成的新字串 (留空代表直接刪除): "

echo.
echo 開始進行批次替換...
echo --------------------------------------------------
set "RENAMED_COUNT=0"

for %%F in (%EXTS%) do (
    if exist "%%F" (
        set "FULL_NAME=%%F"
        set "BASE_NAME=%%~nF"
        set "EXT=%%~xF"

        set "NEW_BASE=!BASE_NAME:%SEARCH_STR%=%REPLACE_STR%!"

        if not "!BASE_NAME!"=="!NEW_BASE!" (
            set "NEW_NAME=!NEW_BASE!!EXT!"
            if exist "!NEW_NAME!" (
                echo [跳過] 檔案已存在: !NEW_NAME!
            ) else (
                ren "!FULL_NAME!" "!NEW_NAME!"
                echo [已更名] !FULL_NAME! --^> !NEW_NAME!
                set /a RENAMED_COUNT+=1
            )
        )
    )
)
echo --------------------------------------------------
echo 完成！共重新命名 !RENAMED_COUNT! 個檔案。
goto SHOW_RESULT

:: ==================================================
:: 功能 2：純數字檔名增減 (透過 tmp_ 暫存前綴簡化)
:: ==================================================
:SHIFT_NUMBERS
echo.
set /p "OFFSET=請輸入增減數值 (例如 +3 或 -3): "
if "%OFFSET%"=="" (
    echo [錯誤] 數值不得為空！
    pause
    goto MENU
)

echo.
echo 第一階段：計算數值並加上暫存前綴 tmp_...
echo --------------------------------------------------
set "COUNT=0"

for %%F in (%EXTS%) do (
    if exist "%%F" (
        set "BASE=%%~nF"
        set "EXT=%%~xF"

        :: 檢查是否為純數字檔名
        set "IS_NUM=1"
        for /f "delims=0123456789" %%C in ("!BASE!") do (
            set "IS_NUM=0"
        )

        if "!IS_NUM!"=="1" (
            :: 去除開頭 0 (避免誤判 8 進位)
            set "RAW_NUM=!BASE!"
            for /f "tokens=* delims=0" %%A in ("!RAW_NUM!") do set "RAW_NUM=%%A"
            if "!RAW_NUM!"=="" set "RAW_NUM=0"

            :: 計算新數字
            set /a "NEW_NUM=RAW_NUM + (%OFFSET%)"

            if !NEW_NUM! lss 0 (
                echo [跳過] 運算結果為負數無法命名: %%F
            ) else (
                ren "%%F" "tmp_!NEW_NUM!!EXT!"
                echo [運算更名] %%F --^> tmp_!NEW_NUM!!EXT!
                set /a COUNT+=1
            )
        )
    )
)

echo.
echo 第二階段：去除 tmp_ 前綴完成正式檔名...
echo --------------------------------------------------
for %%F in (tmp_*.*) do (
    if exist "%%F" (
        set "OLD_NAME=%%F"
        set "NEW_NAME=!OLD_NAME:tmp_=!"

        ren "!OLD_NAME!" "!NEW_NAME!"
        echo [完成] !OLD_NAME! --^> !NEW_NAME!
    )
)

echo --------------------------------------------------
echo 全部完成！共重新命名 !COUNT! 個純數字檔案。

:: ==================================================
:: 顯示更新後清單
:: ==================================================
:SHOW_RESULT
echo.
echo ==================================================
echo [更新後的圖檔列表]
echo ==================================================
for %%F in (%EXTS%) do (
    if exist "%%F" (
        echo   %%F
    )
)
echo ==================================================
echo.
pause
goto MENU