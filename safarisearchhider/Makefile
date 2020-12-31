# Dropped armv7 for 10.3 SDK :/
ARCHS = arm64 arm64e

# SDKVERSION = 10.2
# SYSROOT = theos/sdks/iPhoneOS10.2.sdk

# Different version because my build env is messed up
TARGET=iphone:10.3

FINALPACKAGE = 1
# Uncomment this for NSLogs (maybe)
# FINALPACKAGE = 0
# DEBUG = 1

include theos/makefiles/common.mk

BUNDLE_NAME = SafariSearchHider
SafariSearchHider_FILES = SafariSearchHider.mm
SafariSearchHider_INSTALL_PATH = /Library/PreferenceBundles
SafariSearchHider_FRAMEWORKS = UIKit
SafariSearchHider_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SafariSearchHider.plist$(ECHO_END)
