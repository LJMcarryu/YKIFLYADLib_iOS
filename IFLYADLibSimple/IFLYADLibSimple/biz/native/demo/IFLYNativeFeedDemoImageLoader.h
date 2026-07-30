#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^IFLYNativeFeedDemoImageCompletion)(UIImage *_Nullable image);

@protocol IFLYNativeFeedDemoImageRequest <NSObject>
- (void)cancel;
@end

@protocol IFLYNativeFeedDemoImageLoading <NSObject>
- (nullable id<IFLYNativeFeedDemoImageRequest>)loadImageWithURLString:(nullable NSString *)URLString
                                                            completion:(IFLYNativeFeedDemoImageCompletion)completion;
@end

@interface IFLYNativeFeedDemoImageLoader : NSObject <IFLYNativeFeedDemoImageLoading>
- (instancetype)init;
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
    NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
