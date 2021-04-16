#import "APDAnimation.h"
#import "Animators/APDAnimators.h"

#import <UIKit/UIKit.h>

@interface SBIconListPageControl : UIPageControl

@property (nonatomic, retain) UIColor *fakeColor;
@property (nonatomic, retain) UIView *fakeView;
@property (nonatomic, retain) NSMutableArray<UIView *> *fakeIndicators;
@property (nonatomic, assign) BOOL fakeSetTintColor;
@property (nonatomic, assign) BOOL inFolder;
@property (nonatomic, assign) BOOL setIdentity;
@property (nonatomic, assign) NSInteger currentPageValue;
@property (nonatomic, retain) NSNumber *percentage;
@property (nonatomic, retain) NSDictionary<NSNumber *, id<APDAnimator>> *animators;
-(void)didScroll:(UIScrollView *)scrollView;
-(void)setFakeViewFrame;
-(void)positionFakeIndicators;
-(void)jumpAnimation:(UIView *)currentIndicatorView nextIndicatorView:(UIView *)nextIndicatorView;
-(UIEdgeInsets)calculateRealInsets:(UIView *)indicator;
-(void)rebuildFakeIndicatorsIfNecessary:(BOOL)needsAll contentView:(UIView *)contentView indicators:(NSArray<UIView *> *)indicators insets:(UIEdgeInsets)insets;

@end

@interface SBFolderView : UIView

@property (nonatomic,retain) SBIconListPageControl * pageControl;

@end

@interface SBRootFolderView : SBFolderView
@end

@interface UIImage ()

@property (nonatomic,readonly) UIEdgeInsets _contentInsets; 

@end