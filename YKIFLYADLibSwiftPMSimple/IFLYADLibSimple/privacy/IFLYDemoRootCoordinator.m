#import "IFLYDemoRootCoordinator.h"

#import "IFLYDemoPrivacyConsentViewController.h"
#import "ViewController.h"

#import <IFLYADLib/IFLYADLib.h>
#import <stdlib.h>

@interface IFLYDemoRootCoordinator ()
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) IFLYDemoPrivacyConsentStore *store;
@property (nonatomic, copy, nullable) IFLYDemoConsentCompletedHandler consentCompletedHandler;
@property (nonatomic, copy) IFLYDemoTerminationHandler terminationHandler;
@end

@implementation IFLYDemoRootCoordinator

- (instancetype)initWithWindow:(UIWindow *)window
                          store:(IFLYDemoPrivacyConsentStore *)store
        consentCompletedHandler:(IFLYDemoConsentCompletedHandler)consentCompletedHandler
             terminationHandler:(IFLYDemoTerminationHandler)terminationHandler {
    self = [super init];
    if (self) {
        _window = window;
        _store = store;
        _consentCompletedHandler = [consentCompletedHandler copy];
        if (terminationHandler) {
            _terminationHandler = [terminationHandler copy];
        } else {
            _terminationHandler = ^{
                exit(0);
            };
        }
    }
    return self;
}

- (BOOL)hasAcceptedPrivacy {
    return self.store.hasAccepted;
}

- (void)start {
    if (self.store.hasAccepted) {
        [self showHome];
    } else {
        [self showPrivacyConsent];
    }
}

- (void)showPrivacyConsent {
    __weak typeof(self) weakSelf = self;
    IFLYDemoPrivacyConsentViewController *consentViewController =
        [[IFLYDemoPrivacyConsentViewController alloc]
            initWithAgreeHandler:^{
                [weakSelf acceptPrivacy];
            }
            declineHandler:^{
                [weakSelf declinePrivacy];
            }
            URLOpener:nil];
    self.window.rootViewController = consentViewController;
}

- (void)acceptPrivacy {
    if (self.store.hasAccepted) {
        return;
    }
    [self.store markAccepted];
    [self showHome];
    if (self.consentCompletedHandler) {
        self.consentCompletedHandler();
    }
}

- (void)declinePrivacy {
    self.terminationHandler();
}

- (void)showHome {
    [IFLYAdConfig setPersonalizedEnabled:YES];
    [IFLYAdConfig setLogEnabled:YES];
    ViewController *homeViewController = [[ViewController alloc] init];
    self.window.rootViewController =
        [[UINavigationController alloc] initWithRootViewController:homeViewController];
}

@end
