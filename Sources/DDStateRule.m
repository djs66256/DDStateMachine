//
//  DDStateRule.m
//  example
//
//  Created by Daniel on 2019/5/14.
//  Copyright © 2019 Daniel. All rights reserved.
//

#import "DDStateRule.h"

@implementation DDStateRule

- (BOOL)obeyWithResult:(NSString *)result params:(NSDictionary *)params {
    return YES;
}

@end

@implementation DDStateResultRule

- (BOOL)obeyWithResult:(NSString *)result params:(NSDictionary *)params {
    if (self.result) {
        return [self.result isEqualToString:result];
    }
    else {
        return YES;
    }
}

@end
