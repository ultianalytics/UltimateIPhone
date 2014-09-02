//
//  PlayerPositionalView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/23/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "PlayerPositionalView.h"
#import "PasserButton.h"

@implementation PlayerPositionalView


#pragma mark - Superclass Overrides

-(NSString*)nibName {
    return @"PlayerPositionalView";
}

-(void)initUI {
    [super initUI];
    // don't allow passer changes in the action view when collecting actions positionally
    self.passerButton.userInteractionEnabled = NO;
}

@end
