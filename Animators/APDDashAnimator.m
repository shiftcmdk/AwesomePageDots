#import "APDDashAnimator.h"

@implementation APDDashAnimator

+(BOOL)needsAllPageDots {
    return YES;
}

+(void)animateWith:(CGRect)currentIndicatorView nextIndicatorView:(CGRect)nextIndicatorView position:(void (^)(void))position percentage:(NSNumber *)percentage fakeView:(UIView *)fakeView currentPageValue:(NSInteger)currentPageValue fakeIndicators:(NSArray *)fakeIndicators {
    position();

    CGFloat indicatorWidth = currentIndicatorView.size.width;
    CGFloat indicatorHeight = currentIndicatorView.size.width;

    CGFloat currentX = currentIndicatorView.origin.x;
    CGFloat nextX = nextIndicatorView.origin.x;

    CGFloat distance = nextIndicatorView.origin.x - currentX;

    CGFloat dotX = currentIndicatorView.origin.x + [percentage floatValue] * distance;
    CGFloat dotCenterX = dotX + indicatorWidth / 2.0;
    CGFloat stretchedX = dotCenterX - distance / 2.0;

    CGFloat newWidth;
    CGFloat newX;

    if ([percentage floatValue] < 0.5) {
        CGFloat cutOff = fmax(0.0, currentX - stretchedX) * 2.0;
        newWidth = distance - cutOff;
        newX = currentX + fmax(0.0, stretchedX - currentX);
    } else if ([percentage floatValue] > 0.5) {
        CGFloat cutOff = fmax(0.0, (stretchedX + distance) - (nextX + indicatorWidth)) * 2.0;
        newWidth = distance - cutOff;
        newX = stretchedX + cutOff / 2.0;
    } else {
        newWidth = distance;
        newX = stretchedX;
    }

    fakeView.frame = CGRectMake(
        newX,
        currentIndicatorView.origin.y,
        fmax(newWidth, indicatorWidth),
        indicatorHeight
    );
}

@end