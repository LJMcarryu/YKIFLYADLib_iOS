#import "IFLYNativeViewController.h"

#import "IFLYADUtil.h"
#import "demo/IFLYNativeFeedDemoImageLoader.h"
#import <IFLYADLib/IFLYADLib.h>

static NSInteger const IFLYNativeFeedDemoAdRow = 4;
static NSInteger const IFLYNativeFeedDemoRowCount = 13;
static NSString *const IFLYNativeFeedDemoContentCellIdentifier = @"youku-native-content";
static NSString *const IFLYNativeFeedDemoAdCellIdentifier = @"youku-native-ad";
static NSString *const IFLYNativeFeedDemoAdItemIdentifier = @"youku-native-stable-ad-item";

/// 数据层对象与稳定 itemIdentifier 同生命周期；SDK 托管视图会话，媒体数据层只持有 Ad。
@interface IFLYNativeFeedDemoItem : NSObject
@property (nonatomic, copy) NSString *itemIdentifier;
@property (nonatomic, strong) IFLYNativeFeedAd *ad;
@property (nonatomic, assign) NSUInteger loadGeneration;
@property (nonatomic, assign) BOOL videoCoverVisible;
@property (nonatomic, copy, nullable) NSString *videoStatusText;
@end

@implementation IFLYNativeFeedDemoItem
@end

/// Cell 只维护媒体 UI，不保存 Session、Binding、Ad 或首次/复用状态。
@interface IFLYNativeFeedDemoCell : UITableViewCell
@property (nonatomic, copy, readonly, nullable) NSString *representedItemIdentifier;
- (BOOL)configureWithAd:(IFLYNativeFeedAd *)ad
         itemIdentifier:(NSString *)itemIdentifier
                  error:(IFLYAdError *_Nullable *_Nullable)error;
- (void)detachFromContainer;
- (void)setVideoCoverVisible:(BOOL)visible text:(nullable NSString *)text;
@end

@interface IFLYNativeFeedDemoCell ()
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIView *mediaView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *mediaPlaceholderLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *adBadgeLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) IFLYNativeFeedDemoImageLoader *imageLoader;
@property (nonatomic, strong, nullable) id<IFLYNativeFeedDemoImageRequest> imageRequest;
@property (nonatomic, copy, readwrite, nullable) NSString *representedItemIdentifier;
@property (nonatomic, assign) NSUInteger renderGeneration;
@property (nonatomic, assign) BOOL videoCoverVisible;
@end

@implementation IFLYNativeFeedDemoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _imageLoader = [[IFLYNativeFeedDemoImageLoader alloc] init];

        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = UIColor.whiteColor;
        _cardView.layer.cornerRadius = 8.0;
        _cardView.layer.borderWidth = 1.0;
        _cardView.layer.borderColor = [UIColor colorWithWhite:0.86 alpha:1.0].CGColor;
        _cardView.clipsToBounds = YES;
        [self.contentView addSubview:_cardView];

        _mediaView = [[UIView alloc] init];
        _mediaView.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];
        _mediaView.clipsToBounds = YES;
        [_cardView addSubview:_mediaView];

        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        [_mediaView addSubview:_coverImageView];

        _mediaPlaceholderLabel = [[UILabel alloc] init];
        _mediaPlaceholderLabel.textAlignment = NSTextAlignmentCenter;
        _mediaPlaceholderLabel.textColor = UIColor.whiteColor;
        _mediaPlaceholderLabel.font = [UIFont systemFontOfSize:13.0];
        [_mediaView addSubview:_mediaPlaceholderLabel];

        _adBadgeLabel = [[UILabel alloc] init];
        _adBadgeLabel.text = @"广告";
        _adBadgeLabel.textAlignment = NSTextAlignmentCenter;
        _adBadgeLabel.font = [UIFont systemFontOfSize:10.0];
        _adBadgeLabel.textColor = UIColor.whiteColor;
        _adBadgeLabel.backgroundColor = [UIColor colorWithWhite:0.25 alpha:0.8];
        _adBadgeLabel.layer.cornerRadius = 3.0;
        _adBadgeLabel.clipsToBounds = YES;
        [_cardView addSubview:_adBadgeLabel];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
        _titleLabel.textColor = UIColor.blackColor;
        [_cardView addSubview:_titleLabel];

        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:13.0];
        _descLabel.textColor = [UIColor colorWithWhite:0.35 alpha:1.0];
        _descLabel.numberOfLines = 2;
        [_cardView addSubview:_descLabel];

        _closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _closeButton.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.75];
        _closeButton.layer.cornerRadius = 14.0;
        [_closeButton setTitle:@"×" forState:UIControlStateNormal];
        [_closeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_cardView addSubview:_closeButton];

        [self resetVisuals];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat margin = 12.0;
    CGFloat width = CGRectGetWidth(self.contentView.bounds) - margin * 2.0;
    self.cardView.frame = CGRectMake(margin, 8.0, width, CGRectGetHeight(self.contentView.bounds) - 16.0);
    CGFloat innerWidth = width - 24.0;
    self.mediaView.frame = CGRectMake(12.0, 12.0, innerWidth, 190.0);
    self.coverImageView.frame = self.mediaView.bounds;
    self.mediaPlaceholderLabel.frame = self.mediaView.bounds;
    self.closeButton.frame = CGRectMake(width - 40.0, 14.0, 28.0, 28.0);
    self.adBadgeLabel.frame = CGRectMake(12.0, 212.0, 38.0, 20.0);
    self.titleLabel.frame = CGRectMake(58.0, 208.0, width - 110.0, 26.0);
    self.descLabel.frame = CGRectMake(12.0, 238.0, innerWidth, 42.0);
}

