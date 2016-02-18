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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  A constant defining the default height of a `JSQMessagesTypingIndicatorFooterView`.
 */
FOUNDATION_EXPORT const CGFloat kJSQMessagesTypingIndicatorFooterViewHeight;

/**
 *  The `JSQMessagesTypingIndicatorFooterView` class implements a reusable view that can be placed
 *  at the bottom of a `JSQMessagesCollectionView`. This view represents a typing indicator 
 *  for incoming messages.
 */
@interface JSQMessagesTypingIndicatorFooterView : UICollectionReusableView

#pragma mark - Class methods

/**
 *  Returns the `UINib` object initialized for the collection reusable view.
 *
 *  @return The initialized `UINib` object or `nil` if there were errors during
 *  initialization or the nib file could not be located.
 */
+ (UINib *)nib;

/**
 *  Returns the default string used to identify the reusable footer view.
 *
 *  @return The string used to identify the reusable footer view.
 */
+ (NSString *)footerReuseIdentifier;

@end
