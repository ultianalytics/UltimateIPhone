//
//  TeamsViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"
#import "TeamViewController.h"

@class Team;

@interface TeamsViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource> {
    @private
    NSArray* teamDescriptions;
    BOOL isAfterFirstView;
}

@property (nonatomic, strong) TeamViewController* detailController; // only used in iPad

-(void)retrieveTeamDescriptions;
-(void)goToAddTeam;
-(void)goToBestView;
-(void)goToTeamView: (Team*) team animated: (BOOL) animated;

@end