- (BOOL)configureWithAd:(IFLYNativeFeedAd *)ad
         itemIdentifier:(NSString *)itemIdentifier
                  error:(IFLYAdError **)error {
    // Cell 可能在未触发 prepareForReuse 的情况下被直接改配。先按容器反注册旧视图，
    // 再修改媒体 UI；SDK 内部会隔离旧 generation，不需要媒体保存 Binding。
    [self detachFromContainer];

    IFLYNativeFeedAdData *data = ad.adData;
    if (!ad || !data || !data.isMaterialComplete ||
        data.materialType == IFLYNativeFeedAdMaterialTypeUnknown) {
        if (error) {
            *error = [IFLYAdError generateByCode:IFLYAdErrorCodeNativeFeedMaterialInvalid];
        }
        return NO;
    }

    self.representedItemIdentifier = [itemIdentifier copy];
    self.titleLabel.text = data.title ?: data.appName ?: data.brand ?: @"广告";
    self.descLabel.text = data.desc ?: data.content ?: data.ctaText ?: @"";
    self.adBadgeLabel.hidden = NO;
    self.closeButton.hidden = NO;
    BOOL isVideo = data.materialType == IFLYNativeFeedAdMaterialTypeVideo;
    [self setVideoCoverVisible:YES text:(isVideo ? @"视频加载中" : @"图片加载中")];

    NSString *imageURL = isVideo ? (data.videoCoverURL ?: data.mainImage.url)
                                 : data.imageURLs.firstObject;
    NSUInteger generation = self.renderGeneration;
    NSString *representedIdentifier = self.representedItemIdentifier;
    __weak typeof(self) weakSelf = self;
    self.imageRequest =
        [self.imageLoader loadImageWithURLString:imageURL
                                      completion:^(UIImage *image) {
                                          __strong typeof(weakSelf) self = weakSelf;
                                          if (!self || generation != self.renderGeneration ||
                                              ![self.representedItemIdentifier
                                                  isEqualToString:representedIdentifier]) {
                                              return;
                                          }
                                          self.coverImageView.image = image;
                                          if (isVideo) {
                                              self.coverImageView.hidden =
                                                  !self.videoCoverVisible || image == nil;
                                              self.mediaPlaceholderLabel.hidden =
                                                  !self.videoCoverVisible || image != nil;
                                          } else {
                                              self.coverImageView.hidden = image == nil;
                                              self.mediaPlaceholderLabel.hidden = image != nil;
                                          }
                                      }];

    IFLYNativeFeedAdViewBinder *binder = [[IFLYNativeFeedAdViewBinder alloc] init];
    binder.containerView = self.cardView;
    binder.renderViews = @[
        self.mediaView,
        self.coverImageView,
        self.mediaPlaceholderLabel,
        self.adBadgeLabel,
        self.titleLabel,
        self.descLabel,
        self.closeButton,
    ];
    BOOL clickable =
        data.interactionType == IFLYNativeFeedAdInteractionTypeRedirect ||
        data.interactionType == IFLYNativeFeedAdInteractionTypeDownload;
    // nil 会默认让整个容器可点击；纯曝光和未知行为必须显式传空数组。
    binder.clickViews = clickable ? @[ self.mediaView, self.titleLabel ] : @[];
    binder.closeView = self.closeButton;
    binder.videoView = isVideo ? self.mediaView : nil;
    binder.imageView = isVideo ? nil : self.coverImageView;
    binder.titleView = self.titleLabel;
    binder.descView = self.descLabel;
    binder.adSourceView = self.adBadgeLabel;

    if (![ad attachWithViewBinder:binder error:error]) {
        [IFLYNativeFeedAd detachAdFromContainerView:self.cardView];
        [self resetAfterFailedAttach];
        return NO;
    }
    return YES;
}

