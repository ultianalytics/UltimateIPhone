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

@end
