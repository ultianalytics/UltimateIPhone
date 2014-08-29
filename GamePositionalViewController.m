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
#import "Game.h"
#import "PlayerView.h"
#import "Event.h"
#import "OffenseEvent.h"
#import "DefenseEvent.h"
#import "PickPlayerForEventViewController.h"
#import "Player.h"
#import "PullLandPickerViewController.h"

#define kActionViewMargin 20;

@interface GamePositionalViewController ()

@property (nonatomic, strong) IBOutlet UIButton* otherTeamCatchButton;
@property (nonatomic, strong) IBOutlet GameFieldView* fieldView;
@property (nonatomic, strong) IBOutlet UIView* actionViewContainer;
@property (nonatomic, strong) IBOutlet UIView* topViewOverlay;
@property (nonatomic, strong) IBOutlet UIView* bottomViewOverlay;
@property (nonatomic, strong) IBOutlet UIView* eventsViewContainer;
@property (nonatomic, strong) IBOutlet UIButton* cancelButton;
@property (nonatomic, strong) IBOutlet UIView* buttonsView;
@property (nonatomic, strong) IBOutlet PickPlayerForEventViewController* beginEventPlayerPickerViewController;
@property (nonatomic, strong) IBOutlet UIView* beginEventPlayerPickerSubview;
@property (nonatomic, strong) IBOutlet PullLandPickerViewController* pullLandingViewController;
@property (nonatomic, strong) IBOutlet UIView* pullLandSubview;

@property (nonatomic, strong) Game* game;

@end

@implementation GamePositionalViewController
@dynamic game;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

#pragma mark - Lifecycle 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePickupDiskPlayerPickerView];
    [self configurePullLandingView];
    [self configureFieldView];
    [self.eventsViewController adjustInsetForTabBar];
    [self.cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.otherTeamThrowAwayButton setTitle:@"Throwaway" forState:UIControlStateNormal];  // override vertical style used by superclass
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

-(void)eventsUpdated {
    [self hideActionView];
    [self.fieldView updateForCurrentEvents];
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
    [self hideActionView];
}

- (void)showActionViewForPoint: (CGPoint) eventPoint {
    [self updateActionViewForSelectedPasser];
    [self updateActionViewLayoutForOffenseOrDefense];
    [self repositionAndShowChooserView:self.actionViewContainer adjacentToEventAt:eventPoint];
}

- (void)hideActionView {
    [self hideChooserView:self.actionViewContainer];
}

#pragma mark - Pickup Disc, Pick Puller player picker

-(void)configurePickupDiskPlayerPickerView {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PickPlayerForEventViewController" bundle:nil];
    self.beginEventPlayerPickerViewController  = [storyboard instantiateInitialViewController];
    __typeof(self) __weak weakSelf = self;
    self.beginEventPlayerPickerViewController.doneRequestedBlock = ^(Player* player) {
        [weakSelf handlePickupPlayerChosen: player];
    };
    [self addChildViewController:self.beginEventPlayerPickerViewController inSubView:self.beginEventPlayerPickerSubview];
}

-(void)showPickupDiscPlayerPickerViewForPoint:(CGPoint) eventPoint isPull: (BOOL) isPull {
    self.beginEventPlayerPickerViewController.line = self.game.currentLineSorted;
    self.beginEventPlayerPickerViewController.instructions = isPull ? @"Player who will pull?" : @"Player who picked up disc?";
    self.beginEventPlayerPickerViewController.allowCancel = !isPull;
    [self.beginEventPlayerPickerViewController refresh];
    [self repositionAndShowChooserView:self.beginEventPlayerPickerSubview adjacentToEventAt:eventPoint];
}

-(void)hidePickupDiscPlayerPickerView {
    [self hideChooserView:self.beginEventPlayerPickerSubview];
}

#pragma mark - Pull landing chooser

-(void)configurePullLandingView {
    self.pullLandingViewController = [[PullLandPickerViewController alloc] init];
    __typeof(self) __weak weakSelf = self;
    self.pullLandingViewController.doneRequestedBlock = ^(Action action) {
        [weakSelf handlePullLandingChosen:action];
    };
    [self addChildViewController:self.pullLandingViewController inSubView:self.pullLandSubview];
}

-(void)showPullLandingPickerViewForPoint:(CGPoint) eventPoint {
    [self repositionAndShowChooserView:self.pullLandSubview adjacentToEventAt:eventPoint];
}

