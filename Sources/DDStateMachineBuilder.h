//
//  DDStateMachineFactory.h
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DDStateMachine.h"
#import "DDCompositeStateMachine.h"
#import "DDStateMachineResultConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDStateMachineBuilder : NSObject

+ (DDCompositeStateMachine *)buildCompositeStateMachine:(void (^)(DDStateMachineBuilder *b))builder;

@property (nonatomic, strong, readonly) DDStateMachine *start;
@property (nonatomic, strong, readonly) DDStateMachine *end;

- (void)bindMachine:(DDStateMachine *)machine withResult:(NSString * _Nullable )result to:(DDStateMachine *)to traceLog:(nullable NSString *)trace;
- (void)bindMachine:(DDStateMachine *)machine withResult:(NSString * _Nullable )result to:(DDStateMachine *)to;
- (void)bindMachine:(DDStateMachine *)machine to:(DDStateMachine *)to;

- (DDStateMachine *)name:(NSString *)name check:(BOOL (^)(NSDictionary * _Nullable params))block;

@end

NS_ASSUME_NONNULL_END