- (void)detachFromContainer {
    [IFLYNativeFeedAd detachAdFromContainerView:self.cardView];
    self.renderGeneration += 1;
    [self.imageRequest cancel];
    self.imageRequest = nil;
    self.representedItemIdentifier = nil;
    [self resetVisuals];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self detachFromContainer];
}

- (void)setVideoCoverVisible:(BOOL)visible text:(NSString *)text {
    self.videoCoverVisible = visible;
    self.coverImageView.hidden = !visible || self.coverImageView.image == nil;
    self.mediaPlaceholderLabel.hidden = !visible || self.coverImageView.image != nil;
    self.mediaPlaceholderLabel.text = text ?: @"";
}

- (void)resetAfterFailedAttach {
    self.renderGeneration += 1;
    [self.imageRequest cancel];
    self.imageRequest = nil;
    self.representedItemIdentifier = nil;
    [self resetVisuals];
}

- (void)resetVisuals {
    self.videoCoverVisible = NO;
    self.coverImageView.image = nil;
    self.coverImageView.hidden = YES;
    self.mediaPlaceholderLabel.hidden = NO;
    self.mediaPlaceholderLabel.text = @"等待广告条目进入屏幕";
    self.titleLabel.text = nil;
    self.descLabel.text = nil;
    self.adBadgeLabel.hidden = YES;
    self.closeButton.hidden = YES;
}

@end

@interface IFLYNativeViewController ()
    <UITableViewDataSource, UITableViewDelegate, IFLYNativeFeedAdDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *slotControl;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong, nullable) IFLYNativeFeedDemoItem *adItem;
@property (nonatomic, assign) NSUInteger loadGeneration;
@property (nonatomic, weak, nullable) IFLYNativeFeedDemoCell *visibleAdCell;
@property (nonatomic, weak, nullable) IFLYNativeFeedDemoCell *attachedAdCell;
@property (nonatomic, copy, nullable) NSString *visibleAdItemIdentifier;
@end

@implementation IFLYNativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自渲染信息流示例";
    self.view.backgroundColor = UIColor.whiteColor;

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"媒体摇一摇上报"
                                        style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(reportMediaShakeTriggered)];
    self.navigationItem.rightBarButtonItem.accessibilityIdentifier =
        @"nativeFeed.demo.reportMediaShake";

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:IFLYNativeFeedDemoContentCellIdentifier];
    [self.tableView registerClass:IFLYNativeFeedDemoCell.class
           forCellReuseIdentifier:IFLYNativeFeedDemoAdCellIdentifier];
    [self.view addSubview:self.tableView];
    [self configureTableHeader];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.isMovingFromParentViewController || self.isBeingDismissed ||
        self.navigationController.isBeingDismissed) {
        [self clearCurrentItem];
    }
}

- (void)dealloc {
    [self clearCurrentItem];
}

- (void)configureTableHeader {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 112.0)];
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 10.0, width - 32.0, 40.0)];
    hint.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    hint.numberOfLines = 2;
    hint.font = [UIFont systemFontOfSize:13.0];
    hint.textColor = [UIColor colorWithWhite:0.35 alpha:1.0];
    hint.text = @"上下滚动让广告 Cell 离屏再回屏：数据层只保留原 Ad，Cell 仅按容器 detach、按 Ad attach。";
    [header addSubview:hint];

    self.slotControl = [[UISegmentedControl alloc] initWithItems:@[ @"图文", @"视频" ]];
    self.slotControl.frame = CGRectMake(16.0, 54.0, width - 32.0, 30.0);
    self.slotControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.slotControl.selectedSegmentIndex = 0;
    [self.slotControl addTarget:self
                         action:@selector(slotSelectionChanged:)
               forControlEvents:UIControlEventValueChanged];
    [header addSubview:self.slotControl];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 88.0, width - 32.0, 18.0)];
    self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.statusLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium];
    self.statusLabel.textColor = [IFLYADUtil demoIndigoColor];
    self.statusLabel.text = @"等待广告条目进入屏幕";
    [header addSubview:self.statusLabel];
    self.tableView.tableHeaderView = header;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return IFLYNativeFeedDemoRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == IFLYNativeFeedDemoAdRow) {
        return [tableView dequeueReusableCellWithIdentifier:IFLYNativeFeedDemoAdCellIdentifier
                                                forIndexPath:indexPath];
    }

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:IFLYNativeFeedDemoContentCellIdentifier
                                        forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"内容行 %ld", (long)indexPath.row + 1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == IFLYNativeFeedDemoAdRow ? 304.0 : 64.0;
}

