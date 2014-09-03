//
//  UIView+Screenshot.m
//  MarvelApp
//
//  Created by Jonathan on 17/05/2014.
//

#import "UIView+Screenshot.h"

@implementation UIView (Screenshot)
-(UIImage *)convertViewToImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
