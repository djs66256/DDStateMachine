//
//  DDStateMachine.m
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#include <stdatomic.h>
#import "DDStateMachine.h"
#import "DDStateMachine+Private.h"

@implementation DDStateMachine {
    atomic_bool _cancelled, _excuting;
}

- (BOOL)isCancelled {
    return atomic_load(&_cancelled);
}

- (BOOL)isExcuting {
    return atomic_load(&_excuting);
}

- (void)mainWithParams:(NSDictionary *)params {
    
}

- (void)startWithParams:(NSDictionary *)params {
    if (!atomic_load(&_cancelled) && !atomic_load(&_excuting)) {
        atomic_store(&_excuting, YES);
        if (self.queue) {
            dispatch_async(self.queue, ^{
                if (atomic_load(&self->_cancelled)) {
                    atomic_store(&self->_excuting, NO);
                }
                else {
                    [self mainWithParams:params];
                }
            });
        }
        else {
            [self mainWithParams:params];
        }
    }
}

- (void)cancelWithParams:(NSDictionary *)params {
    atomic_store(&_cancelled, YES);
    atomic_store(&_excuting, NO);
}

- (void)finishWithResult:(NSString *)result params:(NSDictionary *)params {
    atomic_store(&_excuting, NO);
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
    
    __weak __auto_type weakSelf = self;
    self.block(self, params, ^(NSString * _Nonnull result, NSDictionary * _Nonnull params) {
        __strong __auto_type strongSelf = weakSelf;
        [strongSelf finishWithResult:result params:params];
    });
}

@end

@implementation DDContinueStateMachine

- (void)mainWithParams:(NSDictionary *)params {
    [self finishWithResult:nil params:params];
}

@end
