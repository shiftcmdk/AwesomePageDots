#import "AwesomePageDots.h"

APDAnimation selectedAnimation = APDAnimationDash;
BOOL moveUp = NO;

%hook SBFolderView

-(void)scrollViewDidScroll:(UIScrollView *)arg1 {
    %orig;

    [self.pageControl didScroll:arg1];
}

-(void)_updatePageControlToIndex:(long long)arg1 {
    self.pageControl.inFolder = ![self isKindOfClass:[%c(SBRootFolderView) class]];

    %orig;
}

%end

%hook SBIconListPageControl

%property (nonatomic, retain) UIColor *fakeColor;
%property (nonatomic, retain) UIView *fakeView;
%property (nonatomic, assign) BOOL fakeSetTintColor;
%property (nonatomic, assign) NSInteger currentPageValue;
%property (nonatomic, retain) NSNumber *percentage;
%property (nonatomic, assign) BOOL inFolder;
%property (nonatomic, assign) BOOL setIdentity;
%property (nonatomic, retain) NSMutableArray *fakeIndicators;
%property (nonatomic, retain) NSDictionary *animators;

-(id)initWithFrame:(CGRect)arg1 {
    SBIconListPageControl *original = %orig;

    original.fakeSetTintColor = NO;
    original.currentPageValue = -1;
    original.percentage = [NSNumber numberWithFloat:0.0];
    original.inFolder = NO;
    original.setIdentity = NO;
    original.animators = @{
        [NSNumber numberWithInt:APDAnimationDash]: [APDDashAnimator class],
        [NSNumber numberWithInt:APDAnimationSwap]: [APDSwapAnimator class],
        [NSNumber numberWithInt:APDAnimationShuffle]: [APDShuffleAnimator class],
        [NSNumber numberWithInt:APDAnimationShuffleTop]: [APDShuffleTopAnimator class],
        [NSNumber numberWithInt:APDAnimationShuffleBottom]: [APDShuffleBottomAnimator class],
        [NSNumber numberWithInt:APDAnimationFollow]: [APDFollowAnimator class],
        [NSNumber numberWithInt:APDAnimationFade]: [APDFadeAnimator class],
        [NSNumber numberWithInt:APDAnimationJump]: [APDJumpAnimator class]
    };

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveUpChanged:) name:@"AwesomePageDotsMoveUpChanged" object:nil];

    return original;
}

%new
-(void)moveUpChanged:(NSNotification *)notification {
    self.transform = CGAffineTransformIdentity;
}

%new
-(void)positionFakeIndicators {
    NSArray<UIView *> *indicators;

    UIView *theRealContentView = [[[UIView alloc] init] autorelease];

    if (@available(iOS 14, *)) {
        NSMutableArray *indicatorSubviews = [NSMutableArray array];

        NSArray<UIView *> *possibleContentContainer = self.subviews[0].subviews;

        for (UIView *aView in possibleContentContainer) {
            if ([aView isKindOfClass:NSClassFromString(@"_UIPageControlIndicatorContentView")]) {
                theRealContentView = aView;

                for (UIView *indicatorView in aView.subviews) {
                    if ([indicatorView isKindOfClass:NSClassFromString(@"_UIPageIndicatorView")]) {
                        [indicatorSubviews addObject:indicatorView];
                    }
                }
            }
        }

        indicators = indicatorSubviews;
    } else {
        indicators = [self valueForKey:@"_indicators"];
    }

    UIUserInterfaceLayoutDirection direction = [UIApplication sharedApplication].userInterfaceLayoutDirection;
    
    BOOL isRightToLeft = direction == UIUserInterfaceLayoutDirectionRightToLeft;

    UIEdgeInsets realInsets = UIEdgeInsetsZero;

    if (indicators.count > 0) {
        realInsets = [self calculateRealInsets:indicators[0]];
    }

    BOOL needsAll = indicators.count == self.fakeIndicators.count;

    for (int i = 0; i < indicators.count; i++) {
        int fakeIndex = 0;

        if (needsAll) {
            fakeIndex = i;
        } else {
            fakeIndex = i < self.currentPageValue ? i : i - 1;
        }

        if (needsAll || i != self.currentPageValue) {
            self.fakeIndicators[fakeIndex].frame = UIEdgeInsetsInsetRect(indicators[isRightToLeft ? self.numberOfPages - i - 1 : i].frame, realInsets);
            self.fakeIndicators[fakeIndex].layer.cornerRadius = self.fakeIndicators[fakeIndex].bounds.size.height / 2.0;
            self.fakeIndicators[fakeIndex].backgroundColor = [self pageIndicatorTintColor];

            if (!self.fakeIndicators[fakeIndex].superview) {
                [indicators[i].superview addSubview:self.fakeIndicators[fakeIndex]];
            }

            self.fakeIndicators[fakeIndex].alpha = 1.0;
        }

        if (!self.fakeView.superview) {
            [indicators[i].superview addSubview:self.fakeView];
        }

        indicators[i].alpha = 0.0;
    }
}

