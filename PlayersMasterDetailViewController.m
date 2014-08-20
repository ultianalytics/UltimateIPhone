//
//  PlayersMasterDetailViewController.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/8/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "PlayersMasterDetailViewController.h"
#import "UIViewController+Additions.h"
#import "UIView+Convenience.h"
#import "TeamPlayersViewController.h"
#import "PlayerDetailsViewController.h"
#import "Team.h"

@interface PlayersMasterDetailViewController ()

// master/detail
@property (weak, nonatomic) IBOutlet UIView *masterDetailView;
@property (weak, nonatomic) IBOutlet UIView *masterSubView;
@property (weak, nonatomic) IBOutlet UIView *detailSubView;

// list only
@property (weak, nonatomic) IBOutlet UIView *listOnlyView;

@property (strong, nonatomic) TeamPlayersViewController *masterViewController;
@property (strong, nonatomic) PlayerDetailsViewController *detailViewController;
@property (strong, nonatomic) TeamPlayersViewController *listOnlyViewController;


@property (strong, nonatomic) UINavigationController *masterNavController;
@property (strong, nonatomic) UINavigationController *detailNavController;
@property (strong, nonatomic) UINavigationController *listOnlyNavController;

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
    [self configureMasterDetailView];
    [self configureListOnlyView];
    [self updateViewConfig];
}

- (void)configureMasterDetailView {
    self.masterViewController = [self createTeamsListViewController];
    self.detailViewController = [[PlayerDetailsViewController alloc] init];
    self.detailViewController.edgesForExtendedLayout = UIRectEdgeNone;

    self.masterViewController.detailController = self.detailViewController;
    
    self.masterNavController = [[UINavigationController alloc] initWithRootViewController:self.masterViewController];
    self.masterNavController.navigationBar.translucent = NO;
    self.detailNavController = [[UINavigationController alloc] initWithRootViewController:self.detailViewController];
    self.detailNavController.navigationBar.translucent = NO;
    
    [self addChildViewController:self.masterNavController inSubView:self.masterSubView];
    [self addChildViewController:self.detailNavController inSubView:self.detailSubView];
}

- (void)configureListOnlyView {
    self.listOnlyViewController = [self createTeamsListViewController];
    
    self.listOnlyNavController = [[UINavigationController alloc] initWithRootViewController:self.listOnlyViewController];
    
    [self addChildViewController:self.listOnlyNavController inSubView:self.listOnlyView];
}

- (TeamPlayersViewController*)createTeamsListViewController {
    TeamPlayersViewController* viewController = [[TeamPlayersViewController alloc] init];
    viewController.edgesForExtendedLayout = UIRectEdgeNone;
    __typeof(self) __weak weakSelf = self;
    viewController.playersChangedBlock = ^{
        [weakSelf updateViewConfig];
    };
    viewController.backRequestedBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    return viewController;
}

- (void)updateViewConfig {
    Team* team = [Team getCurrentTeam];
    BOOL useListOnlyView =  (team.isLeaguevineTeam && team.arePlayersFromLeagueVine) || ![team hasPlayers];
    if ((useListOnlyView && self.listOnlyView.hidden) || (!useListOnlyView && self.listOnlyView.visible))  {
        // TODO...animate this
        self.listOnlyView.visible = useListOnlyView;
        self.masterDetailView.visible = !useListOnlyView;
    }
    [self refreshListController];
}

- (void)refreshListController {
    if (self.masterDetailView.visible) {
        [self.masterViewController refresh];
    } else {
        [self.listOnlyViewController refresh];
    }
}


@end