- (void)tableView:(UITableView *)tableView
 willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != IFLYNativeFeedDemoAdRow ||
        ![cell isKindOfClass:IFLYNativeFeedDemoCell.class]) {
        return;
    }

    IFLYNativeFeedDemoCell *adCell = (IFLYNativeFeedDemoCell *)cell;
    self.visibleAdCell = adCell;
    self.visibleAdItemIdentifier = IFLYNativeFeedDemoAdItemIdentifier;

    IFLYNativeFeedAd *ad = self.adItem.ad;
    if (ad) {
        if (!ad.adData) {
            return;
        }

        if ([self attachCurrentAdToCell:adCell]) {
            return;
        }

        // TTL/视频截止时间只禁止迁移或恢复。旧 Cell 仍活动时先等其离屏 detach，
        // 不用媒体查询或维护 SDK 内部会话状态。
        if (self.attachedAdCell && self.attachedAdCell != adCell) {
            return;
        }
        [self clearCurrentItem];
        self.visibleAdCell = adCell;
        self.visibleAdItemIdentifier = IFLYNativeFeedDemoAdItemIdentifier;
    }
    [self startLoadingCurrentItem];
}

- (void)tableView:(UITableView *)tableView
didEndDisplayingCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![cell isKindOfClass:IFLYNativeFeedDemoCell.class]) {
        return;
    }

    IFLYNativeFeedDemoCell *adCell = (IFLYNativeFeedDemoCell *)cell;
    NSString *itemIdentifier = adCell.representedItemIdentifier ?: IFLYNativeFeedDemoAdItemIdentifier;
    [adCell detachFromContainer];
    if (self.attachedAdCell == adCell) {
        self.attachedAdCell = nil;
    }
    if (self.visibleAdCell == adCell) {
        self.visibleAdCell = nil;
        self.visibleAdItemIdentifier = nil;
    }

    // 数据源变化后 indexPath 可能已过期。这里只按回调 Cell 的容器 detach，
    // 再用稳定 itemIdentifier 处理 willDisplay(new) 先于 didEndDisplaying(old) 的乱序。
    [self continueDisplayingItemAfterCellDetached:itemIdentifier];
}

#pragma mark - Stable item lifecycle

- (void)startLoadingCurrentItem {
    if (self.adItem) {
        return;
    }

    NSString *adUnitId = self.slotControl.selectedSegmentIndex == 1
                             ? __FEED_VIDEO_AD_UNIT_ID__
                             : __TYPED_ONE_NATIVE_AD_UNIT_ID__;
    if (adUnitId.length == 0) {
        [self updateStatus:@"请先配置优酷信息流广告位" color:UIColor.redColor];
        return;
    }

    self.loadGeneration += 1;
    IFLYNativeFeedDemoItem *item = [[IFLYNativeFeedDemoItem alloc] init];
    item.itemIdentifier = IFLYNativeFeedDemoAdItemIdentifier;
    item.loadGeneration = self.loadGeneration;
    item.videoCoverVisible = YES;
    item.videoStatusText = @"视频加载中";
    item.ad = [[IFLYNativeFeedAd alloc] initWithAdUnitId:adUnitId];
    item.ad.delegate = self;
    item.ad.currentViewController = self;
    item.ad.muteOnStart = YES;
    self.adItem = item;
    [self updateStatus:@"正在加载原逻辑广告条目" color:[IFLYADUtil demoIndigoColor]];
    [item.ad loadAdWithRequestConfig:[IFLYADUtil mediaSampleRequestConfig]];
}

