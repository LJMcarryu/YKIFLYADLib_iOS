//
//  ViewController.m
//  IFLYADLibSimple
//
//  Created by admin on 3.3.25.
//

#import "IFLYInterstitialViewController.h"
#import "IFLYNativeFeedPresentationDemoViewController.h"
#import "IFLYNativeViewController.h"
#import "IFLYSplashViewController.h"
#import "ViewController.h"

#import "IFLYADUtil.h"
#import <IFLYADLib/IFLYADLib.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"优酷定制 SDK 示例";
    self.view.backgroundColor = UIColor.whiteColor;
    [self initADTypeListView];
}

- (void)initADTypeListView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];

    CGFloat width = self.view.bounds.size.width;
    CGFloat margin = 24;
    CGFloat contentWidth = width - margin * 2;
    CGFloat y = 24;

    UILabel *versionLabel =
        [IFLYADUtil createSectionTitleWithText:[NSString stringWithFormat:@"SDK Version: %@", [IFLYAdTool sdkVersion]]
                                         frame:CGRectMake(margin, y, contentWidth, 20)];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:versionLabel];
    y += 36;

    UILabel *descLabel = [IFLYADUtil
        createSectionTitleWithText:@"仅演示优酷交付范围：开屏、插屏和自渲染信息流；同时提供开屏、插屏的自渲染视觉示例。"
                             frame:CGRectMake(margin, y, contentWidth, 52)];
    descLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:descLabel];
    y += 72;

    NSArray<NSDictionary<NSString *, NSString *> *> *items = @[
        @{@"title" : @"开屏广告", @"selector" : @"splashADTypeClick:"},
        @{@"title" : @"插屏广告", @"selector" : @"interstitialADTypeClick:"},
        @{@"title" : @"自渲染开屏", @"selector" : @"nativeSplashADTypeClick:"},
        @{@"title" : @"自渲染插屏", @"selector" : @"nativeInterstitialADTypeClick:"},
        @{@"title" : @"自渲染信息流示例", @"selector" : @"nativeFeedADTypeClick:"},
    ];

    for (NSDictionary<NSString *, NSString *> *item in items) {
        SEL selector = NSSelectorFromString(item[@"selector"]);
        UIButton *button = [IFLYADUtil createADTypeButtonWithFrame:CGRectMake(margin, y, contentWidth, 48)
                                                             title:item[@"title"]
                                                            target:self
                                                            action:selector];
        [scrollView addSubview:button];
        y += 62;
    }

    scrollView.contentSize = CGSizeMake(width, y + 24);
}

- (void)splashADTypeClick:(UIButton *)sender {
    [self.navigationController pushViewController:IFLYSplashViewController.alloc.init animated:YES];
}

- (void)nativeSplashADTypeClick:(UIButton *)sender {
    IFLYNativeFeedPresentationDemoViewController *controller =
        [[IFLYNativeFeedPresentationDemoViewController alloc]
            initWithPresentationStyle:IFLYNativeFeedDemoPresentationStyleSplash];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)nativeInterstitialADTypeClick:(UIButton *)sender {
    IFLYNativeFeedPresentationDemoViewController *controller =
        [[IFLYNativeFeedPresentationDemoViewController alloc]
            initWithPresentationStyle:IFLYNativeFeedDemoPresentationStyleInterstitial];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)nativeFeedADTypeClick:(UIButton *)sender {
    [self.navigationController pushViewController:IFLYNativeViewController.alloc.init animated:YES];
}

- (void)interstitialADTypeClick:(UIButton *)sender {
    [self.navigationController pushViewController:IFLYInterstitialViewController.alloc.init animated:YES];
}

@end
