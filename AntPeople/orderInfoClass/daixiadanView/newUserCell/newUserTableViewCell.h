//
//  newUserTableViewCell.h
//  AntPeople
//
//  Created by 蜂尚网络 on 2018/4/25.
//  Copyright © 2018年 王绵峰. All rights reserved.
//

#import <UIKit/UIKit.h>




typedef void(^textFieldBlock)(UITextField * textFieldname,NSInteger currentRow);


@protocol keyBoardDelegate <NSObject>


- (void)keyBoardUp;
- (void)keyBoardHides;

@end




//@protocol keyBoardDelegate <NSObject>
//
//
//- (void)keyBoardUp;
//- (void)keyBoardHides;
//
//@end



@interface newUserTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (strong, nonatomic) IBOutlet UITextField *rightTextField;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textFieldBgWidth;


@property (nonatomic,copy) textFieldBlock block;

@property (weak,nonatomic) id<keyBoardDelegate>delegate;


- (void)setindexPath:(NSIndexPath *)indexPath;

@end
