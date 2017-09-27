//
//  APPInfo.h
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/9/22.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

#import <CoreData/CoreData.h>

//#import "APPInfo3+CoreDataClass.h"
//#import "APPInfo3+CoreDataProperties.h"
//
//#import "APPInfo3+CoreDataClass.m"
//#import "APPInfo3+CoreDataProperties.m"

NS_ASSUME_NONNULL_BEGIN

@interface APPInfo : NSManagedObject

+ (NSFetchRequest<APPInfo *> *)fetchRequest;

+(void)runTest;


@property (nonatomic) NSString * name;
@property (nonatomic) int16_t appid;

@end
NS_ASSUME_NONNULL_END

//#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface APPInfo3 : NSManagedObject
//
//@end
//
//NS_ASSUME_NONNULL_END
//
//#import "APPInfo3+CoreDataProperties.h"

//NS_ASSUME_NONNULL_BEGIN
//
//@interface APPInfo3 (CoreDataProperties)
//
//+ (NSFetchRequest<APPInfo3 *> *)fetchRequest;
//
//@property (nonatomic) int16_t appid;
//@property (nullable, nonatomic, copy) NSString *name;
//
//@end
//
//NS_ASSUME_NONNULL_END

