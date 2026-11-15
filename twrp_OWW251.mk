#
# TWRP product config - OPPO Watch X2 (OWW251)
#

# 基础 AOSP product（必须有，vendor/twrp/config/common.mk 只有 289 字节，
# 不继承任何 base；缺了它会 lunch 失败或产物缺包）。参照 catfish 手表树写法。
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, device/oppo/OWW251/device.mk)

# 真机是动态分区（super 4 GiB，组 qti_dynamic_partitions，见 BoardConfig）。
# 打开后 recovery 才会：
#   1) 编出 fastbootd 并置 TW_IS_SUPER=1（TWRP 能 map /dev/block/mapper/*）
#   2) Reboot 菜单出现 Fastboot 项（对应 TW_INCLUDE_FASTBOOTD）
#   3) 引入 liblp / health@2.1 等动态分区依赖
PRODUCT_USE_DYNAMIC_PARTITIONS := true
# TWRP 只需要 recovery.img，不需要生成 super 镜像
PRODUCT_BUILD_SUPER_PARTITION := false

PRODUCT_DEVICE := OWW251
PRODUCT_NAME := twrp_OWW251
PRODUCT_BRAND := OPPO
PRODUCT_MODEL := OWW251
PRODUCT_MANUFACTURER := OPPO
PRODUCT_GMS_CLIENTID_BASE := android-oppo

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="OWW251-user 11 RKQ1.220916.001.11_A.87.250318010337 01 release-keys"

BUILD_FINGERPRINT := OPPO/OWW251/OWW251:11/RKQ1.220916.001.11_A.87.250318010337/01:user/release-keys
