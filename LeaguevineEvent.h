//
//  LeaguevineEvent.h
//  UltimateIPhone
//
//  Created by james on 3/29/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CRUDAdd=0,
    CRUDUpdate,
    CRUDDelete
} CRUD;

@interface LeaguevineEvent : NSObject

@property (nonatomic) CRUD crud;
@property (nonatomic) NSUInteger leaguevineGameId;
@property (nonatomic) NSUInteger leaguevineEventType;
@property (nonatomic) NSUInteger leaguevinePlayer1Id;
@property (nonatomic) NSUInteger leaguevinePlayer2Id;
@property (nonatomic) NSUInteger leaguevinePlayer3Id;
@property (nonatomic) NSUInteger leaguevinePlayer1TeamId;
@property (nonatomic) NSUInteger leaguevinePlayer2TeamId;
@property (nonatomic) NSUInteger leaguevinePlayer3TeamId;
@property (nonatomic) NSUInteger leaguevineEventId;
@property (nonatomic) NSTimeInterval iUltimateTimestamp;

+(LeaguevineEvent*)leaguevineEventWithCrud: (CRUD)crud;
+(LeaguevineEvent*)restoreFrom: (NSString*)filePath;
-(void)save: (NSString*)filePath;

@end
