@echo off
call hexo g
call git clone git@github.com:Xin-FAS/xin-fas.github.io.git
if exist xin-fas.github.io\.git\ (
    call xcopy xin-fas.github.io\.git\ .\.git\ /s/q
    call rd xin-fas.github.io /s/q
    call xcopy source\html\ public\iframe\ /s/q
    call xcopy public\ docs\ /s/q
    call git add .
    call git commit -m "update"
    call git push origin main
    call rd docs /s/q
    call rd .git /s/q
    pause
) else (
    echo "git拉取失败！"
    pause
)