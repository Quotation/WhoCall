//
//  MMPDeepSleepPreventer.h
//  MMPDeepSleepPreventer
//
//  Created by Marco Peluso on 20.08.09.
//  Copyright (c) 2009-2010, Marco Peluso - marcopeluso.com
//  All rights reserved.
// 
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
// 
//    1. Redistributions of source code must retain the above copyright notice,
//       this list of conditions and the following disclaimer.
// 
//    2. Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
// 
//    3. Neither the name of the copyright holders nor the names of its
//       contributors may be used to endorse or promote products derived from
//       this software without specific prior written permission.
// 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
//  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#pragma mark -
#pragma mark MMPLog

// Set up some advanced logging preprocessor macros to replace NSLog.
// I usually have this in an external file (MMPLog.h) which is maintained in its own git repository.
// I add this repository in my other projects as a submodule (via git submodule) and import the MMPLog.h
// in a project's Prefix.pch.
//
// For convenience reasons, I just include these macros here, so other people are not confused by
// git submodule if they are unfamiliar with it or simply don't have to bother and can use MMPDeepSleepPreventer
// as simple drop-in code.

#ifndef MMPDLog
	#ifdef DEBUG
		#define MMPDLog(format, ...) NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
	#else
		#define MMPDLog(...) do { } while (0)
	#endif
#endif

#ifndef MMPALog
	#define MMPALog(format, ...) NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif


#pragma mark -
#pragma mark Imports and Forward Declarations

#import <Foundation/Foundation.h>

@class AVAudioPlayer;


#pragma mark -
#pragma mark Public Interface

@interface MMPDeepSleepPreventer : NSObject
{

}


#pragma mark -
#pragma mark Properties

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSTimer       *preventSleepTimer;


#pragma mark -
#pragma mark Public Methods

- (void)startPreventSleep;
- (void)stopPreventSleep;

@end
