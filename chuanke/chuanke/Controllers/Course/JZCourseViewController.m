//
//  JZCourseViewController.m
//  chuanke
//
//  Created by dfjty on 16/9/8.
//  Copyright © 2016年 chenshun131. All rights reserved.
//

#import "JZCourseViewController.h"
#import "JZSpeechViewController.h"
#import "ImageScrollCell.h"
#import "JZAlbumCell.h"
#import "JZCourseCell.h"
#import "JZCourseListModel.h"
#import "JZFocusListModel.h"
#import "JZCourseDetailViewController.h"
#import "JZCateViewController.h"
#import "MJRefresh.h"
#import "NetworkSingleton.h"
#import "SVProgressHUD.h"
#import "MJExtension.h"
#import "JZAlbumListModel.h"

@interface JZCourseViewController ()<UITableViewDelegate, UITableViewDataSource, ImageScrollViewDelegate, JZAlbumDelegate>
{
    NSMutableArray *_focusListArray;/**< 第一个轮播数据 */
    NSMutableArray *_focusImgurlArray;/**< 第一个轮播图片URL数据 */
    NSMutableArray *_courseListArray;/**< 列表数据 */
    NSMutableArray *_albumListArray;/**< 第二个轮播数据 */
    NSMutableArray *_albumImgurlArray;/**< 第二个轮播图片URL数据 */
    
    NSInteger _type;/**< segment */
    
    NSMutableArray *_classCategoryArray;/**< 课程分类数组 */
    NSMutableArray *_iCategoryListArray;/**< 课程类型 */
}

@end

@implementation JZCourseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initData];
    [self setNav];
    [self initTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    _focusListArray = [[NSMutableArray alloc] init];
    _focusImgurlArray = [[NSMutableArray alloc] init];
    _courseListArray = [[NSMutableArray alloc] init];
    _albumListArray = [[NSMutableArray alloc] init];
    _albumImgurlArray = [[NSMutableArray alloc] init];
    
    _type = 0;
    
    // 读取plist文件
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"classCategory" ofType:@"plist"];
    _classCategoryArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    // 课程类型
    NSString *iCategoryListPath = [[NSBundle mainBundle] pathForResource:@"iCategoryList" ofType:@"plist"];
    _iCategoryListArray = [[NSMutableArray alloc] initWithContentsOfFile:iCategoryListPath];
}

- (void)setNav
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 98)];
    backView.backgroundColor = navigationBarColor;
    [self.view addSubview:backView];
    
    // 创建 "点击这" UIButton
    UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nameBtn.frame = CGRectMake(10, 20, 60, 40);
    nameBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [nameBtn setTitle:@"点击这" forState:UIControlStateNormal];
    [nameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nameBtn addTarget:self action:@selector(OnNameBtn) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:nameBtn];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen_width / 2 - 80, 20, 160, 30)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"百度传课";
    titleLabel.font = [UIFont systemFontOfSize:19];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:titleLabel];
    
    // 搜索框
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame =CGRectMake(screen_width - 10 - 40, 20, 40, 40) ;
    [searchBtn setImage:[UIImage imageNamed:@"search_btn_unpre_bg"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(OnSearchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:searchBtn];

    // "精选推荐" "课程分类"
    NSArray *segmentArray = [[NSArray alloc] initWithObjects:@"精选推荐", @"课程分类", nil];
    UISegmentedControl *segmentCtr = [[UISegmentedControl alloc] initWithItems:segmentArray];
    segmentCtr.frame = CGRectMake(36, 64, screen_width - 36 * 2, 30);
    segmentCtr.selectedSegmentIndex = 0;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [segmentCtr setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [segmentCtr setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    
    segmentCtr.tintColor = RGB(46, 158, 138);
    [segmentCtr addTarget:self action:@selector(OnTapSegmentCtr:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:segmentCtr];
}

- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 98, screen_width, screen_height - 98 - 49) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    // 添加下拉的动画图片
    // 设置下拉刷新回调
    [self.tableView addGifHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for(NSUInteger i = 1; i <= 60; i++)
    {
        UIImage *image = [UIImage imageNamed:@"icon_listheader_animation_1"];
        [idleImages addObject:image];
    }
    [self.tableView.gifHeader setImages:idleImages forState:MJRefreshHeaderStateIdle];
    
    // 设置即将刷新状态的动画图片
    NSMutableArray *refreshingImages = [NSMutableArray array];
    UIImage *image1 = [UIImage imageNamed:@"icon_listheader_animation_1"];
    [refreshingImages addObject:image1];
    UIImage *image2 = [UIImage imageNamed:@"icon_listheader_animation_2"];
    [refreshingImages addObject:image2];
    [self.tableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStatePulling];
    
    // 设置正在刷新是的动画图片
    [self.tableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStateRefreshing];
    
    // 马上进入刷新状态
    [self.tableView.gifHeader beginRefreshing];
}

- (void)loadNewData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getRecommendData];
    });
}

