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

@interface GamePositionalViewController ()

@property (nonatomic, strong) IBOutlet GameFieldView* fieldView;

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
    __typeof(self) __weak weakSelf = self;
    self.fieldView.positionTappedBlock = ^(EventPosition* position) {
        [weakSelf showActionView:YES];
    };
    [self showActionView: NO];

}

#pragma mark - Superclass Overrides

- (void)configureForOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {

    } else {

    }
}

-(void)configureActionView {
    // add the action view
    NSString* actionViewNib = @"GameActionView_positional";
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:actionViewNib owner:self options:nil];
    UIView* actionView = (UIView*)nibViews[0];
    [self.actionSubView addSubview:actionView];
    actionView.backgroundColor = [ColorMaster actionBackgroundColor];
}

#pragma mark - Miscellaneous

- (void)showActionView: (BOOL)show {
    // todo...position relative to current event
    
    self.actionSubView.visible = show;
    
}

@end
