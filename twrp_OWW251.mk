#
# TWRP product config - OPPO Watch X2 (OWW251)
#

# 基础 AOSP product（必须有；vendor/twrp/config/common.mk 不继承任何 base，
# catfish 等手表树同样先继承这一行）
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, device/oppo/OWW251/device.mk)

# 【当前基线】先关掉动态分区：TWRP 能进主界面后再打开（super/liblp 也在启动路径上）
PRODUCT_USE_DYNAMIC_PARTITIONS := false
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
