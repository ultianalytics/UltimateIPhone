//
//  SHSLogsMailer.m
//  UltimateIPhone
//
//  Created by james on 4/23/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "SHSLogsMailer.h"
#import "SHSLogger.h"
#import <MessageUI/MessageUI.h>

@interface SHSLogsMailer() <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIViewController* presentingController;

@end

@implementation SHSLogsMailer

static SHSLogsMailer *sharedInstance = nil;

+ (SHSLogsMailer *)sharedMailer {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[SHSLogsMailer alloc] init];
    });
    
    return sharedInstance;
}

-(void)presentEmailLogsControllerOn: (UIViewController*)presentingController {
    self.presentingController = presentingController;
    MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
    mailComposeVC.mailComposeDelegate = self;
    [mailComposeVC setSubject:@"iUltimate Logs"];
    
    NSArray* recipients = [NSArray arrayWithObject:@"support@ultimate-numbers.com"];
    [mailComposeVC setToRecipients:recipients];
    
    for (NSString* logFilePath in [[SHSLogger sharedLogger] filesInDateAscendingOrder]) {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:logFilePath];
        NSString* fileName = [logFilePath lastPathComponent];
        [mailComposeVC addAttachmentData:data mimeType:@"text/plain" fileName:fileName];
    }
    
    NSString *emailBody = @"iUltimate log files attached";
    [mailComposeVC setMessageBody:emailBody isHTML:NO];
    [self.presentingController presentModalViewController:mailComposeVC animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self.presentingController dismissModalViewControllerAnimated:YES];
    self.presentingController = nil;
}

@end