//
//  AppDelegate.m
//  Menu Bar Timer
//
//  Created by Daniel Seitz on 9/6/15.
//  Copyright © 2015 Daniel Seitz. All rights reserved.
//

#import "AppDelegate.h"
#import "TimerViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, getter=isDarkModeOn) BOOL darkModeOn;
@property (nonatomic, strong) NSPopover *popover;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSStatusItem* statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem.button setTitle:@"00:00:00"];
    statusItem.button.action = @selector(statusItemClicked:);

    self.statusItem = statusItem;

    NSPopover *popover = [[NSPopover alloc] init];
}

- (void)statusItemClicked:(NSStatusBarButton *)sender {
    NSLog(@"Clicked me!");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
