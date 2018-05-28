
#import "CircleIndicator.h"

#define KAnimationKeyChase      @"chase"
#define KAnimationKeyFill       @"fill"
#define KAnimationKeyDrain      @"drain"

@interface CircleIndicator () <CAAnimationDelegate>

@property (nonatomic, retain) CAShapeLayer      *animationLayer;

@property (nonatomic, retain) CABasicAnimation  *fillAnimation;
@property (nonatomic, retain) CAAnimationGroup  *drainAnimation;

@property (nonatomic, retain) CABasicAnimation  *clearAnimation;
@property (nonatomic, retain) CABasicAnimation  *colorAnimation;

@end

@implementation CircleIndicator
{
    BOOL        _isAnimating;
}

- (CAShapeLayer *)animationLayer
{
    if (!_animationLayer) {
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2,
                                                                               self.bounds.size.height/2)
                                                            radius:self.bounds.size.width/2 startAngle:(1.5 * M_PI) endAngle:(3.5 * M_PI) clockwise:YES];
        
        _animationLayer = [[CAShapeLayer alloc] init];
        _animationLayer.frame = self.bounds;
        _animationLayer.lineWidth = self.lineWidth;
        _animationLayer.lineCap = kCALineCapRound;
        _animationLayer.strokeColor = self.circleColor.CGColor;
        _animationLayer.fillColor = [UIColor clearColor].CGColor;
        _animationLayer.path = path.CGPath;
        _animationLayer.strokeEnd = 0;
    }
    
    return _animationLayer;
}

- (CABasicAnimation *)fillAnimation
{
    if (!_fillAnimation) {
        
        _fillAnimation = [[CABasicAnimation animationWithKeyPath:@"strokeEnd"] retain];
        _fillAnimation.delegate = self;
        _fillAnimation.fromValue = @(0.0);
        _fillAnimation.toValue = @(1.0);
        _fillAnimation.duration = 0.75;
        _fillAnimation.repeatCount = 1;
        _fillAnimation.removedOnCompletion = NO;
        _fillAnimation.fillMode = kCAFillModeForwards;
    }
    
    return _fillAnimation;
}

- (CAAnimationGroup *)drainAnimation
{
    if (!_drainAnimation) {
        
        _drainAnimation = [[CAAnimationGroup animation] retain];
        _drainAnimation.delegate = self;
        _drainAnimation.duration = 0.75;
        _drainAnimation.repeatCount = 1;
        _drainAnimation.animations = @[self.clearAnimation,self.colorAnimation];
        _drainAnimation.removedOnCompletion = NO;
        _drainAnimation.fillMode = kCAFillModeForwards;
    }
    
    return _drainAnimation;
}

- (CABasicAnimation *)clearAnimation
{
    if (!_clearAnimation) {
        
        _clearAnimation = [[CABasicAnimation animationWithKeyPath:@"strokeStart"] retain];
        _clearAnimation.fromValue = @(0.0);
        _clearAnimation.toValue = @(1.0);
    }
    
    return _clearAnimation;
}

- (CABasicAnimation *)colorAnimation
{
    if (!_colorAnimation) {
        
        _colorAnimation = [[CABasicAnimation animationWithKeyPath:@"strokeColor"] retain];
        _colorAnimation.fromValue = (id)self.circleColor.CGColor;
        _colorAnimation.toValue = (id)self.circleColor.CGColor;
    }
    
    return _colorAnimation;
}

- (BOOL)isAnimating
{
    return _isAnimating;
}

- (void)setType:(CircleIndicatorType)type
{
    _type = type;
    
    if (0 == self.duration) {
        
        if (type == CircleIndicatorTypeChase) {
            
            self.duration = 1.0;
        }
        else if (type == CircleIndicatorTypeFillAndDrain) {
            
            self.duration = 1.5;
        }
    }
}

- (void)setDuration:(CGFloat)duration
{
    _duration = duration;
    
    self.fillAnimation.duration = duration/2;
    self.drainAnimation.duration = duration/2;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    
    self.animationLayer.lineWidth = lineWidth;
}

- (void)setCircleColor:(UIColor *)circleColor
{
    [_circleColor release];
    [circleColor retain];
    _circleColor = circleColor;
    
    self.animationLayer.strokeColor = circleColor.CGColor;
    self.colorAnimation.fromValue = (id)self.circleColor.CGColor;
    self.colorAnimation.toValue = (id)[self.circleColor colorWithAlphaComponent:0.2].CGColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.lineWidth = 10;
        self.circleColor = AppNormalColor;
        self.duration = 0.0;
        self.type = CircleIndicatorTypeFillAndDrain;
        self.durationBetweenFillAndDrain = 0.3;
        [self.layer addSublayer:self.animationLayer];
        
        self.hidden = YES;
    }
    
    return self;
}

- (void)dealloc
{
    [self.animationLayer removeAllAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAnimation) object:nil];
    
    self.fillAnimation  = nil;
    self.clearAnimation = nil;
    self.colorAnimation = nil;
    self.drainAnimation = nil;
    self.animationLayer = nil;
    self.circleColor    = nil;
    
    [super dealloc];
}

- (void)startAnimation
{
    if (self.isAnimating) {
        
        return;
    }
    
    self.hidden = NO;
    
    if (CircleIndicatorTypeChase == self.type) {
        
        [self startChaseAnimation];
    }
    else if (CircleIndicatorTypeFillAndDrain == self.type) {
        
        [self startFillAndDrainAnimation];
    }
}

- (void)stopAnimation
{
    if (!self.isAnimating) {
        
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAnimation) object:nil];
    [self.animationLayer removeAllAnimations];
    
    self.hidden = YES;
    _isAnimating = NO;
}

- (void)startFillAndDrainAnimation
{
    if (CircleIndicatorTypeFillAndDrain != self.type) {
        
        return;
    }
    
    _isAnimating = YES;
    
    self.animationLayer.strokeColor = self.circleColor.CGColor;
    [self.animationLayer addAnimation:self.fillAnimation forKey:@"fill"];
}

- (void)startChaseAnimation
{
    if (CircleIndicatorTypeChase != self.type) {
        
        return;
    }
    
    _isAnimating = YES;
    
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.fromValue = @(-0.5);
    strokeStartAnimation.toValue = @(1.0);
    
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.fromValue = @(0.0);
    strokeEndAnimation.toValue = @(1.0);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = self.duration;
    group.repeatCount = CGFLOAT_MAX;
    group.animations = @[strokeStartAnimation,strokeEndAnimation];
    
    [self.animationLayer addAnimation:group forKey:KAnimationKeyChase];
}

#pragma mark -
#pragma mark - <CAAnimationDelegate>
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([[self.animationLayer animationForKey:KAnimationKeyFill] isEqual:anim]) {
        
        [self.animationLayer addAnimation:self.drainAnimation forKey:KAnimationKeyDrain];
    }
    else if ([[self.animationLayer animationForKey:KAnimationKeyDrain] isEqual:anim]){
        
        [self.animationLayer removeAllAnimations];
        [self performSelector:@selector(startFillAndDrainAnimation) withObject:nil afterDelay:self.durationBetweenFillAndDrain];
    }
}

@end

