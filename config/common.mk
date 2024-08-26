#
# Copyright (C) 2018-2022 StatiXOS
#
# SPDX-License-Identifier: Apache-2.0
#

include vendor/statix/build/core/utils.mk
include vendor/statix/build/core/vendor/*.mk

# Conditionally call QCOM makefiles
ifeq ($(PRODUCT_USES_QCOM_HARDWARE), true)
include vendor/statix/build/core/ProductConfigQcom.mk
endif

# Define some properties for GMS
ifneq ($(TARGET_DOES_NOT_USE_GAPPS), true)
$(call inherit-product-if-exists, vendor/gms/products/gms.mk)
# Anything including updatable_apex.mk should have done so by now.
ifeq ($(TARGET_FLATTEN_APEX), false)
$(call inherit-product-if-exists, vendor/partner_modules/build/mainline_modules.mk)
else
$(call inherit-product-if-exists, vendor/partner_modules/build/mainline_modules_flatten_apex.mk)
endif
# Enable certified props overlay
PRODUCT_COPY_FILES += \
    vendor/statix/prebuilt/etc/overlay/config-system_ext.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/overlay/config/config.xml
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    keyguard.no_require_sim=true \
    dalvik.vm.debug.alloc=0 \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.error.receiver.system.apps=com.google.android.gms \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dataroaming=false \
    ro.atrace.core.services=com.google.android.gms,com.google.android.gms.ui,com.google.android.gms.persistent \
    ro.com.android.dateformat=MM-dd-yyyy \
    persist.sys.disable_rescue=true \
    ro.build.selinux=1

# Conditionally enable blur
ifeq ($(TARGET_USES_BLUR), true)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.sf.blurs_are_expensive=1 \
    ro.surface_flinger.supports_background_blur=1
endif

# Make some features conditional
ifeq ($(ENABLE_GAMETOOLS), true)
PRODUCT_COPY_FILES += \
    vendor/statix/prebuilt/etc/sysconfig/game_service.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/game_service.xml
endif
ifneq ($(DISABLE_COLUMBUS), true)
PRODUCT_COPY_FILES += \
    vendor/statix/prebuilt/etc/sysconfig/quick_tap.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/quick_tap.xml
endif

# Enable support of one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode?=true

# Copy over some StatiX assets
PRODUCT_COPY_FILES += \
    vendor/statix/prebuilt/etc/init.statix.rc:system/etc/init/init.statix.rc \
    vendor/statix/prebuilt/etc/permissions/privapp-permissions-statix-product.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-statix-product.xml \
    vendor/statix/prebuilt/etc/permissions/privapp-permissions-statix-se.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-statix-se.xml

# Compile SystemUI on device with `speed`.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.systemuicompilerfilter=speed

# Face Unlock
TARGET_FACE_UNLOCK_SUPPORTED ?= $(TARGET_SUPPORTS_64_BIT_APPS)

ifeq ($(TARGET_FACE_UNLOCK_SUPPORTED),true)
PRODUCT_PACKAGES += \
    ParanoidSense

PRODUCT_SYSTEM_EXT_PROPERTIES += \
    ro.face.sense_service=true

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml
endif

# Packages
include vendor/statix/config/packages.mk

# Branding
include vendor/statix/config/branding.mk

# Bootanimation
include vendor/statix/config/bootanimation.mk

# Fonts
include vendor/statix/config/fonts.mk

# Overlays
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/statix/overlay
DEVICE_PACKAGE_OVERLAYS += vendor/statix/overlay/common

# Artifact path requirements
PRODUCT_ARTIFACT_PATH_REQUIREMENT_ALLOWED_LIST += \
    system/etc/pvmfw.bin \
    system/etc/init/init.statix.rc \
    system/lib/libRSSupport.so \
    system/lib/libblasV8.so \
    system/lib/librsjni.so \
    system/lib64/libRSSupport.so \
    system/lib64/libblasV8.so \
    system/lib64/librsjni.so

# Enable Compose in SystemUI by default.
SYSTEMUI_USE_COMPOSE ?= true

# Flags
ifeq ($(TARGET_BUILD_VARIANT), user)
    PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false
    PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true
    PRODUCT_SYSTEM_SERVER_DEBUG_INFO := false
    WITH_DEXPREOPT_DEBUG_INFO := false
endif
