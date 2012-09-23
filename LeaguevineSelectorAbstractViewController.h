//
//  LeaguevineSelectorAbstractViewController.h
//  UltimateIPhone
//
//  Created by james on 9/22/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeaguevineClient.h"
@class LeaguevineItem;

@interface LeaguevineSelectorAbstractViewController : UIViewController <UISearchBarDelegate>

@property (nonatomic, strong) LeaguevineClient* leaguevineClient;
@property (nonatomic, strong) NSArray* items;
@property (strong, nonatomic) void (^selectedBlock)(LeaguevineItem* item);

// protected
@property (nonatomic, strong) NSArray* filteredItems;

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

-(void)startBusyDialog;
-(void)stopBusyDialog;
-(void)alertFailure: (LeaguevineInvokeStatus) type;
-(void)alertError:(NSString*) title message: (NSString*) message;
-(void)itemSelected: (LeaguevineItem*) item;

@end
