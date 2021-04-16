#import "APDFollowAnimator.h"

@implementation APDFollowAnimator

+(BOOL)needsAllPageDots {
    return YES;
}

+(void)animateWith:(CGRect)currentIndicatorView nextIndicatorView:(CGRect)nextIndicatorView position:(void (^)(void))position percentage:(NSNumber *)percentage fakeView:(UIView *)fakeView currentPageValue:(NSInteger)currentPageValue fakeIndicators:(NSArray *)fakeIndicators {
    position();

    CGFloat currentX = currentIndicatorView.origin.x;

    CGFloat distance = nextIndicatorView.origin.x - currentX;

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