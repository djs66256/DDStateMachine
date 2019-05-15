//
//  DDUIAlertViewStateMachine.m
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DDUIAlertViewStateMachine.h"

@interface DDUIAlertViewStateMachineAction : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) DDStateMachineResult result;
@property (nonatomic, assign) UIAlertActionStyle style;

@end

@implementation DDUIAlertViewStateMachineAction

@end

@implementation DDUIAlertViewStateMachine {
    NSMutableArray<DDUIAlertViewStateMachineAction *> *_actions;
}

- (void)addAction:(NSString *)title style:(UIAlertActionStyle)style result:(DDStateMachineResult)result {
    if (_actions == nil) {
        _actions = [NSMutableArray new];
    }
    [_actions addObject:({
        DDUIAlertViewStateMachineAction *action = [DDUIAlertViewStateMachineAction new];
        action.title = title;
        action.style = style;
        action.result = result;
        action;
    })];
}

- (void)startWithParams:(NSDictionary *)params {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.title
                                                                   message:self.message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    __weak __auto_type weakSelf = self;
    for (DDUIAlertViewStateMachineAction *action in _actions) {
        NSString *result = action.result;
        [alert addAction:[UIAlertAction actionWithTitle:action.title
                                                  style:action.style
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    __strong __auto_type strongSelf = weakSelf;
                                                    [strongSelf finishWithResult:result params:nil];
                                                }]];
    }
    [self.context.viewController presentViewController:alert animated:YES completion:^{
        
    }];
}

- (NSArray<NSString *> *)validResults {
    NSMutableArray *array = [NSMutableArray new];
    for (DDUIAlertViewStateMachineAction *action in _actions) {
        [array addObject:action.result];
    }
    return array;
}

@end
