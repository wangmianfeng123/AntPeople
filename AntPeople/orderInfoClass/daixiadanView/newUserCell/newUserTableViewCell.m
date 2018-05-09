//
//  newUserTableViewCell.m
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/25.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import "newUserTableViewCell.h"


@implementation newUserTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
     self.rightTextField.inputAccessoryView = [self addToolbar];
//     self.rightTextField.inputAccessoryView = [self addToolbar];

}



- (void)setBlock:(textFieldBlock)block{
    _block = block;
}



- (void)setindexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        self.firstLabel.text = @"姓名:";
        self.rightTextField.placeholder = @"请输入姓名";
    }else if (indexPath.row == 1){
        self.firstLabel.text = @"电话:";
        self.rightTextField.placeholder = @"请输入电话号码";
        self.rightTextField.keyboardType = UIKeyboardTypePhonePad;
    }
}

- (IBAction)textFieldAction:(UITextField *)sender {
    if ([self.delegate respondsToSelector:@selector(keyBoardUp)]) {
        [self.delegate keyBoardUp];
    }
}


//键盘添加自定义按钮
- (UIToolbar *)addToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    toolbar.tintColor = [UIColor blueColor];
    toolbar.backgroundColor = [UIColor grayColor];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(textFieldDone)];
    toolbar.items = @[space, bar];
    return toolbar;
}



- (void)textFieldDone{
    if ([self.delegate respondsToSelector:@selector(keyBoardHides)]) {
        [self.delegate keyBoardHides];
    }
}




@end
