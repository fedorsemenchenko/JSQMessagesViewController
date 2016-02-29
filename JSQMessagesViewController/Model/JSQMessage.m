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
                  dboPaymentView:(UIView *)dboPaymentView
                  dboSupportName:(NSString *)dboSupportName
                     messageType:(MessageType)messageType
                     messageSize:(CGSize)messageSize;


@end



@implementation JSQMessage

#pragma mark - Initialization

+ (instancetype)messageWithSenderId:(NSString *)senderId
                        displayName:(NSString *)displayName
                               text:(NSString *)text
                     dboPaymentView:(UIView *)dboPaymentView
                     dboSupportName:(NSString *)dboSupportName
                        messageType:(MessageType)messageType
                        messageSize:(CGSize)messageSize
{
    return [[self alloc] initWithSenderId:senderId
                        senderDisplayName:displayName
                                     date:[NSDate date]
                                     text:text
                           dboPaymentView:dboPaymentView
                           dboSupportName:dboSupportName
                              messageType:messageType
                              messageSize:(CGSize)messageSize];
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                            text:(NSString *)text
                  dboPaymentView:(UIView *)dboPaymentView
                  dboSupportName:(NSString *)dboSupportName
                     messageType:(MessageType)messageType
                     messageSize:(CGSize)messageSize
{
    NSParameterAssert(text != nil);

    self = [self initWithSenderId:senderId
                senderDisplayName:senderDisplayName
                             date:date
                   dboPaymentView:dboPaymentView
                   dboSupportName:dboSupportName
                      messageType:messageType
                      messageSize:(CGSize)messageSize];
    if (self) {
        _text = [text copy];
        _messageType = messageType;
        _messageSize = messageSize;
    }
    return self;
}

+ (instancetype)messageWithSenderId:(NSString *)senderId
                        displayName:(NSString *)displayName
                              media:(id<JSQMessageMediaData>)media
                               text:(NSString *)text
                     dboSupportName:(NSString *)dboSupportName
                        messageType:(MessageType)messageType
                        messageSize:(CGSize)messageSize
{
    return [[self alloc] initWithSenderId:senderId
                        senderDisplayName:displayName
                                     date:[NSDate date]
                                    media:media
                                     text:text
                           dboSupportName:dboSupportName
                              messageType:messageType
                              messageSize:(CGSize)messageSize];
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           media:(id<JSQMessageMediaData>)media
                            text:(NSString *)text
                  dboSupportName:(NSString *)dboSupportName
                     messageType:(MessageType)messageType
                     messageSize:(CGSize)messageSize
{
    NSParameterAssert(media != nil);

    self = [self initWithSenderId:senderId
                senderDisplayName:senderDisplayName
                             date:date
                   dboPaymentView:nil
                   dboSupportName:dboSupportName
                      messageType:messageType
                      messageSize:(CGSize)messageSize];
    if (self) {
        _text = text;
        _media = media;
        _messageType = messageType;
        _messageSize = messageSize;
    }
    return self;
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                  dboPaymentView:(UIView *)dboPaymentView
                  dboSupportName:(NSString *)dboSupportName
                     messageType:(MessageType)messageType
                     messageSize:(CGSize)messageSize
{
    NSParameterAssert(senderId != nil);
    NSParameterAssert(senderDisplayName != nil);
    NSParameterAssert(date != nil);

    self = [super init];
    if (self) {
        _senderId = [senderId copy];
        _senderDisplayName = [senderDisplayName copy];
        _date = [date copy];
        _dboPaymentView = dboPaymentView;
        _dboSupportName = dboSupportName;
        _messageType = messageType;
        _messageSize = messageSize;
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

    if (self.messageType != aMessage.messageType) {
        return NO;
    }

    BOOL hasEqualContent = self.messageType == MessageTypeImage ? [self.media isEqual:aMessage.media] : [self.text isEqualToString:aMessage.text];

    return [self.senderId isEqualToString:aMessage.senderId]
    && [self.senderDisplayName isEqualToString:aMessage.senderDisplayName]
    && ([self.date compare:aMessage.date] == NSOrderedSame)
    && hasEqualContent;
}

- (NSUInteger)hash
{
    NSUInteger contentHash = self.messageType == MessageTypeImage ? [self.media mediaHash] : self.text.hash;
    return self.senderId.hash ^ self.date.hash ^ contentHash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: senderId=%@, senderDisplayName=%@, date=%@, text=%@, media=%@, dboPaymentView=%@>",
            [self class], self.senderId, self.senderDisplayName, self.date, self.text, self.media, self.dboPaymentView];
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
        _text = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(text))];
        _media = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(media))];
        _dboPaymentView = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dboPaymentView))];
        _messageType = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(messageType))];
        _dboSupportName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dboSupportName))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.senderId forKey:NSStringFromSelector(@selector(senderId))];
    [aCoder encodeObject:self.senderDisplayName forKey:NSStringFromSelector(@selector(senderDisplayName))];
    [aCoder encodeObject:self.date forKey:NSStringFromSelector(@selector(date))];
    [aCoder encodeObject:self.text forKey:NSStringFromSelector(@selector(text))];
    [aCoder encodeObject:self.dboPaymentView forKey:NSStringFromSelector(@selector(dboPaymentView))];
    [aCoder encodeBool:self.messageType forKey:NSStringFromSelector(@selector(messageType))];
    [aCoder encodeObject:self.dboSupportName forKey:NSStringFromSelector(@selector(dboSupportName))];

    if ([self.media conformsToProtocol:@protocol(NSCoding)]) {
        [aCoder encodeObject:self.media forKey:NSStringFromSelector(@selector(media))];
    }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    if (self.messageType == MessageTypeImage) {
        return [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:self.date
                                                             media:self.media
                                                              text:self.text
                                                    dboSupportName:self.dboSupportName
                                                       messageType:self.messageType
                                                       messageSize:self.messageSize];
    }

    return [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                             senderDisplayName:self.senderDisplayName
                                                          date:self.date
                                                          text:self.text
                                                dboPaymentView:self.dboPaymentView
                                                dboSupportName:self.dboSupportName
                                                   messageType:self.messageType
                                                   messageSize:self.messageSize];
}

@end
