//
//  PlayerSubstitution.h
//  UltimateIPhone
//
//  Created by james on 10/31/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Player;

typedef enum {
    SubstitutionReasonInjury,
    SubstitutionReasonOther
} SubstitutionReason;

@interface PlayerSubstitution : NSObject

@property (nonatomic, strong) Player* fromPlayer;
@property (nonatomic, strong) Player* toPlayer;
@property (nonatomic) SubstitutionReason reason;
@property (nonatomic) NSTimeInterval timestamp;

@end
