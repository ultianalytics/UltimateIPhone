//
//  GameDownloadPickerViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/7/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Game;

@interface GameDownloadPickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray* games;
@property (nonatomic, strong) Game* selectedGame;
@property (nonatomic, strong) IBOutlet UITableView* gamesTableView;

@end
