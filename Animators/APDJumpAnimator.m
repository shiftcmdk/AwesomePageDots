#import "APDJumpAnimator.h"

@implementation APDJumpAnimator

+(BOOL)needsAllPageDots {
    return NO;
}

+(void)animateWith:(CGRect)currentIndicatorView nextIndicatorView:(CGRect)nextIndicatorView position:(void (^)(void))position percentage:(NSNumber *)percentage fakeView:(UIView *)fakeView currentPageValue:(NSInteger)currentPageValue fakeIndicators:(NSArray *)fakeIndicators {
    position();

    UIView *nextFakeIndicator = fakeIndicators[currentPageValue];

    CGFloat currentX = currentIndicatorView.origin.x;
    CGFloat currentY = currentIndicatorView.origin.y;

    CGFloat distance = nextIndicatorView.origin.x - currentX;

    CGFloat radius = distance / 2.0;
    
    nextFakeIndicator.frame = CGRectMake(
        nextIndicatorView.origin.x - [percentage floatValue] * distance,
        nextFakeIndicator.frame.origin.y,
        nextFakeIndicator.frame.size.width,
        nextFakeIndicator.frame.size.height
    );

    CGFloat x = currentX + radius + radius * cos(M_PI + [percentage floatValue] * M_PI);
    CGFloat y = currentY + radius * sin(M_PI + [percentage floatValue] * M_PI);

    CGFloat indicatorWidth = currentIndicatorView.size.width;
    CGFloat indicatorHeight = currentIndicatorView.size.width;

    fakeView.frame = CGRectMake(
        x,
        y,
        indicatorWidth,
        indicatorHeight
    );
}

@end