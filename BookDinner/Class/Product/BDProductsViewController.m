//
//  BDProductsViewController.m
//  BookDinner
//
//  Created by zqchen on 7/25/15.
//  Copyright (c) 2015 chenzq. All rights reserved.
//

#import "BDProductsViewController.h"
#import "BDProductModel.h"
#import "BDCategoryModel.h"
#import "BDProductCell.h"

@interface BDProductsViewController ()<HNYRefreshTableViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) HNYRefreshTableViewController *tableController;
@property (nonatomic,strong) NSArray *categorys;
@property (nonatomic,strong) NSMutableArray *products;
@property (nonatomic,strong) UIView *topView;

@end

@implementation BDProductsViewController
- (instancetype)init{
    self = [super init];
    if (self) {
        self.products = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTable];
    [self requestProductCategory];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)createNaviBar{
    
}

- (void)createTable{
    self.tableController = [[HNYRefreshTableViewController alloc] init];
    self.tableController.view.frame = CGRectMake(0, self.naviBar.frame.size.height + self.topView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.naviBar.frame.size.height - self.topView.frame.size.height);
    self.tableController.tableView.delegate = self;
    self.tableController.tableView.dataSource = self;
    self.tableController.tableView.separatorColor = [UIColor clearColor];
    self.tableController.pageNum = 1;
    self.tableController.pageSize = 10;
    self.tableController.delegate = self;
    [self.view addSubview:self.tableController.view];
    [self addChildViewController:self.tableController];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate,UIScrolViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.tableController scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.tableController scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableController.list.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentify = @"BDProductCell";
    BDProductCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell = [[BDProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    [cell configureCellWith:[self.tableController.list objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//        BDProductModel *model = [self.tableController.list objectAtIndex:indexPath.row];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"%d", indexPath.row);
        [self.tableController.list removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }
}
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark - HNYRefreshTableViewControllerDelegate
//下拉Table View
-(void)pullDownTable{
    [self.tableController.list removeAllObjects];
    [self.tableController.tableView reloadData];
    self.tableController.loadType = 0;
    self.tableController.pageNum = 1;
    self.tableController.enbleFooterLoad = YES;
    [self requestProductList];
    
}
//上拉Table View
-(void)pullUpTable{
    self.tableController.loadType = 1;
    self.tableController.pageNum += 1;
    [self requestProductList];
}
- (NSString *)descriptionOfTableCellAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}
#pragma mark - http request
- (void)requestProductCategory{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [AppInfo headInfo],HTTP_HEAD,
                                  nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",KAPI_ServerUrl,KAPI_ActionProductsCategory];
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"url = %@ \n param = %@",urlString,param);
    
    NSString *jsonString = [param JSONRepresentation];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    ASIFormDataRequest *formRequest = [ASIFormDataRequest requestWithURL:url];
    formRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:KAPI_ActionProductsCategory,HTTP_USER_INFO, nil];
    [formRequest appendPostData:data];
    [formRequest setDelegate:self];
    [formRequest startAsynchronous];
}

- (void)requestProductList{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [AppInfo headInfo],HTTP_HEAD,
                                  @1,@"page",
                                  @20,@"list_number",
                                  @0,@"type_id",
                                  nil];
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",KAPI_ServerUrl,KAPI_ActionProductsList];
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"url = %@ \n param = %@",urlString,param);
    
    NSString *jsonString = [param JSONRepresentation];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    ASIFormDataRequest *formRequest = [ASIFormDataRequest requestWithURL:url];
    formRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:KAPI_ActionProductsList,HTTP_USER_INFO, nil];
    [formRequest appendPostData:data];
    [formRequest setDelegate:self];
    [formRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *string =[[NSString alloc]initWithData:request.responseData encoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [string JSONValue];
    NSLog(@"result = %@",dictionary);
    [self.hud removeFromSuperview];
    
    if ([[dictionary objectForKey:HTTP_RESULT] intValue] == 1) {
        if ([KAPI_ActionProductsCategory isEqualToString:[request.userInfo objectForKey:HTTP_USER_INFO]]) {
            if ([[dictionary valueForKey:@"value"] isKindOfClass:[NSDictionary class]]) {
                self.categorys = [HNYJSONUitls mappingDicAry:[[dictionary valueForKey:@"value"] valueForKey:@"data"] toObjectAryWithClassName:@"BDCategoryModel"];
            }
            [self requestProductList];
        }
       else if ([KAPI_ActionProductsList isEqualToString:[request.userInfo objectForKey:HTTP_USER_INFO]]) {
            if ([[dictionary valueForKey:@"value"] isKindOfClass:[NSDictionary class]]) {
                NSArray *array = [HNYJSONUitls mappingDicAry:[[dictionary valueForKey:@"value"] valueForKey:@"data"] toObjectAryWithClassName:@"BDProductModel"];
                [self.tableController doneRefresh];
                [self.tableController.list addObjectsFromArray:array];
                [self.tableController.tableView reloadData];
                if (array.count < self.tableController.pageSize)
                    self.tableController.enbleFooterLoad = NO;
                else
                    self.tableController.enbleFooterLoad = YES;
                
                if (self.tableController.list.count == 0)
                    [self showTips:@"无优惠券"];

            }
        }
    }
    else{
        if ([KAPI_ActionProductsCategory isEqualToString:[request.userInfo objectForKey:HTTP_USER_INFO]]) {
            [self showTips:[dictionary valueForKey:HTTP_INFO]];
            [self requestProductList];
            
        }
        else if ([KAPI_ActionProductsList isEqualToString:[request.userInfo objectForKey:HTTP_USER_INFO]]) {
            [self showTips:[dictionary valueForKey:HTTP_INFO]];
            
        }

    }
}

@end
