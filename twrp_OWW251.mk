#
# TWRP product config for OPPO Watch X2 (OWW251)
# 用于 minimal-manifest-twrp/platform_manifest_twrp_aosp (twrp-11 + twrp-extras.xml)
#

# 继承基础 AOSP product
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# 继承 TWRP 公共配置（twrp-extras.xml 里的 vendor/twrp）
$(call inherit-product, vendor/twrp/config/common.mk)

# 继承本机 device.mk
$(call inherit-product, device/oppo/OWW251/device.mk)

PRODUCT_DEVICE := OWW251
PRODUCT_NAME := twrp_OWW251
PRODUCT_BRAND := OPPO
PRODUCT_MODEL := OPPO Watch X2
PRODUCT_MANUFACTURER := OPPO

PRODUCT_GMS_CLIENTID_BASE := android-oppo

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="OWW251-user 11 RKQ1.220916.001.11_A.87.250318010337 01 release-keys"

BUILD_FINGERPRINT := OPPO/OWW251/OWW251:11/RKQ1.220916.001.11_A.87.250318010337/01:user/release-keys
