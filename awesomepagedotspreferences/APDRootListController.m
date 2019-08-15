#include "APDRootListController.h"
#import "../APDAnimation.h"

@interface APDRootListController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, retain) NSArray<NSNumber *> *animations;
-(NSString *)stringFromAnimation:(APDAnimation)animation;

@end

@implementation APDRootListController

-(id)init {
    if (self = [super init]) {
        self.navigationItem.title = @"AwesomePageDots";
    }

    return self;
}

-(NSString *)stringFromAnimation:(APDAnimation)animation {
    switch (animation) {
        case APDAnimationFade:
            return @"Fade";
        case APDAnimationFollow:
            return @"Follow";
        case APDAnimationJump:
            return @"Jump";
        case APDAnimationShuffle:
            return @"Shuffle";
        case APDAnimationShuffleTop:
            return @"Shuffle (Top)";
        case APDAnimationShuffleBottom:
            return @"Shuffle (Bottom)";
        case APDAnimationSwap:
            return @"Swap";
        default:
            return @"Dash";
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.view addSubview:self.tableView];

    self.animations = @[
        @(APDAnimationDash), 
        @(APDAnimationFade), 
        @(APDAnimationFollow), 
        @(APDAnimationJump), 
        @(APDAnimationShuffle), 
        @(APDAnimationShuffleTop), 
        @(APDAnimationShuffleBottom), 
        @(APDAnimationSwap)
    ];

    NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithSuiteName:@"com.shiftcmdk.awesomepagedotspreferences"] autorelease];

    self.selectedIndexPath = [NSIndexPath indexPathForRow:[defaults integerForKey:@"animation"] inSection:0];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AnimationCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MovePageDotsCell"];

    self.navigationItem.title = @"AwesomePageDots";
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.tableView.frame = self.view.bounds;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.animations.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnimationCell" forIndexPath:indexPath];

        cell.textLabel.text = [self stringFromAnimation:[self.animations[indexPath.row] intValue]];

        cell.accessoryType = self.selectedIndexPath == indexPath ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovePageDotsCell" forIndexPath:indexPath];

        cell.textLabel.text = @"Move Page Dots Up";

        UISwitch *switchView = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

        NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithSuiteName:@"com.shiftcmdk.awesomepagedotspreferences"] autorelease];

        switchView.on = [defaults objectForKey:@"moveup"] != nil && [defaults boolForKey:@"moveup"];

        cell.accessoryView = switchView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [tableView cellForRowAtIndexPath:self.selectedIndexPath].accessoryType = UITableViewCellAccessoryNone;

        self.selectedIndexPath = indexPath;

        [tableView cellForRowAtIndexPath:self.selectedIndexPath].accessoryType = UITableViewCellAccessoryCheckmark;

        NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithSuiteName:@"com.shiftcmdk.awesomepagedotspreferences"] autorelease];

        [defaults setInteger:[self.animations[indexPath.row] intValue] forKey:@"animation"];

        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(), 
            (CFStringRef)@"com.shiftcmdk.awesomepagedotspreferences.prefschanged", 
            NULL, 
            NULL, 
            YES
        );

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Animations";
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return @"Move the page dots up a bit to give the animations more space and avoid clipping.";
    }
    return nil;
}

-(void)switchChanged:(UISwitch *)sender {
    NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithSuiteName:@"com.shiftcmdk.awesomepagedotspreferences"] autorelease];

    [defaults setBool:sender.on forKey:@"moveup"];

    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(), 
        (CFStringRef)@"com.shiftcmdk.awesomepagedotspreferences.prefschanged", 
        NULL, 
        NULL, 
        YES
    );
}

-(void)dealloc {
    [self.tableView removeFromSuperview];

    self.tableView = nil;

    self.selectedIndexPath = nil;

    self.animations = nil;

    [super dealloc];
}

@end

