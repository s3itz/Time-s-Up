//
//  TimeFieldsView.m
//  Time's Up
//
//  Created by Daniel Seitz on 9/6/15.
//  Copyright © 2015 Daniel Seitz. All rights reserved.
//

#import "TimeFieldsView.h"

@interface TimeFieldsView ()

@property (nonatomic, weak) IBOutlet NSView *view;

@property (nonatomic, weak) IBOutlet NSTextField *hoursTextField;
@property (nonatomic, weak) IBOutlet NSTextField *minutesTextField;
@property (nonatomic, weak) IBOutlet NSTextField *secondsTextField;

@end

@implementation TimeFieldsView

#pragma mark - View lifecycle

- (void)xibSetup {
    [[NSBundle mainBundle] loadNibNamed:@"TimeFieldsView" owner:self topLevelObjects:nil];

    CGRect contentFrame = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
    self.view.frame = contentFrame;

    [self addSubview:self.view];
}
- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self xibSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self xibSetup];
    }
    return self;
}

#pragma mark - Custom accessor methods

- (int)hours {
    return self.hoursTextField.intValue;
}

- (int)minutes {
    return self.minutesTextField.intValue;
}

- (int)seconds {
    return self.secondsTextField.intValue;
}

- (void)setHours:(int)hours {
    int h = MAX(0, hours);
    [self setIntegerValue:h forTextField:self.hoursTextField];
}

- (void)setMinutes:(int)minutes {
    int m = MAX(0, minutes);
    [self setIntegerValue:m forTextField:self.minutesTextField];
}

- (void)setSeconds:(int)seconds {
    int s = MAX(0, seconds);
    [self setIntegerValue:s forTextField:self.secondsTextField];
}

- (void)setIntegerValue:(int)value forTextField:(NSTextField *)textField {
    if (value) {
        [textField setStringValue:[NSString stringWithFormat:@"%02d", value]];
    } else {
        [textField setStringValue:@""];
    }
}

- (BOOL)isValid {
    return self.hours || self.minutes || self.seconds;
}

+ (NSSet *)keyPathsForValuesAffectingValid {
    return [NSSet setWithObjects:@"hours", @"minutes", @"seconds", nil];
}

- (void)setEnabled:(BOOL)enabled {
    self.hoursTextField.enabled = enabled;
    self.minutesTextField.enabled = enabled;
    self.secondsTextField.enabled = enabled;

    _enabled = enabled;
}

#pragma mark - Protocol conformance
#pragma mark - NSTextFieldDelegate

- (void):(NSNotification *)obj {
    static NSCharacterSet *numericSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!numericSet)
            numericSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    });

    NSTextField *textField = [obj object];
    NSUInteger len = textField.stringValue.length;

    if (len > 2) { // clip length to two characters
        textField.stringValue = [textField.stringValue substringWithRange:NSMakeRange(0, 2)];
    } else {
        // Verify text is valid and remove invalid characters before they are rendered
        NSMutableString *str = [textField.stringValue mutableCopy];
        for (int i = 0; i < len; ++i) {
            unichar c = [str characterAtIndex:i];
            if (![numericSet characterIsMember:c])
                [str deleteCharactersInRange:NSMakeRange(i, 1)];
            textField.stringValue = [str copy];
        }

        // Now test result and if necessary; assist user and move to next text field
        NSString *resultStr = textField.stringValue;
        NSUInteger resultLen = resultStr.length;
        if (resultLen == 2 && textField != self.secondsTextField) {
            NSTextField *nextTextField = [textField.superview viewWithTag:textField.tag + 1];
            if (nextTextField) {
                [nextTextField becomeFirstResponder];
            }
        }
    }

    // Emulate that we changed this
    [self willChangeValueForKey:@"valid"];
    [self didChangeValueForKey:@"valid"];
}

@end
