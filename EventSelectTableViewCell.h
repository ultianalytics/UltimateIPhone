//
//  EventSelectTableViewCell.h
//  UltimateIPhone
//
//  Created by james on 10/11/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Event;

@interface EventSelectTableViewCell : UITableViewCell

@property (strong, nonatomic) Event* event;
@property (nonatomic) BOOL chosen;

@end
