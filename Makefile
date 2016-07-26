export THEOS_DEVICE_IP=192.168.178.98
export GO_EASY_ON_ME=1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Rescale
Rescale_FILES = RescaleRootListController.m RescaleCustomListController.m
Rescale_INSTALL_PATH = /Library/PreferenceBundles
Rescale_FRAMEWORKS = UIKit
Rescale_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Rescale.plist$(ECHO_END)

after-install::
	install.exec "killall -9 Preferences"