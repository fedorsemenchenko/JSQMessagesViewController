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

#import "JSQMessagesBubblesSizeCalculator.h"

#import "JSQMessagesCollectionView.h"
#import "JSQMessagesCollectionViewDataSource.h"
#import "JSQMessagesCollectionViewFlowLayout.h"
#import "JSQMessageData.h"

#import "UIImage+JSQMessages.h"

static CGFloat const kMinDBOImageCellWidth = 210.f;
static CGFloat const kDBOCellTextWidth = 180.f;
static CGFloat const kDBOSupportLabelHeight = 40.f;

static CGFloat const kMinDBOPaymentWidth = 270.f;
static CGFloat const kDBOPaymentVerticalInset = 65.f;
static CGFloat const spacingBetweenAvatarAndBubble = 2.0f;

@interface JSQMessagesBubblesSizeCalculator ()

@property (strong, nonatomic, readonly) NSCache *cache;

@property (assign, nonatomic, readonly) NSUInteger minimumBubbleWidth;

@property (assign, nonatomic, readonly) BOOL usesFixedWidthBubbles;

@property (assign, nonatomic, readonly) NSInteger additionalInset;

@property (assign, nonatomic) CGFloat layoutWidthForFixedWidthBubbles;

@end


@implementation JSQMessagesBubblesSizeCalculator

#pragma mark - Init

- (instancetype)initWithCache:(NSCache *)cache
           minimumBubbleWidth:(NSUInteger)minimumBubbleWidth
        usesFixedWidthBubbles:(BOOL)usesFixedWidthBubbles
{
    NSParameterAssert(cache != nil);
    NSParameterAssert(minimumBubbleWidth > 0);

    self = [super init];
    if (self) {
        _cache = cache;
        _minimumBubbleWidth = minimumBubbleWidth;
        _usesFixedWidthBubbles = usesFixedWidthBubbles;
        _layoutWidthForFixedWidthBubbles = 0.0f;

        // this extra inset value is needed because `boundingRectWithSize:` is slightly off
        // see comment below
        _additionalInset = 4;
    }
    return self;
}

- (instancetype)init
{
    NSCache *cache = [NSCache new];
    cache.name = @"JSQMessagesBubblesSizeCalculator.cache";
    cache.countLimit = 200;
    return [self initWithCache:cache
            minimumBubbleWidth:[UIImage jsq_bubbleCompactImage].size.width
         usesFixedWidthBubbles:NO];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: cache=%@, minimumBubbleWidth=%@ usesFixedWidthBubbles=%@>",
            [self class], self.cache, @(self.minimumBubbleWidth), @(self.usesFixedWidthBubbles)];
}

#pragma mark - JSQMessagesBubbleSizeCalculating

- (void)prepareForResettingLayout:(JSQMessagesCollectionViewFlowLayout *)layout
{
    [self.cache removeAllObjects];
}

