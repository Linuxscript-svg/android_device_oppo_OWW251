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

# 运行时 prop 覆盖：lunch 目标名必须叫 twrp_OWW251，但要让系统里看到的身份和
# 真机一致，否则第三方 zip / 官方包的 updater assert 会直接拒装，例如：
#   E3004: This package is for "OWW251" product; this is a "twrp_OWW251"
#   —— 这句 assert 查的是 getprop("ro.product.name")
# PRODUCT_BUILD_PROP_OVERRIDES 会以环境变量形式覆盖生成 build.prop 用的 PRODUCT_*，
# 因此 ro.product.<分区>.name（以及由它派生的 ro.product.name）都会变成 OWW251。
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="OWW251-user 11 RKQ1.220916.001.11_A.87.250318010337 01 release-keys" \
    PRODUCT_NAME=OWW251 \
    PRODUCT_DEVICE=OWW251 \
    PRODUCT_MODEL=OWW251 \
    PRODUCT_BRAND=OPPO \
    PRODUCT_MANUFACTURER=OPPO

BUILD_FINGERPRINT := OPPO/OWW251/OWW251:11/RKQ1.220916.001.11_A.87.250318010337/01:user/release-keys
