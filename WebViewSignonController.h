//
//  WebViewSignonController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 7/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebViewSignonControllerDelegate <NSObject>

-(void)dismissSignonController:(BOOL) isSignedOn email: (NSString*) userEmail;

@end

@interface WebViewSignonController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) id<WebViewSignonControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end
