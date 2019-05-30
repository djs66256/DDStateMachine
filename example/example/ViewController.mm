//
//  ViewController.m
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "ViewController.h"
#import "DDStateMachineBuilder.h"
#import "DDStateMachineBuilder+UIKit.h"
#import "DDStateMachine+Private.h"
#import "DDCppStatMachineFactory.h"
#import "DDStateMachineWriter.h"

@interface ViewController ()
@property (nonatomic, strong) DDCompositeStateMachine *stateMachine;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self cppMachine];
}

- (BOOL)isLogin {
    return YES;
}
- (BOOL)isOffline {
    return NO;
}

- (void)ocMachine {
    self.stateMachine = [DDStateMachineBuilder buildCompositeStateMachine:^(DDStateMachineBuilder * _Nonnull b) {
        auto checkNetwork = [b name:@"网络连接" check:^BOOL(NSDictionary * _Nullable params) {
            return YES;
        }];
        auto checkLogin = [b name:@"用户登录" check:^BOOL(NSDictionary * _Nullable params) {
            return YES;
        }];
        auto praiseRequest = [b name:@"点赞请求" request:^NSURLRequest * _Nonnull(NSDictionary * _Nonnull params) {
            return [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
        } completion:^(NSURLRequest * _Nonnull request, NSURLResponse * _Nonnull response, NSDictionary * _Nonnull params, DDBlockStateMachineCompletionBlock  _Nonnull completion) {
            completion(DDStateMachineResultSuccess, nil);
        }];
        
        auto alert = [b name:@"更新UI" alertWithTitle:@"更新UI" message:nil actions:^(DDUIAlertViewStateMachine * _Nonnull machine) {
            [machine addAction:@"确定" style:UIAlertActionStyleDefault result:DDStateMachineResultSuccess];
            [machine addAction:@"取消" style:UIAlertActionStyleCancel result:DDStateMachineResultFailure];
        }];
        alert.context = [DDStateMachineContext new];
        alert.context.viewController = self;
        
        auto successToast = [b name:@"提示" toast:@"请求成功"];
        auto failureToast = [b name:@"提示" toast:@"请求失败"];
        
        [b bindMachine:b.start to:checkNetwork];
        
        [b bindMachine:checkNetwork withResult:DDStateMachineResultYes to:checkLogin];
        [b bindMachine:checkNetwork withResult:DDStateMachineResultNo to:b.end];
        
        [b bindMachine:checkLogin withResult:DDStateMachineResultYes to:praiseRequest];
        [b bindMachine:checkLogin withResult:DDStateMachineResultNo to:b.end];
        
        [b bindMachine:praiseRequest withResult:DDStateMachineResultSuccess to:alert];
        [b bindMachine:praiseRequest withResult:DDStateMachineResultFailure to:b.end];
        
        [b bindMachine:alert withResult:DDStateMachineResultSuccess to:successToast];
        [b bindMachine:alert withResult:DDStateMachineResultFailure to:failureToast];
        
        [b bindMachine:successToast to:b.end];
        [b bindMachine:failureToast to:b.end];
    }];
    [self.stateMachine setCompletionBlock:^(DDStateMachineResult  _Nullable result, NSDictionary * _Nullable params) {
        NSLog(@"%@: %@", result, params);
    }];
    
    [self.stateMachine startWithParams:@{@"test": @"Test Value"}];
}

- (void)origin {
    if ([self isOffline]) {
        return;
    }
    if (![self isLogin]) {
        return;
    }
    
    auto completion = ^(){
        NSLog(@"Finished!");
    };
    
    auto url = [NSURL URLWithString:@"http://www.baidu.com"];
    [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            auto alert = [UIAlertController alertControllerWithTitle:@"更新UI" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [SVProgressHUD showSuccessWithStatus: @"请求成功"];
                completion();
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [SVProgressHUD showSuccessWithStatus: @"请求失败"];
                completion();
            }]];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
        }
    }];
}

- (void)cppMachine {
    using namespace DD::StateMachine;
    auto ctx = [DDStateMachineContext new];
    ctx.viewController = self;
    auto b = Builder(ctx);
    
    auto checkNetwork = b.check(^BOOL(NSDictionary *params) {
        return ![self isOffline];
    }).debugName(@"网络连接");
    auto checkLogin = b.check(^BOOL(NSDictionary * _Nullable params) {
        return [self isLogin];
    }).debugName(@"用户登录");
    auto praiseRequest = b.request(^NSURLRequest * _Nonnull(NSDictionary * _Nonnull params) {
        return [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    }, ^(NSURLRequest * _Nonnull request, NSURLResponse * _Nonnull response, NSDictionary * _Nonnull params, DDBlockStateMachineCompletionBlock  _Nonnull completion) {
        completion(DDStateMachineResultSuccess, nil);
    }).debugName(@"点赞请求");
    
//    auto alert = b.alert(@"更新UI", nil, ^(DDUIAlertViewStateMachine * _Nonnull machine) {
//        [machine addAction:@"确定" style:UIAlertActionStyleDefault result:DDStateMachineResultSuccess];
//        [machine addAction:@"取消" style:UIAlertActionStyleCancel result:DDStateMachineResultFailure];
//    }).debugName(@"更新UI");
    
    auto successToast = b.toast(@"请求成功").debugName(@"提示");
    auto failureToast = b.toast(@"请求失败").debugName(@"提示");
    
    b.start()
        >> checkNetwork;
    
    checkNetwork
        >> Result::Yes >> Trace(@"online") >> checkLogin
        >> Result::No >> b.end();
    
    checkLogin
        >> Result::Yes >> Trace(@"login") >> praiseRequest
        >> Result::No >> b.end();
    
    praiseRequest
        >> Result::Success >> Trace(@"praised")>> successToast
        >> Result::Failure >> failureToast;
    
//    alert
//        >> Result::Success >> successToast
//        >> Result::Failure >> failureToast;
    
    successToast
        >> b.end();
    
    failureToast
        >> b.end();
    
    
    auto machine = b.compositeMachine();
    self.stateMachine = machine;
    
    [self.stateMachine setCompletionBlock:^(DDStateMachineResult  _Nullable result, NSDictionary * _Nullable params) {
        NSLog(@"%@: %@", result, params);
    }];
    
    [self.stateMachine startWithParams:@{@"test": @"Test Value"}];
    
    DDStateMachineMarkdownWriter *writer = [DDStateMachineMarkdownWriter new];
    [self.stateMachine debugWriteMarkdownText:writer];
    NSLog(@"%@", writer.markdownText);
    
    NSError *error = nil;
    [self.stateMachine checkRuleCompleteWithError:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }
}


@end
