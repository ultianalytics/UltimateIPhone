//
//  SHSLogsMailer.h
//  UltimateIPhone
//
//  Created by james on 4/23/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHSLogsMailer : NSObject

+(SHSLogsMailer*)sharedMailer;

-(void)presentEmailLogsControllerOn: (UIViewController*)presentingController includeTeamFiles: (BOOL)includeTeamFiles;

@end
