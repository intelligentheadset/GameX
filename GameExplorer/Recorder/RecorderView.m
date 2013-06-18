//
//  RecorderView.m
//  KnowledgeExplorer
//
//  Created by Martin Lobger on 18/02/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "RecorderView.h"


@interface RecorderView () <AVAudioRecorderDelegate>

@end


@implementation RecorderView {
    CGRect              _peakMeter;
    AVAudioRecorder*    _audioRecorder;
}


- (id)init {
    self = [super init];
    if (self) {
        // Trick: load view from .xib and assign to self. This is a UIView, not a UIViewController.
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        for (id p in nib) {
            if ([p isKindOfClass:[self class]]) {
                self = p;
                break;
            }
        }
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    _peakMeter = _peakMeterImageView.frame;
}


#pragma mark - Interface Bulder Methods

- (IBAction)stopButtonTouchUpInside:(id)sender {
    [self stopRecording];
}


#pragma mark - Public Methods

- (void)startRecording {
    if (!_audioRecorder.recording) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (error == nil) {
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            // When going into PlayAndRecord mode, sound will start comming out of the
            // phone speaker rather than the headset. These lines below, make sound go to headset.
            if (error == nil) {
                UInt32 allowBluetoothInput = 1;
                AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput, sizeof(allowBluetoothInput), &allowBluetoothInput);
            }
        }
        if (error != nil) {
            if ([_delegate respondsToSelector:@selector(recorderView:errorDidOccur:)]) {
                [_delegate recorderView:self errorDidOccur:error];
            }
        }
        else {
            BOOL result = [_audioRecorder record];
            _audioRecorder.meteringEnabled = YES;
            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
            if ([_delegate respondsToSelector:@selector(recorderView:didStartRecordingWithSuccess:)]) {
                [_delegate recorderView:self didStartRecordingWithSuccess:result];
            }
        }
    }
}


- (void)stopRecording {
    [_audioRecorder stop];
}


- (void)deleteRecording {
    [_audioRecorder deleteRecording];
}


#pragma mark - Property Access Methods

- (BOOL)recording {
    return _audioRecorder.recording;
}


#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    // Set things back to "normal" after recording
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    if (flag) {
        if ([_delegate respondsToSelector:@selector(recorderView:didStopRecordingToURL:)]) {
            [_delegate recorderView:self didStopRecordingToURL:_audioRecorder.url];
        }
    }

    // Get ready for next recording
    [self initialize];
}


-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"ERROR: %@", error);
    if ([_delegate respondsToSelector:@selector(recorderView:errorDidOccur:)]) {
        [_delegate recorderView:self errorDidOccur:error];
    }
}


#pragma mark - Private Methods

- (void)initialize {
    if (_audioRecorder == nil) {
        NSString *soundFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"recording.caf"];

        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];

        NSDictionary *recordSettings = @{
                                         AVEncoderAudioQualityKey : @(AVAudioQualityMin),
                                         AVEncoderBitRateKey : @(16),
                                         AVNumberOfChannelsKey : @(2),
                                         AVSampleRateKey : @(44100.0)
                                         };

        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
        _audioRecorder.delegate = self;

        if (error != nil) {
            NSLog(@"ERROR: %@", error.localizedDescription);
            if ([_delegate respondsToSelector:@selector(recorderView:errorDidOccur:)]) {
                [_delegate recorderView:self errorDidOccur:error];
            }
            return;
        }
    }
    
    if (![_audioRecorder prepareToRecord]) {
        if ([_delegate respondsToSelector:@selector(recorderView:errorDidOccur:)]) {
            NSError* error = [NSError errorWithDomain:@"RecorderViewDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Could not prepare for recording"}];
            [_delegate recorderView:self errorDidOccur:error];
        }
    }
}


- (void)updateTimer:(NSTimer*)timer {
    if (!_audioRecorder.isRecording) {
        [timer invalidate];
    }
    int min = (int)_audioRecorder.currentTime / 60;    // divide two longs, truncates
    int sec = (int)_audioRecorder.currentTime % 60;    // remainder of long divide
    _timerLabel.text = [[NSString alloc] initWithFormat:@"%02i:%02i", min, sec];

    [_audioRecorder updateMeters];
    float left = [_audioRecorder averagePowerForChannel:0];
    float right = [_audioRecorder averagePowerForChannel:1];
    float avg =  fabs(left + right) / 160.0;
    _peakMeter.size.width = self.frame.size.width * (1.0 - avg);
    _peakMeterImageView.frame = _peakMeter;
}

@end
