//
//  JSQMessagesCollectionViewCellDBOPayment.m
//  JSQMessages
//
//  Created by Fedor on 09.12.15.
//  Copyright © 2015 Hexed Bits. All rights reserved.
//

#import "JSQMessagesCollectionViewCellDBOPayment.h"

@interface JSQMessagesCollectionViewCellDBOPayment ()

@end

@implementation JSQMessagesCollectionViewCellDBOPayment

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.messageBubbleTopLabel.textAlignment = NSTextAlignmentRight;
    self.cellBottomLabel.textAlignment = NSTextAlignmentRight;
}

@end