// 请求推荐课程数据
-(void)getRecommendData
{
    __weak typeof(self) weakself = self;
    NSString *urlStr = @"http://pop.client.chuanke.com/?mod=recommend&act=mobile&client=2&limit=20";
    [[NetworkSingleton sharedManager] getRecommendCourseResult:nil url:urlStr successBlock:^(id responseBody){
        NSLog(@"请求推荐课程数据成功");
        NSMutableArray *focusArray = [responseBody objectForKey:@"FocusList"];
        NSMutableArray *courseArray = [responseBody objectForKey:@"CourseList"];
        NSMutableArray *albumArray = [responseBody objectForKey:@"AlbumList"];
        [_focusListArray removeAllObjects];
        [_focusImgurlArray removeAllObjects];
        [_courseListArray removeAllObjects];
        [_albumListArray removeAllObjects];
        [_albumImgurlArray removeAllObjects];
        for (int i = 0; i < focusArray.count; ++i)
        {
            JZFocusListModel *jzFocusM = [JZFocusListModel objectWithKeyValues:focusArray[i]];
            [_focusListArray addObject:jzFocusM];
            [_focusImgurlArray addObject:jzFocusM.PhotoURL];
        }
        for (int i = 0; i < courseArray.count; ++i)
        {
            JZCourseListModel *jzCourseM = [JZCourseListModel objectWithKeyValues:courseArray[i]];
            [_courseListArray addObject:jzCourseM];
        }
        for (int i = 0; i < albumArray.count; ++i)
        {
            JZAlbumListModel *jzAlbumM = [JZAlbumListModel objectWithKeyValues:albumArray[i]];
            [_albumListArray addObject:jzAlbumM];
            [_albumImgurlArray addObject:jzAlbumM.PhotoURL];
        }
        weakself.tableView.hidden = NO;
        [weakself.tableView reloadData];
        [weakself.tableView.header endRefreshing];
    } failureBlock:^(NSString *error)
     {
         [SVProgressHUD showErrorWithStatus:error];
         NSLog(@"请求推荐课程数据失败：%@",error);
         [weakself.tableView.header endRefreshing];
     }];
}

- (void)OnNameBtn
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"关于作者" message:@"作者：chenshun131，QQ：1539831174，高仿原创所有，转载请注明出处，不可用于商业用途及其他不合法用途。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action)
    {
        NSLog(@"点击 取消按钮");
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"点击 确定按钮");
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)OnSearchBtn:(UIButton *)sender
{
    JZSpeechViewController *jsSpeechVC = [[JZSpeechViewController alloc] init];
    [self.navigationController pushViewController:jsSpeechVC animated:YES];
}

