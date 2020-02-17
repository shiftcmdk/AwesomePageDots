#import "APDAnimation.h"

@interface SBIconListPageControl : UIPageControl

@property (nonatomic, retain) UIColor *fakeColor;
@property (nonatomic, retain) UIView *fakeView;
@property (nonatomic, retain) NSMutableArray<UIView *> *fakeIndicators;
@property (nonatomic, assign) BOOL fakeSetTintColor;
@property (nonatomic, assign) BOOL inFolder;
@property (nonatomic, assign) BOOL setIdentity;
@property (nonatomic, assign) NSInteger currentPageValue;
@property (nonatomic, retain) NSNumber *percentage;
-(void)didScroll:(UIScrollView *)scrollView;
-(void)setFakeViewFrame;
-(void)hideFakeIndicators:(BOOL)hide;
-(void)dashAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView;
-(void)swapAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView;
-(void)shuffleAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView;
-(void)followAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView;
-(void)fadeAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView;
-(void)jumpAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView;

@end

@interface SBFolderView : UIView

@property (nonatomic,retain) SBIconListPageControl * pageControl;

@end

@interface SBRootFolderView : SBFolderView
@end

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

-(id)initWithFrame:(CGRect)arg1 {
    SBIconListPageControl *original = %orig;

    original.fakeSetTintColor = NO;
    original.currentPageValue = -1;
    original.percentage = [NSNumber numberWithFloat:0.0];
    original.inFolder = NO;
    original.setIdentity = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveUpChanged:) name:@"AwesomePageDotsMoveUpChanged" object:nil];

    return original;
}

%new
-(void)moveUpChanged:(NSNotification *)notification {
    self.transform = CGAffineTransformIdentity;
}

%new
-(void)hideFakeIndicators:(BOOL)hide {
    NSArray<UIView *> *indicators = [self valueForKey:@"_indicators"];

    UIUserInterfaceLayoutDirection direction = [UIApplication sharedApplication].userInterfaceLayoutDirection;
    
    BOOL isRightToLeft = direction == UIUserInterfaceLayoutDirectionRightToLeft;

    for (int i = 0; i < indicators.count; i++) {
        int fakeIndex = i < self.currentPageValue ? i : i - 1;

        if (i != self.currentPageValue) {
            self.fakeIndicators[fakeIndex].frame = indicators[isRightToLeft ? self.numberOfPages - i - 1 : i].frame;
            self.fakeIndicators[fakeIndex].layer.cornerRadius = self.fakeIndicators[fakeIndex].bounds.size.height / 2.0;
            self.fakeIndicators[fakeIndex].backgroundColor = [self pageIndicatorTintColor];
            self.fakeIndicators[fakeIndex].alpha = hide ? 0.0 : 1.0;
        }
        indicators[i].alpha = hide ? 1.0 : 0.0;
    }
}

%new
-(void)dashAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView {
    [self hideFakeIndicators:YES];

    CGFloat indicatorWidth = currentIndicatorView.frame.size.width;
    CGFloat indicatorHeight = currentIndicatorView.frame.size.width;

    CGFloat currentX = currentIndicatorView.frame.origin.x;
    CGFloat nextX = nextIndicatorView.frame.origin.x;

    CGFloat distance = nextIndicatorView.frame.origin.x - currentX;

    CGFloat dotX = currentIndicatorView.frame.origin.x + [self.percentage floatValue] * distance;
    CGFloat dotCenterX = dotX + indicatorWidth / 2.0;
    CGFloat stretchedX = dotCenterX - distance / 2.0;

    CGFloat newWidth;
    CGFloat newX;

    if ([self.percentage floatValue] < 0.5) {
        CGFloat cutOff = fmax(0.0, currentX - stretchedX) * 2.0;
        newWidth = distance - cutOff;
        newX = currentX + fmax(0.0, stretchedX - currentX);
    } else if ([self.percentage floatValue] > 0.5) {
        CGFloat cutOff = fmax(0.0, (stretchedX + distance) - (nextX + indicatorWidth)) * 2.0;
        newWidth = distance - cutOff;
        newX = stretchedX + cutOff / 2.0;
    } else {
        newWidth = distance;
        newX = stretchedX;
    }

    self.fakeView.frame = CGRectMake(
        newX,
        currentIndicatorView.frame.origin.y,
        fmax(newWidth, indicatorWidth),
        indicatorHeight
    );
}

