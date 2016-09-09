//
//  JZCateViewController.h
//  chuanke
//
//  Created by dfjty on 16/9/9.
//  Copyright © 2016年 chenshun131. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JZCateViewController : UIViewController

// zhibo 和 feizhibo    时必须传的参数
@property(nonatomic, strong) NSString *cateType;/**< 课程类型 @"zhibo";@"feizhibo"*/

// feizhibo  时必须传的参数
@property(nonatomic, strong) NSMutableArray *cateNameArray;/**< 课程名数组 */
@property(nonatomic, strong) NSMutableArray *cateIDArray;/**< 课程ID数组 */

@end
