#
# TWRP product config - OPPO Watch X2 (OWW251)
#

# 基础 AOSP product（必须有；vendor/twrp/config/common.mk 不继承任何 base）
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, device/oppo/OWW251/device.mk)

# 动态分区必须开：twrp.fstab 的 logical 挂载和 fastbootd 都依赖 liblp/super
PRODUCT_USE_DYNAMIC_PARTITIONS := true
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
