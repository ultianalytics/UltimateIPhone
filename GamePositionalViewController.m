//
//  GamePositionalViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/22/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GamePositionalViewController.h"
#import "GameFieldViewController.h"
#import "UIViewController+Additions.h"
#import "UIView+Convenience.h"

@interface GamePositionalViewController ()

@property (nonatomic, weak) IBOutlet UIView *fieldSubView;
@property (nonatomic, strong) GameFieldViewController* fieldViewController;

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
    self.fieldViewController = [[GameFieldViewController alloc] init];
    [self addChildViewController:self.fieldViewController inSubView:self.fieldSubView];
    [self showActionView:NO];
}

#pragma mark - Superclass Overrides

- (void)configureForOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {

    } else {

    }
}

#pragma mark - Drawing field

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [super drawLayer:layer inContext:ctx];
    // TODO-DO draw the field lines
}

#pragma mark - Miscellaneous

- (void)showActionView: (BOOL)show {
    // todo...position relative to current event
    
    self.actionSubView.visible = show;
    
}

@end
