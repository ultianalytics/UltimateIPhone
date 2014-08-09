//
//  TeamsMasterDetailViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/8/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "TeamsMasterDetailViewController.h"
#import "UIViewController+Additions.h"
#import "TeamsViewController.h"
#import "TeamViewController.h"

@interface TeamsMasterDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *teamsListSubView;
@property (weak, nonatomic) IBOutlet UIView *teamDetailSubView;

@property (strong, nonatomic) TeamsViewController *teamsViewController;
@property (strong, nonatomic) TeamViewController *teamViewController;

@property (strong, nonatomic) UINavigationController *teamsNavController;
@property (strong, nonatomic) UINavigationController *teamNavController;

@end

@implementation TeamsMasterDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.teamsViewController = [[TeamsViewController alloc] init];
    self.teamViewController = [[TeamViewController alloc] init];
    self.teamsViewController.detailController = self.teamViewController;
    
    self.teamsViewController.edgesForExtendedLayout = UIRectEdgeNone;
    self.teamViewController.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.teamsNavController = [[UINavigationController alloc] initWithRootViewController:self.teamsViewController];
    self.teamNavController = [[UINavigationController alloc] initWithRootViewController:self.teamViewController];
    
    [self addChildViewController:self.teamsNavController inSubView:self.teamsListSubView];
    [self addChildViewController:self.teamNavController inSubView:self.teamDetailSubView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

@end
