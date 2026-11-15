#!/system/bin/sh
#
# OWW251 进入 EDL（9008）的兜底脚本。
# TWRP 的 Reboot -> EDL 会优先执行 /system/bin/rebootedl.sh（如果存在），
# 所以这里直接走内核 restart reason：
#   sys.powerctl=reboot,edl  ->  init 调 __reboot(RB_AUTOBOOT, "edl")
#   -> Qualcomm 内核写入 restart reason -> ABL 识别为 EDL 并进入 9008
#
# ABL 里确实有 EDL 分支（字符串 "Failed to WriteRecoveryMessageEdl"），
# 说明这条重启原因是支持的；硬件按键进 EDL 仍然是最稳的途径。
#
sync
setprop sys.powerctl "reboot,edl"

# 走到这里说明 setprop 没生效，最后再试一次 reboot 命令
sleep 1
reboot edl