%new
-(UIEdgeInsets)calculateRealInsets:(UIView *)indicator {
    if (@available(iOS 14, *)) {
        UIEdgeInsets insets = ((UIImage *)[indicator valueForKey:@"image"])._contentInsets;
        CGRect indicatorFrame = UIEdgeInsetsInsetRect(indicator.frame, insets);
        CGFloat indicatorWidth = MIN(indicatorFrame.size.width, indicatorFrame.size.height);
        indicatorWidth = 7.5;

        CGFloat horizontalInset = (indicator.frame.size.width - indicatorWidth) / 2.0;
        CGFloat verticalInset = (indicator.frame.size.height - indicatorWidth) / 2.0;

        UIEdgeInsets realInsets = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);

        return realInsets;
    }

    return UIEdgeInsetsZero;
}

%new
-(void)rebuildFakeIndicatorsIfNecessary:(BOOL)needsAll contentView:(UIView *)contentView indicators:(NSArray<UIView *> *)indicators insets:(UIEdgeInsets)insets {
    BOOL needsRebuild = !self.fakeIndicators || (needsAll && self.fakeIndicators.count < indicators.count) || (!needsAll && self.fakeIndicators.count >= indicators.count) || (!needsAll && self.fakeIndicators.count != indicators.count - 1);

    if (needsRebuild) {
        if (self.fakeIndicators) {
            for (UIView *indicator in self.fakeIndicators) {
                [indicator removeFromSuperview];
            }
        }

        self.fakeIndicators = [NSMutableArray array];

        int count = needsAll ? indicators.count : indicators.count - 1;

        for (int i = 0; i < count; i++) {
            UIView *indicator = indicators[i];

            UIView *fakeIndicator = [[[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(indicator.frame, insets)] autorelease];

            [contentView addSubview:fakeIndicator];

            [self.fakeIndicators addObject:fakeIndicator];
        }
    }
}

%new
-(void)setFakeViewFrame {
    NSArray<UIView *> *indicators;

    UIView *theRealContentView = self;

    if (@available(iOS 14, *)) {
        NSMutableArray *indicatorSubviews = [NSMutableArray array];

        NSArray<UIView *> *possibleContentContainer = self.subviews[0].subviews;

        for (UIView *aView in possibleContentContainer) {
            if ([aView isKindOfClass:NSClassFromString(@"_UIPageControlIndicatorContentView")]) {
                theRealContentView = aView;

                for (UIView *indicatorView in aView.subviews) {
                    if ([indicatorView isKindOfClass:NSClassFromString(@"_UIPageIndicatorView")]) {
                        [indicatorSubviews addObject:indicatorView];
                    }
                }
            }
        }
        indicators = indicatorSubviews;
    } else {
        indicators = [self valueForKey:@"_indicators"];
    }

    if (!indicators || indicators.count == 0) {
        return;
    }

    UIEdgeInsets realInsets = [self calculateRealInsets:indicators[0]];

    id<APDAnimator> animator = [self.animators objectForKey:[NSNumber numberWithInt:selectedAnimation]];

    if (!animator) {
        animator = [APDDashAnimator class];
    }

    [self rebuildFakeIndicatorsIfNecessary:[animator needsAllPageDots] contentView:theRealContentView indicators:indicators insets:realInsets];

    if (self.currentPageValue == -1 || self.currentPageValue >= indicators.count) {
        self.currentPageValue = MIN(self.currentPage, indicators.count - 1);
    }

    if (!self.fakeView) {
        self.fakeView = [[[UIView alloc] init] autorelease];

        [theRealContentView addSubview:self.fakeView];
    }

    UIUserInterfaceLayoutDirection direction = [UIApplication sharedApplication].userInterfaceLayoutDirection;
    
    BOOL isRightToLeft = direction == UIUserInterfaceLayoutDirectionRightToLeft;

    UIView *currentIndicatorView = indicators[isRightToLeft ? MAX(0, self.numberOfPages - self.currentPageValue - 1) : self.currentPageValue];

    if (self.currentPageValue >= 0 && self.currentPageValue < self.numberOfPages - 1) {
        UIView *nextIndicatorView = indicators[isRightToLeft ? self.numberOfPages - self.currentPageValue - 2 : self.currentPageValue + 1];

        [animator 
            animateWith:UIEdgeInsetsInsetRect(currentIndicatorView.frame, realInsets)  
            nextIndicatorView:UIEdgeInsetsInsetRect(nextIndicatorView.frame, realInsets) 
            position:^ {
                [self positionFakeIndicators];
            }
            percentage:self.percentage 
            fakeView:self.fakeView 
            currentPageValue:self.currentPageValue 
            fakeIndicators:self.fakeIndicators
        ];
    } else if (self.currentPageValue == self.numberOfPages - 1) {
        [self positionFakeIndicators];
        self.fakeView.frame = UIEdgeInsetsInsetRect(currentIndicatorView.frame, realInsets);
    }

    self.fakeView.backgroundColor = self.fakeColor;
    self.fakeView.layer.cornerRadius = self.fakeView.bounds.size.height / 2.0;

    self.fakeView.hidden = self.numberOfPages == 1 && self.inFolder;
}

%new
-(void)didScroll:(UIScrollView *)scrollView {
    CGFloat width = scrollView.bounds.size.width;

    self.currentPageValue = (int)(scrollView.contentOffset.x / width);

    CGFloat offsetInPage = scrollView.contentOffset.x - (CGFloat)self.currentPageValue * width;

    self.percentage = [NSNumber numberWithFloat:fmax(0.0, offsetInPage / width)];

    [self setFakeViewFrame];
}

-(void)layoutSubviews {
    %orig;

    [self setFakeViewFrame];
}

-(void)setFrame:(CGRect)frame {
    self.setIdentity = YES;

    self.transform = CGAffineTransformIdentity;

    %orig;

    self.setIdentity = NO;

    self.transform = CGAffineTransformIdentity;
}

-(void)setTransform:(CGAffineTransform)arg1 {
    if (moveUp && !self.setIdentity) {
        %orig(CGAffineTransformTranslate(arg1, 0.0, self.inFolder ? -6.0 : -3.0));
    } else {
        %orig;
    }
}

-(void)setCurrentPageIndicatorTintColor:(UIColor *)arg1 {
    if (self.fakeSetTintColor) {
        %orig;
    } else {
        self.fakeColor = arg1;

        self.fakeView.backgroundColor = self.fakeColor;

        %orig([UIColor clearColor]);
    }

    self.fakeSetTintColor = NO;
}

-(void)setPageIndicatorTintColor:(UIColor *)arg1 {
    %orig;

    self.fakeSetTintColor = YES;

    [self setCurrentPageIndicatorTintColor:arg1];
}

-(UIColor *)currentPageIndicatorTintColor {
    return self.pageIndicatorTintColor;
}

-(void)setNumberOfPages:(long long)arg1 {
    if (self.fakeIndicators) {
        for (UIView *indicator in self.fakeIndicators) {
            [indicator removeFromSuperview];
        }
    }

    self.fakeIndicators = nil;

    %orig;
}

-(void)dealloc {
    self.fakeColor = nil;

    [self.fakeView removeFromSuperview];

    self.fakeView = nil;

    self.percentage = nil;

    self.fakeIndicators = nil;

    self.animators = nil;

    %orig;
}

%end

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithSuiteName:@"com.shiftcmdk.awesomepagedotspreferences"] autorelease];

    selectedAnimation = (APDAnimation)[defaults integerForKey:@"animation"];
    moveUp = [defaults boolForKey:@"moveup"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"AwesomePageDotsMoveUpChanged" object:nil];
}

static void *observer = NULL;

%ctor {
    NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithSuiteName:@"com.shiftcmdk.awesomepagedotspreferences"] autorelease];

    selectedAnimation = (APDAnimation)[defaults integerForKey:@"animation"];
    moveUp = [defaults boolForKey:@"moveup"];

    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        &observer,
        notificationCallback,
        (CFStringRef)@"com.shiftcmdk.awesomepagedotspreferences.prefschanged",
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately
    );
}

%dtor {
    CFNotificationCenterRemoveObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        &observer,
        (CFStringRef)@"com.shiftcmdk.awesomepagedotspreferences.prefschanged",
        NULL
    );
}

