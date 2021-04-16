#import "APDFadeAnimator.h"

@implementation APDFadeAnimator

+(BOOL)needsAllPageDots {
    return YES;
}

+(void)animateWith:(CGRect)currentIndicatorView nextIndicatorView:(CGRect)nextIndicatorView position:(void (^)(void))position percentage:(NSNumber *)percentage fakeView:(UIView *)fakeView currentPageValue:(NSInteger)currentPageValue fakeIndicators:(NSArray *)fakeIndicators {
    position();

    CGFloat indicatorWidth = currentIndicatorView.size.width;
    CGFloat indicatorHeight = currentIndicatorView.size.width;

    CGRect newFrame;

    if ([percentage floatValue] < 0.5) {
        CGFloat newWidthAndHeight = indicatorWidth - 2.0 * [percentage floatValue] * indicatorWidth;

        newFrame = CGRectMake(
            currentIndicatorView.origin.x + indicatorWidth / 2.0 - newWidthAndHeight / 2.0,
            currentIndicatorView.origin.y + indicatorHeight / 2.0 - newWidthAndHeight / 2.0,
            newWidthAndHeight,
            newWidthAndHeight
        );
    } else if ([percentage floatValue] > 0.5) {
        CGFloat newWidthAndHeight = 2.0 * ([percentage floatValue] - 0.5) * indicatorWidth;

        newFrame = CGRectMake(
            nextIndicatorView.origin.x + indicatorWidth / 2.0 - newWidthAndHeight / 2.0,
            nextIndicatorView.origin.y + indicatorHeight / 2.0 - newWidthAndHeight / 2.0,
            newWidthAndHeight,
            newWidthAndHeight
        );
    } else {
        newFrame = CGRectZero;
    }

    fakeView.frame = newFrame;
}

@end