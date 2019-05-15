//
//  DDStateMachineBuilder+UIKit.h
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DDStateMachineBuilder.h"
#import "DDUIAlertViewStateMachine.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDStateMachineBuilder (UIKit)

- (DDUIAlertViewStateMachine *)name:(NSString *)name
                     alertWithTitle:(NSString * _Nullable)title
                            message:(NSString * _Nullable)message
                            actions:(void(^)(DDUIAlertViewStateMachine *machine))block;

- (DDStateMachine *)name:(NSString *)name toast:(NSString *)text;
- (DDStateMachine *)name:(NSString *)name request:(NSURLRequest *(^)(NSDictionary *params))request completion:(void(^)(NSURLRequest *request, NSURLResponse *response, NSDictionary *params, DDBlockStateMachineCompletionBlock completion))block;

@end

NS_ASSUME_NONNULL_END
