//
//  NSArray+Utilities.h
//  Boardlink
//
//  Created by Jim Geppert on 5/29/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Utilities)

//  Enumerate the receiver's elements, applying each to the result using the block.
//  Return the aggregated value.
-(id) aggregateTo: (id) result applying: (id (^)(id result, id element)) aggregation;

//  Enumerate the receiver's elements, applying the transformation block to each element
//  Return the list of transformed elements (same count as receiver, same order as receiver)
-(NSMutableArray *) transform: (id (^)(id element)) transformation;

//  Enumerate the receiver's elements, applying the filter for each.
//  Return the list of elements that meet the criteria of the filter.
-(NSMutableArray *) filter: (BOOL (^)(id element)) filter;

//  Enumerate the receiver's elements, applying the filter for each.
//  Return the first of the elements that meet the criteria of the filter
//  (nil if not found)
-(id) filterFirst: (BOOL (^)(id element)) filter;

-(id) first;

@end
