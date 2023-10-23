#import "MPUMarqueeView.h"

@implementation MPUMarqueeView
-(instancetype)initWithFrame:(CGRect)frame {
 self = [super initWithFrame:frame];
 if (self) {
  self->_marqueeDelay = 3.0;
  self->_marqueeScrollRate = 30.0;
  _fadeEdgeInsets = UIEdgeInsetsZero;
  _coordinatedMarqueeViews = [NSPointerArray weakObjectsPointerArray];
  [self setClipsToBounds:YES];
  _contentView = [[MPUMarqueeContentView alloc]initWithFrame:[self bounds]];
  [self addSubview:_contentView];
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sceneDidEnterBackgroundNotification:) name:UISceneDidEnterBackgroundNotification object:nil];
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sceneWillEnterForegroundNotification:) name:UISceneWillEnterForegroundNotification object:nil];
 }
 return self;
}
-(void)didMoveToWindow {
 [super didMoveToWindow];
 UIWindow *ourWindow = [self window];
 if (ourWindow) {
  [self _createMarqueeAnimationIfNeeded];
 } else {
  [self _tearDownMarqueeAnimation];
 }
}
-(void)invalidateIntrinsicContentSize {
 [super invalidateIntrinsicContentSize];
 UIView *viewForContentSize = self->_viewForContentSize;
 if (viewForContentSize) {
  CGSize size = [viewForContentSize intrinsicContentSize];
  [self setContentSize:size];
 }
}
-(CGSize)intrinsicContentSize {
 UIView *viewForContentSize = self->_viewForContentSize;
 if (viewForContentSize) {
  return [viewForContentSize intrinsicContentSize];
 }
 return _contentSize;
}
-(id)viewForFirstBaselineLayout {
 return [[[self->_contentView subviews]firstObject]viewForFirstBaselineLayout];
}
-(id)viewForLastBaselineLayout {
 return [[[self->_contentView subviews]lastObject]viewForLastBaselineLayout];
}
-(void)animationDidStop:(id)animation finished:(BOOL)finished {
 if ([[animation valueForKey:@"_MPUMarqueeViewAnimationIdentifierKey"] isEqual:_currentAnimationID]) {
  [self _tearDownMarqueeAnimation];
  id delegate = self->_delegate;
  if ([delegate respondsToSelector:@selector(marqueeViewDidEndMarqueeIteration:finished:)]) {
   [delegate marqueeViewDidEndMarqueeIteration:self finished:finished];
  }
  if (finished) {
   /* does something with the _options ivar, but i dont know what... */
   [self _createMarqueeAnimationIfNeeded];
  }
 }
}
-(void)setContentGap:(double)contentGap {
 if (_contentGap != contentGap) {
  _contentGap = contentGap;
  [self _tearDownMarqueeAnimation];
  [self _createMarqueeAnimationIfNeeded];
  [self setNeedsLayout];
 }
}
-(void)setMarqueeDelay:(double)delay {
 if (_marqueeDelay != delay) {
  _marqueeDelay = delay;
  [self _createMarqueeAnimationIfNeeded];
 }
}
-(void)setAnimationReferenceView:(UIView *)animationReferenceView {
 if (self->_animationReferenceView != animationReferenceView) {
  self->_animationReferenceView = animationReferenceView;
  [self _createMarqueeAnimationIfNeeded];
 }
}
-(void)setMarqueeEnabled:(bool)marqueeEnabled {
 [self setMarqueeEnabled:marqueeEnabled withOptions:nil];
}
-(void)setMarqueeScrollRate:(double)rate {
 if (_marqueeScrollRate != rate) {
  _marqueeScrollRate = rate;
  [self _tearDownMarqueeAnimation];
  [self _createMarqueeAnimationIfNeeded];
 }
}
-(void)setViewForContentSize:(UIView *)view {
 if (_viewForContentSize != view) {
  _viewForContentSize = view;
  [self invalidateIntrinsicContentSize];
 }
}
-(void)setAnimationDirection:(long long)animationDirection {
 if (_animationDirection != animationDirection) {
  _animationDirection = animationDirection;
  [self setNeedsLayout];
 }
}
-(void)addCoordinatedMarqueeView:(MPUMarqueeView *)view {
 if (_primaryMarqueeView) {
  [self->_primaryMarqueeView addCoordinatedMarqueeView:_primaryMarqueeView];
 } else {
  view->_primaryMarqueeView = self;
  [self->_coordinatedMarqueeViews addPointer:(__bridge void * _Nullable)(_primaryMarqueeView)];
 }
}
-(id)coordinatedMarqueeViews {
 [_coordinatedMarqueeViews compact];
 return [_coordinatedMarqueeViews allObjects];
}
-(void)resetMarqueePosition {
 [self _tearDownMarqueeAnimation];
 [self _createMarqueeAnimationIfNeeded];
}
-(void)_tearDownMarqueeAnimation {
 [[self->_contentView layer]removeAnimationForKey:@"_MPUMarqueeViewLayerAnimationKey"];
}
-(void)sceneDidEnterBackgroundNotification:(id)scene {
 id sceneObj = [scene object];
 id windowScene = [[self window]windowScene];
 if (sceneObj == windowScene) {
   [self setMarqueeEnabled:NO];
 }
}
-(void)sceneWillEnterForegroundNotification:(id)scene {
 id sceneObj = [scene object];
 id windowScene = [[self window]windowScene];
 if (sceneObj == windowScene) {
   [self setMarqueeEnabled:YES];
 }
}
@end

/*
 * Not yet implemented:
 * layoutSubviews
 * setBounds
 * setFrame
 * setContentSize:
 * setMarqueeEnabled:withOptions:
 * _applyMarqueeFade
 * _createMarqueeAnimationIfNeeded
 * _createMarqueeAnimationIfNeededWithMaximumDuration:beginTime:
 * _duration
 *
 * Some methods may be inaccurate.
*/
