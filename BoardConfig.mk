#
# TWRP device tree - OPPO Watch X2 (OWW251), Qualcomm monaco (SDW4100 class)
# Pure 32-bit arm, A-only partitions, dynamic partitions inside /super.
#
# 所有数值均取自真机 GPT / super 元数据 / 原厂 fstab.qcom，不用生成器占位值。
#

DEVICE_PATH := device/oppo/OWW251

# 允许最小 manifest
ALLOW_MISSING_DEPENDENCIES := true

# ---------------------------------------------------------------------------
# 架构（纯 32 位，无 abilist64）
# ---------------------------------------------------------------------------
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a53
TARGET_CPU_VARIANT_RUNTIME := cortex-a53
TARGET_USES_64_BIT_BINDER := false
TARGET_SUPPORTS_32_BIT_APPS := true
TARGET_SUPPORTS_64_BIT_APPS := false

# ---------------------------------------------------------------------------
# 平台
# ---------------------------------------------------------------------------
TARGET_BOARD_PLATFORM := monaco
TARGET_BOOTLOADER_BOARD_NAME := monaco
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
TARGET_SCREEN_DENSITY := 320

# APEX 不拍平（TWRP 12.1 默认行为）
#OVERRIDE_TARGET_FLATTEN_APEX := true

# ---------------------------------------------------------------------------
# 内核 / boot 头（与 stock recovery.img 逐项一致）
# ---------------------------------------------------------------------------
BOARD_BOOTIMG_HEADER_VERSION := 2
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_DTB_OFFSET := 0x01f00000
BOARD_KERNEL_PAGESIZE := 4096

# 末尾的 androidboot.dynamic_partitions=true 是给 fastbootd / liblp 用的：
# stock 的 build_default.prop 里写死了 ro.boot.dynamic_partitions=true，
# TWRP 没有这个 prop，只能从 cmdline 补。
BOARD_KERNEL_CMDLINE := console=ttyMSM0,115200n8 earlycon=msm_geni_serial,0x4a98000 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=2048 vmalloc=300M loop.max_part=7 iptable_raw.raw_before_defrag=1 ip6table_raw.raw_before_defrag=1 cgroup.memory=nokmem,nosocket buildvariant=user androidboot.dynamic_partitions=true

# prebuilt 内核 / dtb / recovery_dtbo（全部取自本机 recovery.img）
TARGET_FORCE_PREBUILT_KERNEL := true
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/zImage
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_KERNEL_IMAGE_NAME := zImage

BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOTIMG_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB)
BOARD_MKBOOTIMG_ARGS += --os_version 11.0.0 --os_patch_level 2024-03

# ---------------------------------------------------------------------------
# 分区（GPT 实测）
# ---------------------------------------------------------------------------
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432        # 65536 sectors = 32 MiB
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864    # 131072 sectors = 64 MiB
BOARD_CACHEIMAGE_PARTITION_SIZE := 268435456      # 256 MiB
BOARD_FLASH_BLOCK_SIZE := 262144

BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_SYSTEMIMAGE_PARTITION_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_COPY_OUT_VENDOR := vendor

# /metadata 独立分区（userdata 为 metadata 加密 + wrappedkey，必须有）
BOARD_USES_METADATA_PARTITION := true

# 动态分区：真机 super 元数据里组名是 qti_dynamic_partitions，
# 只包含 system / system_ext / vendor / product（没有 odm！）
BOARD_SUPER_PARTITION_SIZE := 4294967296
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := system system_ext vendor product
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 4290772992

# ---------------------------------------------------------------------------
# Recovery
# ---------------------------------------------------------------------------
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_SUPPRESS_SECURE_ERASE := true

# recovery.fstab 会被当作 /system/etc/recovery.fstab 打进 ramdisk，
# init / fastbootd 用它；TWRP 自己优先读同目录的 twrp.fstab。
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab

# recovery/root/** 整体拷进 ramdisk 根目录（init rc、fstab、rebootedl.sh 等）
TARGET_RECOVERY_DEVICE_DIRS += $(DEVICE_PATH)

# ---------------------------------------------------------------------------
# AVB（保持与原镜像一致；解锁状态下不校验）
# ---------------------------------------------------------------------------
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1
PLATFORM_SECURITY_PATCH := 2099-12-31

# ---------------------------------------------------------------------------
# TWRP 基本配置
# ---------------------------------------------------------------------------
TW_THEME := portrait_hdpi
TW_ROUND_SCREEN := true
TW_EXTRA_LANGUAGES := true
TW_DEFAULT_LANGUAGE := zh_CN
TW_SCREEN_BLANK_ON_BOOT := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_USE_TOOLBOX := true
TW_EXCLUDE_TWRPAPP := true
TW_NO_SCREEN_TIMEOUT := true
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 128
TW_BRIGHTNESS_PATH := /sys/class/backlight/panel0-backlight/brightness
TW_DEVICE_VERSION := OWW251
TW_SKIP_COMPATIBILITY_CHECK := true

# 本机 ABL 不传 androidboot.usbcontroller，TWRP 自带的 legacy android_usb init rc
# 和 configfs 触发器都拿不到 UDC 名，adb/MTP 会整体失效。
# 这里关掉 TWRP 的默认 USB init，改用设备树里的 recovery/root/init.recovery.usb.rc
#（configfs + ffs.mtp 全套，UDC 名在 init.recovery.qcom.rc 里写死）。
TW_EXCLUDE_DEFAULT_USB_INIT := true

TW_OVERRIDE_SYSTEM_PROPS := "ro.build.fingerprint=OPPO/OWW251/OWW251:11/RKQ1.220916.001.11_A.87.250318010337/01:user/release-keys;ro.product.device=OWW251;ro.product.model=OWW251;ro.hardware=qcom"

# ---------------------------------------------------------------------------
# 修复 1：动态分区必须开这个才会 map /dev/block/mapper/*
# ---------------------------------------------------------------------------
TW_INCLUDE_LOGICAL := true

# ---------------------------------------------------------------------------
# 修复 2：fastbootd（Reboot 菜单的 Fastboot 项 + sys.usb.config=fastboot）
# ---------------------------------------------------------------------------
TW_INCLUDE_FASTBOOTD := true

# ---------------------------------------------------------------------------
# 修复 3：EDL / Download 菜单项（对应主题里的 tw_edl_mode / tw_download_mode）
# ---------------------------------------------------------------------------
TW_HAS_EDL_MODE := true
TW_HAS_DOWNLOAD_MODE := true

# ---------------------------------------------------------------------------
# 修复 4：/data 解密（FBE v2 + metadata 加密 + wrappedkey_v0）
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# /data 加密：本机 userdata 默认不加密（未启用 metadata/FBE），
# 所以不编 crypto，也就不需要 vendor keymaster/gatekeeper blobs。
# 如果以后换了会加密的 ROM，再打开下面三行并补回 keymaster blobs：
#TW_INCLUDE_CRYPTO := true
#TW_INCLUDE_CRYPTO_FBE := true
#TW_INCLUDE_FBE_METADATA_DECRYPT := true
#TW_CRYPTO_USE_SYSTEM_VOLD := true
