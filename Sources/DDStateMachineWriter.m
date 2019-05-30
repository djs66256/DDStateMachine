//
//  DDStateMachineWriter.m
//  example
//
//  Created by Daniel on 2019/5/16.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DDStateMachineWriter.h"

@implementation DDStateMachineWriter

- (void)writeStateMachine:(DDStateMachine *)from rule:(DDStateRule *)rule to:(DDStateMachine *)to {
    
}

@end


@implementation DDStateMachineMarkdownWriter {
    NSMutableDictionary<NSString *, NSNumber *> *_classIndexMap;
    NSMapTable<DDStateMachine *, NSString *> *_nameMap;
    NSMutableString *_stream;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _stream = [NSMutableString new];
        _nameMap = [NSMapTable strongToStrongObjectsMapTable];
        _classIndexMap = [NSMutableDictionary new];
    }
    return self;
}

- (NSString *)nameWithMachine:(DDStateMachine *)machine {
    NSString *name = [_nameMap objectForKey:machine];
    if (name == nil) {
        NSString *className = NSStringFromClass(machine.class);
        NSNumber *number = [_classIndexMap objectForKey:className];
        NSInteger idx = number.integerValue + 1;
        _classIndexMap[className] = @(idx);
        
        name = [NSString stringWithFormat:@"%@%zd", className, idx];
        [_nameMap setObject:name forKey:machine];
    }
    
    return name;
}

- (void)beginWriteCompositeMachine:(DDStateMachine *)machine {
    [_stream appendString:@"\n"];
}

- (void)endWriteCompositeMachine:(DDStateMachine *)machine {
    [_stream appendString:@"\n"];
}

- (void)writeStateMachine:(DDStateMachine *)from rule:(DDStateRule *)rule to:(DDStateMachine *)to {
    NSString *fromName = [self nameWithMachine:from];
    NSString *toName = [self nameWithMachine:to];
    
    [_stream appendString:fromName];
    if (from.debugName) {
        switch (from.debugType) {
            case DDStateMachineTypeDefault:
                [_stream appendString:@"("];
                [_stream appendString:from.debugName];
                [_stream appendString:@")"];
                break;
            case DDStateMachineTypeBoolean:
                [_stream appendString:@"{"];
                [_stream appendString:from.debugName];
                [_stream appendString:@"}"];
                break;
            case DDStateMachineTypeStartEnd:
                [_stream appendString:@"["];
                [_stream appendString:from.debugName];
                [_stream appendString:@"]"];
                break;
            default:
                break;
        }
    }
    [_stream appendString:@" --> "];
    NSString *ruleName = rule.name;
    if (ruleName.length > 0) {
        [_stream appendFormat:@"|%@| ", ruleName];
    }
    [_stream appendString:toName];
    if (to.debugName) {
        switch (to.debugType) {
            case DDStateMachineTypeDefault:
                [_stream appendString:@"("];
                [_stream appendString:to.debugName];
                [_stream appendString:@")"];
                break;
            case DDStateMachineTypeBoolean:
                [_stream appendString:@"{"];
                [_stream appendString:to.debugName];
                [_stream appendString:@"}"];
                break;
            case DDStateMachineTypeStartEnd:
                [_stream appendString:@"["];
                [_stream appendString:to.debugName];
                [_stream appendString:@"]"];
                break;
            default:
                break;
        }
    }
    [_stream appendString:@"\n"];
}

- (NSString *)markdownText {
    NSMutableString *stream = [NSMutableString new];
    [stream appendString:@"```mermaid\ngraph TD\n"];
    [stream appendString:_stream];
    [stream appendString:@"```"];
    return stream;
}

@end

