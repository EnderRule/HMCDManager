//
//  APPInfo.m
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/9/22.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

#import "APPInfo.h"
#import "HMCDManager-Swift.h"

@implementation APPInfo

+ (NSFetchRequest<APPInfo *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"APPInfo"];
}

-(void)didChangeValueForKey:(NSString *)key{
    NSLog(@"did change %@",key);
}
@dynamic appid;
@dynamic name;
 
+(void)runTest{
    
    APPInfo *app = [APPInfo newObj];
    app.name = @"fsffssf";
    app.appid = arc4random()%30000;
    
    [app db_updateWithCompletion:^(NSString * _Nullable error) {
        if(error){
            NSLog(@" test updae %@",error );
        }
    }];
    
    [APPInfo db_queryWithOffset:0 limitCount:0 success:^(NSArray<NSManagedObject *> * _Nonnull objs) {
        for (APPInfo *obj in objs){
            NSLog(@"query obj %@ %d",obj.name,obj.appid );
        }
    } failure:^(NSString * _Nonnull error ) {
        NSLog(@"query error:%@",error );
    }];
}

@end
