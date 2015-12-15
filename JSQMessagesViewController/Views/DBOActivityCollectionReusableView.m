//
//  DBOActivityCollectionReusableView.m
//  JSQMessages
//
//  Created by Fedor on 15.12.15.
//  Copyright © 2015 Hexed Bits. All rights reserved.
//

#import "DBOActivityCollectionReusableView.h"

@interface DBOActivityCollectionReusableView ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView  *activityIndicator;

@end

@implementation DBOActivityCollectionReusableView

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([DBOActivityCollectionReusableView class])
                          bundle:[NSBundle bundleForClass:[DBOActivityCollectionReusableView class]]];
}

+ (NSString *)headerReuseIdentifier
{
    return NSStringFromClass([DBOActivityCollectionReusableView class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.activityIndicator startAnimating];
}

@end