-(void)hidePullLandingPickerView {
    [self hideChooserView:self.pullLandSubview];
}

#pragma mark - Event Handlers

- (IBAction)cancelButtonTapped:(id)sender {
    [self hideActionView];
    [self hidePullLandingPickerView];
    [self.fieldView updateForCurrentEvents];
}

-(IBAction)otherTeamCatchTapped: (id) sender {
    DefenseEvent* event = [[DefenseEvent alloc] initOpponentCatch];
    [self addEvent: event];
}

-(BOOL)handleFieldTappedAtPosition: (EventPosition*) position atPoint: (CGPoint) fieldPoint {
    CGPoint pointInMyView = [self.fieldView convertPoint:fieldPoint toView:self.view];
    if ([self.game needsPositionalBegin]) {
        if ([self.game isPointInProgress]) {
            // turnover
            if (self.isOffense) {
                [self showPickupDiscPlayerPickerViewForPoint:pointInMyView isPull:NO];
                return YES; // show potential event
            } else {
                Event* pickupEvent = [[DefenseEvent alloc] initPickupDisc];
                pickupEvent.position = position;
                self.game.positionalPickupEvent = pickupEvent;
                [self.fieldView updateForCurrentEvents];
                return NO;  // do not show potential event
            }
        } else {
            // pull
            if (self.isOffense) {
                Event* pickupEvent = [[OffenseEvent alloc] initOpponentPullBegin];
                pickupEvent.position = position;
                self.game.positionalPickupEvent = pickupEvent;
                [self.fieldView updateForCurrentEvents];
                return NO;  // do not show potential event
            } else {
                [self showPickupDiscPlayerPickerViewForPoint:pointInMyView isPull:YES];
                return YES; // show potential event
            }
        }
    } else {
        if ([self.game.positionalPickupEvent isPullBegin]) {
            [self showPullLandingPickerViewForPoint:pointInMyView];
        } else {
            [self showActionViewForPoint:pointInMyView];
        }
        return YES; // show potential event
    }
}

-(void)handlePickupPlayerChosen: (Player*) player { // if player is nil then the user cancelled choice
    [self hidePickupDiscPlayerPickerView];
    if (player) {
        if ([self.game isPointInProgress]) {
            OffenseEvent* pickupEvent = [[OffenseEvent alloc] initPickupDiscWithPlayer:player];
            pickupEvent.position = self.fieldView.potentialEventPosition;
            self.game.positionalPickupEvent = pickupEvent;
        } else {
            DefenseEvent* pickupEvent = [[DefenseEvent alloc] initPullBegin:player];
            pickupEvent.position = self.fieldView.potentialEventPosition;
            self.game.positionalPickupEvent = pickupEvent;
        }
    }
    [self.fieldView updateForCurrentEvents];
};
            
-(void)handlePullLandingChosen: (Action) action {
    [self hidePullLandingPickerView];
    Player* player = self.game.positionalPickupEvent.playerOne;
    if (action != None) {
        Event* pullEvent;
        if ([self.game.positionalPickupEvent isDefense]) {
            pullEvent = [[DefenseEvent alloc] initDefender:player action:action];
        } else {
            Action opponentAction = action == Pull ? OpponentPull : OpponentPullOb;
            pullEvent = [[OffenseEvent alloc] initOpponentPull:opponentAction];
        }
        pullEvent.position = self.fieldView.potentialEventPosition;
        [self addEvent:pullEvent];
    }
    [self.fieldView updateForCurrentEvents];
};

#pragma mark - Miscellaneous

-(void) addEventProperties: (Event*) event {
    event.position = self.fieldView.potentialEventPosition;
    event.beginPosition = self.game.positionalPickupEvent.position;  // only some events will have begin position
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
    Player* playerToSelect = self.game.positionalPickupEvent.playerOne;
    if (!playerToSelect) {
        Event* lastEvent = [self.game getLastEvent];
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

-(void)updateActionViewLayoutForOffenseOrDefense {
    self.otherTeamCatchButton.hidden = self.isOffense;
}

-(Game*)game {
    return [Game getCurrentGame];
}

- (void)configureFieldView {
    __typeof(self) __weak weakSelf = self;
    self.fieldView.positionTappedBlock = ^(EventPosition* position, CGPoint fieldPoint) {
        return [weakSelf handleFieldTappedAtPosition:position atPoint:fieldPoint];
    };
}



@end
