//
//  TimeFieldsView.h
//  Menu Bar Timer
//
//  Created by Daniel Seitz on 9/6/15.
//  Copyright © 2015 Daniel Seitz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TimeFieldsView : NSView

@property (nonatomic) int hours;
@property (nonatomic) int minutes;
@property (nonatomic) int seconds;

// Indicates whether or not the control has a 'valid' value
// This is useful for bindings
@property (nonatomic, readonly, getter=isValid) BOOL valid;

// Allows editable control state to be adjusted
@property (nonatomic, getter=isEditable) BOOL editable;

@end
