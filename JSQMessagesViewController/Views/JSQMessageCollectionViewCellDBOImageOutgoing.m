//
//  JSQMessageCollectionViewCellDBOImageOutgoing.m
//  JSQMessages
//
//  Created by Fedor on 22.12.15.
//  Copyright © 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessageCollectionViewCellDBOImageOutgoing.h"

@implementation JSQMessageCollectionViewCellDBOImageOutgoing

- (void)awakeFromNib {
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentLeft;
    self.cellBottomLabel.textAlignment = NSTextAlignmentLeft;
}

@end
