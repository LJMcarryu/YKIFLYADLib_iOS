#import "IFLYDemoPrivacyConsentViewController.h"

static NSString *const IFLYDemoPrivacyPolicyName = @"《讯飞AI营销SDK隐私政策协议》";

@interface IFLYDemoPrivacyConsentViewController () <UITextViewDelegate>
@property (nonatomic, copy) IFLYDemoPrivacyActionHandler agreeHandler;
@property (nonatomic, copy) IFLYDemoPrivacyActionHandler declineHandler;
@property (nonatomic, copy) IFLYDemoPrivacyURLOpener URLOpener;
@end

@implementation IFLYDemoPrivacyConsentViewController

+ (NSString *)consentTitle {
    return @"温馨提示";
}

+ (NSString *)consentMessage {
    return @"欢迎使用 “讯飞AI营销demo”！我们非常重视您的个人信息和隐私协议。在您使用之前请仔细阅读《讯飞AI营销SDK隐私政策协议》。我们承诺将严格按照经您同意的各项条款使用您的个人信息，以便为您提供更好的服务。点击 “同意并继续” 按钮，代表您已阅读并同意以上内容。";
}

+ (NSURL *)privacyPolicyURL {
    return [NSURL URLWithString:@"https://aimarx.com/help-center/sdk-privacy-policy"];
}

- (instancetype)initWithAgreeHandler:(IFLYDemoPrivacyActionHandler)agreeHandler
                       declineHandler:(IFLYDemoPrivacyActionHandler)declineHandler
                            URLOpener:(IFLYDemoPrivacyURLOpener)URLOpener {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _agreeHandler = [agreeHandler copy];
        _declineHandler = [declineHandler copy];
        if (URLOpener) {
            _URLOpener = [URLOpener copy];
        } else {
            _URLOpener = ^BOOL(NSURL *URL) {
                UIApplication *application = UIApplication.sharedApplication;
                if (![application canOpenURL:URL]) {
                    return NO;
                }
                [application openURL:URL options:@{} completionHandler:nil];
                return YES;
            };
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.23 green:0.04 blue:0.06 alpha:1.0];
    [self buildConsentCard];
}

