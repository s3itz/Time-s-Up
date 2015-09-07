//
//  TimerViewController.m
//  Menu Bar Timer
//
//  Created by Daniel Seitz on 9/6/15.
//  Copyright © 2015 Daniel Seitz. All rights reserved.
//

#import "TimerViewController.h"

@interface TimerViewController ()

@property (nonatomic) NSNumber *hours;
@property (nonatomic) NSNumber *minutes;
@property (nonatomic) NSNumber *seconds;

@property (nonatomic, readonly, getter=isAbleToStart) BOOL ableToStart;

@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic) NSTimeInterval remainingTicks;

@end

@implementation TimerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - Custom Accessors

- (BOOL)isAbleToStart {
    return ((self.hours && self.hours.integerValue > 0)
            || (self.minutes && self.minutes.integerValue > 0)
            || (self.seconds && self.seconds.integerValue > 0));
}

#pragma mark - IBActions

- (IBAction)startPressed:(NSButton *)sender {
    NSLog(@"%s", __func__);
    sender.title = @"Pause";
    sender.action = @selector(pausedPressed:);
}

- (IBAction)pausedPressed:(NSButton *)sender {
    NSLog(@"%s", __func__);
    sender.title = @"Start";
    sender.action = @selector(startPressed:);
}

- (IBAction)resetPressed:(NSButton* )sender {
    NSLog(@"%s", __func__);
}

#pragma mark - Protocol conformance
#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj {
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
        [self willChangeValueForKey:@"ableToStart"];

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
        if (resultLen == 2) {
            NSInteger tag = textField.tag;
            if (tag != 2) {
                NSTextField *nextTextField = [textField.superview viewWithTag:tag + 1];
                if (nextTextField)
                    [nextTextField becomeFirstResponder];
            }
        }

        [self didChangeValueForKey:@"ableToStart"];
    }
}

@end
