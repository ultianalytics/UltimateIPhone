//
//  Scrubber.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 5/23/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scrubber : NSObject {

}

@property (nonatomic) BOOL isOn;

+(Scrubber*)currentScrubber;
-(NSString*)substitutePlayerName: (NSString*) originalName isMale: (BOOL) isMale;
-(NSString*)substituteTournamentName: (NSString*) originalName;
-(NSString*)substituteOpponentName: (NSString*) originalName;

@end
