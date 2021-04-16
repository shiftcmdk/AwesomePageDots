#import <UIKit/UIKit.h>

@protocol APDAnimator

+(BOOL)needsAllPageDots;
+(void)animateWith:(CGRect)currentIndicatorView nextIndicatorView:(CGRect)nextIndicatorView position:(void (^)(void))position percentage:(NSNumber *)percentage fakeView:(UIView *)fakeView currentPageValue:(NSInteger)currentPageValue fakeIndicators:(NSArray *)fakeIndicators;

@end