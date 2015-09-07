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
//@property (nonatomic, getter=isDarkModeOn) BOOL darkModeOn;
@property (nonatomic, strong) NSPopover *popover;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSStatusItem* statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem.button setTitle:@"00:00:00"];
    statusItem.button.action = @selector(togglePopover:);

    self.statusItem = statusItem;

    NSPopover *popover = [[NSPopover alloc] init];
    popover.contentViewController = [[TimerViewController alloc] initWithNibName:@"TimerViewController" bundle:nil];
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

@end
