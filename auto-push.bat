@echo off
if exist public\ (
    call rd public /s/q
)
call hexo g
if exist .git\ (
    call echo "use git"
) else (
    call git clone git@github.com:Xin-FAS/xin-fas.github.io.git
    if exist xin-fas.github.io\.git\ (
        call xcopy xin-fas.github.io\.git\ .\.git\ /s/q
        call rd xin-fas.github.io /s/q
    ) else (
        echo "git clone error!"
        pause
    )
)
if exist .git\ (
    call xcopy source\html\ public\iframe\ /s/q
    call xcopy public\ docs\ /s/q
    call git add .
    call git commit -m "update"
    call git push origin main
    call rd docs /s/q
    pause
)