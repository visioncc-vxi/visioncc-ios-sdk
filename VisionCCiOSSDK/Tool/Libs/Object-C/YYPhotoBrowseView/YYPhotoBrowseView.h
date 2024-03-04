//
//  YYPhotoGroupView.h
//
//  Created by ibireme on 14/3/9.
//  Copyright (C) 2014 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Get main screen's scale.
CGFloat YYScreenScale(void);

/// Single picture's info.
@interface YYPhotoGroupItem : NSObject
@property (nonatomic, strong) UIView *thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, assign) CGSize largeImageSize;
@property (nonatomic, strong) NSURL *largeImageURL;

/** 新增类型(UIImage 或 NSString) */
@property(nonatomic, strong) id imgOrUrl;

@end


/// Used to show a group of images.
/// One-shot.
@interface YYPhotoBrowseView : UIView
@property (nonatomic, readonly) NSArray *groupItems; ///< Array<YYPhotoGroupItem>
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, assign) BOOL blurEffectBackground; ///< Default is YES


- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithGroupItems:(NSArray *)groupItems;

- (void)presentFromImageView:(UIView *)fromView
                 toContainer:(UIView *)container
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion;

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismiss;


/// 打开指定页面的图片
/// @param index 页面索引
- (void)setShowFirstViewFor:(NSInteger)index;

@end

//MARK: - CALayer
@interface CALayer (shlingzhang)
@property (nonatomic) CGPoint center;      ///< Shortcut for center.
@property (nonatomic) CGFloat centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint origin;      ///< Shortcut for frame.origin.
@property (nonatomic, getter=frameSize, setter=setFrameSize:) CGSize  size; ///< Shortcut for frame.size.
@property (nonatomic) CGFloat transformScale; ///< key path "tranform.scale"

/**
 Add a fade animation to layer's contents when the contents is changed.
 
 @param duration Animation duration
 @param curve    Animation curve.
 */
- (void)addFadeAnimationWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve;

/**
 Remove all sublayers.
 */
- (void)removeAllSublayers;

@end

//MARK: UIImage(VXI)
@interface UIImage(VXI)
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
- (UIImage *)imageByBlurDark;

- (UIImage *)imageByBlurRadius:(CGFloat)blurRadius
                     tintColor:(UIColor *)tintColor
                      tintMode:(CGBlendMode)tintBlendMode
                    saturation:(CGFloat)saturation
                     maskImage:(UIImage *)maskImage;
@end

//MARK: - UIView
@interface UIView (VXI)

@property (nonatomic) CGPoint vxiOrigin;
@property (nonatomic) CGSize vxiSize;

@property (readonly) CGPoint vxiBottomLeft;
@property (readonly) CGPoint vxiBottomRight;
@property (readonly) CGPoint vxiTopRight;

@property (nonatomic) CGFloat vxiOriginX;
@property (nonatomic) CGFloat vxiOriginY;
@property (nonatomic) CGFloat vxiCenterX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat vxiCenterY;     ///< Shortcut for center.y

@property (nonatomic) CGFloat vxiFrameRight;
@property (nonatomic) CGFloat vxiFrameBottom;

@property (nonatomic) CGFloat vxiFrameWidth;
@property (nonatomic) CGFloat vxiWidth;
@property (nonatomic) CGFloat vxiFrameHeight;
@property (nonatomic) CGFloat vxiHeight;

@property (nonatomic) CGFloat vxiLeft;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat vxiTop;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat vxiRight;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat vxiBottom;      ///< Shortcut for frame.origin.y + frame.size.height

- (BOOL) containsSubView:(UIView *_Nonnull)subView;
- (BOOL) containsSubViewOfClassType:(Class _Nonnull)aClass;
- (void) removeAllSubviews;

- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;

- (nullable UIViewController *)getParentVC;

/**
 Create a snapshot image of the complete view hierarchy.
 */
- (nullable UIImage *)snapshotImage;

/**
 Create a snapshot image of the complete view hierarchy.
 @discussion It's faster than "snapshotImage", but may cause screen updates.
 See -[UIView drawViewHierarchyInRect:afterScreenUpdates:] for more information.
 */
- (nullable UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

- (nullable UIViewController *)viewController;

- (nonnull NSString *)className;

@end
