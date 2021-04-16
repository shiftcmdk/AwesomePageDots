ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AwesomePageDots

AwesomePageDots_FRAMEWORKS = UIKit CoreGraphics

AwesomePageDots_FILES = Tweak.xm Animators/APDDashAnimator.m Animators/APDSwapAnimator.m Animators/APDShuffleTopAnimator.m Animators/APDShuffleBottomAnimator.m Animators/APDShuffleAnimator.m Animators/APDFollowAnimator.m Animators/APDFadeAnimator.m Animators/APDJumpAnimator.m

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += awesomepagedotspreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
