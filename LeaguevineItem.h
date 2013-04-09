//
//  LeaguevineItem.h
//  UltimateIPhone
//
//  Created by james on 9/23/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeaguevineItem : NSObject

@property (nonatomic) int itemId;
@property (nonatomic, strong) NSString* name;

-(void)populateFromJson:(NSDictionary*) dict;
-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;
-(NSMutableDictionary*)asDictionary;
-(void)populateFromDictionary:(NSDictionary*) dict;
-(NSString*)listDescription;
-(NSString*)shortDescription;

@end
