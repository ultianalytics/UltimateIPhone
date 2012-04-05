//
//  TeamsViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Team;

@interface TeamsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView* teamsTableView;

-(void)retrieveTeamDescriptions;
-(void)goToAddTeam;
-(void)goToBestView;
-(void)goToTeamView: (Team*) team animated: (BOOL) animated;

@end
