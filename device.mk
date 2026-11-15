#
# OPPO Watch X2 (OWW251) device config
#
# recovery/root/** 由 TARGET_RECOVERY_DEVICE_DIRS 自动拷进 recovery ramdisk：
#   recovery/root/system/etc/{recovery,twrp}.fstab   mount / fastbootd 用
#   recovery/root/init.recovery.qcom*.rc             启动 keymaster/gatekeeper、建 /dev/block 链接
#   recovery/root/system/bin/*                       vendor HAL（keymaster/gatekeeper）、rebootedl.sh
#   recovery/root/{vendor,system}/lib/*              HAL 依赖库
#

LOCAL_PATH := device/oppo/OWW251

# TWRP 认设备名用，避免刷入时提示不匹配
PRODUCT_PROPERTY_OVERRIDES += \
    ro.twrp.target.devices=OWW251
