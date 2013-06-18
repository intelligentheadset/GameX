//
//  RecorderView.h
//  KnowledgeExplorer
//
//  Created by Martin Lobger on 18/02/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol RecorderViewDelegate;


@interface RecorderView : UIView {
    
    __weak IBOutlet UIImageView *_peakMeterImageView;
    __weak IBOutlet UILabel *_timerLabel;
    __weak IBOutlet UIButton *_stopButton;
}


@property (nonatomic, weak) id<RecorderViewDelegate> delegate;
@property (nonatomic, readonly) BOOL recording;

- (IBAction)stopButtonTouchUpInside:(id)sender;

- (void)startRecording;
- (void)stopRecording;
- (void)deleteRecording;

@end


@protocol RecorderViewDelegate <NSObject>
@optional

- (void)recorderView:(RecorderView*)recorderView didStartRecordingWithSuccess:(BOOL)success;
- (void)recorderView:(RecorderView*)recorderView didStopRecordingToURL:(NSURL*)url;

- (void)recorderView:(RecorderView*)recorderView errorDidOccur:(NSError*)error;


@end
