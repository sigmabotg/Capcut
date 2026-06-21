ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CapCutPro
CapCutPro_FILES = Tweak.x
CapCutPro_CFLAGS = -fobjc-arc
CapCutPro_LAYOUT = layout

include $(THEOS_MAKE_PATH)/tweak.mk
