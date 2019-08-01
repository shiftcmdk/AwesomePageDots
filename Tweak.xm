@interface SBIconListPageControl : UIPageControl

@property (nonatomic, retain) UIColor *fakeColor;
@property (nonatomic, retain) UIView *fakeView;
@property (nonatomic, assign) BOOL fakeSetTintColor;
@property (nonatomic, assign) BOOL inFolder;
@property (nonatomic, assign) NSInteger currentPageValue;
@property (nonatomic, retain) NSNumber *percentage;
-(void)didScroll:(UIScrollView *)scrollView;
-(void)setFakeViewFrame;

@end

@interface SBFolderView : UIView

@property (nonatomic,retain) SBIconListPageControl * pageControl;

@end

@interface SBRootFolderView : SBFolderView
@end

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

-(id)initWithFrame:(CGRect)arg1 {
	SBIconListPageControl *original = %orig;

	original.fakeSetTintColor = NO;
	original.currentPageValue = -1;
	original.percentage = [NSNumber numberWithFloat:0.0];
	original.inFolder = NO;

	return original;
}

%new
-(void)setFakeViewFrame {
	if (!self.fakeView) {
		self.fakeView = [[[UIView alloc] init] autorelease];

		[self addSubview:self.fakeView];
	}

	NSArray *indicators = [self valueForKey:@"_indicators"];

	UIUserInterfaceLayoutDirection direction = [UIApplication sharedApplication].userInterfaceLayoutDirection;

    BOOL isRightToLeft = direction == UIUserInterfaceLayoutDirectionRightToLeft;

	if (self.currentPageValue == -1) {
		self.currentPageValue = self.currentPage;
	}

	UIView *currentIndicatorView = indicators[isRightToLeft ? MAX(0, self.numberOfPages - self.currentPageValue - 1) : self.currentPageValue];

	if (self.currentPageValue >= 0 && self.currentPageValue < self.numberOfPages - 1) {
		UIView *nextIndicatorView = indicators[isRightToLeft ? self.numberOfPages - self.currentPageValue - 2 : self.currentPageValue + 1];

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
	} else if (self.currentPageValue == self.numberOfPages - 1) {
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

	self.percentage = [NSNumber numberWithFloat:offsetInPage / width];

	[self setFakeViewFrame];
}

-(void)layoutSubviews {
	%orig;

	[self setFakeViewFrame];
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

-(void)dealloc {
	self.fakeColor = nil;

	[self.fakeView removeFromSuperview];

	self.fakeView = nil;

	self.percentage = nil;

	%orig;
}

%end
