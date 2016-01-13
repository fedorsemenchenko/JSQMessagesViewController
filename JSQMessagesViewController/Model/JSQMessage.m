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

#import "JSQMessage.h"


@interface JSQMessage ()

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                         isMedia:(BOOL)isMedia
                    isDBOPayment:(BOOL)isDBOPayment
                  dboPaymentView:(UIView *)dboPaymentView
                 isMediaWithText:(BOOL)isMediaWithText;

@end



@implementation JSQMessage

#pragma mark - Initialization

+ (instancetype)messageWithSenderId:(NSString *)senderId
                        displayName:(NSString *)displayName
                               text:(NSString *)text
                       isDBOPayment:(BOOL)isDBOPayment
                     dboPaymentView:(UIView *)dboPaymentView
{
    return [[self alloc] initWithSenderId:senderId
                        senderDisplayName:displayName
                                     date:[NSDate date]
                                     text:text
                             isDBOPayment:isDBOPayment
                           dboPaymentView:dboPaymentView];
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                            text:(NSString *)text
                    isDBOPayment:(BOOL)isDBOPayment
                  dboPaymentView:(UIView *)dboPaymentView
{
    NSParameterAssert(text != nil);

    self = [self initWithSenderId:senderId senderDisplayName:senderDisplayName date:date isMedia:NO isDBOPayment:(BOOL)isDBOPayment dboPaymentView:dboPaymentView isMediaWithText:NO];
    if (self) {
        _text = [text copy];
    }
    return self;
}

+ (instancetype)messageWithSenderId:(NSString *)senderId
                        displayName:(NSString *)displayName
                              media:(id<JSQMessageMediaData>)media
                    isMediaWithText:(BOOL)isMediaWithText
                               text:(NSString *)text
{
    return [[self alloc] initWithSenderId:senderId
                        senderDisplayName:displayName
                                     date:[NSDate date]
                                    media:media
                          isMediaWithText:isMediaWithText
                                     text:text];
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           media:(id<JSQMessageMediaData>)media
                 isMediaWithText:(BOOL)isMediaWithText
                            text:(NSString *)text
{
    NSParameterAssert(media != nil);

    self = [self initWithSenderId:senderId senderDisplayName:senderDisplayName date:date isMedia:YES isDBOPayment:NO dboPaymentView:nil isMediaWithText:isMediaWithText];
    if (self) {
        _text = text;
        _media = media;
    }
    return self;
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                         isMedia:(BOOL)isMedia
                    isDBOPayment:(BOOL)isDBOPayment
                  dboPaymentView:(UIView *)dboPaymentView
                 isMediaWithText:(BOOL)isMediaWithText
{
    NSParameterAssert(senderId != nil);
    NSParameterAssert(senderDisplayName != nil);
    NSParameterAssert(date != nil);

    self = [super init];
    if (self) {
        _senderId = [senderId copy];
        _senderDisplayName = [senderDisplayName copy];
        _date = [date copy];
        _isMediaMessage = isMedia;
        _isDBOPaymentMessage = isDBOPayment;
        _dboPaymentView = dboPaymentView;
        _isMediaMessageWithText = isMediaWithText;
    }
    return self;
}

- (id)init
{
    NSAssert(NO, @"%s is not a valid initializer for %@.", __PRETTY_FUNCTION__, [self class]);
    return nil;
}

- (void)dealloc
{
    _senderId = nil;
    _senderDisplayName = nil;
    _date = nil;
    _text = nil;
    _media = nil;
}

- (NSUInteger)messageHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    JSQMessage *aMessage = (JSQMessage *)object;

    if (self.isMediaMessage != aMessage.isMediaMessage) {
        return NO;
    }

    BOOL hasEqualContent = self.isMediaMessage ? [self.media isEqual:aMessage.media] : [self.text isEqualToString:aMessage.text];

    return [self.senderId isEqualToString:aMessage.senderId]
    && [self.senderDisplayName isEqualToString:aMessage.senderDisplayName]
    && ([self.date compare:aMessage.date] == NSOrderedSame)
    && hasEqualContent;
}

- (NSUInteger)hash
{
    NSUInteger contentHash = self.isMediaMessage ? [self.media mediaHash] : self.text.hash;
    return self.senderId.hash ^ self.date.hash ^ contentHash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: senderId=%@, senderDisplayName=%@, date=%@, isMediaMessage=%@, text=%@, media=%@ isDBOPayment=%@ dboPaymentView=%@>",
            [self class], self.senderId, self.senderDisplayName, self.date, @(self.isMediaMessage), self.text, self.media, @(self.isDBOPaymentMessage), self.dboPaymentView];
}

- (id)debugQuickLookObject
{
    return [self.media mediaView] ?: [self.media mediaPlaceholderView];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _senderId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(senderId))];
        _senderDisplayName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(senderDisplayName))];
        _date = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(date))];
        _isMediaMessage = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isMediaMessage))];
        _isDBOPaymentMessage = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isDBOPaymentMessage))];
        _text = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(text))];
        _media = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(media))];
        _dboPaymentView = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dboPaymentView))];
        _isMediaMessageWithText = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isMediaMessageWithText))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.senderId forKey:NSStringFromSelector(@selector(senderId))];
    [aCoder encodeObject:self.senderDisplayName forKey:NSStringFromSelector(@selector(senderDisplayName))];
    [aCoder encodeObject:self.date forKey:NSStringFromSelector(@selector(date))];
    [aCoder encodeBool:self.isMediaMessage forKey:NSStringFromSelector(@selector(isMediaMessage))];
    [aCoder encodeBool:self.isDBOPaymentMessage forKey:NSStringFromSelector(@selector(isDBOPaymentMessage))];
    [aCoder encodeObject:self.text forKey:NSStringFromSelector(@selector(text))];
    [aCoder encodeObject:self.dboPaymentView forKey:NSStringFromSelector(@selector(dboPaymentView))];
    [aCoder encodeBool:self.isMediaMessageWithText forKey:NSStringFromSelector(@selector(isMediaMessageWithText))];

    if ([self.media conformsToProtocol:@protocol(NSCoding)]) {
        [aCoder encodeObject:self.media forKey:NSStringFromSelector(@selector(media))];
    }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    if (self.isMediaMessage) {
        return [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:self.date
                                                             media:self.media
                                                   isMediaWithText:self.isMediaMessageWithText
                                                              text:self.text];
    }

    return [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                             senderDisplayName:self.senderDisplayName
                                                          date:self.date
                                                          text:self.text
                                                  isDBOPayment:self.isDBOPaymentMessage
                                                dboPaymentView:self.dboPaymentView];
}

@end
