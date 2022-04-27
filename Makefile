# The SDK and iOS version to target. This is specifying the iOS 14.4 SDK and minimum build target as iOS 14.0
TARGET = iphone:14.4:14.0
# The archiectures to compile for, arm64 is fine for most apps
ARCHS = arm64

# The name of the process to kill upon install, the name of your app
INSTALL_TARGET_PROCESSES = debloader

include $(THEOS)/makefiles/common.mk
# The name of your Xcode project/workspace
XCODEPROJ_NAME = DebLoader
# The scheme of your app to compile 
DebLoader_XCODE_SCHEME = DebLoader
# The ldid flag to sign your app with, we will make this next
DebLoader_CODESIGN_FLAGS = -SdebloaderEntitlements.xml

include $(THEOS_MAKE_PATH)/xcodeproj.mk