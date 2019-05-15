//
//  DDStateMachineFactory.m
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DDStateMachineBuilder.h"
#import "DDStateRule.h"

@implementation DDStateMachineBuilder {
    DDCompositeStateMachine *_machine;
}

+ (DDCompositeStateMachine *)buildCompositeStateMachine:(void (^)(DDStateMachineBuilder * _Nonnull))builder {
    DDStateMachineBuilder *b = [DDStateMachineBuilder new];
    builder(b);
    return b->_machine;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _machine = [DDCompositeStateMachine new];
    }
    return self;
}

- (DDStateMachine *)start {
    return _machine.start;
}

- (DDStateMachine *)end {
    return _machine.end;
}

- (void)bindMachine:(DDStateMachine *)machine withResult:(NSString *)result to:(DDStateMachine *)to traceLog:(NSString *)trace {
    if (result) {
        DDStateResultRule *rule = [DDStateResultRule new];
        rule.traceLog = trace;
        rule.result = result;
        [_machine addRule:rule from:machine to:to];
    }
    else {
        DDStateRule *rule = [DDStateRule new];
        rule.traceLog = trace;
        [_machine addRule:rule from:machine to:to];
    }
}

- (void)bindMachine:(DDStateMachine *)machine withResult:(NSString *)result to:(DDStateMachine *)to {
    [self bindMachine:machine withResult:result to:to traceLog:nil];
}

- (void)bindMachine:(DDStateMachine *)machine to:(DDStateMachine *)to {
    [self bindMachine:machine withResult:nil to:to];
}

- (DDStateMachine *)name:(NSString *)name check:(BOOL (^)(NSDictionary * _Nonnull))block {
    NSParameterAssert(block);
    DDBlockStateMachine *machine = [DDBlockStateMachine stateMachineWithBlock:^(DDBlockStateMachine * _Nonnull machine, NSDictionary * _Nonnull params, DDBlockStateMachineCompletionBlock  _Nonnull completion) {
        BOOL result = block(params);
        completion(result ? DDStateMachineResultYes : DDStateMachineResultNo, nil);
    }];
    machine.debugName = name;
    return machine;
}

@end
