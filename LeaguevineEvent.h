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
    CRUDUpdate,   // line changes are always update
    CRUDDelete
} CRUD;

#define kLineChangeEventType 888

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
@property (nonatomic, strong) NSArray* latestLine;
@property (nonatomic) NSString* eventDescription;

+(LeaguevineEvent*)leaguevineEventWithCrud: (CRUD)crud;
+(LeaguevineEvent*)restoreFrom: (NSString*)filePath;
-(void)save: (NSString*)filePath;

-(BOOL)isAdd;
-(BOOL)isUpdate;
-(BOOL)isDelete;
-(BOOL)isUpdateOrDelete;
-(BOOL)isLineChange;
-(NSString*)crudDescription;



@end
