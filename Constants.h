//
//  Constants.h
//  Ultimate
//
//  Created by Jim Geppert on 2/15/12.
//  Copyright (c) 2012 Summit Hill Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kProductName @"iUltimate"
#define kMaxTournamentNameLength 50
#define kMaxOpponentNameLength 50
#define kMaxNicknameLength 8
#define kMaxTeamNameLength 50
#define kNoAccountText @"NO TWITTER ACCOUNT"
#define kAnonymousTeam @"Anonymous Team"
#define STD_ROW_TYPE @"stdRowType"
#define kSingleSectionGroupedTableSectionHeaderHeight 1

typedef struct {
    int ours;
    int theirs;
} Score;

@interface Constants : NSObject

@end
