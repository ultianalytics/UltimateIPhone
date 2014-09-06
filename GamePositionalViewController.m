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
#import "CalloutsContainerView.h"

#define kActionViewMargin 20;
#define kFlipSidesConfirmAlert 1;

@interface GamePositionalViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton* otherTeamCatchButton;
@property (nonatomic, strong) IBOutlet UIView* fieldContainerView;
@property (nonatomic, strong) IBOutlet GameFieldView* fieldView;
@property (nonatomic, strong) IBOutlet UIView* actionViewContainer;
@property (nonatomic, strong) IBOutlet UIView* topViewOverlay;
@property (nonatomic, strong) IBOutlet UIView* bottomViewOverlay;
@property (nonatomic, strong) IBOutlet UIView* eventsViewContainer;
@property (nonatomic, strong) IBOutlet UIButton* cancelButton;
@property (nonatomic, strong) IBOutlet UIView* buttonsView;
@property (nonatomic, strong) PickPlayerForEventViewController* beginEventPlayerPickerViewController;
@property (nonatomic, strong) IBOutlet UIView* beginEventPlayerPickerSubview;
@property (nonatomic, strong) IBOutlet UIView* pullLandSubview;
@property (nonatomic, strong) IBOutlet UIView* actionViewPlayerButtons;
@property (nonatomic, strong) IBOutlet UIView* opponentActionButtonsView;
@property (nonatomic, strong) IBOutlet UIButton* flipSidesButton;
@property (nonatomic, strong) UILabel* outOfBoundsToast;

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
    [self configureFieldView];
    [self.eventsViewController adjustInsetForTabBar];
    [self.cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.otherTeamThrowAwayButton setTitle:@"Throwaway" forState:UIControlStateNormal];
    [self.otherTeamScoreButton setTitle:@"Goal" forState:UIControlStateNormal];
    [self.otherTeamCatchButton setTitle:@"Catch" forState:UIControlStateNormal];
    self.opponentActionButtonsView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.opponentActionButtonsView.layer.borderWidth = 1.0f;
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outOfBoundsTapped:)];
    [self.fieldContainerView addGestureRecognizer: tapRecognizer];
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

-(Event*)removeLastEvent {
    if (self.game.positionalBeginEvent) {
        Event* lastEventForRemoval =  self.game.positionalBeginEvent;
        self.game.positionalBeginEvent = nil;
        return lastEventForRemoval;
    } else {
        Event* lastEventForRemoval = [[Game getCurrentGame] getLastEvent];
        [[Game getCurrentGame] removeLastEvent];
        if (lastEventForRemoval.beginPosition) {
            self.game.positionalBeginEvent = [lastEventForRemoval asBeginEvent];
        }
        return lastEventForRemoval;
    }
}

