//
//  CircleIndicator.h
//  SwannOne_iPhone
//
//  Created by 宋云龙 on 2018/5/25.
//  Copyright © 2018年 Rainy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    CircleIndicatorTypeFillAndDrain,       // Default
    CircleIndicatorTypeChase
    
} CircleIndicatorType;

@interface CircleIndicator : UIView

/**
 Animation Type
 Default is LoadingCicleTypeFillAndDrain
 */
@property (nonatomic, assign)           CircleIndicatorType   type;

/**
 Animation Duration
 Default 1.5 for LoadingCicleTypeFillAndDrain
 Default 1.0 for LoadingCicleTypeChase
 */
@property (nonatomic, assign)           CGFloat            duration;

/**
 The Duration bwtween Fill And Drain for LoadingCicleTypeFillAndDrain
 Default is 0.3
 */
@property (nonatomic, assign)           CGFloat            durationBetweenFillAndDrain;

/**
 Default is AppNormalColor
 */
@property (nonatomic, retain)           UIColor            *circleColor;

/**
 Width of the Circle
 Default is 10
 */
@property (nonatomic, assign)           CGFloat            lineWidth;

@property (nonatomic, readonly, assign) BOOL               isAnimating;

/**
 When start animation
 Will auto set hidden to NO
 */
- (void)startAnimation;

/**
 When stop animation
 Will auto set hidden to YES
 */
- (void)stopAnimation;

@end
