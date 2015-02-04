//
//  ViewController.m
//  FancyTabBar
//
//  Created by Jonathan on 03/09/2014.
//
//

#import "ViewController.h"
#import "UIView+Screenshot.h"
#import "UIImage+ImageEffects.h"
#import "FancyTabBar.h"

@interface ViewController ()<FancyTabBarDelegate>

@property(nonatomic,strong) FancyTabBar *fancyTabBar;
@property (nonatomic,strong) UIImageView *backgroundView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _fancyTabBar = [[FancyTabBar alloc]initWithFrame:self.view.bounds];
    [_fancyTabBar setUpChoices:self choices:@[@"gallery",@"dropbox",@"camera",@"draw"] withMainButtonImage:[UIImage imageNamed:@"main_button"]];
    //Custom Placement
//    [_fancyTabBar setUpChoices:self choices:@[@"gallery",@"dropbox",@"camera",@"draw"] withMainButtonImage:[UIImage imageNamed:@"main_button"] andMainButtonCustomOrigin:CGPointMake(100, 100)];
    _fancyTabBar.delegate = self;
    [self.view addSubview:_fancyTabBar];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FancyTabBarDelegate
- (void) didCollapse{
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        if(finished) {
            [_backgroundView removeFromSuperview];
            _backgroundView = nil;
        }
    }];
}


- (void) didExpand{
    if(!_backgroundView){
        _backgroundView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        _backgroundView.alpha = 0;
        [self.view addSubview:_backgroundView];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
    [self.view bringSubviewToFront:_fancyTabBar];
    UIImage *backgroundImage = [self.view convertViewToImage];
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    UIImage *image = [backgroundImage applyBlurWithRadius:10 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
    _backgroundView.image = image;
}
// PERFORM SEGUES TO NEXT VIEWS BASED ON INDEX PATH
- (void)optionsButton:(UIButton*)optionButton didSelectItem:(int)index{
    NSLog(@"Hello index %d tapped !", index);
//GALLERY SEGUE
  if (index == 1) {
        [self performSegueWithIdentifier:@"YOUR NEXT VIEW" sender: self];
}
}
@end
