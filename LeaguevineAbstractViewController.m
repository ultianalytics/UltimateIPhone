//
//  LeaguevineAbstractViewController.m
//  UltimateIPhone
//
//  Created by james on 9/22/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineAbstractViewController.h"
#import "LeaguevineClient.h"

@interface LeaguevineAbstractViewController()

@property (nonatomic, strong) UIAlertView* busyView;

@end

@implementation LeaguevineAbstractViewController

#pragma mark - Busy Dialog

-(void)startBusyDialog {
    self.busyView = [[UIAlertView alloc] initWithTitle: @"Talking to Leaguevine..."
                                          message: nil
                                         delegate: self
                                cancelButtonTitle: nil
                                otherButtonTitles: nil];
    // Add a spinner
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = CGRectMake(50,50, 200, 50);
    [self.busyView addSubview:spinner];
    [spinner startAnimating];
    
    [self.busyView show];
}

-(void)stopBusyDialog {
    if (self.busyView) {
        [self.busyView dismissWithClickedButtonIndex:0 animated:NO];
        [self.busyView removeFromSuperview];
        NSLog(@"stopping busy dialog");
    }
}

#pragma mark - Error alerting

-(void)alertError:(NSString*) title message: (NSString*) message {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: title
                                                        message: message
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
    [alertView show];
}

-(void)alertFailure: (LeaguevineInvokeStatus) type {
    [self alertError:@"Error talking to Leaguevine" message:[self errorDescription:type]];
}

-(NSString*)errorDescription: (LeaguevineInvokeStatus) type {
    switch(type) {
        case LeaguevineInvokeNetworkError:
            return @"Network error detected...are you connected to the internet?";
        case LeaguevineInvokeInvalidResponse:
            return @"Leaguevine is having problems. Try later";
        default:
            return @"Unkown error. Try later";
    }
}

-(void)errorAlertDismissed {
    // subclasses can implement
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self errorAlertDismissed];
}


                              
@end
