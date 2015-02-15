//
//  FancyTabBar.m
//  FancyTabBar
//
//  Created by Jonathan on 15/05/2014.
//

#import "FancyTabBar.h"
#import "Coordinate.h"
#import "UIImage+ImageEffects.h"
#import "UIView+Screenshot.h"

#define PADDING 10
#define DegreesToRadians(x) ((x) * M_PI / 180.0)

static const int subviewTagConstant = 1000;
static const float openAnimationDuration = 0.5;
static const float collapseAnimationDuration = 0.5;

@interface FancyTabBar(){
    
}

@property(nonatomic,assign) BOOL calculated;
@property(nonatomic,assign) BOOL open;
@property(nonatomic,assign) BOOL animating;

@property(nonatomic,strong) NSArray *choices;
@property(nonatomic,strong) NSMutableDictionary *destinationCoordinateDictionary;
@property(nonatomic,strong) NSMutableDictionary *originalCoordinateDictionary;
@property(nonatomic,strong) UIImage *mainButtonImage;
@property(nonatomic,strong) UIButton *mainButton;
@property(nonatomic,strong) UIView *backgroundView;
@property(nonatomic,strong) UIDynamicAnimator *dynamicsAnimator;
@property(nonatomic,strong) UIDynamicBehavior *dynamicBehaviour;
@property (assign, nonatomic) CGPoint mainBtnCustomOrigin;

@property(nonatomic,weak) UIViewController *parentViewController;

- (void) resetViews;

@end

@implementation FancyTabBar

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(!_open){
        if (hitView == self){
            return nil;
        }else{
            return hitView;
        }
    }
    return hitView;
}

#pragma mark - setup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void) resetViews{
    for (UIButton *button in self.subviews){
        button.hidden = NO;
        button.transform = CGAffineTransformMakeScale(1, 1);
        button.alpha  = 1.0;
    }
}

- (void) setUpChoices:(UIViewController*) parentViewController choices:(NSArray*) choices withMainButtonImage:(UIImage*)mainButtonImage andMainButtonCustomOrigin:(CGPoint)customOrigin
{
    _mainBtnCustomOrigin=customOrigin;
    [self setUpChoices:parentViewController choices:choices withMainButtonImage:mainButtonImage];
}
- (void) setUpChoices:(UIViewController*) parentViewController choices:(NSArray*) choices withMainButtonImage:(UIImage*)mainButtonImage{
    _parentViewController = parentViewController;
    _choices = choices;
    _mainButtonImage = mainButtonImage;
    _destinationCoordinateDictionary = [[NSMutableDictionary alloc]init];
    _originalCoordinateDictionary =  [[NSMutableDictionary alloc]init];

    _mainButton = [[UIButton alloc]initWithFrame:CGRectZero];

    CGRect frame = _mainButton.frame;
    frame.size = CGSizeMake(mainButtonImage.size.width, mainButtonImage.size.height);
    _mainButton.frame = frame;
  
    [_mainButton addTarget:self action:@selector(explode) forControlEvents:UIControlEventTouchUpInside];
    [_mainButton setImage:mainButtonImage forState:UIControlStateNormal];
    
    [self calculateExpandedCoordinates];
    [self addSubview:_mainButton];

}

- (void) choose:(id) sender{
    UIButton *button = (UIButton*)sender;
    NSInteger tag = button.tag;
    [self collapseAnimation];
    
    if(_delegate && [_delegate respondsToSelector:@selector(optionsButton:didSelectItem:)]){
        [_delegate optionsButton:button didSelectItem:tag/subviewTagConstant];
    }
}

