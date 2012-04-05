//
//  TeamDescription.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamDescription : NSObject

@property (nonatomic, strong) NSString* teamId;
@property (nonatomic, strong) NSString* name;

- (id)initWithId:(NSString*)aTeamId name:(NSString*)aName;

@end
