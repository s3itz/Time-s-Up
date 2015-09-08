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
@property (nonatomic, weak) IBOutlet NSButton *reverseButton;
@property (nonatomic, weak) IBOutlet NSButton *stopwatchButton;

@property (nonatomic, strong) NSTimer *timer;  // holds a reference to the active timer

@property (nonatomic, copy) NSDate *startDate;          // stores start time
@property (nonatomic) NSTimeInterval interval;          // stored the desired time for countdowns
@property (nonatomic) NSTimeInterval previouslyElapsed; // stores time between pauses

@property (nonatomic, readonly, getter=isAbleToStart) BOOL ableToStart;
@property (nonatomic, getter=isStopwatch) BOOL stopwatch;

@end

@implementation TimerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - Custom Accessors

- (BOOL)isAbleToStart {
    return self.timeFieldsView.valid || self.stopwatch;
}

+ (NSSet *)keyPathsForValuesAffectingAbleToStart {
    return [NSSet setWithObjects:@"timeFieldsView.valid", @"stopwatch", nil];
}

#pragma mark - IBActions

- (IBAction)startPressed:(NSButton *)sender {
    self.stopwatchButton.enabled = NO;

    self.startDate = [NSDate date];

    if (!self.timer) {
        [self getDesiredInterval];
        [self createTimer];
    } else {
        [self.timer setFireDate:[NSDate date]];
    }

    self.timeFieldsView.enabled = NO;

    sender.title = @"Pause";
    sender.action = @selector(pausedPressed:);
}

- (void)pausedPressed:(NSButton *)sender {
    self.previouslyElapsed += [[NSDate date] timeIntervalSinceDate:self.startDate];
    [self.timer setFireDate:[NSDate distantFuture]];

    sender.title = @"Start";
    sender.action = @selector(startPressed:);
}

- (IBAction)resetPressed:(NSButton* )sender {
    [self resetTimer];
    [self resetViews];
}

- (IBAction)pressedQuit:(NSButton *)sender {
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0];
}

- (IBAction)stopwatchPressed:(NSButton *)sender {
    self.reverseButton.enabled = self.stopwatch;
    self.timeFieldsView.enabled = self.stopwatch;
    self.stopwatch = !self.stopwatch;
}

#pragma mark - Timer logic

- (void)createTimer {
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [timer fire];
    self.timer = timer;
}

- (void)resetTimer {
    if (self.timer) {
        [self.timer invalidate];
    }

    self.startDate = nil;
    self.timer = nil;
    self.interval = 0;
    self.previouslyElapsed = 0;
}

- (void)resetViews {
    self.timeFieldsView.hours = 0;
    self.timeFieldsView.minutes = 0;
    self.timeFieldsView.seconds = 0;
    self.timeFieldsView.enabled = YES;
    self.stopwatchButton.enabled = YES;

    self.statusBarButton.title = @"00:00:00";

    self.startPauseButton.title = @"Start";
    self.startPauseButton.action = @selector(startPressed:);
}

- (void)updateTime:(NSTimer *)timer {
    NSDate *currentDate = [NSDate date];
    NSTimeInterval elapsedTime = [currentDate timeIntervalSinceDate:self.startDate];
    elapsedTime += self.previouslyElapsed;

    // If counting up, just show interval
    if (self.stopwatch || (!self.stopwatch && self.reverseButton.state == NSOnState)) {
        self.statusBarButton.title = [self stringFromTimeInterval:elapsedTime];
    } else { // otherwise, show as countdown
        self.statusBarButton.title = [self stringFromTimeInterval:self.interval - elapsedTime];
    }

    if (self.interval - elapsedTime <= 0) {
        [self resetTimer];
        [self resetViews];
        [self displayNotification];
    }
}

#pragma mark - Helper functions

- (void)getDesiredInterval {
    int hours = self.timeFieldsView.hours;
    int minutes = self.timeFieldsView.minutes;
    int seconds = self.timeFieldsView.seconds;

    self.interval = hours * 3600 + minutes * 60 + seconds;
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (int)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = ti / 3600;

    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
}

- (void)displayNotification {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Time's up!";
    notification.informativeText =  @"Your countdown timer has finished.";
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end
