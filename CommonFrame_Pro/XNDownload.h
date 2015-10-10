//
//  XNDownload.h
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/9.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XNDownload : NSObject

@property (nonatomic, strong) NSString * fileName;

// 保存在沙盒中的文件路径
@property (nonatomic, strong) NSString *cachePath;

- (void)downloadWithURL:(NSURL *)url progress:(void (^)(float))progress;

@end