- (void) calculateExpandedCoordinates{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    float width;
    float height;
    float parentWidth;
    float parentHeight;
    
    if(orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight){
        parentHeight = _parentViewController.view.frame.size.width;
        parentWidth = _parentViewController.view.frame.size.height;
        width = self.frame.size.height;
        height = self.frame.size.width;
    }else{
        parentHeight = _parentViewController.view.frame.size.height;
        parentWidth = _parentViewController.view.frame.size.width;
        width = self.frame.size.width;
        height = self.frame.size.height;
    }
    
    self.frame = CGRectMake(0,0, parentWidth, parentHeight);
    
    if (CGPointEqualToPoint(_mainBtnCustomOrigin, CGPointZero)) {
        _mainBtnCustomOrigin=CGPointMake((width -_mainButtonImage.size.width)/2, height - _mainButtonImage.size.height);
    }
    _mainButton.frame = CGRectMake(_mainBtnCustomOrigin.x,_mainBtnCustomOrigin.y, _mainButtonImage.size.width, _mainButtonImage.size.height);
    
    for (int i = 0;i<_choices.count;i++){
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectZero];
        CGRect frame = button.frame;
        UIImage *buttonChoiceImage = [UIImage imageNamed:_choices[i]];
        frame.size = CGSizeMake(buttonChoiceImage.size.width,buttonChoiceImage.size.height);
        button.frame = frame;
        int x = (int)width/2;
        int y = _mainButton.frame.origin.y + _mainButton.frame.size.height/2;
        button.center =  CGPointMake(x,y);
        Coordinate *originalCoordinate = [[Coordinate alloc]init];
        originalCoordinate.x = [NSNumber numberWithInteger:x];
        originalCoordinate.y = [NSNumber numberWithInteger:y];
        int tag = subviewTagConstant*(i+1);
        [_originalCoordinateDictionary setObject:originalCoordinate forKey:[NSNumber numberWithInteger:tag]];
        [button setImage:[UIImage imageNamed:_choices[i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = tag;
        button.alpha = 0;
        [self addSubview:button];
    }
    
    float plane = (parentWidth)-2*PADDING;
    float radius = plane/3;
    float xCentre = _mainButton.center.x;
    float yCentre = _mainButton.center.y;
    
    
    float x;
    float y;
    
    float degrees = 180/(_choices.count-1);
    
    for (int i=0; i < _choices.count; i++) {
        int tag = (i+1)*subviewTagConstant;
        Coordinate *coordinate = [[Coordinate alloc] init];
        float radian = (degrees*(i)*M_PI)/180;
        if (_currentDirectionToPopOptions==FancyTabBarItemsPop_Down) {
            //Pop Option Buttons Down
            radian = (degrees*(i)*M_PI)/-180;
        }
        float cosineRadian = cosf(radian);
        float sineRadian = sinf(radian);
        
        float radiusLengthX = (radius * cosineRadian);
        float radiusLengthY = (radius * sineRadian);
        
        x = xCentre + radiusLengthX;
        y = yCentre - radiusLengthY;
        
        coordinate.x = [NSNumber numberWithInt:x];
        coordinate.y = [NSNumber numberWithInt:y];
        
        coordinate.x = [NSNumber  numberWithInt:x];
        
        coordinate.y = [NSNumber numberWithFloat:y];
        [_destinationCoordinateDictionary setObject:coordinate forKey:[NSNumber numberWithInt:tag]];
    }
    
}

#pragma mark - animation

- (void) explode{
    if(!_animating){
        _animating = YES;
        [self resetViews];
        if(!_open){
            [self expandAnimation];
        }else{
            [self collapseAnimation];
        }
    }
}

- (void) collapse{
    for (int i=0; i < _choices.count; i++) {
        int tag = (i+1)*subviewTagConstant;
        UIButton *button = (UIButton*)[self viewWithTag:tag];
        button.alpha = 0.0;
        _backgroundView.alpha = 0.0;
        Coordinate *coordinate =  [_originalCoordinateDictionary objectForKey:[NSNumber numberWithInt:tag]];
        button.center =  CGPointMake([coordinate.x floatValue], [coordinate.y floatValue]);
    }
    double rads = DegreesToRadians(-45);
    _mainButton.layer.transform = CATransform3DMakeRotation(rads, 0, 0, 0);
}


- (void) collapseAnimation{
    if(_delegate && [_delegate respondsToSelector:@selector(didCollapse)]){
        [_delegate didCollapse];
    }
    [UIView animateWithDuration:collapseAnimationDuration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        [self collapse];
    } completion:^(BOOL finished) {
        _open  = NO;
        _animating = NO;
    }];
    
}

- (void) expandAnimation{
    if(_delegate && [_delegate respondsToSelector:@selector(didExpand)]){
        [_delegate didExpand];
    }
    [UIView animateWithDuration:openAnimationDuration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        for (int i=0; i < _choices.count; i++) {
            int tag = (i+1)*subviewTagConstant;
            UIButton *button = (UIButton*)[self viewWithTag:tag];
            button.alpha = 1.0;
            Coordinate *coordinate =  [_destinationCoordinateDictionary objectForKey:[NSNumber numberWithInt:tag]];
            button.center =  CGPointMake([coordinate.x floatValue], [coordinate.y floatValue]);
        }
        double rads = DegreesToRadians(45);
        _mainButton.layer.transform = CATransform3DMakeRotation(rads, 0, 0, 1);
    } completion:^(BOOL finished) {
        _open  = YES;
        _animating = NO;
    }];
}


@end
