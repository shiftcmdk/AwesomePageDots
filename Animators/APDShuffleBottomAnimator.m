#import "APDShuffleBottomAnimator.h"

@implementation APDShuffleBottomAnimator

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

    CGFloat factor = -1.0;

    CGFloat x = currentX + radius + radius * cos(M_PI + factor * [percentage floatValue] * M_PI);
    CGFloat y = currentY + radius * sin(M_PI + factor * [percentage floatValue] * M_PI);

    CGFloat nextX = currentX + radius + radius * cos(2.0 * M_PI + factor * [percentage floatValue] * M_PI);
    CGFloat nextY = currentY + radius * sin(2.0 * M_PI + factor * [percentage floatValue] * M_PI);

    nextFakeIndicator.frame = CGRectMake(
        nextX,
        nextY,
        nextFakeIndicator.frame.size.width,
        nextFakeIndicator.frame.size.height
    );

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