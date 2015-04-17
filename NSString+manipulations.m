//
//  NSString+manipulations.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 5/29/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "NSString+manipulations.h"

@implementation NSString (manipulations)

-(NSString*)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
-(BOOL)isNotEmpty {
    return ![[self trim] isEqualToString:@""];
}

-(NSDictionary*)toQueryStringParamaters {
    NSString* paramsToParse = [self trim];
    if ([self hasPrefix:@"?" ] || [self hasPrefix:@"#"]) {
        paramsToParse = [paramsToParse substringFromIndex:1];
    }
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    NSArray *keyValueList = [paramsToParse componentsSeparatedByString:@"&"];

    for (NSString *keyValuePair in keyValueList) {
        NSArray *keyAndValueArray = [keyValuePair componentsSeparatedByString:@"="];
        if ([keyAndValueArray count] == 2) {
            [paramsDict setObject:[keyAndValueArray objectAtIndex:1] forKey:[keyAndValueArray objectAtIndex:0]];
        } else {
            SHSLog(@"Warning...malformed query string: %@", self);
            return nil;
        }
    }
    
    return paramsDict;
}

-(NSString*)urlEncoded {
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(NSData*)asData {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

+(NSString*)stringWithData: (NSData*)data {
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

-(BOOL)contains: (NSString*) anotherString {
    return [self rangeOfString:anotherString].location != NSNotFound;
}

+(NSString*)stringWithGuid {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    NSString* guid = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, theUUID);
    CFRelease (theUUID);
    return guid;
}

-(BOOL)writeToTempDirectoryFile: (NSString*)fileName {
    NSError* writeError = nil;
    NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent: fileName];
    [self writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    return writeError != nil;
}

+(NSString*)readFromTempDirectoryFile: (NSString*)fileName {
    NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent: fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData* data = [[NSData alloc] initWithContentsOfFile: filePath];
        if (data) {
            return [NSString stringWithData:data];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

+(BOOL)deleteFromTempDirectoryFile: (NSString*)fileName {
    NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent: fileName];
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}


@end
