//
//  NSArray+Utilities.m
//  Boardlink
//
//  Created by Jim Geppert on 5/29/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "NSArray+Utilities.h"

@implementation NSArray (Utilities)

//  Enumerate the receiver's elements, applying each to the result using the block.
//  Return the aggregated value.
-(id) aggregateTo: (id) result applying: (id (^)(id result, id element)) aggregation {
    id newResult = result;
    for (id obj in self) {
        newResult = aggregation(newResult, obj);
    }
    return newResult;
}

//  Enumerate the receiver's elements, applying the transformation block to each element
//  Return the list of transformed elements (same count as receiver, same order as receiver)
-(NSMutableArray *) transform: (id (^)(id element)) transformation {
    NSMutableArray *arrayOfTransformedElements = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (id obj in self) {
        id transformedElement = transformation(obj);
        [arrayOfTransformedElements addObject:transformedElement];
    }
    return arrayOfTransformedElements;
}

//  Enumerate the receiver's elements, applying the filter for each.
//  Return the list of elements that meet the criteria of the filter.
-(NSMutableArray *) filter: (BOOL (^)(id element)) filter {
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    for (id obj in self) {
        if (filter(obj)) {
            [filteredArray addObject:obj];
        }
    }
    return filteredArray;
}

//  Enumerate the receiver's elements, applying the filter for each.
//  Return the first of the elements that meet the criteria of the filter
//  (nil if not found)
-(id) filterFirst: (BOOL (^)(id element)) filter {
    for (id obj in self) {
        if (filter(obj)) {
            return obj;
        }
    }
    return nil;
}

-(id) first {
	return [self count] > 0 ? [self objectAtIndex: 0] : nil;
}

@end