%new
-(void)swapAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView {
    [self hideFakeIndicators:NO];

    UIView *nextFakeIndicator = self.fakeIndicators[self.currentPageValue];

    CGFloat currentX = currentIndicatorView.frame.origin.x;

    CGFloat distance = nextIndicatorView.frame.origin.x - currentX;
    
    nextFakeIndicator.frame = CGRectMake(
        nextIndicatorView.frame.origin.x - [self.percentage floatValue] * distance,
        nextFakeIndicator.frame.origin.y,
        nextFakeIndicator.frame.size.width,
        nextFakeIndicator.frame.size.height
    );

    CGFloat indicatorWidth = currentIndicatorView.frame.size.width;
    CGFloat indicatorHeight = currentIndicatorView.frame.size.width;
    
    self.fakeView.frame = CGRectMake(
        currentIndicatorView.frame.origin.x + [self.percentage floatValue] * distance,
        currentIndicatorView.frame.origin.y,
        indicatorWidth,
        indicatorHeight
    );
}

%new
-(void)shuffleAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView {
    [self hideFakeIndicators:NO];

    UIView *nextFakeIndicator = self.fakeIndicators[self.currentPageValue];

    CGFloat currentX = currentIndicatorView.frame.origin.x;
    CGFloat currentY = currentIndicatorView.frame.origin.y;

    CGFloat distance = nextIndicatorView.frame.origin.x - currentX;
    CGFloat radius = distance / 2.0;

    CGFloat factor;

    if (selectedAnimation == APDAnimationShuffleTop) {
        factor = 1.0;
    } else if (selectedAnimation == APDAnimationShuffleBottom) {
        factor = -1.0;
    } else {
        factor = self.currentPageValue % 2 == 0 ? 1.0 : -1.0;
    }

    CGFloat x = currentX + radius + radius * cos(M_PI + factor * [self.percentage floatValue] * M_PI);
    CGFloat y = currentY + radius * sin(M_PI + factor * [self.percentage floatValue] * M_PI);

    CGFloat nextX = currentX + radius + radius * cos(2.0 * M_PI + factor * [self.percentage floatValue] * M_PI);
    CGFloat nextY = currentY + radius * sin(2.0 * M_PI + factor * [self.percentage floatValue] * M_PI);

    nextFakeIndicator.frame = CGRectMake(
        nextX,
        nextY,
        nextFakeIndicator.frame.size.width,
        nextFakeIndicator.frame.size.height
    );

    CGFloat indicatorWidth = currentIndicatorView.frame.size.width;
    CGFloat indicatorHeight = currentIndicatorView.frame.size.width;

    self.fakeView.frame = CGRectMake(
        x,
        y,
        indicatorWidth,
        indicatorHeight
    );
}

%new
-(void)followAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView {
    [self hideFakeIndicators:YES];

    CGFloat currentX = currentIndicatorView.frame.origin.x;

    CGFloat distance = nextIndicatorView.frame.origin.x - currentX;

    CGFloat indicatorWidth = currentIndicatorView.frame.size.width;
    CGFloat indicatorHeight = currentIndicatorView.frame.size.width;
    
    self.fakeView.frame = CGRectMake(
        currentIndicatorView.frame.origin.x + [self.percentage floatValue] * distance,
        currentIndicatorView.frame.origin.y,
        indicatorWidth,
        indicatorHeight
    );
}

%new
-(void)fadeAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView {
    [self hideFakeIndicators:YES];

    CGFloat indicatorWidth = currentIndicatorView.frame.size.width;
    CGFloat indicatorHeight = currentIndicatorView.frame.size.width;

    CGRect newFrame;

    if ([self.percentage floatValue] < 0.5) {
        CGFloat newWidthAndHeight = indicatorWidth - 2.0 * [self.percentage floatValue] * indicatorWidth;

        newFrame = CGRectMake(
            currentIndicatorView.frame.origin.x + indicatorWidth / 2.0 - newWidthAndHeight / 2.0,
            currentIndicatorView.frame.origin.y + indicatorHeight / 2.0 - newWidthAndHeight / 2.0,
            newWidthAndHeight,
            newWidthAndHeight
        );
    } else if ([self.percentage floatValue] > 0.5) {
        CGFloat newWidthAndHeight = 2.0 * ([self.percentage floatValue] - 0.5) * indicatorWidth;

        newFrame = CGRectMake(
            nextIndicatorView.frame.origin.x + indicatorWidth / 2.0 - newWidthAndHeight / 2.0,
            nextIndicatorView.frame.origin.y + indicatorHeight / 2.0 - newWidthAndHeight / 2.0,
            newWidthAndHeight,
            newWidthAndHeight
        );
    } else {
        newFrame = CGRectZero;
    }

    self.fakeView.frame = newFrame;
}

