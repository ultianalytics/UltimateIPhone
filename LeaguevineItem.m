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

#define kLeaguevineItemId @"id"
#define kLeaguevineItemName @"name"

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

-(NSMutableDictionary*)asDictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue: self.name forKey:kLeaguevineItemName];
    [dict setValue: [NSNumber numberWithInt:self.itemId ] forKey:kLeaguevineItemId];
    return dict;
}

-(void)populateFromDictionary:(NSDictionary*) dict {
    self.name = [dict objectForKey:kLeaguevineItemName];
    NSNumber* itemIdAsNSNumber = [dict objectForKey:kLeaguevineItemId];
    if (itemIdAsNSNumber) {
        self.itemId = [itemIdAsNSNumber intValue];
    }
}


-(NSString*)listDescription {
    return self.name;
}

@end



