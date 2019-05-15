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

- (NSArray<DDStateRule *> *)allRules;
- (void)enumerateRulesBlock:(void (^)(DDStateRule *rule, DDStateMachine *machine))block;
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

- (NSArray<DDStateRule *> *)allRules {
    NSMutableArray *array = [NSMutableArray new];
    __auto_type enumerator = _ruleWithMachine.keyEnumerator;
    DDStateRule *rule = nil;
    while ((rule = [enumerator nextObject])) {
        [array addObject:rule];
    }
    
    return array;
}

- (void)enumerateRulesBlock:(void (^)(DDStateRule *, DDStateMachine *))block {
    NSParameterAssert(block);
    __auto_type enumerator = _ruleWithMachine.keyEnumerator;
    DDStateRule *rule = nil;
    while ((rule = [enumerator nextObject])) {
        block(rule, [_ruleWithMachine objectForKey:rule]);
    };
}

- (void)addRule:(DDStateRule *)rule toMachine:(DDStateMachine *)machine {
    [_ruleWithMachine setObject:machine forKey:rule];
}

- (void)nextStateMachineWithResult:(NSString *)result params:(NSDictionary *)params result:(void(^NS_NOESCAPE)(DDStateRule *, DDStateMachine *))block {
    NSParameterAssert(block);
    __auto_type enumerator = _ruleWithMachine.keyEnumerator;
    DDStateRule *rule = nil;
    while ((rule = [enumerator nextObject])) {
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
    DDCompositeStateRules *rules = [_rules objectForKey:stateMachine];
    [rules nextStateMachineWithResult:result params:params result:^(DDStateRule *rule, DDStateMachine *machine) {
        if (machine == self->_end) {
            if (!self.isCancelled) {
                [self.delegate stateMachine:self finishWithResult:result params:params];
                if (self.completionBlock) {
                    self.completionBlock(result, params);
                }
            }
        }
        else {
            machine.delegate = self;
            [machine startWithParams:params];
        }
    }];
}

- (void)addRule:(DDStateRule *)rule from:(DDStateMachine *)from to:(DDStateMachine *)to {
    DDCompositeStateRules *rules = [_rules objectForKey:from];
    if (rules == nil) {
        rules = [DDCompositeStateRules new];
        [_rules setObject:rules forKey:from];
    }
    [rules addRule:rule toMachine:to];
}

- (BOOL)checkRuleCompleteWithError:(NSError * _Nullable __autoreleasing *)error {
    NSMutableString *errorString = [NSMutableString new];
    DDStateMachine *machine = nil;
    __auto_type machineEnumerator = _rules.keyEnumerator;
    while ((machine = machineEnumerator.nextObject)) {
        if ([machine isKindOfClass:DDCompositeStateMachine.class]) {
            NSError *e = nil;
            if (![(DDCompositeStateMachine *)machine checkRuleCompleteWithError:&e]) {
                [errorString appendString:e.localizedDescription ?: @""];
            }
            continue;
        }
        
        __auto_type validResults = machine.validResults;
        __auto_type rules = [[_rules objectForKey:machine] allRules];
        for (NSString *result in validResults) {
            BOOL found = NO;
            for (DDStateRule *rule in rules) {
                if ([rule obeyWithResult:result params:nil]) {
                    found = YES;
                    break;
                }
            }
            if (found) {
                break;
            }
            else {
                // Not found, add error
                [errorString appendFormat:@"<%@> %@ do not obey result(%@); ", NSStringFromClass(machine.class), machine.debugName, result];
            }
        }
    }
    if (errorString.length) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.statemachine" code:-1 userInfo:@{NSLocalizedDescriptionKey: errorString}];
        }
        return NO;
    }
    return YES;
}

- (void)debugWriteMarkdownText:(DDStateMachineWriter *)writer {
    NSMutableString *stream = [NSMutableString new];
    
    [writer beginWriteCompositeMachine:self];
    
    DDStateMachine *machine = nil;
    __auto_type machineEnumerator = _rules.keyEnumerator;
    while ((machine = machineEnumerator.nextObject)) {
        if ([machine isKindOfClass:DDCompositeStateMachine.class]) {
            [(DDCompositeStateMachine *)machine debugWriteMarkdownText:writer];
            continue;
        }
        
        [stream appendString:@"\n"];
        __auto_type rules = [_rules objectForKey:machine];
        [rules enumerateRulesBlock:^(DDStateRule *rule, DDStateMachine *toMachine) {
            [writer writeStateMachine:machine rule:rule to:toMachine];
        }];
    }
    
    [writer endWriteCompositeMachine:self];
}

@end
