//
//  SHSLogsMailer.m
//  UltimateIPhone
//
//  Created by james on 4/23/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "SHSLogsMailer.h"
#import "SHSLogger.h"
#import "SHSTeamFileZipper.h"
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

-(void)presentEmailLogsControllerOn: (UIViewController*)presentingController includeTeamFiles: (BOOL)includeTeamFiles {
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
    if (includeTeamFiles) {
        NSString* zipFilePath = [SHSTeamFileZipper zipTeamAndGameFiles];
        if (zipFilePath) {
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:zipFilePath];
            NSString* zipFileName = [zipFilePath lastPathComponent];
            [mailComposeVC addAttachmentData:data mimeType:@"application/zip" fileName:zipFileName];
        }
    }
    
    NSString *emailBody = @"iUltimate log and team files attached";
    [mailComposeVC setMessageBody:emailBody isHTML:NO];
    [self.presentingController presentViewController:mailComposeVC animated:YES completion: nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self.presentingController dismissViewControllerAnimated:YES completion:nil];
    self.presentingController = nil;
}

@end
