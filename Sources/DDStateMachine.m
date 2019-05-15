//
//  DDStateMachine.m
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DDStateMachine.h"
#import "DDStateMachine+Private.h"

@implementation DDStateMachine

- (void)mainWithParams:(NSDictionary *)params {
    
}

- (void)startWithParams:(NSDictionary *)params {
    if (!_cancelled) {
        [self mainWithParams:params];
    }
}

- (void)cancelWithParams:(NSDictionary *)params {
    _cancelled = YES;
}

- (void)finishWithResult:(NSString *)result params:(NSDictionary *)params {
    if (!self.isCancelled) {
        [self.delegate stateMachine:self finishWithResult:result params:params];
    }
}

@end

@implementation DDBlockStateMachine

+ (instancetype)stateMachineWithBlock:(DDBlockStateMachineBlock)block validResults:(NSArray<NSString *> *)validResults {
    DDBlockStateMachine *machine = [DDBlockStateMachine new];
    machine.block = block;
    machine->_validResults = validResults;
    return machine;
}

+ (instancetype)stateMachineWithBlock:(DDBlockStateMachineBlock)block {
    return [self stateMachineWithBlock:block validResults:nil];
}

- (void)mainWithParams:(NSDictionary *)params {
    NSParameterAssert(self.block);
    if (self.queue) {
        dispatch_async(self.queue, ^{
            __weak __auto_type weakSelf = self;
            if (!self.isCancelled) {
                self.block(self, params, ^(NSString * _Nonnull result, NSDictionary * _Nonnull params) {
                    __strong __auto_type strongSelf = weakSelf;
                    [strongSelf finishWithResult:result params:params];
                });
            }
        });
    }
    else {
        __weak __auto_type weakSelf = self;
        self.block(self, params, ^(NSString * _Nonnull result, NSDictionary * _Nonnull params) {
            __strong __auto_type strongSelf = weakSelf;
            [strongSelf finishWithResult:result params:params];
        });
    }
}

@end

@implementation DDContinueStateMachine

- (void)mainWithParams:(NSDictionary *)params {
    [self finishWithResult:nil params:params];
}

@end
