//
//  AppDelegate.m
//  IFLYADLibSimple
//
//  Created by admin on 3.3.25.
//

#import "AppDelegate.h"
#import "IFLYDemoPrivacyConsentStore.h"
#import "IFLYDemoRootCoordinator.h"

#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface AppDelegate ()

@property (nonatomic, assign) BOOL didRequestTrackingAuthorization;
@property (nonatomic, strong) IFLYDemoRootCoordinator *rootCoordinator;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    __weak typeof(self) weakSelf = self;
    self.rootCoordinator = [[IFLYDemoRootCoordinator alloc]
        initWithWindow:self.window
        store:[[IFLYDemoPrivacyConsentStore alloc] init]
        consentCompletedHandler:^{
            [weakSelf requestTrackingAuthorizationIfNeeded];
        }
        terminationHandler:nil];
    [self.rootCoordinator start];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (self.rootCoordinator.hasAcceptedPrivacy) {
        [self requestTrackingAuthorizationIfNeeded];
    }
}

- (void)requestTrackingAuthorizationIfNeeded {
    if (@available(iOS 14, *)) {
        if (self.didRequestTrackingAuthorization) {
            return;
        }

        ATTrackingManagerAuthorizationStatus currentStatus = ATTrackingManager.trackingAuthorizationStatus;
        if (currentStatus != ATTrackingManagerAuthorizationStatusNotDetermined) {
            self.didRequestTrackingAuthorization = YES;
            IFLYSampleLogInfo(@"ATT", @"trackingAuthorizationStatus=%ld", (long)currentStatus);
            return;
        }

        self.didRequestTrackingAuthorization = YES;
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            IFLYSampleLogInfo(@"ATT", @"trackingAuthorizationStatus=%ld", (long)status);
        }];
    }
}

@end
