TARGET := iphone:clang:16.5:16.0
ARCHS = arm64e
INSTALL_TARGET_PROCESSES = SpringBoard
THEOS_PACKAGE_SCHEME = rootless
TWEAK_NAME = TouchXSQInterfaceProbe
TouchXSQInterfaceProbe_FILES = Tweak.xm
TouchXSQInterfaceProbe_CFLAGS = -fobjc-arc
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
