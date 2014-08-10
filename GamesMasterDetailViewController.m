//
//  GamesMasterDetailViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/8/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GamesMasterDetailViewController.h"
#import "UIViewController+Additions.h"
#import "GamesPlayedController.h"
#import "GameDetailViewController.h"

@interface GamesMasterDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *gamesListSubView;
@property (weak, nonatomic) IBOutlet UIView *gameDetailSubView;

@property (strong, nonatomic) GamesPlayedController *gamesViewController;
@property (strong, nonatomic) GameDetailViewController *gameViewController;

@property (strong, nonatomic) UINavigationController *gamesNavController;
@property (strong, nonatomic) UINavigationController *gameNavController;

@end

@implementation GamesMasterDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.gamesViewController = [[GamesPlayedController alloc] init];
    self.gameViewController = [[GameDetailViewController alloc] init];
    self.gamesViewController.detailController = self.gameViewController;
    
    self.gamesViewController.edgesForExtendedLayout = UIRectEdgeNone;
    self.gameViewController.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.gamesNavController = [[UINavigationController alloc] initWithRootViewController:self.gamesViewController];
    self.gameNavController = [[UINavigationController alloc] initWithRootViewController:self.gameViewController];
    
    [self addChildViewController:self.gamesNavController inSubView:self.gamesListSubView];
    [self addChildViewController:self.gameNavController inSubView:self.gameDetailSubView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

@end
