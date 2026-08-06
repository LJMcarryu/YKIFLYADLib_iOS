#import "IFLYNativeViewController.h"

#import "IFLYADUtil.h"
#import "demo/IFLYNativeFeedDemoImageLoader.h"
#import <IFLYADLib/IFLYADLib.h>

static NSInteger const IFLYNativeFeedDemoAdRow = 4;
static NSInteger const IFLYNativeFeedDemoRowCount = 13;
static NSString *const IFLYNativeFeedDemoContentCellIdentifier = @"youku-native-content";
static NSString *const IFLYNativeFeedDemoAdCellIdentifier = @"youku-native-ad";
static NSString *const IFLYNativeFeedDemoAdItemIdentifier = @"youku-native-stable-ad-item";

/// 数据层对象与稳定 itemIdentifier 同生命周期；Cell 复用不会替换这里的 Ad 或 DisplaySession。
@interface IFLYNativeFeedDemoItem : NSObject
@property (nonatomic, copy) NSString *itemIdentifier;
@property (nonatomic, strong) IFLYNativeFeedAd *ad;
@property (nonatomic, strong, nullable) IFLYNativeFeedDisplaySession *displaySession;
@property (nonatomic, assign) NSUInteger loadGeneration;
@property (nonatomic, assign) BOOL videoCoverVisible;
@property (nonatomic, copy, nullable) NSString *videoStatusText;
@end

@implementation IFLYNativeFeedDemoItem
@end

/// Cell 只拥有当前一次挂载返回的 Binding，绝不拥有或销毁逻辑广告条目。
@interface IFLYNativeFeedDemoCell : UITableViewCell
@property (nonatomic, strong, readonly, nullable) IFLYNativeFeedAdBinding *binding;
@property (nonatomic, strong, readonly, nullable) IFLYNativeFeedAd *boundAd;
@property (nonatomic, copy, readonly, nullable) NSString *representedItemIdentifier;
- (BOOL)attachDisplaySession:(IFLYNativeFeedDisplaySession *)displaySession
              itemIdentifier:(NSString *)itemIdentifier
                       error:(IFLYAdError *_Nullable *_Nullable)error;
- (void)detachBinding;
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
@property (nonatomic, strong, readwrite, nullable) IFLYNativeFeedAdBinding *binding;
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

- (IFLYNativeFeedAd *)boundAd {
    return self.binding.displaySession.ad;
}

- (BOOL)attachDisplaySession:(IFLYNativeFeedDisplaySession *)displaySession
              itemIdentifier:(NSString *)itemIdentifier
                       error:(IFLYAdError **)error {
    if (self.binding.isActive && self.binding.displaySession == displaySession &&
        [self.representedItemIdentifier isEqualToString:itemIdentifier]) {
        if (error) {
            *error = nil;
        }
        return YES;
    }
    [self detachBinding];

    IFLYNativeFeedAd *ad = displaySession.ad;
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

    IFLYNativeFeedAdBinding *binding = [displaySession attachWithViewBinder:binder error:error];
    if (!binding) {
        [self resetAfterFailedAttach];
        return NO;
    }
    self.binding = binding;
    return YES;
}

