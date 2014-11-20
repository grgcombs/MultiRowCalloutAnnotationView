//
//  MultiRowCalloutCell.h
//  Created by Greg Combs on 11/29/11.
//
//  based on work at https://github.com/grgcombs/MultiRowCalloutAnnotationView
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MultiRowCalloutCell;
typedef void(^MultiRowAccessoryTappedBlock)(MultiRowCalloutCell *cell, UIControl *control, NSDictionary *userData);

@interface MultiRowCalloutCell : UITableViewCell
@property (nonatomic,strong) NSDictionary *userData;
@property (nonatomic,copy) MultiRowAccessoryTappedBlock onCalloutAccessoryTapped;
@property (nonatomic,unsafe_unretained) NSString *title;
@property (nonatomic,unsafe_unretained) NSString *subtitle;
@property (nonatomic,unsafe_unretained) UIImage *image;
+ (instancetype)cellWithImage:(UIImage *)image title:(NSString *)title subtitle:(NSString *)subtitle userData:(NSDictionary *)userData;
+ (instancetype)cellWithImage:(UIImage *)image title:(NSString *)title subtitle:(NSString *)subtitle userData:(NSDictionary *)userData onCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)block;
@end

extern CGSize const kMultiRowCalloutCellSize;