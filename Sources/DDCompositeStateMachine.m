//
//  DDCompositeStateMachine.m
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DDCompositeStateMachine.h"

@interface DDCompositeStateRules : NSObject {
    NSMapTable<DDStateRule *, DDStateMachine *> *_ruleWithMachine;
}

- (void)addRule:(DDStateRule *)rule toMachine:(DDStateMachine *)machine;
- (void)nextStateMachineWithResult:(NSString *)result params:(NSDictionary *)params result:(void(^NS_NOESCAPE)(DDStateRule *, DDStateMachine *))block;

@end

@implementation DDCompositeStateRules

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ruleWithMachine = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (void)addRule:(DDStateRule *)rule toMachine:(DDStateMachine *)machine {
    [_ruleWithMachine setObject:machine forKey:rule];
}

- (void)nextStateMachineWithResult:(NSString *)result params:(NSDictionary *)params result:(void(^NS_NOESCAPE)(DDStateRule *, DDStateMachine *))block {
    NSParameterAssert(block);
    __auto_type enumerator = _ruleWithMachine.keyEnumerator;
    DDStateRule *rule = nil;
    while (rule = [enumerator nextObject]) {
        if ([rule obeyWithResult:result params:params]) {
            DDStateMachine *machine = [_ruleWithMachine objectForKey:rule];
            block(rule, machine);
            return;
        }
    }
    block(nil, nil);
}

@end

@interface DDCompositeStateMachine () <DDStateMachineDelegate>

@property (nonatomic, strong) NSMapTable<DDStateMachine *, DDCompositeStateRules *> *rules;
@property (nonatomic, strong) NSMutableDictionary *params;

@end

@implementation DDCompositeStateMachine
@synthesize start = _start, end = _end;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _rules = [NSMapTable strongToStrongObjectsMapTable];
        
    }
    return self;
}

- (DDStateMachine *)start {
    if (_start == nil) {
        _start = [DDContinueStateMachine new];
        _start.delegate = self;
    }
    return _start;
}

- (DDStateMachine *)end {
    if (_end == nil) {
        _end = [DDContinueStateMachine new];
        _end.delegate = self;
    }
    return _end;
}

- (void)startWithParams:(NSDictionary *)params {
    NSParameterAssert(_start);
    _params = params.mutableCopy;
    [_start startWithParams:params];
}

- (void)stateMachine:(DDStateMachine *)stateMachine finishWithResult:(NSString *)result params:(NSDictionary *)params {
    if (params) {
        [_params addEntriesFromDictionary:params];
    }
    
    params = _params.copy;
    if (stateMachine == _end) {
        if (!self.isCancelled) {
            [self.delegate stateMachine:self finishWithResult:result params:params];
            if (self.completionBlock) {
                self.completionBlock(result, params);
            }
        }
    }
    else {
        DDCompositeStateRules *rules = [_rules objectForKey:stateMachine];
        [rules nextStateMachineWithResult:result params:params result:^(DDStateRule *rule, DDStateMachine *machine) {
            machine.delegate = self;
            [machine startWithParams:params];
        }];
    }
}

- (void)addRule:(DDStateRule *)rule from:(DDStateMachine *)from to:(DDStateMachine *)to {
    DDCompositeStateRules *rules = [_rules objectForKey:from];
    if (rules == nil) {
        rules = [DDCompositeStateRules new];
        [_rules setObject:rules forKey:from];
    }
    [rules addRule:rule toMachine:to];
}

@end
