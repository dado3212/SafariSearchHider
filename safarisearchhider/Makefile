ARCHS = armv7 arm64 arm64e

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