%new
-(void)jumpAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView {
    [self hideFakeIndicators:NO];

    UIView *nextFakeIndicator = self.fakeIndicators[self.currentPageValue];

    CGFloat currentX = currentIndicatorView.frame.origin.x;
    CGFloat currentY = currentIndicatorView.frame.origin.y;

    CGFloat distance = nextIndicatorView.frame.origin.x - currentX;

    CGFloat radius = distance / 2.0;
    
    nextFakeIndicator.frame = CGRectMake(
        nextIndicatorView.frame.origin.x - [self.percentage floatValue] * distance,
        nextFakeIndicator.frame.origin.y,
        nextFakeIndicator.frame.size.width,
        nextFakeIndicator.frame.size.height
    );

    CGFloat x = currentX + radius + radius * cos(M_PI + [self.percentage floatValue] * M_PI);
    CGFloat y = currentY + radius * sin(M_PI + [self.percentage floatValue] * M_PI);

    CGFloat indicatorWidth = currentIndicatorView.frame.size.width;
    CGFloat indicatorHeight = currentIndicatorView.frame.size.width;

    self.fakeView.frame = CGRectMake(
        x,
        y,
        indicatorWidth,
        indicatorHeight
    );
}

%new
-(void)setFakeViewFrame {
    NSArray<UIView *> *indicators = [self valueForKey:@"_indicators"];

    if (!indicators || indicators.count == 0) {
        return;
    }

    if (!self.fakeIndicators) {
        self.fakeIndicators = [NSMutableArray array];

        for (int i = 0; i < indicators.count - 1; i++) {
            UIView *indicator = indicators[i];

            UIView *fakeIndicator = [[[UIView alloc] initWithFrame:indicator.frame] autorelease];

            [self addSubview:fakeIndicator];

            [self.fakeIndicators addObject:fakeIndicator];
        }
    }

    if (self.currentPageValue == -1 || self.currentPageValue >= indicators.count) {
        self.currentPageValue = self.currentPage;
    }

    if (!self.fakeView) {
        self.fakeView = [[[UIView alloc] init] autorelease];

        [self addSubview:self.fakeView];
    }

    UIUserInterfaceLayoutDirection direction = [UIApplication sharedApplication].userInterfaceLayoutDirection;
    
    BOOL isRightToLeft = direction == UIUserInterfaceLayoutDirectionRightToLeft;

    UIView *currentIndicatorView = indicators[isRightToLeft ? MAX(0, self.numberOfPages - self.currentPageValue - 1) : self.currentPageValue];

    if (self.currentPageValue >= 0 && self.currentPageValue < self.numberOfPages - 1) {
        UIView *nextIndicatorView = indicators[isRightToLeft ? self.numberOfPages - self.currentPageValue - 2 : self.currentPageValue + 1];

        switch (selectedAnimation) {
            case APDAnimationFade:
                [self fadeAnimation:currentIndicatorView nextIndicatorView:nextIndicatorView];
                break;
            case APDAnimationFollow:
                [self followAnimation:currentIndicatorView nextIndicatorView:nextIndicatorView];
                break;
            case APDAnimationJump:
                [self jumpAnimation:currentIndicatorView nextIndicatorView:nextIndicatorView];
                break;
            case APDAnimationShuffle:
                [self shuffleAnimation:currentIndicatorView nextIndicatorView:nextIndicatorView];
                break;
            case APDAnimationShuffleTop:
                [self shuffleAnimation:currentIndicatorView nextIndicatorView:nextIndicatorView];
                break;
            case APDAnimationShuffleBottom:
                [self shuffleAnimation:currentIndicatorView nextIndicatorView:nextIndicatorView];
                break;
            case APDAnimationSwap:
                [self swapAnimation:currentIndicatorView nextIndicatorView:nextIndicatorView];
                break;
            default:
                [self dashAnimation:currentIndicatorView nextIndicatorView:nextIndicatorView];
                break;
        }
    } else if (self.currentPageValue == self.numberOfPages - 1) {
        switch (selectedAnimation) {
            case APDAnimationFade:
            case APDAnimationFollow:
            case APDAnimationDash:
                [self hideFakeIndicators:YES];
                break;
            default:
                [self hideFakeIndicators:NO];
                break;
        }
        self.fakeView.frame = currentIndicatorView.frame;
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

