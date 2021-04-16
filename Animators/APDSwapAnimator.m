#import "APDSwapAnimator.h"

@implementation APDSwapAnimator

+(BOOL)needsAllPageDots {
    return NO;
}

+(void)animateWith:(CGRect)currentIndicatorView nextIndicatorView:(CGRect)nextIndicatorView position:(void (^)(void))position percentage:(NSNumber *)percentage fakeView:(UIView *)fakeView currentPageValue:(NSInteger)currentPageValue fakeIndicators:(NSArray *)fakeIndicators {
    position();

    UIView *nextFakeIndicator = fakeIndicators[currentPageValue];

    CGFloat currentX = currentIndicatorView.origin.x;

    CGFloat distance = nextIndicatorView.origin.x - currentX;
    
    nextFakeIndicator.frame = CGRectMake(
        nextIndicatorView.origin.x - [percentage floatValue] * distance,
        nextFakeIndicator.frame.origin.y,
        nextFakeIndicator.frame.size.width,
        nextFakeIndicator.frame.size.height
    );

    CGFloat indicatorWidth = currentIndicatorView.size.width;
    CGFloat indicatorHeight = currentIndicatorView.size.width;
    
    fakeView.frame = CGRectMake(
        currentIndicatorView.origin.x + [percentage floatValue] * distance,
        currentIndicatorView.origin.y,
        indicatorWidth,
        indicatorHeight
    );
}

@end