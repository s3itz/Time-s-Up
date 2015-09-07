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
@property (nonatomic, copy) NSDate *countdownStartTime;
@property (nonatomic) NSTimeInterval countdownInterval;
@property (nonatomic) BOOL paused; // TODO: we'll implement pause feature by checking this state

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
            || (self.seconds && self.seconds.integerValue > 0)
            || (self.countdownTimer != nil));
}

- (void)setHours:(NSNumber *)hours {
    [self willChangeValueForKey:@"hours"];
    _hours = hours;
    [self didChangeValueForKey:@"hours"];
}

- (void)setMinutes:(NSNumber *)minutes {
    [self willChangeValueForKey:@"minutes"];
     _minutes = minutes;
     [self didChangeValueForKey:@"minutes"];
}

- (void)setSeconds:(NSNumber *)seconds {
    [self willChangeValueForKey:@"seconds"];
    _seconds = seconds;
    [self didChangeValueForKey:@"seconds"];
}

- (void)setCountdownTimer:(NSTimer *)countdownTimer {
    [self willChangeValueForKey:@"countdownTimer"];
    _countdownTimer = countdownTimer;
    [self didChangeValueForKey:@"countdownTimer"];
}

#pragma mark - IBActions

- (IBAction)startPressed:(NSButton *)sender {
    self.countdownStartTime = [NSDate date];

    if (!self.countdownTimer) {
        NSInteger hours = self.hours ? self.hours.integerValue : 0;
        NSInteger minutes = self.minutes ? self.minutes.integerValue : 0;
        NSInteger seconds = self.seconds ? self.seconds.integerValue : 0;
        self.countdownInterval = hours * 3600 + minutes * 60 + seconds;

        NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

        self.countdownTimer = timer;

        self.statusBarButton.title = [self stringFromTimeInterval:self.countdownInterval];
    } else {
        [self.countdownTimer setFireDate:[NSDate date]];
    }

    sender.title = @"Pause";
    sender.action = @selector(pausedPressed:);
}

- (IBAction)pausedPressed:(NSButton *)sender {
    [self.countdownTimer setFireDate:[NSDate distantFuture]];
    self.countdownInterval -= [self elapsedTime];

    sender.title = @"Start";
    sender.action = @selector(startPressed:);
}

- (IBAction)resetPressed:(NSButton* )sender {
    [self resetTimer];

    // TODO: reset views
}

#pragma mark - NSTimer helpers

- (void)resetTimer {
    if (self.countdownTimer) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    }
    self.hours = self.minutes = self.seconds = nil;
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = round(interval);
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = ti / 3600;

    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
}

- (NSTimeInterval)elapsedTime {
    return [[NSDate date] timeIntervalSinceDate:self.countdownStartTime];
}

- (void)updateTime:(NSTimer *)timer {
    NSLog(@"%s", __func__);

    NSTimeInterval elapsedTimeInterval = [self elapsedTime];
    NSTimeInterval remainingTimeInterval = self.countdownInterval - elapsedTimeInterval;

    if (remainingTimeInterval <= 0) {
        [self resetTimer];
    }

    self.statusBarButton.title = [self stringFromTimeInterval:remainingTimeInterval];
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