- (void)detachBinding {
    IFLYNativeFeedAdBinding *binding = self.binding;
    self.binding = nil;
    self.renderGeneration += 1;
    [self.imageRequest cancel];
    self.imageRequest = nil;
    [binding detach];
    self.representedItemIdentifier = nil;
    [self resetVisuals];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self detachBinding];
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
    hint.text = @"上下滚动让广告 Cell 离屏再回屏：数据层保留原 Ad + DisplaySession，Cell 仅 detach/attach Binding。";
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

    IFLYNativeFeedDisplaySession *session = self.adItem.displaySession;
    if (session) {
        if (session.isValid) {
            [self attachCurrentSessionToCell:adCell];
            return;
        }

        // TTL/视频截止时间只禁止下一次 attach；当前活动 Binding 不在 willDisplay 中强拆。
        BOOL cellKeepsCurrentBinding =
            adCell.binding.isActive && adCell.binding.displaySession == session;
        if (cellKeepsCurrentBinding || session.isAttached) {
            return;
        }
        [self clearCurrentItem];
        self.visibleAdCell = adCell;
        self.visibleAdItemIdentifier = IFLYNativeFeedDemoAdItemIdentifier;
    } else if (self.adItem.ad) {
        return;
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
    [adCell detachBinding];
    if (self.attachedAdCell == adCell) {
        self.attachedAdCell = nil;
    }
    if (self.visibleAdCell == adCell) {
        self.visibleAdCell = nil;
        self.visibleAdItemIdentifier = nil;
    }

    // 数据源变化后 indexPath 可能已过期。这里只 detach 回调 Cell 自己持有的 Binding，
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

- (BOOL)attachCurrentSessionToCell:(IFLYNativeFeedDemoCell *)cell {
    IFLYNativeFeedDemoItem *item = self.adItem;
    IFLYNativeFeedDisplaySession *session = item.displaySession;
    if (!cell || !session || !session.isValid || session.ad != item.ad) {
        return NO;
    }
    if (cell.binding.isActive && cell.binding.displaySession == session) {
        self.attachedAdCell = cell;
        return YES;
    }

    IFLYAdError *error = nil;
    BOOL attached = [cell attachDisplaySession:session
                                itemIdentifier:item.itemIdentifier
                                         error:&error];
    if (attached) {
        self.attachedAdCell = cell;
        if (item.ad.adData.materialType == IFLYNativeFeedAdMaterialTypeVideo) {
            // attach 内可能同步恢复播放并先触发 delegate；稳定条目保存该状态，待 Binding
            // 写入 Cell 后再回填，避免封面继续遮住已经恢复的播放器。
            [cell setVideoCoverVisible:item.videoCoverVisible text:item.videoStatusText];
        }
        NSString *state = session.hasExposed ? @"已恢复原广告（不重复曝光）"
                                             : @"已挂载原广告（重新累计连续可见时长）";
        [self updateStatus:state color:[IFLYADUtil demoTealColor]];
    } else if (!session.isAttached) {
        [self updateStatus:[NSString stringWithFormat:@"挂载失败：%@",
                                                      [IFLYADUtil summaryForError:error]]
                      color:UIColor.redColor];
        // valid 在前置检查与实际 attach 之间可能因 TTL/视频截止时间到达而变为 NO。
        // 当前已无活动 Binding，直接淘汰旧会话并为仍可见的稳定条目请求新广告。
        if (!session.isValid && self.visibleAdCell == cell &&
            [self.visibleAdItemIdentifier isEqualToString:item.itemIdentifier]) {
            [self clearCurrentItem];
            [self startLoadingCurrentItem];
        }
    }
    return attached;
}

- (void)continueDisplayingItemAfterCellDetached:(NSString *)itemIdentifier {
    IFLYNativeFeedDemoCell *visibleCell = self.visibleAdCell;
    if (!visibleCell || visibleCell.binding ||
        ![self.visibleAdItemIdentifier isEqualToString:itemIdentifier]) {
        return;
    }

    IFLYNativeFeedDisplaySession *session = self.adItem.displaySession;
    if (!session || session.isAttached) {
        return;
    }
    if (session.isValid) {
        [self attachCurrentSessionToCell:visibleCell];
        return;
    }

    // 到期发生在活动 Binding 期间时，等待该 Binding 正常 detach 后才淘汰旧条目。
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
    if ((item.displaySession && attachedCell.binding.displaySession == item.displaySession) ||
        (item.ad && attachedCell.boundAd == item.ad)) {
        [attachedCell detachBinding];
    }
    IFLYNativeFeedDemoCell *visibleCell = self.visibleAdCell;
    if (visibleCell != attachedCell &&
        ((item.displaySession && visibleCell.binding.displaySession == item.displaySession) ||
         (item.ad && visibleCell.boundAd == item.ad))) {
        [visibleCell detachBinding];
    }
    // 逻辑条目淘汰的固定顺序：Cell detach -> Session end -> Ad destroy。
    [item.displaySession endDisplaySession];
    item.ad.delegate = nil;
    [item.ad destroy];
}

#pragma mark - Actions

- (void)slotSelectionChanged:(UISegmentedControl *)sender {
    [self clearCurrentItem];
    [self updateStatus:@"已切换广告位，原逻辑条目已淘汰" color:[IFLYADUtil demoIndigoColor]];
    if (self.visibleAdCell) {
        [self startLoadingCurrentItem];
    }
}

- (void)reportMediaShakeTriggered {
    IFLYNativeFeedAd *ad = self.adItem.ad;
    if (!ad || self.visibleAdCell.boundAd != ad || !self.visibleAdCell.binding.isActive) {
        [self updateStatus:@"媒体摇一摇忽略：当前没有活动 Binding" color:UIColor.grayColor];
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

    // attach 内同步回调时 Cell 尚未保存新 Binding；先更新数据层，attach 返回后会回填。
    // 其他时刻只更新真实 Binding owner，旧 Cell 的迟到事件不会污染新 Cell。
    IFLYNativeFeedDemoCell *cell = self.attachedAdCell;
    if (cell.boundAd != ad) {
        cell = self.visibleAdCell;
    }
    if (cell.boundAd == ad) {
        [cell setVideoCoverVisible:visible text:text];
    }
}

#pragma mark - IFLYNativeFeedAdDelegate

- (void)nativeFeedAdDidLoad:(IFLYNativeFeedAd *)ad {
    IFLYNativeFeedDemoItem *item = self.adItem;
    if (ad != item.ad || item.loadGeneration != self.loadGeneration) {
        return;
    }

    IFLYAdError *error = nil;
    IFLYNativeFeedDisplaySession *session = [ad beginDisplaySessionWithError:&error];
    if (!session) {
        [self updateStatus:[NSString stringWithFormat:@"创建 DisplaySession 失败：%@",
                                                      [IFLYADUtil summaryForError:error]]
                      color:UIColor.redColor];
        [self clearCurrentItem];
        return;
    }
    item.displaySession = session;
    [self updateStatus:@"数据层已保存 Ad + DisplaySession" color:[IFLYADUtil demoIndigoColor]];
    if (self.visibleAdCell && !self.visibleAdCell.binding) {
        [self attachCurrentSessionToCell:self.visibleAdCell];
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
    if (ad == self.adItem.ad && self.visibleAdCell.boundAd == ad) {
        [self updateStatus:@"当前 Cell Binding 已生效" color:[IFLYADUtil demoTealColor]];
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
