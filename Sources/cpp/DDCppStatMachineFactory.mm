//
//  DDCppStatMachineFactory.cpp
//  example
//
//  Created by Daniel on 2019/5/15.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DDCppStatMachineFactory.h"

namespace DD {
namespace StateMachine {
    
    StateMachine Builder::check(NSString *name, BOOL(^block)(NSDictionary *params)) {
        auto machine = [DDBlockStateMachine stateMachineWithBlock:^(DDBlockStateMachine * _Nonnull machine, NSDictionary * _Nullable params, DDBlockStateMachineCompletionBlock  _Nonnull completion) {
                        if (block(params)) {
                        completion(Result::Yes, nil);
                        }
                        else {
                        completion(Result::No, nil);
                        }
                        }];
        machine.debugName = name;
        machine.context = context_;
        return StateMachine(machine, compositeMachine_);
    }
    StateMachine Builder::alert(NSString *name, NSString *title, NSString *message, void (^actions)(DDUIAlertViewStateMachine *)) {
        NSCParameterAssert(actions);
        DDUIAlertViewStateMachine *machine = [DDUIAlertViewStateMachine new];
        machine.debugName = name;
        machine.context = context_;
        machine.title = title;
        machine.message = message;
        actions(machine);
        return StateMachine(machine, compositeMachine_);
    }
    
    StateMachine Builder::toast(NSString *name, NSString *text) {
        DDStateMachine *machine = [DDBlockStateMachine stateMachineWithBlock:^(DDBlockStateMachine * _Nonnull machine, NSDictionary * _Nullable params, DDBlockStateMachineCompletionBlock  _Nonnull completion) {
                                   [SVProgressHUD showSuccessWithStatus:text];
                                   completion(nil, nil);
                                   }];
        machine.debugName = name;
        machine.context = context_;
        return StateMachine(machine, compositeMachine_);
    }
    
    StateMachine Builder::request(NSString *name, NSURLRequest *(^requestBlock)(NSDictionary * ), void (^completionBlock)(NSURLRequest *, NSURLResponse *, NSDictionary *, DDBlockStateMachineCompletionBlock)) {
        DDStateMachine *machine = [DDBlockStateMachine stateMachineWithBlock:^(DDBlockStateMachine * _Nonnull machine, NSDictionary * _Nullable params, DDBlockStateMachineCompletionBlock  _Nonnull completion) {
                                   NSURLRequest *req = requestBlock(params);
                                   [[NSURLSession.sharedSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                     completionBlock(req, response, params, completion);
                                     }] resume];
                                   }];
        machine.debugName = name;
        machine.context = context_;
        return StateMachine(machine, compositeMachine_);
    }
    
}
}
