//
//  GamePositionalViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/22/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GamePositionalViewController.h"
#import "UIViewController+Additions.h"
#import "UIView+Convenience.h"
#import "GameFieldView.h"
#import "ColorMaster.h"

#define kActionViewMargin 20;

@interface GamePositionalViewController ()

@property (nonatomic, strong) IBOutlet GameFieldView* fieldView;
@property (nonatomic, strong) IBOutlet UIView* actionViewContainer;
@property (nonatomic, strong) IBOutlet UIView* topViewOverlay;
@property (nonatomic, strong) IBOutlet UIView* bottomViewOverlay;
@property (nonatomic, strong) IBOutlet UIButton* cancelButton;

@end

@implementation GamePositionalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

#pragma mark - Lifecycle 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    __typeof(self) __weak weakSelf = self;
    self.fieldView.positionTappedBlock = ^(EventPosition* position, CGPoint fieldPoint) {
        [weakSelf showActionViewForPoint:[weakSelf.fieldView convertPoint:fieldPoint toView:weakSelf.view]];
    };
    [self hideActionView];
}

#pragma mark - Superclass Overrides

- (void)configureForOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {

    } else {

    }
}

-(void)eventActionSelected {
    [self hideActionView];
}

-(CGFloat)throwawayButtonOffsetOnDefense {
    return -100.0;
}

-(void)configureActionView {
    // add the action view
    NSString* actionViewNib = @"GameActionView_positional";
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:actionViewNib owner:self options:nil];
    UIView* actionView = (UIView*)nibViews[0];
    [self.actionSubView addSubview:actionView];
    actionView.backgroundColor = [ColorMaster actionBackgroundColor];
}

#pragma mark - Event Handlers

- (IBAction)cancelButtonTapped:(id)sender {
    [self hideActionView];
}

#pragma mark - Miscellaneous

- (void)showActionViewForPoint: (CGPoint) eventPoint {
    self.actionViewContainer.center = self.fieldView.center;  // center vertically in the field view
    if (eventPoint.x != 0 && eventPoint.y != 0) {
        BOOL isLeft = eventPoint.x < (self.view.boundsWidth / 2.0f);
        CGFloat distanceFromPointToActionView = 40;
        CGFloat x;
        if (isLeft) {
            x = eventPoint.x + distanceFromPointToActionView;
        } else {
            x = eventPoint.x - self.actionViewContainer.frameWidth - distanceFromPointToActionView;
        }
        self.actionViewContainer.frameX = x;
    }
    
    self.topViewOverlay.visible = YES;
    self.bottomViewOverlay.visible = YES;
    self.actionViewContainer.visible = YES;
}

- (void)hideActionView {
    self.topViewOverlay.hidden = YES;
    self.bottomViewOverlay.hidden = YES;
    self.actionViewContainer.hidden = YES;
}

@end
