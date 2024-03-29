//
//  LeagueVineSelectorGameViewController.m
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeagueVineSelectorGameViewController.h"
#import "ColorMaster.h"
#import "LeaguevineSeason.h"
#import "LeaguevineTournament.h"
#import "LeaguevineTeam.h"
#import "LeaguevineGame.h"
#import "LeaguevineClient.h"
#import "Team.h"
#import "LeagueVineSelectorGameTableViewCell.h"


@interface LeagueVineSelectorGameViewController ()

@property (nonatomic, strong) NSDateFormatter* timeFormatter;
@property (nonatomic, strong) NSDateFormatter* farDateFormatter;
@property (nonatomic, strong) NSDateFormatter* nearDateFormatter;

@end

@implementation LeagueVineSelectorGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =  @"Leaguevine Game";
        
        self.farDateFormatter = [[NSDateFormatter alloc] init];
        [self.farDateFormatter setLocale:[NSLocale currentLocale]];
        [self.farDateFormatter setDateFormat:@"EEE, MMM d, ''yy"];
        self.nearDateFormatter = [[NSDateFormatter alloc] init];
        [self.nearDateFormatter setLocale:[NSLocale currentLocale]];
        [self.nearDateFormatter setDateFormat:@"EEEE"];
        self.timeFormatter  = [[NSDateFormatter alloc] init];
        [self.timeFormatter setLocale:[NSLocale currentLocale]];
        [self.timeFormatter setDateFormat:@"h:mm a"];
        
    }
    return self;
}

#pragma mark Client interaction

-(void)refreshItems {
    if (self.tournament) {
        [self.leaguevineClient retrieveGamesForTeam:self.myTeam.itemId andTournament:self.tournament.itemId completion:^(LeaguevineInvokeStatus status, id result) {
            [self refreshItems:status result:result];
        }];
    } else {
        [self.leaguevineClient retrieveGamesForTeam:self.myTeam.itemId completion:^(LeaguevineInvokeStatus status, id result) {
            [self refreshItems:status result:result];
        }];
    }
}

-(NSString*)getNoResultsText {
    return @"No games found";
}

#pragma mark TableView delegate

-(UITableViewCell*)createCell: (NSString*) rowType {
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LeagueVineSelectorGameTableViewCell class]) owner:nil options:nil];
    LeagueVineSelectorGameTableViewCell*  cell = (LeagueVineSelectorGameTableViewCell *)[nib objectAtIndex:0];
    cell.backgroundColor = [ColorMaster getFormTableCellColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.selectionStyle= UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)populateCell: (UITableViewCell*) cell withItem: (LeaguevineItem*) item {
    LeagueVineSelectorGameTableViewCell* gameCell = (LeagueVineSelectorGameTableViewCell*)cell;
    LeaguevineGame* leaguevineGame = (LeaguevineGame*)item;
    gameCell.startTimeLabel.text = [self formatGameDate:leaguevineGame];
    gameCell.opponentLabel.text = [leaguevineGame opponentDescription];
}

-(NSString*)formatGameDate: (LeaguevineGame*) game {
    // use game's local timezone
    [self.timeFormatter setTimeZone:[game getStartTimezone]];
    [self.timeFormatter setTimeZone:[game getStartTimezone]];
    
    NSDate* date = game.startTime;
    if (!date) {
        return @"Not sure";
    } else {
        return [NSString stringWithFormat:@"%@, %@", [self.farDateFormatter stringFromDate:date], [self.timeFormatter stringFromDate:date]];
    }
}

#pragma mark Lifecycle 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainTableView.rowHeight = [self createCell:nil].bounds.size.height;
}

#pragma mark Overrides 

-(int)getBestRowPositionAfterRefresh {
    NSDate* now = [NSDate date];
    for (int i = 0; i < [self.filteredItems count]; i++) {
        LeaguevineGame* game = [self.filteredItems objectAtIndex:i];
        if ([game.startTime isEqualToDate:now] || [game.startTime earlierDate:now] == game.startTime) {
            return i < 1 ? 0 : i - 1;
        }
    }
    return 0;
}

@end