- (BOOL)attachCurrentAdToCell:(IFLYNativeFeedDemoCell *)cell {
    IFLYNativeFeedDemoItem *item = self.adItem;
    IFLYNativeFeedAd *ad = item.ad;
    if (!cell || !ad || !ad.adData) {
        return NO;
    }

    // 重复的 willDisplay/didLoad 不需要媒体判断“首次还是复用”。当前容器的 UI 已配置时
    // 保持不变；SDK 对同一 Ad + 容器的重复 attach 也具备幂等语义。
    if (self.attachedAdCell == cell &&
        [cell.representedItemIdentifier isEqualToString:item.itemIdentifier]) {
        self.attachedAdCell = cell;
        return YES;
    }

    IFLYAdError *error = nil;
    BOOL attached = [cell configureWithAd:ad
                           itemIdentifier:item.itemIdentifier
                                    error:&error];
    if (attached) {
        self.attachedAdCell = cell;
        if (ad.adData.materialType == IFLYNativeFeedAdMaterialTypeVideo) {
            // attach 内可能同步恢复播放并先触发 delegate；稳定条目保存媒体封面状态，
            // attach 返回后再回填，避免封面继续遮住已经恢复的播放器。
            [cell setVideoCoverVisible:item.videoCoverVisible text:item.videoStatusText];
        }
        [self updateStatus:@"原广告已挂载；曝光与视频状态由 SDK 按逻辑条目恢复"
                      color:[IFLYADUtil demoTealColor]];
    } else {
        if (self.attachedAdCell == cell) {
            self.attachedAdCell = nil;
        }
        [self updateStatus:[NSString stringWithFormat:@"挂载失败：%@",
                                                      [IFLYADUtil summaryForError:error]]
                      color:UIColor.redColor];
    }
    return attached;
}

- (void)continueDisplayingItemAfterCellDetached:(NSString *)itemIdentifier {
    IFLYNativeFeedDemoCell *visibleCell = self.visibleAdCell;
    if (!visibleCell || self.attachedAdCell == visibleCell ||
        ![self.visibleAdItemIdentifier isEqualToString:itemIdentifier]) {
        return;
    }

    IFLYNativeFeedAd *ad = self.adItem.ad;
    if (!ad || !ad.adData) {
        return;
    }
    if ([self attachCurrentAdToCell:visibleCell] ||
        (self.attachedAdCell && self.attachedAdCell != visibleCell)) {
        return;
    }

    // 到期发生在活动挂载期间时，等待旧容器正常 detach 后才淘汰旧条目。
    [self clearCurrentItem];
    if (self.visibleAdCell == visibleCell &&
        [self.visibleAdItemIdentifier isEqualToString:itemIdentifier]) {
        [self startLoadingCurrentItem];
    }
}

- (void)clearCurrentItem {
    IFLYNativeFeedDemoItem *item = self.adItem;
    if (!item) {
        return;
    }
    self.loadGeneration += 1;
    self.adItem = nil;

    IFLYNativeFeedDemoCell *attachedCell = self.attachedAdCell;
    self.attachedAdCell = nil;
    if ([attachedCell.representedItemIdentifier isEqualToString:item.itemIdentifier]) {
        [attachedCell detachFromContainer];
    }
    IFLYNativeFeedDemoCell *visibleCell = self.visibleAdCell;
    if (visibleCell != attachedCell &&
        [visibleCell.representedItemIdentifier isEqualToString:item.itemIdentifier]) {
        [visibleCell detachFromContainer];
    }
    item.ad.delegate = nil;
    item.ad.currentViewController = nil;
    // 正常列表只需释放数据层的最后一个 Ad 强引用；SDK 自动收口请求、容器、
    // 手势、曝光、传感器和播放器。destroy 只用于仍持有 Ad 时主动提前终止。
    item.ad = nil;
}

#pragma mark - Actions

- (void)slotSelectionChanged:(UISegmentedControl *)sender {
    [self clearCurrentItem];
    [self updateStatus:@"已切换广告位，原逻辑条目已释放" color:[IFLYADUtil demoIndigoColor]];
    if (self.visibleAdCell) {
        [self startLoadingCurrentItem];
    }
}

