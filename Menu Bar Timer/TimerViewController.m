//
//  TimerViewController.m
//  Menu Bar Timer
//
//  Created by Daniel Seitz on 9/6/15.
//  Copyright © 2015 Daniel Seitz. All rights reserved.
//

#import "TimerViewController.h"
#import "TimeFieldsView.h"

@interface TimerViewController ()

@property (nonatomic, weak) IBOutlet TimeFieldsView *timeFieldsView;
@property (nonatomic, weak) IBOutlet NSButton *startPauseButton;

@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, copy) NSDate *countdownStartTime;
@property (nonatomic) NSTimeInterval countdownInterval;
@property (nonatomic) BOOL paused; // TODO: we'll implement pause feature by checking this state

@property (nonatomic, readonly, getter=isAbleToStart) BOOL ableToStart;

@end

@implementation TimerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - Custom Accessors

- (BOOL)isAbleToStart {
    TimeFieldsView *timeFieldsView = self.timeFieldsView;
    return timeFieldsView.hours || timeFieldsView.minutes || timeFieldsView.seconds;
}

#pragma mark - IBActions

- (IBAction)startPressed:(NSButton *)sender {
    self.countdownStartTime = [NSDate date];

    if (!self.countdownTimer) {
        int hours = self.timeFieldsView.hours;
        int minutes = self.timeFieldsView.minutes;
        int seconds = self.timeFieldsView.seconds;

        self.countdownInterval = hours * 3600 + minutes * 60 + seconds;

        NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

        self.countdownTimer = timer;

        self.statusBarButton.title = [self stringFromTimeInterval:self.countdownInterval];
    } else {
        [self.countdownTimer setFireDate:[NSDate date]];
    }

    self.timeFieldsView.editable = NO;

    sender.title = @"Pause";
    sender.action = @selector(pausedPressed:);
}

- (void)pausedPressed:(NSButton *)sender {
    [self.countdownTimer setFireDate:[NSDate distantFuture]];
    self.countdownInterval -= [self elapsedTime];

    sender.title = @"Start";
    sender.action = @selector(startPressed:);
}

- (IBAction)resetPressed:(NSButton* )sender {
    [self resetTimer];
    [self resetViews];
}

#pragma mark - NSTimer helpers

- (void)resetTimer {
    if (self.countdownTimer) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    }
}

- (void)resetViews {
    self.timeFieldsView.hours = 0;
    self.timeFieldsView.minutes = 0;
    self.timeFieldsView.seconds = 0;
    self.timeFieldsView.editable = YES;

    self.statusBarButton.title = @"00:00:00";

    self.startPauseButton.title = @"Start";
    self.startPauseButton.action = @selector(startPressed:);
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
    NSTimeInterval elapsedTimeInterval = [self elapsedTime];
    NSTimeInterval remainingTimeInterval = self.countdownInterval - elapsedTimeInterval;

    if (remainingTimeInterval <= 0) {
        [self resetTimer];
    }

    self.statusBarButton.title = [self stringFromTimeInterval:remainingTimeInterval];
}

#pragma mark - Protocol conformance
#pragma mark - NSTextFieldDelegate

@end
