//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesTypingIndicatorFooterView.h"

#import "JSQMessagesBubbleImageFactory.h"

#import "UIImage+JSQMessages.h"

const CGFloat kJSQMessagesTypingIndicatorFooterViewHeight = 20.f;

@interface JSQMessagesTypingIndicatorFooterView ()

@property (weak, nonatomic) IBOutlet UILabel *notifyWritingLabel;

@end

@implementation JSQMessagesTypingIndicatorFooterView

#pragma mark - Class methods

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([JSQMessagesTypingIndicatorFooterView class])
                          bundle:[NSBundle bundleForClass:[JSQMessagesTypingIndicatorFooterView class]]];
}

+ (NSString *)footerReuseIdentifier {
    return NSStringFromClass([JSQMessagesTypingIndicatorFooterView class]);
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Reusable view

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
}

@end
