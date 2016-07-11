//
//  MKRScene.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRScene.h"

@interface MKRScene()

@property (readwrite, nonatomic) NSInteger identifier;

@end

@implementation MKRScene

-(instancetype)initWithIdentifier:(NSInteger)identifier {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setBars:[NSMutableArray<MKRBar *> new]];
    [self setIdentifier:identifier];
    
    return self;
}

-(BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    @throw([NSException exceptionWithName:NSInternalInconsistencyException reason:@"You must override this method in subclass" userInfo:nil]);
}

-(void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andWithResultCursorPtr:(CMTime *)resultCursorPtr andWithMSPQ:(NSInteger)MSPQ {
    NSLog(@"scene identifier = %ld", self.identifier);
    for (MKRBar *bar in self.bars) {
        AVMutableComposition *barAsset = [barsAssets objectForKey:@(bar.identifier)];
        if (barAsset == nil) {
            @throw([NSException exceptionWithName:@"Bar asset not found" reason:@"Bar asset not found" userInfo:nil]);
        }
        CMTimeRange barTimeRange = CMTimeRangeMake(kCMTimeZero, barAsset.duration);
        [composition insertTimeRange:barTimeRange ofAsset:barAsset atTime:*resultCursorPtr error:nil];
        *resultCursorPtr = CMTimeAdd(*resultCursorPtr, [barAsset duration]);
        
        if (bar.totalQuantsLength > bar.quantsLength) {
            NSInteger quantsRemainder = bar.totalQuantsLength - bar.quantsLength;
            CMTime remainder = CMTimeMakeWithSeconds(quantsRemainder * MSPQ / 1000.0, 60000);
            *resultCursorPtr = CMTimeAdd(*resultCursorPtr, remainder);
        }

        NSLog(@"bar id: %ld d: %f td: %f ql: %ld tql: %ld", bar.identifier, CMTimeGetSeconds(barAsset.duration), CMTimeGetSeconds(*resultCursorPtr), bar.quantsLength, bar.totalQuantsLength);
    }
}

@end
