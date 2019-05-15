//
//  DDStateMachineBuilder+UIKit.m
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DDStateMachineBuilder+UIKit.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation DDStateMachineBuilder (UIKit)

- (DDUIAlertViewStateMachine *)name:(NSString *)name alertWithTitle:(NSString *)title message:(NSString *)message actions:(void (^)(DDUIAlertViewStateMachine * _Nonnull))block {
    NSParameterAssert(block);
    DDUIAlertViewStateMachine *machine = [DDUIAlertViewStateMachine new];
    machine.debugName = name;
    machine.title = title;
    machine.message = message;
    block(machine);
    return machine;
}

- (DDStateMachine *)name:(NSString *)name toast:(NSString *)text {
    DDStateMachine *machine = [DDBlockStateMachine stateMachineWithBlock:^(DDBlockStateMachine * _Nonnull machine, NSDictionary * _Nullable params, DDBlockStateMachineCompletionBlock  _Nonnull completion) {
        [SVProgressHUD showSuccessWithStatus:text];
        completion(nil, nil);
    } validResults:nil];
    machine.debugName = name;
    return machine;
}

- (DDStateMachine *)name:(NSString *)name request:(NSURLRequest * _Nonnull (^)(NSDictionary * _Nonnull))request completion:(void (^)(NSURLRequest * _Nonnull, NSURLResponse * _Nonnull, NSDictionary * _Nonnull, DDBlockStateMachineCompletionBlock _Nonnull))block {
    DDStateMachine *machine = [DDBlockStateMachine stateMachineWithBlock:^(DDBlockStateMachine * _Nonnull machine, NSDictionary * _Nullable params, DDBlockStateMachineCompletionBlock  _Nonnull completion) {
        NSURLRequest *req = request(params);
        [[NSURLSession.sharedSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            block(req, response, params, completion);
        }] resume];
    }];
    machine.debugName = name;
    return machine;
}

@end
