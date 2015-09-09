//
//  AppDelegate.m
//  Time's Up
//
//  Created by Daniel Seitz on 9/6/15.
//  Copyright © 2015 Daniel Seitz. All rights reserved.
//

#import "AppDelegate.h"
#import "TimerViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSStatusItem *statusItem;
//@property (nonatomic, getter=isDarkModeOn) BOOL darkModeOn;
@property (nonatomic, strong) NSPopover *popover;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSStatusItem* statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem.button setTitle:@"00:00:00"];
    statusItem.button.action = @selector(togglePopover:);
    self.statusItem = statusItem;

    TimerViewController *vc = [[TimerViewController alloc] initWithNibName:@"TimerViewController" bundle:nil];
    vc.statusBarButton = statusItem.button;

    NSPopover *popover = [[NSPopover alloc] init];
    popover.contentViewController = vc;
    self.popover = popover;
}

- (void)togglePopover:(NSStatusBarButton *)sender {
    if (self.popover.isShown) {
        [self.popover performClose:sender];
    } else {
        NSStatusBarButton *button = self.statusItem.button;
        [self.popover showRelativeToRect:button.bounds ofView:button preferredEdge:NSMinYEdge];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)applicationDidResignActive:(NSNotification *)notification {
    if (self.popover.isShown) {
        [self.popover performClose:self];
    }
}

@end
