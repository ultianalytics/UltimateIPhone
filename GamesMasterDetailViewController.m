//
//  GamesMasterDetailViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/8/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GamesMasterDetailViewController.h"
#import "UIViewController+Additions.h"
#import "GamesViewController.h"
#import "GameDetailViewController.h"
#import "Team.h"
#import "UIView+Convenience.h"

@interface GamesMasterDetailViewController ()


// master/detail
@property (weak, nonatomic) IBOutlet UIView *masterDetailView;
@property (weak, nonatomic) IBOutlet UIView *masterSubView;
@property (weak, nonatomic) IBOutlet UIView *detailSubView;

// list only
@property (weak, nonatomic) IBOutlet UIView *listOnlyView;

@property (strong, nonatomic) GamesViewController *masterViewController;
@property (strong, nonatomic) GameDetailViewController *detailViewController;
@property (strong, nonatomic) GamesViewController *listOnlyViewController;

@property (strong, nonatomic) UINavigationController *masterNavController;
@property (strong, nonatomic) UINavigationController *detailNavController;
@property (strong, nonatomic) UINavigationController *listOnlyNavController;

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
    [self configureMasterDetailView];
    [self configureListOnlyView];
}

- (void)configureMasterDetailView {
    UIStoryboard *gamesStoryboard = [UIStoryboard storyboardWithName:@"GamesViewController" bundle:nil];
    self.masterViewController  = [gamesStoryboard instantiateInitialViewController];
    self.detailViewController = [[GameDetailViewController alloc] init];
    self.masterViewController.detailController = self.detailViewController;
    self.masterViewController.topViewController = self;
    self.detailViewController.topViewController = self;
    __typeof(self) __weak weakSelf = self;
    self.masterViewController.gamesChangedBlock = ^{
        [weakSelf updateViewConfig];
    };
    
    self.detailViewController.edgesForExtendedLayout = UIRectEdgeNone;
    self.masterViewController.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.masterNavController = [[UINavigationController alloc] initWithRootViewController:self.masterViewController];
    self.detailNavController = [[UINavigationController alloc] initWithRootViewController:self.detailViewController];
    
    [self addChildViewController:self.masterNavController inSubView:self.masterSubView];
    [self addChildViewController:self.detailNavController inSubView:self.detailSubView];
}

- (void)configureListOnlyView {
    UIStoryboard *gamesStoryboard = [UIStoryboard storyboardWithName:@"GamesViewController" bundle:nil];
    self.listOnlyViewController  = [gamesStoryboard instantiateInitialViewController];
    self.listOnlyViewController.topViewController = self;
    __typeof(self) __weak weakSelf = self;
    self.listOnlyViewController.gamesChangedBlock = ^{
        [weakSelf updateViewConfig];
    };
    
    self.listOnlyViewController.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.listOnlyNavController = [[UINavigationController alloc] initWithRootViewController:self.listOnlyViewController];
    
    [self addChildViewController:self.listOnlyNavController inSubView:self.listOnlyView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self updateViewConfig];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)updateViewConfig {
    Team* team = [Team getCurrentTeam];
    BOOL useListOnlyView =  ![team hasGames];
    if ((useListOnlyView && self.listOnlyView.hidden) || (!useListOnlyView && self.listOnlyView.visible))  {
        self.listOnlyView.visible = useListOnlyView;
        self.masterDetailView.visible = !useListOnlyView;
    }
    [self refreshListController];
}

- (void)refreshListController {
    if (self.masterDetailView.visible) {
        [self.masterViewController reset];
    } else {
        [self.listOnlyViewController reset];
    }
}

@end
