include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ConfiBrowse
ConfiBrowse_FILES = ConfiRootListController.m
ConfiBrowse_INSTALL_PATH = /Library/PreferenceBundles
ConfiBrowse_FRAMEWORKS = LocalAuthentication MessageUI UIKit
ConfiBrowse_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ConfiBrowse.plist$(ECHO_END)
