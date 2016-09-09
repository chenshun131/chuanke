//
//  JZCateViewController.m
//  chuanke
//
//  Created by dfjty on 16/9/9.
//  Copyright © 2016年 chenshun131. All rights reserved.
//

#import "JZCateViewController.h"

@interface JZCateViewController ()

@end

@implementation JZCateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)OnTapSegmentCtr:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    if(0 == index)
    {
        
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
