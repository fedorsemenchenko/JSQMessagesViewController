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

#import "JSQMessagesCollectionViewCell.h"

#import "JSQMessagesCollectionViewCellIncoming.h"
#import "JSQMessagesCollectionViewCellOutgoing.h"
#import "JSQMessagesCollectionViewLayoutAttributes.h"
#import "JSQMessagesCollectionViewCellDBOPayment.h"
#import "JSQMessagesCollectionViewCellDBOPaymentIncoming.h"

#import "UIView+JSQMessages.h"
#import "UIDevice+JSQMessages.h"


static NSMutableSet *jsqMessagesCollectionViewCellActions = nil;


@interface JSQMessagesCollectionViewCell ()

@property (weak, nonatomic) IBOutlet JSQMessagesLabel *cellTopLabel;
@property (weak, nonatomic) IBOutlet JSQMessagesLabel *cellBottomLabel;

@property (weak, nonatomic) IBOutlet UILabel *supportNameLabel;

@property (weak, nonatomic) IBOutlet UIView *messageBubbleContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *messageBubbleImageView;
@property (weak, nonatomic) IBOutlet JSQMessagesCellTextView *textView;


@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIView *avatarContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBubbleContainerWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewTopVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewAvatarHorizontalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewMarginHorizontalSpaceConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellTopLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellBottomLabelHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarContainerViewHeightConstraint;

//DBO Image with text
@property (weak, nonatomic) IBOutlet UIView *dboImageContainerView;
@property (weak, nonatomic) IBOutlet UIView *dboLoaderContainerView;


@property (weak, nonatomic) IBOutlet UIView *dboPaymentContainerView;

@property (assign, nonatomic) UIEdgeInsets textViewFrameInsets;

@property (assign, nonatomic) CGSize avatarViewSize;

@property (weak, nonatomic, readwrite) UITapGestureRecognizer *tapGestureRecognizer;

- (void)jsq_handleTapGesture:(UITapGestureRecognizer *)tap;

- (void)jsq_updateConstraint:(NSLayoutConstraint *)constraint withConstant:(CGFloat)constant;

@end


@implementation JSQMessagesCollectionViewCell

#pragma mark - Class methods

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jsqMessagesCollectionViewCellActions = [NSMutableSet new];
    });
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
}

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (NSString *)mediaCellReuseIdentifier
{
    return [NSString stringWithFormat:@"%@_JSQMedia", NSStringFromClass([self class])];
}

+ (void)registerMenuAction:(SEL)action
{
    [jsqMessagesCollectionViewCellActions addObject:NSStringFromSelector(action)];
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.backgroundColor = [UIColor whiteColor];

    self.dboImageContainerView.clipsToBounds = YES;
    [self.dboImageContainerView.layer setCornerRadius:20.f];
    
    self.cellTopLabelHeightConstraint.constant = 0.0f;
    self.cellBottomLabelHeightConstraint.constant = 0.0f;

    self.avatarViewSize = CGSizeZero;

    self.cellTopLabel.textAlignment = NSTextAlignmentCenter;
    self.cellTopLabel.textColor = [UIColor lightGrayColor];
    self.cellBottomLabel.textColor = [UIColor lightGrayColor];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jsq_handleTapGesture:)];
    [self addGestureRecognizer:tap];
    self.tapGestureRecognizer = tap;    
}

- (void)dealloc
{
    _delegate = nil;

    _cellTopLabel = nil;
    _cellBottomLabel = nil;

    _textView = nil;
    _messageBubbleImageView = nil;
    _mediaView = nil;

    _avatarImageView = nil;

    [_tapGestureRecognizer removeTarget:nil action:NULL];
    _tapGestureRecognizer = nil;
}

#pragma mark - Collection view cell

