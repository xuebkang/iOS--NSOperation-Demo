//
//  CustomOperation.h
//  多线程——NSOperation
//
//  Created by CJW on 2019/8/13.
//  Copyright © 2019 CJW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomOperation : NSOperation
- (instancetype)initWithName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
