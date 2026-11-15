#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Omni stuff.
$(call inherit-product, vendor/omni/config/common.mk)

# Inherit from OWW251 device
$(call inherit-product, device/oppo/OWW251/device.mk)

PRODUCT_DEVICE := OWW251
PRODUCT_NAME := omni_OWW251
PRODUCT_BRAND := OPPO
PRODUCT_MODEL := OPPO Watch X2
PRODUCT_MANUFACTURER := OPPO

PRODUCT_GMS_CLIENTID_BASE := android-oppo

# 真机 build.prop 原文（非 Qualcomm 参考板）
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="OWW251-user 11 RKQ1.220916.001.11_A.87.250318010337 01 release-keys"

BUILD_FINGERPRINT := OPPO/OWW251/OWW251:11/RKQ1.220916.001.11_A.87.250318010337/01:user/release-keys
