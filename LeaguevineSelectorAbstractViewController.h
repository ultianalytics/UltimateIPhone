//
//  LeaguevineSelectorAbstractViewController.h
//  UltimateIPhone
//
//  Created by james on 9/22/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeaguevineClient.h"
#import "UltimateViewController.h"
@class LeaguevineItem;

@interface LeaguevineSelectorAbstractViewController : UltimateViewController <UISearchBarDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) LeaguevineClient* leaguevineClient;
@property (nonatomic, strong) NSArray* items;
@property (strong, nonatomic) void (^selectedBlock)(LeaguevineItem* item);

// protected
@property (nonatomic, strong) NSArray* filteredItems;

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

-(void)alertFailure: (LeaguevineInvokeStatus) type;
-(void)alertError:(NSString*) title message: (NSString*) message;
-(void)itemSelected: (LeaguevineItem*) item;
-(void)refreshItems:(LeaguevineInvokeStatus)status result:(id)result;
-(void)refresh;

@end
