//
//  DDCppStatMachineFactory.h
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#ifndef DDCppStatMachineFactory_h
#define DDCppStatMachineFactory_h

#import "DDStateMachineBuilder.h"
#import "DDStateMachineResultConstants.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "DDStateMachine+Private.h"
#import "DDUIAlertViewStateMachine.h"

namespace DD {
namespace StateMachine {
    namespace Result {
        static constexpr DDStateMachineResult Yes = @"YES";
        static constexpr DDStateMachineResult No = @"NO";
        static constexpr DDStateMachineResult Ok = @"ok";
        static constexpr DDStateMachineResult Cancelled = @"cancelled";
        static constexpr DDStateMachineResult Success = @"success";
        static constexpr DDStateMachineResult Failure = @"failure";
    }
    
    class Trace {
    public:
        explicit Trace() {}
        explicit Trace(NSString *log) : log_(log) {}
        NSString *log() { return log_; }
        void reset() {
            log_ = nil;
        }
    private:
        NSString *log_;
    };
    
    class StateMachine {
    public:
        enum class Type {
            Default = DDStateMachineTypeDefault,
            Boolean = DDStateMachineTypeBoolean,
            StartEnd = DDStateMachineTypeStartEnd,
        };
        
        explicit StateMachine(DDStateMachine *machine, DDCompositeStateMachine *compositeMachine) :
            machine_(machine),
            compositeMachine_(compositeMachine) {}
        
        StateMachine& debugName(NSString *name) {
            machine_.debugName = name;
            return *this;
        }
        
        StateMachine& debugType(Type type) {
            machine_.debugType = (DDStateMachineType)type;
            return *this;
        }
        
        StateMachine& operator >> (NSString *result) {
            result_ = result;
            return *this;
        }
        StateMachine& operator >> (Trace&& trace) {
            trace_ = trace;
            return *this;
        }
        StateMachine& operator >> (StateMachine&& machine) {
            return operator>>(machine.machine_);
        }
        StateMachine& operator >> (StateMachine& machine) {
            return operator>>(machine.machine_);
        }
        StateMachine& operator >> (DDStateMachine *machine) {
            DDStateRule *rule = nil;
            if (result_ == nil) {
                rule = [DDStateRule new];
            }
            else {
                rule = ({
                    auto r = [DDStateResultRule new];
                    r.result = result_;
                    r;
                });
            }
            rule.traceLog = trace_.log();
            [compositeMachine_ addRule:rule from:machine_ to:machine];
            
            result_ = nil;
            trace_.reset();
            
            return *this;
        }
    private:
        Trace trace_;
        NSString *result_;
        DDStateMachine *machine_;
        DDCompositeStateMachine *compositeMachine_;
    };
    
    class Builder {
    public:
        Builder(DDStateMachineContext *ctx) : context_(ctx) {}
        
        StateMachine start() {
            return StateMachine(compositeMachine_.start, compositeMachine_).debugName(@"Start");
        }
        StateMachine end() {
            return StateMachine(compositeMachine_.end, compositeMachine_).debugName(@"End");
        }
        
        StateMachine check(BOOL(^block)(NSDictionary *params));
        StateMachine alert(NSString *title, NSString *message, void (^actions)(DDUIAlertViewStateMachine *));
        
        StateMachine toast(NSString *text);
        
        StateMachine request(NSURLRequest *(^requestBlock)(NSDictionary * ), void (^completionBlock)(NSURLRequest *, NSURLResponse *, NSDictionary *, DDBlockStateMachineCompletionBlock));
        
        DDCompositeStateMachine *compositeMachine() { return compositeMachine_; }
    private:
        DDStateMachineContext *context_;
        DDCompositeStateMachine *compositeMachine_ = [DDCompositeStateMachine new];
    };
}
}

#endif /* DDCppStatMachineFactory_h */
