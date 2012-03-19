//
//  GamesPlayedController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@interface GamesPlayedController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray* gameDescriptions;
@property (nonatomic, strong) IBOutlet UITableView* gamesTableView;

-(void)retrieveGameDescriptions;

@end