- (void)prepareForReuse
{
    [super prepareForReuse];

//    self.cellTopLabel.text = nil;
//    self.messageBubbleTopLabel.text = nil;
//    self.cellBottomLabel.text = nil;
//
//    self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
//    self.textView.text = nil;
//    self.textView.attributedText = nil;
//
//    self.avatarImageView.image = nil;
//    self.avatarImageView.highlightedImage = nil;
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    return layoutAttributes;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];

    JSQMessagesCollectionViewLayoutAttributes *customAttributes = (JSQMessagesCollectionViewLayoutAttributes *)layoutAttributes;

    if (!UIEdgeInsetsEqualToEdgeInsets(self.textView.textContainerInset, customAttributes.textViewTextContainerInsets)) {
        self.textView.textContainerInset = customAttributes.textViewTextContainerInsets;
    }

    self.textViewFrameInsets = customAttributes.textViewFrameInsets;

    [self jsq_updateConstraint:self.messageBubbleContainerWidthConstraint
                  withConstant:customAttributes.messageBubbleContainerViewWidth];

    [self jsq_updateConstraint:self.cellTopLabelHeightConstraint
                  withConstant:customAttributes.cellTopLabelHeight];

    [self jsq_updateConstraint:self.cellBottomLabelHeightConstraint
                  withConstant:customAttributes.cellBottomLabelHeight];

    if ([self isKindOfClass:[JSQMessagesCollectionViewCellIncoming class]]) {
        self.avatarViewSize = customAttributes.incomingAvatarViewSize;
    }
    
    // This will force cell in correct size in current execute loop https://github.com/jessesquires/JSQMessagesViewController/issues/451
    [self layoutSubviews];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.messageBubbleImageView.highlighted = highlighted;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.messageBubbleImageView.highlighted = selected;
}

//  FIXME: radar 18326340
//         remove when fixed
//         hack for Xcode6 / iOS 8 SDK rendering bug that occurs on iOS 7.x
//         see issue #484
//         https://github.com/jessesquires/JSQMessagesViewController/issues/484
//
- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];

    if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
        self.contentView.frame = bounds;
    }
}

#pragma mark - Menu actions

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([jsqMessagesCollectionViewCellActions containsObject:NSStringFromSelector(aSelector)]) {
        return YES;
    }

    return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([jsqMessagesCollectionViewCellActions containsObject:NSStringFromSelector(anInvocation.selector)]) {
        __unsafe_unretained id sender;
        [anInvocation getArgument:&sender atIndex:0];
        [self.delegate messagesCollectionViewCell:self didPerformAction:anInvocation.selector withSender:sender];
    }
    else {
        [super forwardInvocation:anInvocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if ([jsqMessagesCollectionViewCellActions containsObject:NSStringFromSelector(aSelector)]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }

    return [super methodSignatureForSelector:aSelector];
}

#pragma mark - Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];

    self.cellTopLabel.backgroundColor = backgroundColor;
    self.cellBottomLabel.backgroundColor = backgroundColor;

    self.messageBubbleImageView.backgroundColor = backgroundColor;
    self.avatarImageView.backgroundColor = backgroundColor;

    self.messageBubbleContainerView.backgroundColor = backgroundColor;
    self.avatarContainerView.backgroundColor = backgroundColor;
}

- (void)setAvatarViewSize:(CGSize)avatarViewSize
{
    if (CGSizeEqualToSize(avatarViewSize, self.avatarViewSize)) {
        return;
    }

    [self jsq_updateConstraint:self.avatarContainerViewWidthConstraint withConstant:avatarViewSize.width];
    [self jsq_updateConstraint:self.avatarContainerViewHeightConstraint withConstant:avatarViewSize.height];
}

- (void)setTextViewFrameInsets:(UIEdgeInsets)textViewFrameInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets(textViewFrameInsets, self.textViewFrameInsets)) {
        return;
    }

    [self jsq_updateConstraint:self.textViewTopVerticalSpaceConstraint withConstant:textViewFrameInsets.top];
    [self jsq_updateConstraint:self.textViewBottomVerticalSpaceConstraint withConstant:textViewFrameInsets.bottom];
    [self jsq_updateConstraint:self.textViewAvatarHorizontalSpaceConstraint withConstant:textViewFrameInsets.right];
    [self jsq_updateConstraint:self.textViewMarginHorizontalSpaceConstraint withConstant:textViewFrameInsets.left];
}

- (void)setMediaView:(UIView *)mediaView
{
    [self.messageBubbleImageView removeFromSuperview];
    [self.textView removeFromSuperview];

    [mediaView setTranslatesAutoresizingMaskIntoConstraints:NO];
    mediaView.frame = self.messageBubbleContainerView.bounds;
    
    [self.messageBubbleContainerView addSubview:mediaView];
    [self.messageBubbleContainerView jsq_pinAllEdgesOfSubview:mediaView];
    _mediaView = mediaView;

    //  because of cell re-use (and caching media views, if using built-in library media item)
    //  we may have dequeued a cell with a media view and add this one on top
    //  thus, remove any additional subviews hidden behind the new media view
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSUInteger i = 0; i < self.messageBubbleContainerView.subviews.count; i++) {
            if (self.messageBubbleContainerView.subviews[i] != _mediaView) {
                [self.messageBubbleContainerView.subviews[i] removeFromSuperview];
            }
        }
    });
}

