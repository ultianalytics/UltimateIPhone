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
#import "GameHistoryController.h"
#import "BeginEventPlayerPickerViewController.h"
#import "Game.h"
#import "BeginEvent.h"
#import "PlayerView.h"

#define kActionViewMargin 20;

@interface GamePositionalViewController ()

@property (nonatomic, strong) IBOutlet GameFieldView* fieldView;
@property (nonatomic, strong) IBOutlet UIView* actionViewContainer;
@property (nonatomic, strong) IBOutlet UIView* topViewOverlay;
@property (nonatomic, strong) IBOutlet UIView* bottomViewOverlay;
@property (nonatomic, strong) IBOutlet UIView* eventsViewContainer;
@property (nonatomic, strong) IBOutlet UIButton* cancelButton;
@property (nonatomic, strong) IBOutlet UIView* buttonsView;
@property (nonatomic, strong) IBOutlet BeginEventPlayerPickerViewController* beginEventPlayerPickerViewController;
@property (nonatomic, strong) IBOutlet UIView* beginEventPlayerPickerSubview;

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
    [self configureBeginEventPlayerPickerView];
    [self.cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    __typeof(self) __weak weakSelf = self;
    self.fieldView.positionTappedBlock = ^(EventPosition* position, CGPoint fieldPoint) {
        CGPoint pointInMyView = [weakSelf.fieldView convertPoint:fieldPoint toView:weakSelf.view];
        if ([[Game getCurrentGame] needsPositionalBegin]) {
            [weakSelf showBeginEventPlayerPickerViewForPoint:pointInMyView isPull:NO];
        } else {
            [weakSelf showActionViewForPoint:pointInMyView];
        }
    };
    [self.eventsViewController adjustInsetForTabBar];
    [self hideActionView];
    self.hideReceiverView.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [self.fieldView updateForCurrentEvents];
}

#pragma mark - Superclass Overrides

- (void)configureForOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {

    } else {

    }
    self.bottomOrRightView.frameWidth = self.view.boundsWidth;
    self.bottomOrRightView.frameHeight = self.view.boundsHeight - self.topOrLeftView.frameHeight;
}

-(void)eventActionSelected {
    [self hideActionView];
    [self.fieldView updateForCurrentEvents];
}

-(CGFloat)throwawayButtonOffsetOnDefense {
    return -100.0;
}

-(BOOL)calloutsAllowed {
    return NO;
}

#pragma mark - ActionView (who/what for event)

-(void)configureActionView {
    NSString* actionViewNib = @"GameActionView_positional";
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:actionViewNib owner:self options:nil];
    UIView* actionView = (UIView*)nibViews[0];
    [self.actionSubView addSubview:actionView];
    actionView.backgroundColor = [ColorMaster actionBackgroundColor];
}

- (void)showActionViewForPoint: (CGPoint) eventPoint {
    [self updateActionViewForSelectedPasser];
    [self repositionAndShowChooserView:self.actionViewContainer adjacentToEventAt:eventPoint];
}

- (void)hideActionView {
    [self hideChooserView:self.actionViewContainer];
}

#pragma mark - BeginEvent player picker (who for the ephemeral "begin" event)

-(void)configureBeginEventPlayerPickerView {
    self.beginEventPlayerPickerViewController = [[BeginEventPlayerPickerViewController alloc] init];
    __typeof(self) __weak weakSelf = self;
    self.beginEventPlayerPickerViewController.doneRequestedBlock = ^(Player* player) {
        [weakSelf hideBeginEventPlayerPickerView];
        if (player) {
            BOOL isPullBegin = ![Game getCurrentGame].isPointInProgress;
            BeginEvent* beginEvent = [BeginEvent eventWithAction: (isPullBegin ? BeginPull : PickupDisc) andPlayer:player];
            beginEvent.position = weakSelf.fieldView.potentialEventPosition;
            [Game getCurrentGame].positionalBeginEvent = beginEvent;
        }
        [weakSelf.fieldView updateForCurrentEvents];
    };
    [self addChildViewController:self.beginEventPlayerPickerViewController inSubView:self.beginEventPlayerPickerSubview];
}

-(void)showBeginEventPlayerPickerViewForPoint:(CGPoint) eventPoint isPull: (BOOL)isPull {
    self.beginEventPlayerPickerViewController.line = [Game getCurrentGame].currentLineSorted;
    self.beginEventPlayerPickerViewController.instructions = isPull ? @"Pick player who is pulling" : @"Pick player who picked up the disc";
    [self.beginEventPlayerPickerViewController refresh];
    [self repositionAndShowChooserView:self.beginEventPlayerPickerSubview adjacentToEventAt:eventPoint];
}

-(void)hideBeginEventPlayerPickerView {
    [self hideChooserView:self.beginEventPlayerPickerSubview];
}

#pragma mark - Event Handlers

- (IBAction)cancelButtonTapped:(id)sender {
    [self hideActionView];
}

#pragma mark - Miscellaneous

-(void) addEventProperties: (Event*) event {
    event.position = self.fieldView.potentialEventPosition;
    event.beginPosition = [Game getCurrentGame].positionalBeginEvent.position;  // only some events will have begin position
}

- (void)repositionAndShowChooserView: (UIView*)chooserView adjacentToEventAt: (CGPoint) eventPoint {
    chooserView.center = self.fieldView.center;  // center vertically in the field view
    if (eventPoint.x != 0 && eventPoint.y != 0) {
        BOOL isLeft = eventPoint.x < (self.view.boundsWidth / 2.0f);
        CGFloat distanceFromPointToActionView = 40;
        CGFloat x;
        if (isLeft) {
            x = eventPoint.x + distanceFromPointToActionView;
        } else {
            x = eventPoint.x - chooserView.frameWidth - distanceFromPointToActionView;
        }
        chooserView.frameX = x;
    }
    self.topViewOverlay.visible = YES;
    self.bottomViewOverlay.visible = YES;
    chooserView.visible = YES;
}

- (void)hideChooserView: (UIView*)chooserView {
    self.topViewOverlay.hidden = YES;
    self.bottomViewOverlay.hidden = YES;
    chooserView.hidden = YES;
}

- (void)updateActionViewForSelectedPasser {
    Player* playerToSelect = [Game getCurrentGame].positionalBeginEvent.player;
    if (!playerToSelect) {
        Event* lastEvent = [[Game getCurrentGame] getLastEvent];
        if (lastEvent.isOffense) {
            playerToSelect = lastEvent.playerTwo;
        } 
    }
    BOOL playerSelected = NO;
    if (playerToSelect) {
        for (int i = 0; i < 7; i++) {
            PlayerView* playerView = self.playerViews[i];
            if ([playerView.player.name isEqualToString:playerToSelect.name]) {
                [playerView makeSelected: YES];
                playerSelected = YES;
            } else {
                [playerView makeSelected: NO];
            }
        }
    }
    [self.playerViews[7] makeSelected:!playerSelected]; // pick anon if nobody else fits
}

@end
