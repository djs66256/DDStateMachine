//
//  DDStateRule.h
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DDStateMachine.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDStateRule : NSObject

@property (nonatomic, strong) NSString *traceLog;

- (BOOL)obeyWithResult:(DDStateMachineResult _Nullable)result params:(NSDictionary *)params;

@end

@interface DDStateResultRule : DDStateRule

@property (nonatomic, strong, nullable) DDStateMachineResult result;

@end

NS_ASSUME_NONNULL_END
