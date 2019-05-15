//
//  DDUIAlertViewStateMachine.h
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDStateMachine.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDUIAlertViewStateMachine : DDStateMachine

@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, strong, nullable) NSString *message;

- (void)addAction:(NSString *)title style:(UIAlertActionStyle)style result:(DDStateMachineResult)result;

@end

NS_ASSUME_NONNULL_END
