//
//  DDStateMachine.h
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDStateMachineContext.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString * DDStateMachineResult;

typedef NS_ENUM(NSInteger, DDStateMachineType) {
    DDStateMachineTypeDefault,
    DDStateMachineTypeBoolean,
    DDStateMachineTypeStartEnd,
};

@class DDStateMachine;
@protocol DDStateMachineDelegate <NSObject>

- (void)stateMachine:(DDStateMachine *)stateMachine finishWithResult:(nullable DDStateMachineResult)result params:(nullable NSDictionary *)params;

@end

@interface DDStateMachine : NSObject {
    @protected
    NSArray<NSString *> *_validResults;
}

@property (nonatomic, weak) id<DDStateMachineDelegate> delegate;

@property (nonatomic, strong, readonly) DDStateMachineContext *context;
@property (nonatomic, assign, readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, assign, readonly, getter=isExcuting) BOOL excuting;
@property (nonatomic, assign, nullable) dispatch_queue_t queue;

// for override
- (void)startWithParams:(nullable NSDictionary *)params;
- (void)mainWithParams:(nullable NSDictionary *)params;
- (void)cancelWithParams:(nullable NSDictionary *)params NS_REQUIRES_SUPER;

/**
 Must call finish when this state finished.

 @param result <#result description#>
 @param params <#params description#>
 */
- (void)finishWithResult:(nullable DDStateMachineResult)result params:(nullable NSDictionary *)params;

// for debug
@property (nonatomic, assign) DDStateMachineType debugType;
@property (nonatomic, strong, nullable) NSString *debugName;
@property (nonatomic, strong, nullable) NSArray<NSString *> *validResults;

@end

@class DDBlockStateMachine;
typedef void (^DDBlockStateMachineCompletionBlock)(DDStateMachineResult _Nullable result, NSDictionary * _Nullable params);
typedef void (^DDBlockStateMachineBlock)(DDBlockStateMachine *machine,
                                         NSDictionary * _Nullable params,
                                         DDBlockStateMachineCompletionBlock completion);

@interface DDBlockStateMachine : DDStateMachine

@property (nonatomic, strong) DDBlockStateMachineBlock block;

+ (instancetype)stateMachineWithBlock:(DDBlockStateMachineBlock)block;
+ (instancetype)stateMachineWithBlock:(DDBlockStateMachineBlock)block validResults:(nullable NSArray<NSString *> *)validResults;

@end

@interface DDContinueStateMachine : DDStateMachine

@end

NS_ASSUME_NONNULL_END
