//
//  DDStateMachineWriter.h
//  example
//
//  Created by Daniel on 2019/5/16.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDStateMachine.h"
#import "DDStateRule.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDStateMachineWriter : NSObject

- (void)beginWriteCompositeMachine:(DDStateMachine *)machine;
- (void)endWriteCompositeMachine:(DDStateMachine *)machine;
- (void)writeStateMachine:(DDStateMachine *)from rule:(DDStateRule *)rule to:(DDStateMachine *)to;

- (NSString *)markdownText;

@end

@interface DDStateMachineMarkdownWriter : DDStateMachineWriter

@end

NS_ASSUME_NONNULL_END