#pragma mark - Add Load View At Media View

- (void)setLoadViewOnMediaView:(UIView *)loadView {
    
    [loadView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.mediaView addSubview:loadView];
    [self.mediaView jsq_pinAllEdgesOfSubview:loadView];

    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSUInteger i = 0; i < self.mediaView.subviews.count; i++) {
            if (self.mediaView.subviews[i] != loadView) {
                [self.mediaView.subviews[i] removeFromSuperview];
            }
        }
    });
}

- (void)removeLoadViewFromMediaView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSUInteger i = 0; i < self.mediaView.subviews.count; i++) {
            [self.mediaView.subviews[i] removeFromSuperview];
        }
    });
}

#pragma mark - Add Load View At Image Container

- (void)setLoadViewOnImageContainerView:(UIView *)loadView {
    
    [loadView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.dboLoaderContainerView addSubview:loadView];
    [self.dboLoaderContainerView jsq_pinAllEdgesOfSubview:loadView];
    
    for (NSUInteger i = 0; i < self.dboLoaderContainerView.subviews.count; i++) {
        if (self.dboLoaderContainerView.subviews[i] != loadView) {
            [self.dboLoaderContainerView.subviews[i] removeFromSuperview];
        }
    }
}

- (void)removeLoadViewFromImageContainer {
    for (NSUInteger i = 0; i < self.dboLoaderContainerView.subviews.count; i++) {
        [self.dboLoaderContainerView.subviews[i] removeFromSuperview];
    }
}


#pragma mark - Support Name

- (void)setSupportNameText:(NSString *)supportName {
    self.supportNameLabel.text = supportName;
}

- (void)setMessageWithTextImage:(UIView *)mediaView {
    
    [self.dboImageContainerView addSubview:mediaView];
    [self.dboImageContainerView bringSubviewToFront:self.dboLoaderContainerView];

    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSUInteger i = 0; i < self.dboImageContainerView.subviews.count; i++) {
            if (self.dboImageContainerView.subviews[i] != mediaView && self.dboImageContainerView.subviews[i] != self.dboLoaderContainerView) {
                [self.dboImageContainerView.subviews[i] removeFromSuperview];
            }
        }
    });
}

#pragma mark - Getters

- (CGSize)avatarViewSize
{
    return CGSizeMake(self.avatarContainerViewWidthConstraint.constant,
                      self.avatarContainerViewHeightConstraint.constant);
}

- (UIEdgeInsets)textViewFrameInsets
{
    return UIEdgeInsetsMake(self.textViewTopVerticalSpaceConstraint.constant,
                            self.textViewMarginHorizontalSpaceConstraint.constant,
                            self.textViewBottomVerticalSpaceConstraint.constant,
                            self.textViewAvatarHorizontalSpaceConstraint.constant);
}

#pragma mark - Set Payment

- (void)setDboPaymentView:(UIView *)dboPaymentView {
    _dboPaymentView = dboPaymentView;
    [[self.dboPaymentContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _dboPaymentView.frame = self.dboPaymentContainerView.bounds;
    [self.dboPaymentContainerView addSubview: _dboPaymentView];
}

#pragma mark - Utilities

- (void)jsq_updateConstraint:(NSLayoutConstraint *)constraint withConstant:(CGFloat)constant
{
    if (constraint.constant == constant) {
        return;
    }

    constraint.constant = constant;
}

#pragma mark - Gesture recognizers

- (void)jsq_handleTapGesture:(UITapGestureRecognizer *)tap
{
    CGPoint touchPt = [tap locationInView:self];

    if (CGRectContainsPoint(self.avatarContainerView.frame, touchPt)) {
        [self.delegate messagesCollectionViewCellDidTapAvatar:self];
    }
    else if (CGRectContainsPoint(self.messageBubbleContainerView.frame, touchPt)) {
        [self.delegate messagesCollectionViewCellDidTapMessageBubble:self];
    }
    else {
        [self.delegate messagesCollectionViewCellDidTapCell:self atPosition:touchPt];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchPt = [touch locationInView:self];

    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return CGRectContainsPoint(self.messageBubbleContainerView.frame, touchPt);
    }
    
    return YES;
}

#pragma mark - Set Font For Text 

- (void)setFontsForText:(UIFont *)fontText fontSupport:(UIFont *)fontSupport {
    [self.supportNameLabel setFont:fontSupport];
    [self.textView setFont:fontText];
}

@end
