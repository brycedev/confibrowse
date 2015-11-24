include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ConfiBrowse
ConfiBrowse_FILES = ConfiBrowse.xm
ConfiBrowse_FRAMEWORKS = Foundation LocalAuthentication UIKit
ConfiBrowse_PRIVATE_FRAMEWORKS = WebUI

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSafari; killall -9 Preferences; killall -9 SpringBoard"
SUBPROJECTS += confibrowse
include $(THEOS_MAKE_PATH)/aggregate.mk
