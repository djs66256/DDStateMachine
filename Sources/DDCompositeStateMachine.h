//
//  DDCompositeStateMachine.h
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DDStateMachine.h"
#import "DDStateRule.h"
#import "DDStateMachineWriter.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDCompositeStateMachine : DDStateMachine

@property (nonatomic, strong, readonly) DDStateMachine *start;
@property (nonatomic, strong, readonly) DDStateMachine *end;

@property (nonatomic, strong) DDBlockStateMachineCompletionBlock completionBlock;

- (void)addRule:(DDStateRule *)rule from:(DDStateMachine *)from to:(DDStateMachine *)to;

- (BOOL)checkRuleCompleteWithError:(NSError **)error;
- (void)debugWriteMarkdownText:(DDStateMachineWriter *)writer;

@end

NS_ASSUME_NONNULL_END
