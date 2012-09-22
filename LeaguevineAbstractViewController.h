//
//  LeaguevineAbstractViewController.h
//  UltimateIPhone
//
//  Created by james on 9/22/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeaguevineClient.h"

@interface LeaguevineAbstractViewController : UIViewController

@property (nonatomic, strong) LeaguevineClient* leaguevineClient;

-(void)startBusyDialog;
-(void)stopBusyDialog;
-(void)alertFailure: (LeaguevineInvokeStatus) type;
-(void)alertError:(NSString*) title message: (NSString*) message ;

@end
