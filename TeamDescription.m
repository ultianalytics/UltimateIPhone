//
//  TeamDescription.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TeamDescription.h"

@implementation TeamDescription
@synthesize teamId,name;

- (id)initWithId:(NSString*)aTeamId name:(NSString*)aName {
    self = [super init];
    if (self) {
        self.teamId = aTeamId;
        self.name = aName;
    }
    return self;
}


@end
