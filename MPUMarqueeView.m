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
-(id)viewForFirstBaselineLayout {
 return [[[self->_contentView subviews]firstObject]viewForFirstBaselineLayout];
}
-(id)viewForLastBaselineLayout {
 return [[[self->_contentView subviews]lastObject]viewForLastBaselineLayout];
}
-(void)resetMarqueePosition {
 [self _tearDownMarqueeAnimation];
 [self _createMarqueeAnimationIfNeeded];
}
-(void)_tearDownMarqueeAnimation {
 [[self->_contentView layer]removeAnimationForKey:@"_MPUMarqueeViewLayerAnimationKey"];
}
@end