- (void)buildConsentCard {
    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 14.0;
    card.layer.masksToBounds = YES;
    card.accessibilityIdentifier = @"privacyConsentCard";
    [self.view addSubview:card];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = self.class.consentTitle;
    titleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor colorWithWhite:0.16 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.accessibilityIdentifier = @"privacyTitleLabel";
    titleLabel.accessibilityTraits = UIAccessibilityTraitHeader;
    [card addSubview:titleLabel];

    UITextView *messageTextView = [[UITextView alloc] init];
    messageTextView.translatesAutoresizingMaskIntoConstraints = NO;
    messageTextView.backgroundColor = UIColor.clearColor;
    messageTextView.editable = NO;
    messageTextView.selectable = YES;
    messageTextView.scrollEnabled = YES;
    messageTextView.delegate = self;
    messageTextView.textContainerInset = UIEdgeInsetsMake(4.0, 0, 4.0, 0);
    messageTextView.textContainer.lineFragmentPadding = 0;
    messageTextView.attributedText = [self attributedConsentMessage];
    messageTextView.linkTextAttributes = @{
        NSForegroundColorAttributeName : [UIColor colorWithRed:0.10 green:0.55 blue:0.88 alpha:1.0],
        NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle),
    };
    messageTextView.accessibilityIdentifier = @"privacyMessageTextView";
    messageTextView.accessibilityLabel = self.class.consentMessage;
    [card addSubview:messageTextView];

    UIButton *agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    agreeButton.translatesAutoresizingMaskIntoConstraints = NO;
    agreeButton.backgroundColor = [UIColor colorWithRed:0.12 green:0.60 blue:0.92 alpha:1.0];
    agreeButton.layer.cornerRadius = 24.0;
    agreeButton.titleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];
    [agreeButton setTitle:@"同意并继续" forState:UIControlStateNormal];
    [agreeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [agreeButton addTarget:self action:@selector(agreeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    agreeButton.accessibilityIdentifier = @"privacyAgreeButton";
    agreeButton.accessibilityLabel = @"同意并继续";
    [card addSubview:agreeButton];

    UIButton *declineButton = [UIButton buttonWithType:UIButtonTypeSystem];
    declineButton.translatesAutoresizingMaskIntoConstraints = NO;
    declineButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [declineButton setTitle:@"不同意并退出应用" forState:UIControlStateNormal];
    [declineButton setTitleColor:[UIColor colorWithWhite:0.55 alpha:1.0] forState:UIControlStateNormal];
    [declineButton addTarget:self action:@selector(declineButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    declineButton.accessibilityIdentifier = @"privacyDeclineButton";
    declineButton.accessibilityLabel = @"不同意并退出应用";
    [card addSubview:declineButton];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    NSLayoutConstraint *preferredWidth = [card.widthAnchor constraintEqualToAnchor:safeArea.widthAnchor constant:-48.0];
    preferredWidth.priority = UILayoutPriorityDefaultHigh;
    NSLayoutConstraint *preferredMessageHeight = [messageTextView.heightAnchor constraintEqualToConstant:220.0];
    preferredMessageHeight.priority = 900;

    [NSLayoutConstraint activateConstraints:@[
        [card.centerXAnchor constraintEqualToAnchor:safeArea.centerXAnchor],
        [card.centerYAnchor constraintEqualToAnchor:safeArea.centerYAnchor],
        [card.leadingAnchor constraintGreaterThanOrEqualToAnchor:safeArea.leadingAnchor constant:24.0],
        [card.trailingAnchor constraintLessThanOrEqualToAnchor:safeArea.trailingAnchor constant:-24.0],
        [card.topAnchor constraintGreaterThanOrEqualToAnchor:safeArea.topAnchor constant:16.0],
        [card.bottomAnchor constraintLessThanOrEqualToAnchor:safeArea.bottomAnchor constant:-16.0],
        [card.widthAnchor constraintLessThanOrEqualToConstant:420.0],
        preferredWidth,

        [titleLabel.topAnchor constraintEqualToAnchor:card.topAnchor constant:22.0],
        [titleLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:22.0],
        [titleLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-22.0],

        [messageTextView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:12.0],
        [messageTextView.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24.0],
        [messageTextView.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-24.0],
        [messageTextView.heightAnchor constraintGreaterThanOrEqualToConstant:100.0],
        preferredMessageHeight,

        [agreeButton.topAnchor constraintEqualToAnchor:messageTextView.bottomAnchor constant:18.0],
        [agreeButton.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:36.0],
        [agreeButton.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-36.0],
        [agreeButton.heightAnchor constraintEqualToConstant:48.0],

        [declineButton.topAnchor constraintEqualToAnchor:agreeButton.bottomAnchor constant:6.0],
        [declineButton.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24.0],
        [declineButton.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-24.0],
        [declineButton.heightAnchor constraintEqualToConstant:44.0],
        [declineButton.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-12.0],
    ]];
}

- (NSAttributedString *)attributedConsentMessage {
    NSString *message = self.class.consentMessage;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 5.0;
    paragraphStyle.paragraphSpacing = 2.0;
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc]
        initWithString:message
            attributes:@{
                NSFontAttributeName : [UIFont systemFontOfSize:15.0],
                NSForegroundColorAttributeName : [UIColor colorWithWhite:0.20 alpha:1.0],
                NSParagraphStyleAttributeName : paragraphStyle,
            }];
    NSRange policyRange = [message rangeOfString:IFLYDemoPrivacyPolicyName];
    if (policyRange.location != NSNotFound) {
        [attributed addAttribute:NSLinkAttributeName value:self.class.privacyPolicyURL range:policyRange];
    }
    return attributed;
}

- (void)agreeButtonTapped {
    if (self.agreeHandler) {
        self.agreeHandler();
    }
}

- (void)declineButtonTapped {
    if (self.declineHandler) {
        self.declineHandler();
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView
    shouldInteractWithURL:(NSURL *)URL
                  inRange:(NSRange)characterRange
              interaction:(UITextItemInteraction)interaction {
    (void)textView;
    (void)characterRange;
    (void)interaction;
    if (self.URLOpener) {
        self.URLOpener(URL);
    }
    return NO;
}

@end
