//
//  PlayersMasterDetailViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/8/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "PlayersMasterDetailViewController.h"
#import "UIViewController+Additions.h"
#import "TeamPlayersViewController.h"
#import "PlayerDetailsViewController.h"

@interface PlayersMasterDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *playersListSubView;
@property (weak, nonatomic) IBOutlet UIView *playerDetailSubView;

@property (strong, nonatomic) TeamPlayersViewController *playersViewController;
@property (strong, nonatomic) PlayerDetailsViewController *playerViewController;

@property (strong, nonatomic) UINavigationController *playersNavController;
@property (strong, nonatomic) UINavigationController *playerNavController;

@end

@implementation PlayersMasterDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.playersViewController = [[TeamPlayersViewController alloc] init];
    self.playerViewController = [[PlayerDetailsViewController alloc] init];
    self.playersViewController.detailsViewController = self.playerViewController;
    
    self.playersViewController.edgesForExtendedLayout = UIRectEdgeNone;
    self.playerViewController.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.playersNavController = [[UINavigationController alloc] initWithRootViewController:self.playersViewController];
    self.playerNavController = [[UINavigationController alloc] initWithRootViewController:self.playerViewController];
    
    [self addChildViewController:self.playersNavController inSubView:self.playersListSubView];
    [self addChildViewController:self.playerNavController inSubView:self.playerDetailSubView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

@end
