//
//  LeaguevineItem.m
//  UltimateIPhone
//
//  Created by james on 9/23/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineItem.h"
#import "NSDictionary+JSON.h"

#define kLeaguevineResponseItemId @"id"
#define kLeaguevineResponseItemName @"name"

@implementation LeaguevineItem

-(void)populateFromJson:(NSDictionary*) dict {
    if (dict) {
        self.itemId = [dict intForJsonProperty:kLeaguevineResponseItemId defaultValue:0];
        self.name = [dict stringForJsonProperty:kLeaguevineResponseItemName];
    } 
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.itemId = [decoder decodeIntForKey:kLeaguevineResponseItemId];
        self.name = [decoder decodeObjectForKey:kLeaguevineResponseItemName];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.itemId forKey:kLeaguevineResponseItemId];
    [encoder encodeObject:self.name forKey:kLeaguevineResponseItemName];
}

@end