-(void)eventsUpdated {
    [self hideActionView];
    [self.fieldView updateForCurrentEvents];
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

- (void)showActionViewForPoint: (CGPoint) pointInMyView fieldPoint: (CGPoint)pointInField {
    [self updateActionViewEnabledButtons: pointInField];
    [self updateActionViewForSelectedPasser];
    BOOL isLeft = [self repositionAndShowChooserView:self.actionViewContainer adjacentToEventAt:pointInMyView];
    [self updateActionViewLayoutForOffenseOrDefenseIsLeft: isLeft];
}

- (void)hideActionView {
    [self hideChooserView:self.actionViewContainer];
}

- (void)updateActionViewForSelectedPasser {
    Player* playerToSelect = self.game.positionalBeginEvent.playerOne;
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

-(void)updateActionViewLayoutForOffenseOrDefenseIsLeft: (BOOL)isLeft {
    self.opponentActionButtonsView.hidden = self.isOffense;
    
    if (self.isOffense) {
        self.actionViewPlayerButtons.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    } else {
        if (isLeft) {
            self.actionViewPlayerButtons.transform = CGAffineTransformMakeTranslation(151, 0.0);
            self.opponentActionButtonsView.transform = CGAffineTransformMakeTranslation(0, 0.0);
        } else {
            self.actionViewPlayerButtons.transform = CGAffineTransformMakeTranslation(0, 0.0);
            self.opponentActionButtonsView.transform = CGAffineTransformMakeTranslation(164, 0.0);
        }
    }
}

-(void)updateActionViewEnabledButtons: (CGPoint) eventPoint {
    [self enableAllButtons];
    if ([self.fieldView isPointInGoalEndzone:eventPoint]) {
        [self disableCatchButtons];
    } else {
        [self disableGoalButtons];
    }
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
    self.beginEventPlayerPickerViewController.instructions = isPull ? @"Who is pulling?" : @"Who picked up disc?";
    self.beginEventPlayerPickerViewController.allowCancel = !isPull;
    [self.beginEventPlayerPickerViewController refresh];
    [self repositionAndShowChooserView:self.beginEventPlayerPickerSubview adjacentToEventAt:eventPoint];
}

-(void)hidePickupDiscPlayerPickerView {
    [self hideChooserView:self.beginEventPlayerPickerSubview];
}

#pragma mark - Event Handlers

- (IBAction)cancelButtonTapped:(id)sender {
    [self hideActionView];
    [self.fieldView updateForCurrentEvents];
}

-(IBAction)otherTeamCatchTapped: (id) sender {
    DefenseEvent* event = [[DefenseEvent alloc] initOpponentCatch];
    [self addEvent: event];
}

-(IBAction)flipSidesTapped: (id) sender {
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Are you sure?"
                          message: @"You should only \"Reorient\" if YOU (the stats keeper) switches the side of the field you are recording stats from."
                          delegate: self
                          cancelButtonTitle: @"Cancel"
                          otherButtonTitles: @"Continue", nil];
    alert.tag = kFlipSidesConfirmAlert;
    [alert show];
}

-(void)handleFlipSides {
    self.fieldView.inverted = !self.fieldView.inverted;
    [self.fieldView updateForCurrentEvents];
    [UIView transitionWithView:self.fieldView duration:0.5f options:UIViewAnimationOptionTransitionFlipFromTop animations:^(void) {
        // no-op
    } completion:nil];
}

-(BOOL)handleFieldTappedAtPosition: (EventPosition*) position atPoint: (CGPoint) fieldPoint isOB: (BOOL)isOutOfBounds {
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
                [self updateGameWithBeginEvent: pickupEvent];
                [self.fieldView updateForCurrentEvents];
                return NO;  // do not show potential event
            }
        } else {
            // pull
            if (self.isOffense) {
                Event* pickupEvent = [[OffenseEvent alloc] initOpponentPullBegin];
                pickupEvent.position = position;
                [self updateGameWithBeginEvent: pickupEvent];
                [self.fieldView updateForCurrentEvents];
                return NO;  // do not show potential event
            } else {
                [self showPickupDiscPlayerPickerViewForPoint:pointInMyView isPull:YES];
                return YES; // show potential event
            }
        }
    } else {
        if ([self.game.positionalBeginEvent isPullBegin]) {
            Event* pullEvent;
            if ([self.game.positionalBeginEvent isDefense]) {
                pullEvent = [[DefenseEvent alloc] initDefender:self.game.positionalBeginEvent.playerOne action:isOutOfBounds ? PullOb : Pull];
            } else {
                pullEvent = [[OffenseEvent alloc] initOpponentPull:isOutOfBounds ? OpponentPullOb : OpponentPull];
            }
            pullEvent.position = position;
            pullEvent.beginPosition = self.game.positionalBeginEvent.position;
            [self addEvent:pullEvent];
            return NO;  // do not show potential event
        } else if (isOutOfBounds) {
            if (self.game.positionalBeginEvent) {
                // out of bounds after a pickup...throwaway
                Event* throwawayEvent;
                if ([self.game.positionalBeginEvent isDefense]) {
                    throwawayEvent = [[DefenseEvent alloc] initDefender:self.game.positionalBeginEvent.playerOne action:Throwaway];
                } else {
                    throwawayEvent = [[OffenseEvent alloc] initPasser:self.game.positionalBeginEvent.playerOne action:Throwaway];
                }
                throwawayEvent.position = position;
                throwawayEvent.beginPosition = self.game.positionalBeginEvent.position;
                [self addEvent:throwawayEvent];
                return NO;  // do not show potential event
            } else if ([[self.game getLastEvent] isCatchOrOpponentCatch]) {
                // out of bounds after a catch...throwaway
                Event* lastEvent = [self.game getLastEvent];
                Event* throwawayEvent;
                if (self.isOffense) {
                    throwawayEvent = [[OffenseEvent alloc] initPasser:lastEvent.playerOne action:Throwaway];
                } else {
                    throwawayEvent = [[DefenseEvent alloc] initAction:Throwaway];
                }
                throwawayEvent.position = position;
                [self addEvent:throwawayEvent];
                return NO;  // do not show potential event
            } else {
                [self showActionViewForPoint:pointInMyView fieldPoint:fieldPoint];
            }
        } else {
            [self showActionViewForPoint:pointInMyView  fieldPoint:fieldPoint];
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
            [self updateGameWithBeginEvent: pickupEvent];
        } else {
            DefenseEvent* pickupEvent = [[DefenseEvent alloc] initPullBegin:player];
            pickupEvent.position = self.fieldView.potentialEventPosition;
            [self updateGameWithBeginEvent: pickupEvent];
        }
    }
    [self.fieldView updateForCurrentEvents];
};
            