- (void)OnTapSegmentCtr:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    if(0 == index)
    {
        _type = 0;
    }
    else
    {
        _type = -1;
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(0 == _type)
    {
        if(_courseListArray.count > 0)
        {
            return _courseListArray.count + 2;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return _classCategoryArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(0 == _type)
    {
        if(0 == indexPath.row)
        {
            static NSString *cellIndentifer = @"courseCell0";
            ImageScrollCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifer];
            if(nil == cell)
            {
                cell = [[ImageScrollCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifer frame:CGRectMake(0, 0, screen_width, 155)];
            }
            cell.imageScrollView.delegate = self;
            [cell setImageArr:_focusImgurlArray];
            return cell;
        }
        else if(1 == indexPath.row)
        {
            static NSString *cellIndentifer = @"courseCell1";
            JZAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifer];
            if(nil == cell)
            {
                cell = [[JZAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifer frame:CGRectMake(0, 0, screen_width, 90)];
                // 下划线
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 89.5, screen_width, 0.5)];
                lineView.backgroundColor = separaterColor;
                [cell addSubview:lineView];
            }
            cell.delegate = self;
            [cell setImgurlArray:_albumImgurlArray];
            return cell;
        }
        else if(indexPath.row > 1)
        {
            static NSString *cellIndentifer = @"courseCell2";
            JZCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifer];
            if(nil == cell)
            {
                cell = [[JZCourseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifer];
                // 下划线
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 71.5, screen_width, 0.5)];
                lineView.backgroundColor = separaterColor;
                [cell addSubview:lineView];
            }
            JZCourseListModel *jzCourseM = _courseListArray[indexPath.row - 2];
            [cell setJzCourseM:jzCourseM];
            return cell;
        }
        else
        {
            static NSString *cellIndentifer = @"courseCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifer];
            if(nil == cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifer];
            }
            return cell;
        }
    }
    else
    {
        static NSString *cellIndentifer = @"courseClassCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifer];
        if(nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifer];
            // 下划线
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 59.5, screen_width, 0.5)];
            lineView.backgroundColor = separaterColor;
            [cell addSubview:lineView];
            // 图
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
            imageView.tag = 10;
            [cell addSubview:imageView];
            // 标题
            UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 100, 30)];
            titleLable.tag = 11;
            [cell addSubview:titleLable];
        }
        NSDictionary *dataDic = _classCategoryArray[indexPath.row];
        UIImageView *imageView = [cell viewWithTag:10];
        NSString *imageStr = [dataDic objectForKey:@"image"];
        [imageView setImage:[UIImage imageNamed:imageStr]];
        UILabel *titleLabel = [cell viewWithTag:11];
        titleLabel.text = [dataDic objectForKey:@"title"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == _type)
    {
        if (0 == indexPath.row)
        {
            return 155;
        }
        else if (1 == indexPath.row)
        {
            return 90;
        }
        else
        {
            return 72;
        }
    }
    else
    {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(0 == _type)
    {
        JZCourseListModel *jzCourseM = _courseListArray[indexPath.row-2];
        JZCourseDetailViewController *jzCourseDVC = [[JZCourseDetailViewController alloc] init];
        jzCourseDVC.SID = jzCourseM.SID;
        jzCourseDVC.courseId = jzCourseM.CourseID;
        [self.navigationController pushViewController:jzCourseDVC animated:YES];
    }
    else
    {
        JZCateViewController *jzCateVC = [[JZCateViewController alloc] init];
        if(0 == indexPath.row)
        {
            jzCateVC.cateType = @"zhibo";
        }
        else
        {
            NSDictionary *dic = _iCategoryListArray[indexPath.row-1];
            jzCateVC.cateType = @"feizhibo";
            jzCateVC.cateNameArray = [dic objectForKey:@"categoryName"];
            jzCateVC.cateIDArray = [dic objectForKey:@"categoryID"];
        }
        [self.navigationController pushViewController:jzCateVC animated:YES];
    }
}

#pragma mark - ImageScrollViewDelegate
- (void)didSelectImageAtIndex:(NSInteger)index
{
    JZFocusListModel *jzFocusM = _focusListArray[index];
    JZCourseDetailViewController *jzCourseDVC = [[JZCourseDetailViewController alloc] init];
    jzCourseDVC.SID = jzFocusM.SID;
    jzCourseDVC.courseId = jzFocusM.CourseID;
    [self.navigationController pushViewController:jzCourseDVC animated:YES];
}

#pragma mark - JZAlbumDelegate
- (void)didSelectedAlbumAtIndex:(NSInteger)index
{
    if(index == 0)
    {
        NSURL *url = [NSURL URLWithString:@"openchuankekkiphone:"];
        BOOL isInstalled = [[UIApplication sharedApplication] openURL:url];
        if(isInstalled)
        {
        }
        else
        {
            // 土豆 https://appsto.re/cn/c8oMx.i
            // 找教练 https://appsto.re/cn/kRb26.i
            // 百度传课 https://appsto.re/cn/78XAL.i
            // NSURL *url1 = [NSURL URLWithString:@"https://appsto.re/cn/c8oMx.i"];
            // NSURL *url1 = [NSURL URLWithString:@"https://appsto.re/cn/kRb26.i"];
            NSURL *url1 = [NSURL URLWithString:@"https://appsto.re/cn/78XAL.i"];
            [[UIApplication sharedApplication] openURL:url1];
            NSLog(@"没安装");
        }
    }
    else
    {
        JZSpeechViewController *jzSpeechVC = [[JZSpeechViewController alloc] init];
        [self.navigationController pushViewController:jzSpeechVC animated:YES];
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
