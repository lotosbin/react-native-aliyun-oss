#import "AliyunOSSModule.h"
@import Foundation;

@implementation AliyunOSSModule {
    OSSClient *client;
}
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(AliyunOSSModule)

RCT_EXPORT_METHOD(initWithAppKey:(NSString*) endpoint
        accessKeyId:(NSString*) accessKeyId
        accessKeySecret:(NSString*) accessKeySecret)
{
    NSLog(@"intiWithAppKey:%@,%@,%@",endpoint,accessKeyId,accessKeySecret);
    // 明文设置secret的方式建议只在测试时使用，更多鉴权模式请参考后面的访问控制章节
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:accessKeyId secretKey:accessKeySecret];
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 3; // 网络请求遇到异常失败后的重试次数
    conf.timeoutIntervalForRequest = 30; // 网络请求的超时时间
    conf.timeoutIntervalForResource = 24 * 60 * 60; // 允许资源传输的最长时间
    client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential clientConfiguration:conf];
}
RCT_EXPORT_METHOD(upload:(NSString*)bucketName
        objectKey:(NSString*) objectKey
        uploadFilePath:(NSString*) uploadFilePath
        resolver:(RCTPromiseResolveBlock)resolve
        rejecter:(RCTPromiseRejectBlock)reject)
{
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];

    put.bucketName = bucketName;
    put.objectKey = objectKey;

//    NSData *data = [[NSFileManager defaultManager] contentsAtPath:uploadFilePath];
    NSString* path = [NSURL URLWithString:uploadFilePath].path;
    NSData *data = [NSData dataWithContentsOfFile:path];

//    put.uploadingFileURL = [NSURL fileURLWithPath:uploadFilePath];
    put.uploadingData = data; // 直接上传NSData
    
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };

    OSSTask * putTask = [client putObject:put];

    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"upload object success!");
            resolve(@[[NSNull null], [NSNull null]]);
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
            NSString* msg = [NSString stringWithFormat:@"%@" ,task.error];
            reject(msg, msg, nil);
        }
        return nil;
    }];

// 可以等待任务完成
// [putTask waitUntilFinished];
}
@end