-(void)handlePullLandingChosen: (Action) action {
    Player* player = self.game.positionalBeginEvent.playerOne;
    if (action != None) {
        Event* pullEvent;
        if ([self.game.positionalBeginEvent isDefense]) {
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

- (void)outOfBoundsTapped:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint obPoint = [gestureRecognizer locationInView:self.view];
    CGFloat inBoundX;
    CGFloat inBoundY;
    
    // find the nearest inbound point
    if (obPoint.x < self.fieldView.frameX) {
        inBoundX = 0;
    } else  if (obPoint.x > self.fieldView.frameRight) {
        inBoundX = self.fieldView.frameWidth - 1;
    } else {
        inBoundX = obPoint.x - self.fieldView.frameX;
    }
    if (obPoint.y < self.fieldView.frameY) {
        inBoundY = 0;
    } else  if (obPoint.y > self.fieldView.frameBottom) {
        inBoundY = self.fieldView.frameHeight - 1;
    } else {
        inBoundY = obPoint.y - self.fieldView.frameY;
    }
    CGPoint inBoundPoint = CGPointMake(inBoundX, inBoundY);
    
    [self.fieldView handleTap:inBoundPoint isOB:YES];

}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1 && buttonIndex == 1) {
        [self handleFlipSides];
    }
}

#pragma mark - Miscellaneous

-(void) addEventProperties: (Event*) event {
    if (!event.position) {
        event.position = self.fieldView.potentialEventPosition;
    }
    event.beginPosition = self.game.positionalBeginEvent.position;  // only some events will have begin position
}

- (BOOL)repositionAndShowChooserView: (UIView*)chooserView adjacentToEventAt: (CGPoint) eventPoint {
    BOOL isLeft = NO;
    chooserView.center = self.fieldView.center;  // center vertically in the field view
    if (eventPoint.x != 0 && eventPoint.y != 0) {
        isLeft = eventPoint.x < (self.view.boundsWidth / 2.0f);
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
    return isLeft;
}

- (void)hideChooserView: (UIView*)chooserView {
    self.topViewOverlay.hidden = YES;
    self.bottomViewOverlay.hidden = YES;
    chooserView.hidden = YES;
}

-(Game*)game {
    return [Game getCurrentGame];
}

- (void)configureFieldView {
    __typeof(self) __weak weakSelf = self;
    self.fieldView.positionTappedBlock = ^(EventPosition* position, CGPoint fieldPoint, BOOL isOutOfBounds) {
        return [weakSelf handleFieldTappedAtPosition:position atPoint:fieldPoint isOB: isOutOfBounds];
    };
}

-(void)updateGameWithBeginEvent:(Event *)event {
    self.game.positionalBeginEvent = event;
    [self.eventsViewController refresh];
    [self saveGame];
}

-(void)disableGoalButtons {
    if (self.isOffense) {
        for (PlayerView* playerVew in self.playerViews) {
            [playerVew disableThirdButton];
        }
    } else {
        self.otherTeamScoreButton.enabled = NO;
    }
}

-(void)disableCatchButtons {
    if (self.isOffense) {
        for (PlayerView* playerVew in self.playerViews) {
            [playerVew disableFirstButton];
        }
    } else {
        self.otherTeamCatchButton.enabled = NO;
    }
}

-(void)enableAllButtons {
    for (PlayerView* playerVew in self.playerViews) {
        [playerVew enableButtons];
    }
    self.otherTeamScoreButton.enabled = YES;
    self.otherTeamCatchButton.enabled = YES;
}


@end
