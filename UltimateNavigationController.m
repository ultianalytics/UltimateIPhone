//
//  UltimateNavigationController.m
//  UltimateIPhone
//
//  Created by james on 4/20/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//
//  Handles problems with push/pop caused by lack of synchronization in apple's class
//

#import "UltimateNavigationController.h"

@interface UltimateNavigationController () <UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *waitingList;

@end

@implementation UltimateNavigationController

- (id)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        self.waitingList = [NSMutableArray array];
    }
    return self;
}

-(void)navigationController: ( UINavigationController* ) pNavigationController didShowViewController: ( UIViewController*) pController animated: (BOOL) pAnimated {
    if ([self.waitingList count] > 0) {
        [self.waitingList removeObjectAtIndex: 0];
    }
    if ( [ self.waitingList count ] > 0 ) {
        [super pushViewController: [self.waitingList objectAtIndex: 0 ] animated: pAnimated];
    }
}

-(void)pushViewController:(UIViewController* ) pController animated: (BOOL) pAnimated {
    [self.waitingList addObject: pController];
    if ([self.waitingList count] == 1) {
        [super pushViewController: [self.waitingList objectAtIndex: 0 ] animated: pAnimated];
    }
}

@end
