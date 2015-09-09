//
//  TimerViewController.h
//  Time's Up
//
//  Created by Daniel Seitz on 9/6/15.
//  Copyright © 2015 Daniel Seitz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TimerViewController : NSViewController

// Passed when application starts; prevents having to do any data passing
@property (nonatomic, weak) NSStatusBarButton *statusBarButton;

@end