- (void)reportMediaShakeTriggered {
    IFLYNativeFeedAd *ad = self.adItem.ad;
    if (!ad || !self.visibleAdCell || self.attachedAdCell != self.visibleAdCell ||
        ![self.visibleAdCell.representedItemIdentifier
            isEqualToString:self.adItem.itemIdentifier]) {
        [self updateStatus:@"媒体摇一摇忽略：当前没有活动挂载" color:UIColor.grayColor];
        return;
    }

    IFLYAdError *error = nil;
    BOOL accepted = [ad reportMediaShakeTriggeredWithError:&error];
    if (accepted) {
        [self updateStatus:@"媒体摇一摇已接受" color:[IFLYADUtil demoTealColor]];
    } else {
        [self updateStatus:[NSString stringWithFormat:@"媒体摇一摇失败：%@",
                                                      [IFLYADUtil summaryForError:error]]
                      color:UIColor.redColor];
    }
}

- (void)updateStatus:(NSString *)text color:(UIColor *)color {
    self.statusLabel.text = text;
    self.statusLabel.textColor = color;
    IFLYSampleLogInfo(@"NativeFeed列表复用", @"%@", text);
}

- (void)recordVideoCoverVisible:(BOOL)visible
                           text:(nullable NSString *)text
                          forAd:(IFLYNativeFeedAd *)ad {
    IFLYNativeFeedDemoItem *item = self.adItem;
    if (ad != item.ad) {
        return;
    }
    item.videoCoverVisible = visible;
    item.videoStatusText = text;

    // attach 内同步回调时先更新数据层，attach 返回后再回填当前 Cell。
    // 其他时刻只更新 Controller 记录的当前容器；旧容器迟到事件由 SDK generation 隔离。
    IFLYNativeFeedDemoCell *cell = self.attachedAdCell;
    if (cell && cell == self.visibleAdCell &&
        [cell.representedItemIdentifier isEqualToString:item.itemIdentifier]) {
        [cell setVideoCoverVisible:visible text:text];
    }
}

#pragma mark - IFLYNativeFeedAdDelegate

- (void)nativeFeedAdDidLoad:(IFLYNativeFeedAd *)ad {
    IFLYNativeFeedDemoItem *item = self.adItem;
    if (ad != item.ad || item.loadGeneration != self.loadGeneration) {
        return;
    }

    [self updateStatus:@"数据层只保存 Ad；会话与 Binding 由 SDK 托管"
                  color:[IFLYADUtil demoIndigoColor]];
    if (self.visibleAdCell && self.attachedAdCell != self.visibleAdCell) {
        [self attachCurrentAdToCell:self.visibleAdCell];
    }
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad didFailWithError:(IFLYAdError *)error {
    if (ad != self.adItem.ad) {
        return;
    }
    [self updateStatus:[NSString stringWithFormat:@"加载失败：%@",
                                                  [IFLYADUtil summaryForError:error]]
                  color:UIColor.redColor];
    [self clearCurrentItem];
}

- (void)nativeFeedAdDidRender:(IFLYNativeFeedAd *)ad {
    if (ad == self.adItem.ad && self.visibleAdCell == self.attachedAdCell) {
        [self updateStatus:@"当前 Cell 挂载已生效" color:[IFLYADUtil demoTealColor]];
    }
}

- (void)nativeFeedAdDidExpose:(IFLYNativeFeedAd *)ad {
    if (ad == self.adItem.ad) {
        [self updateStatus:@"原逻辑广告条目已曝光（后续恢复不重复曝光）"
                      color:[IFLYADUtil demoTealColor]];
    }
}

- (void)nativeFeedAdDidClose:(IFLYNativeFeedAd *)ad {
    if (ad != self.adItem.ad) {
        return;
    }
    [self clearCurrentItem];
    [self updateStatus:@"广告已关闭，逻辑条目已永久淘汰" color:UIColor.grayColor];
}

- (void)nativeFeedAdDidStartPlay:(IFLYNativeFeedAd *)ad {
    [self recordVideoCoverVisible:NO text:nil forAd:ad];
}

- (void)nativeFeedAdDidResumePlay:(IFLYNativeFeedAd *)ad {
    [self recordVideoCoverVisible:NO text:nil forAd:ad];
}

- (void)nativeFeedAdDidPausePlay:(IFLYNativeFeedAd *)ad {
    [self recordVideoCoverVisible:YES text:@"视频已暂停" forAd:ad];
}

- (void)nativeFeedAdDidPlayFinish:(IFLYNativeFeedAd *)ad {
    [self recordVideoCoverVisible:YES text:@"视频播放完成" forAd:ad];
}

- (void)nativeFeedAd:(IFLYNativeFeedAd *)ad
didFailToPlayWithError:(IFLYAdError *)error {
    (void)error;
    [self recordVideoCoverVisible:YES text:@"视频播放失败" forAd:ad];
}

@end
