//
//  TestViewController.m
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/9/26.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) UITableView *tableview;

@property (nonatomic) NSArray * datas;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(00, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    
    self.tableview.tableFooterView = [UIView new];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellTV"];
    [self.tableview registerClass:[UITableViewCell class ] forCellReuseIdentifier:@"cellTF"];
    
    [self.view addSubview:self.tableview];
    
    _datas = [NSArray arrayWithObjects:
  @{@"type":@"TV",@"text":@"fsfefewfwefwefsflsjfkj"},
  @{@"type":@"TF",@"text":@"fsfefewfwefwefsflsjfkj2"},
  @{@"type":@"TV",@"text":@"fsfefewfwefwefsflsjfkj3"},
  @{@"type":@"TF",@"text":@"fsfefewfwefwefsflsjfkj4"},
  @{@"type":@"TV",@"text":@"fsfefewfwefwefsflsjfkj5"},
  @{@"type":@"TF",@"text":@"fsfefewfwefwefsflsjfkj6"},
  @{@"type":@"TV",@"text":@"fsfefewfwefwefsflsjfkj7"},
  @{@"type":@"TF",@"text":@"fsfefewfwefwefsflsjfkj8"},
  @{@"type":@"TV",@"text":@"fsfefewfwefwefsflsjfkj9"},
  @{@"type":@"TF",@"text":@"fsfefewfwefwefsflsjfkj00"},
  @{@"type":@"TV",@"text":@"fsfefewfwefwefsflsjfkj11"},
  @{@"type":@"TF",@"text":@"fsfefewfwefwefsflsjfkj22"},
  @{@"type":@"TV",@"text":@"fsfefewfwefwefsflsjfkj33"},
  @{@"type":@"TF",@"text":@"fsfefewfwefwefsflsjfkj44"},
  @{@"type":@"TV",@"text":@"fsfefewfwefwefsflsjfkj55"},
  @{@"type":@"TF",@"text":@"fsfefewfwefwefsflsjfkj66"}, nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self  selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self  selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self  selector:@selector(keyboardShow:) name:UIKeyboardDidChangeFrameNotification object:nil];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = (NSDictionary *)_datas[indexPath.row];
    NSString *type = (NSString *)[info objectForKey:@"type"];
    if ([type isEqualToString:@"TV"]){
        return 400;
    }else{
        return 64;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *info = (NSDictionary *)_datas[indexPath.row];
    NSString *type = (NSString *)[info objectForKey:@"type"];
    NSString *text = (NSString *)[info objectForKey:@"text"];
    if ([type isEqualToString:@"TV"]){
        UITableViewCell *tvCell = [tableView dequeueReusableCellWithIdentifier:@"cellTV" forIndexPath:indexPath];
        
        UITextView *tv = [tvCell viewWithTag:1];
        if( tv == nil ){
            tv = [[UITextView alloc  ]initWithFrame:CGRectMake(0, tvCell.contentView.frame.size.height* 0.6, tvCell.contentView.frame.size.width, tvCell.contentView.frame.size.height* 0.4)];
            tv.tag = 1;
            tv.editable = true ;
            tv.scrollEnabled = true;
            tv.backgroundColor = [UIColor orangeColor];
            tv.textColor = [UIColor blackColor];
            tv.tintColor = [UIColor redColor];
            [tvCell.contentView addSubview:tv];
        }
        tv.text = text;
        return tvCell;
    }else{
        UITableViewCell *tfCell = [tableView dequeueReusableCellWithIdentifier:@"cellTF" forIndexPath:indexPath];
        UITextField *tf = [tfCell viewWithTag:2];
        if( tf == nil ){
            tf = [[UITextField alloc  ]initWithFrame:CGRectMake(0, 0, tfCell.contentView.frame.size.width, tfCell.contentView.frame.size.height)];
            tf.tag = 2;
            tf.textColor = [UIColor blackColor];
            tf.backgroundColor = [UIColor purpleColor];
            tf.tintColor = [UIColor redColor];
            [tfCell.contentView addSubview:tf];
        }
        tf.text = text;
        return tfCell;
    }
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return false;
}

-(UIView * __nullable)findFirsrResponderIn:(UIView *)view{
    if ([view isFirstResponder]){
        return view;
    }
    for (UIView *subview in view.subviews ){
        if ([subview isFirstResponder]){
            return subview;
        }else{
            UIView *view = [self findFirsrResponderIn:subview];
            if([view isFirstResponder]){
                return view;
            }
        }
    }
    return nil ;
}


-(void)keyboardShow:(NSNotification *)notific{
    
    UIView *first = [self findFirsrResponderIn:self.view];
    
    
    if (first){
        if ([first isKindOfClass:[UITextField class]]){
            UITextField *tf = (UITextField *)first;
            NSLog(@"tf text %@ ",tf.text);
        }else if ([first isKindOfClass:[UITextView class]]){
            UITextView *tv = (UITextView *)first;
            NSLog(@"tv text %@ ",tv.text  );
        }
        
        CGRect endframe = [notific.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardheight = endframe.size.height;
        
        CGRect newframe = self.tableview.frame;
        newframe.size.height = self.view.frame.size.height - keyboardheight;
        self.tableview.frame = newframe;
        
        CGRect editFrame = [first convertRect:first.frame toView:self.tableview];
        
        editFrame.origin.y = CGRectGetMinY(editFrame) - CGRectGetMinY(first.frame);
        NSLog(@"edit frame %@",NSStringFromCGRect(editFrame)  );
        
        [self.tableview scrollRectToVisible:editFrame animated:true ];
    }
}

-(void)keyboardHide:(NSNotification *)notific{
    CGRect newframe = self.tableview.frame;
    newframe.size.height = self.view.frame.size.height;
    self.tableview.frame = newframe;
}


@end