- (CGSize)messageBubbleSizeForMessageData:(id<JSQMessageData>)messageData
                              atIndexPath:(NSIndexPath *)indexPath
                               withLayout:(JSQMessagesCollectionViewFlowLayout *)layout
{
    NSValue *cachedSize = [self.cache objectForKey:@([messageData messageHash])];
    if (cachedSize != nil) {
        return [cachedSize CGSizeValue];
    }

//    CGSize finalSize = [messageData messageSize];
//    CGSize finalSize = CGSizeMake(250.f, 60.f);
    CGSize finalSize;
    CGRect stringRect = CGRectZero;
   
    CGSize stringSizeSupport = CGSizeZero;
    
    CGSize stringSize = CGSizeZero;
    CGFloat stringHeight = 0.f;
    
    
    CGSize avatarSize = CGSizeZero;
    CGFloat horizontalContainerInsets = .0f;
    CGFloat horizontalFrameInsets = .0f;
    CGFloat horizontalInsetsTotal = 0.f;
    CGFloat maximumTextWidth = .0f;
    
    CGFloat verticalContainerInsets = .0f;
    CGFloat verticalFrameInsets = .0f;
    CGFloat verticalInsets = .0f;
    
    CGFloat maxWidth = .0f;
    CGFloat finalWidth = .0f;
    
    CGFloat dboPaymentVerticalInset = .0f;
    CGFloat dboPaymentMinWidht = .0f;
    CGFloat dboSupportNameHeight = [[messageData dboSupportName] length] > 0 ? kDBOSupportLabelHeight : 0.f;
    
    MessageType type = [messageData messageType];
    
    switch (type) {
        case MessageTypeText:
            avatarSize = [self jsq_avatarSizeForMessageData:messageData withLayout:layout];
           
            horizontalContainerInsets = layout.messageBubbleTextViewTextContainerInsets.left + layout.messageBubbleTextViewTextContainerInsets.right;
            horizontalFrameInsets = layout.messageBubbleTextViewFrameInsets.left + layout.messageBubbleTextViewFrameInsets.right;
            horizontalInsetsTotal = horizontalContainerInsets + horizontalFrameInsets + spacingBetweenAvatarAndBubble;
           
            maximumTextWidth = [self textBubbleWidthForLayout:layout] - avatarSize.width - layout.messageBubbleLeftRightMargin - horizontalInsetsTotal;
            
            stringRect = [self rectForText:[messageData text] textWidth:maximumTextWidth font:layout.messageBubbleFont];
            stringSizeSupport = [[messageData dboSupportName] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:12.f]}];

            stringSize = CGRectIntegral(stringRect).size;
            
            verticalContainerInsets = layout.messageBubbleTextViewTextContainerInsets.top + layout.messageBubbleTextViewTextContainerInsets.bottom;
            verticalFrameInsets = layout.messageBubbleTextViewFrameInsets.top + layout.messageBubbleTextViewFrameInsets.bottom;
            verticalInsets = verticalContainerInsets + verticalFrameInsets + self.additionalInset;
            
            maxWidth = stringSize.width >= stringSizeSupport.width ? stringSize.width : stringSizeSupport.width;
            finalWidth = MAX(maxWidth + horizontalInsetsTotal, self.minimumBubbleWidth) + self.additionalInset;
            
            stringHeight = stringSize.height;
            
            finalSize = CGSizeMake(finalWidth, stringHeight + verticalInsets + dboSupportNameHeight);
            
            break;
            
        case MessageTypeTransaction:
            
            horizontalContainerInsets = layout.messageBubbleTextViewTextContainerInsets.left + layout.messageBubbleTextViewTextContainerInsets.right;
            horizontalFrameInsets = layout.messageBubbleTextViewFrameInsets.left + layout.messageBubbleTextViewFrameInsets.right;
            horizontalInsetsTotal = horizontalContainerInsets + horizontalFrameInsets + spacingBetweenAvatarAndBubble;
            
            maximumTextWidth = [self textBubbleWidthForLayout:layout] - avatarSize.width - layout.messageBubbleLeftRightMargin - horizontalInsetsTotal;
            
            stringRect = [self rectForText:[messageData text] textWidth:maximumTextWidth font:layout.messageBubbleFont];
            stringSizeSupport = [[messageData dboSupportName] sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:12.f]}];

            stringSize = CGRectIntegral(stringRect).size;
            
            verticalContainerInsets = layout.messageBubbleTextViewTextContainerInsets.top + layout.messageBubbleTextViewTextContainerInsets.bottom;
            verticalFrameInsets = layout.messageBubbleTextViewFrameInsets.top + layout.messageBubbleTextViewFrameInsets.bottom;
            verticalInsets = verticalContainerInsets + verticalFrameInsets + self.additionalInset;
            
            maxWidth = stringSize.width >= stringSizeSupport.width ? stringSize.width : stringSizeSupport.width;
            finalWidth = MAX(maxWidth + horizontalInsetsTotal, self.minimumBubbleWidth) + self.additionalInset;

            dboPaymentVerticalInset = kDBOPaymentVerticalInset;
            dboPaymentMinWidht = kMinDBOPaymentWidth;
            
            stringHeight = stringSize.height;
            
            finalSize = CGSizeMake(MAX(finalWidth, dboPaymentMinWidht), stringHeight + dboPaymentVerticalInset + verticalInsets + dboSupportNameHeight);
            
            break;
            
        case MessageTypeImage:
            finalSize = [[messageData media] mediaViewDisplaySize];
            break;
            
        case MessageTypeImageWithText:
            stringRect = [self rectForText:[messageData text] textWidth:kDBOCellTextWidth font:layout.messageBubbleFont];
            stringSize = CGRectIntegral(stringRect).size;
            stringHeight = stringSize.height;
            finalSize = CGSizeMake(kMinDBOImageCellWidth, stringHeight + 250.f);
            break;
    }

    return finalSize;
}


- (CGRect)rectForText:(NSString *)text
            textWidth:(CGFloat)width
                 font:(UIFont *)font
{

    CGRect stringRect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                           options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                        attributes:@{ NSFontAttributeName :font }
                                           context:nil];
    
    return stringRect;
}

- (CGSize)jsq_avatarSizeForMessageData:(id<JSQMessageData>)messageData
                            withLayout:(JSQMessagesCollectionViewFlowLayout *)layout
{
    NSString *messageSender = [messageData senderId];

    if ([messageSender isEqualToString:[layout.collectionView.dataSource senderId]]) {
        return layout.outgoingAvatarViewSize;
    }

    return layout.incomingAvatarViewSize;
}

- (CGFloat)textBubbleWidthForLayout:(JSQMessagesCollectionViewFlowLayout *)layout
{
    if (self.usesFixedWidthBubbles) {
        return [self widthForFixedWidthBubblesWithLayout:layout];
    }

    return layout.itemWidth;
}

- (CGFloat)widthForFixedWidthBubblesWithLayout:(JSQMessagesCollectionViewFlowLayout *)layout {
    if (self.layoutWidthForFixedWidthBubbles > 0.0f) {
        return self.layoutWidthForFixedWidthBubbles;
    }

    // also need to add `self.additionalInset` here, see comment above
    NSInteger horizontalInsets = layout.sectionInset.left + layout.sectionInset.right + self.additionalInset;
    CGFloat width = CGRectGetWidth(layout.collectionView.bounds) - horizontalInsets;
    CGFloat height = CGRectGetHeight(layout.collectionView.bounds) - horizontalInsets;
    self.layoutWidthForFixedWidthBubbles = MIN(width, height);
    
    return self.layoutWidthForFixedWidthBubbles;
}

@end
