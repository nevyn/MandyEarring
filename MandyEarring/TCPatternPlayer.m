//
//  TCPatternPlayer.m
//  MandyEarring
//
//  Created by Joachim Bengtsson on 2014-01-26.
//  Copyright (c) 2014 ThirdCog. All rights reserved.
//

#import "TCPatternPlayer.h"

@implementation TCPatternPlayer
{
	NSTimer *_next;
}

- (void)stop
{
	_earring.vibrating = NO;
	[_next invalidate];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setVibrating:) object:@YES];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setVibrating:) object:@NO];
}

- (void)playMessageVibration
{
	_earring.vibrating = YES;
	[self performSelector:@selector(setVibrating:) withObject:@NO afterDelay:0.2];
	
	[self performSelector:@selector(setVibrating:) withObject:@YES afterDelay:0.5];
	[self performSelector:@selector(setVibrating:) withObject:@NO afterDelay:0.7];
	
	[self performSelector:@selector(setVibrating:) withObject:@YES afterDelay:1.5];
	[self performSelector:@selector(setVibrating:) withObject:@NO afterDelay:1.7];
	[self performSelector:@selector(setVibrating:) withObject:@YES afterDelay:2.0];
	[self performSelector:@selector(setVibrating:) withObject:@NO afterDelay:2.2];
}

- (void)playRingingVibration
{
	[self _toggleVibrating];
}

- (void)setVibrating:(NSNumber*)vibrating
{
	_earring.vibrating = [vibrating boolValue];
}

- (void)_toggleVibrating
{
	NSLog(@"Toggling");
	_earring.vibrating = !_earring.vibrating;
	if(_earring.vibrating) {
		_next = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:_cmd userInfo:nil repeats:NO];
	} else {
		_next = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:_cmd userInfo:nil repeats:NO];
	}
}

@end
