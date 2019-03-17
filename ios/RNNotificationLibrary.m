
#import "RNNotificationLibrary.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

static void displayStatusChanged(CFNotificationCenterRef center,
                                 void *observer,
                                 CFStringRef name,
                                 const void *object,
                                 CFDictionaryRef userInfo) {
    if (name == CFSTR("com.apple.springboard.lockcomplete")) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisplayStatusLocked"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@implementation RNNotificationLibrary
{
    bool hasListeners;
}



RCT_EXPORT_MODULE()

// Will be called when this module's first listener is added.
-(void)startObserving {
    hasListeners = YES;
    // Set up any upstream listeners or background tasks as necessary
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
    hasListeners = NO;
    // Remove upstream listeners, stop unnecessary background tasks
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:UIApplicationProtectedDataWillBecomeUnavailable object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[CTCallCenter alloc] init].callEventHandler = ^(CTCall *call){
            
            if ([call.callState isEqualToString: CTCallStateConnected])
            {
                //NSLog(@"call stopped");
            }
            else if ([call.callState isEqualToString: CTCallStateDialing])
            {
                [self popupDetectedReminderReceived];
            }
            else if ([call.callState isEqualToString: CTCallStateDisconnected])
            {
                //NSLog(@"call played");
            }
            else if ([call.callState isEqualToString: CTCallStateIncoming])
            {
                //NSLog(@"call stopped");
            }
        };
        UIDevice *device = [UIDevice currentDevice];
        device.batteryMonitoringEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:device];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:UIDeviceBatteryStateDidChangeNotification object:device];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        displayStatusChanged,
                                        CFSTR("com.apple.springboard.lockcomplete"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (void) didReceiveNotification:(NSNotification*)notification
{
    if (notification.name == UIApplicationProtectedDataWillBecomeUnavailable) {
        [self screenLockedReminderReceived];
        return;
    }
    if (notification.name == UIApplicationDidBecomeActiveNotification) {
        [self appOpenedReminderReceived];
        return;
    }
    if (notification.name == UIApplicationDidEnterBackgroundNotification) {
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateInactive) {
            [self screenLockedReminderReceived];
        } else {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC/10);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kDisplayStatusLocked"]) {
                    [self appClosedReminderReceived];
                } else {
                    [self screenLockedReminderReceived];
                }
            });
        }
        return;
    }
    if (notification.name == UIApplicationWillEnterForegroundNotification) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisplayStatusLocked"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) batteryChanged:(NSNotification*)notification
{
    
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"AppOpened", @"AppClosed", @"ScreenLocked", @"PopupDetected"];
}

- (void)appOpenedReminderReceived
{
    if (hasListeners) {
        [self sendEventWithName:@"AppOpened" body:@{}];
    }
}

- (void)appClosedReminderReceived
{
    if (hasListeners) {
        [self sendEventWithName:@"AppClosed" body:@{}];
    }
}

- (void)screenLockedReminderReceived
{
    if (hasListeners) {
        [self sendEventWithName:@"ScreenLocked" body:@{}];
    }
}

- (void)popupDetectedReminderReceived
{
    if (hasListeners) {
        [self sendEventWithName:@"PopupDetected" body:@{}];
    }
}


@end
  
