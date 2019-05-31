
#import "RNNotificationLibrary.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@implementation RNNotificationLibrary
{
    bool hasListeners;
    NSTimer *appResignTimer;
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
    if (notification.name == UIApplicationWillResignActiveNotification) {
        appResignTimer =  [NSTimer scheduledTimerWithTimeInterval:0.001f
                                                           target:self
                                                         selector:@selector(appClosedReminderReceived)
                                                         userInfo:nil
                                                          repeats:NO];
        return;
    }
    if (notification.name == UIApplicationDidEnterBackgroundNotification) {
        if ([appResignTimer isValid]) {
            [appResignTimer invalidate];
            [self screenLockedReminderReceived];
        }
        return;
    }
    if (notification.name == UIApplicationWillEnterForegroundNotification) {
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
  
