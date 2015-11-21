include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ConfiBrowse
ConfiBrowse_FILES = Tweak.xm
ConfiBrowse_FRAMEWORKS = Foundation LocalAuthentication UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSafari"
