#import "IFLYDemoPrivacyConsentStore.h"

static NSString *const IFLYDemoPrivacyConsentAcceptedKey = @"IFLYDemoPrivacyConsentAccepted";

@interface IFLYDemoPrivacyConsentStore ()
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation IFLYDemoPrivacyConsentStore

- (instancetype)init {
    return [self initWithUserDefaults:NSUserDefaults.standardUserDefaults];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    self = [super init];
    if (self) {
        _userDefaults = userDefaults;
    }
    return self;
}

- (BOOL)hasAccepted {
    return [self.userDefaults boolForKey:IFLYDemoPrivacyConsentAcceptedKey];
}

- (void)markAccepted {
    [self.userDefaults setBool:YES forKey:IFLYDemoPrivacyConsentAcceptedKey];
}

@end
