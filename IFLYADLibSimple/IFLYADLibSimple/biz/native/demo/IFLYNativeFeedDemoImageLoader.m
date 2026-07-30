#import "IFLYNativeFeedDemoImageLoader.h"

typedef NS_ENUM(NSUInteger, IFLYNativeFeedDemoImageRequestState) {
    IFLYNativeFeedDemoImageRequestStatePending,
    IFLYNativeFeedDemoImageRequestStateCancelled,
    IFLYNativeFeedDemoImageRequestStateCompletionStarted,
};

@interface IFLYNativeFeedDemoImageRequestToken : NSObject <IFLYNativeFeedDemoImageRequest>
@property (nonatomic, strong) NSLock *stateLock;
@property (nonatomic, strong, nullable) NSURLSessionDataTask *task;
@property (nonatomic, assign) IFLYNativeFeedDemoImageRequestState state;
- (void)setTaskAndResume:(NSURLSessionDataTask *)task;
- (void)completeWithBlock:(dispatch_block_t)block;
@end

@implementation IFLYNativeFeedDemoImageRequestToken

- (instancetype)init {
    self = [super init];
    if (self) {
        _stateLock = [[NSLock alloc] init];
        _state = IFLYNativeFeedDemoImageRequestStatePending;
    }
    return self;
}

- (void)cancel {
    [self.stateLock lock];
    NSURLSessionDataTask *task = nil;
    if (self.state == IFLYNativeFeedDemoImageRequestStatePending) {
        self.state = IFLYNativeFeedDemoImageRequestStateCancelled;
        task = self.task;
        self.task = nil;
    }
    [self.stateLock unlock];
    [task cancel];
}

- (void)setTaskAndResume:(NSURLSessionDataTask *)task {
    [self.stateLock lock];
    BOOL shouldResume = self.state == IFLYNativeFeedDemoImageRequestStatePending;
    if (shouldResume) {
        self.task = task;
    }
    [self.stateLock unlock];
    if (shouldResume) {
        [task resume];
    } else {
        [task cancel];
    }
}

- (void)completeWithBlock:(dispatch_block_t)block {
    [self.stateLock lock];
    BOOL shouldComplete = self.state == IFLYNativeFeedDemoImageRequestStatePending;
    if (shouldComplete) {
        self.state = IFLYNativeFeedDemoImageRequestStateCompletionStarted;
        self.task = nil;
    }
    [self.stateLock unlock];
    if (shouldComplete) {
        block();
    }
}

@end

@interface IFLYNativeFeedDemoImageLoader ()
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSCache<NSString *, UIImage *> *cache;
@end

@implementation IFLYNativeFeedDemoImageLoader

- (instancetype)init {
    return [self initWithSessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:configuration];
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (nullable id<IFLYNativeFeedDemoImageRequest>)loadImageWithURLString:(nullable NSString *)URLString
                                                            completion:(IFLYNativeFeedDemoImageCompletion)completion {
    NSString *trimmedURLString = [URLString stringByTrimmingCharactersInSet:
                                  NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSURL *URL = [NSURL URLWithString:trimmedURLString];
    NSString *scheme = URL.scheme.lowercaseString;
    if (!URL || !([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
        return nil;
    }

    UIImage *cachedImage = [self.cache objectForKey:URL.absoluteString];
    if (cachedImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(cachedImage);
        });
        return nil;
    }

    IFLYNativeFeedDemoImageRequestToken *token = [[IFLYNativeFeedDemoImageRequestToken alloc] init];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:URL
                                             completionHandler:^(NSData *data,
                                                                 NSURLResponse *response,
                                                                 NSError *error) {
        UIImage *image = error == nil ? [UIImage imageWithData:data] : nil;
        if (image) {
            [weakSelf.cache setObject:image forKey:URL.absoluteString];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [token completeWithBlock:^{
                completion(image);
            }];
        });
    }];
    [token setTaskAndResume:task];
    return token;
}

- (void)dealloc {
    [_session invalidateAndCancel];
}

@end
