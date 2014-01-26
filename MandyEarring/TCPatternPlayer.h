//
//  TCPatternPlayer.h
//  MandyEarring
//
//  Created by Joachim Bengtsson on 2014-01-26.
//  Copyright (c) 2014 ThirdCog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCEarringController.h"

@interface TCPatternPlayer : NSObject
@property(nonatomic) TCEarringController *earring;

- (void)playRingingVibration;
- (void)stop;

- (void)playMessageVibration;
@end
