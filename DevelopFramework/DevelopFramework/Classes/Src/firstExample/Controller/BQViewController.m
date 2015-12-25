//
//  ViewController.m
//  DevelopFramework
//
//  Created by momo on 15/12/5.
//  Copyright © 2015年 teason. All rights reserved.
//

#import "BQViewController.h"
#import "XTTableDataDelegate.h"
#import "BQCell.h"
#import "BQModel.h"
#import "UITableViewCell+Extension.h"
#import "BQViewModel.h"
#import "BQViewController2.h"

static NSString *const MyCellIdentifier = @"BQCell" ; // `cellIdentifier` AND `NibName` HAS TO BE SAME !

@interface BQViewController ()

@property (nonatomic, strong) NSMutableArray *arrayList ;
@property (nonatomic, strong) XTTableDataDelegate *tableHander ;

@end

@implementation BQViewController
/**
 *  懒加载存放请求到的数据数组
 */
- (NSMutableArray *)arrayList
{
    if (_arrayList == nil) {
        _arrayList = [NSMutableArray array] ;
    }
    return _arrayList;
}

- (void)viewDidLoad
{
    [super viewDidLoad] ;
    [SVProgressHUD show];
    [BQViewModel getHomeDataList:nil params:nil success:^(NSArray *array) {
        [SVProgressHUD dismiss];
        self.arrayList = [NSMutableArray arrayWithArray:array];
        [self setupTableView] ;
        [self.table reloadData];
    } failure:^(NSError *error) {
        
    }];
    __weak typeof(self) weakSelf = self;
    // 下拉刷新
    self.table.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        [SVProgressHUD show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [BQViewModel getHomeDataList:nil params:nil success:^(NSArray *array) {
                [SVProgressHUD dismiss];
                [weakSelf.arrayList addObjectsFromArray:array];
                [weakSelf.table reloadData];
            } failure:^(NSError *error) {
            }];
            // 结束刷新
            [weakSelf.table.mj_header endRefreshing];
        });
    }];
}

/**
 *  tableView的一些初始化工作
 */
- (void)setupTableView
{
    __weak typeof(self) weakSelf = self;
    self.table.separatorStyle = UITableViewCellSelectionStyleNone;
    
    TableViewCellConfigureBlock configureCell = ^(NSIndexPath *indexPath, BQModel *obj, UITableViewCell *cell) {
        [cell configure:cell customObj:obj indexPath:indexPath] ;
    } ;

    DidSelectCellBlock selectedBlock = ^(NSIndexPath *indexPath, id item) {
        [weakSelf.table deselectRowAtIndexPath:indexPath animated:YES];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BQViewController2 *vc = [sb instantiateViewControllerWithIdentifier:@"ViewController2ID"];
        [weakSelf presentViewController:vc animated:YES completion:nil];
        
        LxPrintf(@"click row : %@",@(indexPath.row)) ;
    } ;
    
    self.tableHander = [[XTTableDataDelegate alloc] initWithItems:self.arrayList
                                                   cellIdentifier:MyCellIdentifier
                                                   configureCellBlock:configureCell
                                                   cellHeightBlock:nil
                                                   didSelectBlock:selectedBlock] ;
    
    [self.tableHander handleTableViewDatasourceAndDelegate:self.table] ;
//    self.tableHander.tableViewSectionsBlock = ^ {
//        return (NSInteger)3;
//    };
}

@end
