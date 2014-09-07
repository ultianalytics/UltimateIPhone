//
//  GameDownloadPickerViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/7/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"
@class GameDescription;

@interface GameDownloadPickerViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource> {
    @private
    NSDateFormatter *dateFormat;
}

@property (nonatomic, strong) NSArray* games;
@property (nonatomic, strong) GameDescription* selectedGame;
@property (nonatomic, strong) IBOutlet UITableView* gamesTableView;

@end
