ARCHS = armv7 armv7s arm64

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

FINALPACKAGE = 0
# DEBUG = 1

# SDKVERSION = 10.2
# TARGET = iphone:10.2
# TARGET_IPHONEOS_DEPLOYMENT_VERSION = 10.2

include theos/makefiles/common.mk

ADDITIONAL_CFLAGS = -Wno-unused-function -Wno-unused-variable

TWEAK_NAME = SafariSearchHider
SafariSearchHider_FILES = Tweak.xm
SafariSearchHider_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += safarisearchhider
include $(THEOS_MAKE_PATH)/aggregate.mk
