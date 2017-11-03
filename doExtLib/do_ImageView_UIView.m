//
//  TYPEID_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_ImageView_UIView.h"

#import "doInvokeResult.h"
#import "doIPage.h"
#import "doIScriptEngine.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "NSData+DoBase64.h"
#import "doUIContainer.h"
#import "doTextHelper.h"
#import "doISourceFS.h"
#import "doServiceContainer.h"
#import "doIOHelper.h"
#import "doIGlobal.h"
#import <CommonCrypto/CommonDigest.h>
#import "doIBorder.h"
#import "doIBitmap.h"
#import "doJsonHelper.h"

static NSCache* dict;

static NSOperationQueue *myqueue;

@interface do_ImageView_UIView()<doIBorder>
@end

#define ANIMATION_DURATION .3

typedef enum : NSUInteger {
    AnimationNone,
    AnimationFade
} AnimationType;

@implementation do_ImageView_UIView
{
    BOOL isEnabled;
    UIImage *defaultImage;
    UIImage *_imageSource;
    NSString *_imageName;
    NSString *_scaleModel;
    AnimationType _animationType;
    BOOL _isClearBorder;
    BOOL _isChangeSource;
}
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    model = (typeof(model)) _doUIModule;
    if(dict==nil){
        dict = [[NSCache alloc]init];
        dict.countLimit = 50;
        dict.totalCostLimit = 10*1024*1024;
    }
    if (!myqueue) {
        myqueue = [NSOperationQueue new];
        myqueue.maxConcurrentOperationCount = 1;//改成单线程串行
    }
    self.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [self addGestureRecognizer:tap];
    self.cacheType = [model GetProperty:@"cacheType"].DefaultValue;
    
    _animationType = AnimationNone;
    
    _isClearBorder = NO;
    
    _isChangeSource = NO;
}

//销毁所有的全局对象
- (void) OnDispose
{
    defaultImage = nil;
    self.image = nil;
    _imageSource = nil;
}
//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:model];
    
    [self autoSize];

    [doUIModuleHelper generateBorder:model :[model GetPropertyValue:@"border"]];
}

- (void)autoSize
{
    BOOL isAutoHeight = [[model GetPropertyValue:@"height"] isEqualToString:@"-1"];
    BOOL isAutoWidth = [[model GetPropertyValue:@"width"] isEqualToString:@"-1"];
    if(!isAutoHeight && !isAutoWidth)
    {
        return;
    }
    UIImage *image = self.image;
    CGSize imageSize = image.size;
    CGFloat w = model.RealWidth;
    CGFloat h = model.RealHeight;
    //-1处理
    if (isAutoHeight) {
        //UIViewContentModeCenter 已经*Zoom过了
        if (self.contentMode != UIViewContentModeCenter) {
            h = imageSize.height * model.YZoom;
            if (self.contentMode == UIViewContentModeScaleToFill && imageSize.width>0) {
                h = imageSize.height*(w/imageSize.width);
            }
        }
        else
        {
            h = imageSize.height;
        }
    }
    if (isAutoWidth ) {
        if (self.contentMode != UIViewContentModeCenter) {
            w = imageSize.width * model.XZoom;
            if (self.contentMode == UIViewContentModeScaleToFill && imageSize.height>0) {
                w = imageSize.width*(h/imageSize.height);
            }
        }
        else
        {
            w = imageSize.width;
        }
    }
    self.frame = CGRectMake(model.RealX,model.RealY, w , h);
    [self setNeedsDisplay];
    
    [doUIModuleHelper OnResize:model];
}

#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */
- (void)change_radius: (NSString *)_radius
{
    CGFloat minZoom = MIN(model.XZoom, model.YZoom);
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = [[doTextHelper Instance] StrToInt:_radius :0]*minZoom;
}

- (void)change_enabled: (NSString *)_enabled
{
    BOOL defule = YES;
    if([[model GetProperty:@"enabled"].DefaultValue isEqualToString:@"false"])
        defule = NO;
    isEnabled = [[doTextHelper Instance] StrToBool:_enabled :defule];
}
- (void)change_defaultImage: (NSString *)_source
{
    NSString * imgPath = [doIOHelper GetLocalFileFullPath:model.CurrentPage.CurrentApp :_source];
    UIImage * img = [UIImage imageWithContentsOfFile:imgPath];
    if (!img) {//默认文件不存在
        if (!_imageSource) {//source文件不存在
            self.image = nil;
        }
        return;
    }
    defaultImage = img;
    if (!_imageSource)  self.image = [self getZoomImage:defaultImage];
}
- (void)change_source: (NSString *)_source
{
    if (_source.length==0) {
        self.image = nil;
        return;
    }
    NSString* cache = [model GetPropertyValue:@"cacheType"];
    if (_source != nil && _source.length > 0)
    {
        _imageName = _source;
        
        if ([_source hasPrefix:@"http"])  //如果是由网络请求
        {
            if ([cache isEqualToString:@"always"])
            {
                UIImage *image = [self getImageFromCache:_source];
                _imageSource = image;
                if(image)
                    self.image = [self getZoomImage:image];
                else{
                    [self clearImage];
                    [self getImageFromNetwork:_source cache:YES show:YES];
                }
            }
            else if ([cache isEqualToString:@"temporary"])
            {
                UIImage *image = [self getImageFromCache:_source];
                _imageSource = image;
                if(image)
                    self.image = [self getZoomImage:image];
                else
                    [self clearImage];
                [self getImageFromNetwork:_source cache:YES show:YES];
            }
            else
            {
                [self clearImage];
                _imageSource = nil;
                [self getImageFromNetwork:_source cache:NO show:YES];
            }
        }
        else  //如果是本地文件
        {
            [self clearImage];
            NSString * imgPath = [doIOHelper GetLocalFileFullPath:model.CurrentPage.CurrentApp :_source];
            NSString *strName = [[doTextHelper Instance] MD5:imgPath];
            
            UIImage * img = [self getImageFromCacheDict:strName :imgPath];
            
            if (img != nil) {
                self.image = [self getZoomImage:img];
                _imageSource = img;
            }
            else//本地图片不存在，不显示defaultimage
            {
                self.image = nil;
            }
            
        }
    }
    if ([_scaleModel isEqualToString:@"centercrop"]) {
        self.image = [self getImageFromImage:self.image];
    }
    _isChangeSource = NO;
}

- (void)change_scale: (NSString *)_scale
{
    if (_scale == nil || _scale.length <= 0)
    {
        _scale = [model GetProperty:@"scale"].DefaultValue;
    }
    if (_scale != nil && _scale.length > 0)
    {
        if ([_scale.lowercaseString isEqualToString:@"fillxy"])
        {
            self.contentMode = UIViewContentModeScaleToFill;
        }
        else if ([_scale.lowercaseString isEqualToString:@"center"])
        {
            self.contentMode = UIViewContentModeCenter;
        }
        else if ([_scale.lowercaseString isEqualToString:@"fillxory"])
        {
            self.contentMode = UIViewContentModeScaleAspectFit;
        }
        else if ([_scale.lowercaseString isEqualToString:@"centercrop"])
        {
            _scaleModel = _scale.lowercaseString;
            self.contentMode = UIViewContentModeScaleAspectFill;
            self.image = [self getImageFromImage:self.image];
        }
    }
}

- (void)change_cacheType: (NSString *)_cache
{
    if (_cache == nil || _cache.length <= 0)
    {
        _cache = [model GetProperty:@"cacheType"].DefaultValue;
    }
    if (_cache != nil && _cache.length > 0)
    {
        self.cacheType = _cache;
    }
}

- (void)change_animation:(NSString *)newValue
{
    if ([newValue isEqualToString:@"fade"]) {
        _animationType = AnimationFade;
    }else
        _animationType = AnimationNone;
}
//同步
- (void)setBitmap:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    NSString *bitmapAddress = [doJsonHelper GetOneText:_dictParas :@"bitmap" :@""];
    
    
    doMultitonModule *_multitonModule = [doScriptEngineHelper ParseMultitonModule:_scritEngine :bitmapAddress];
    
    id<doIBitmap> bitmap = (id<doIBitmap>)_multitonModule;

    self.image = [bitmap getData];
    
    _isChangeSource = YES;
    [doUIModuleHelper generateBorder:model :[model GetPropertyValue:@"border"]];
}

#pragma mark -
#pragma mark - private

- (UIImage *)getZoomImage:(UIImage *)originalImage
{
    CGFloat w = originalImage.size.width;
    CGFloat h = originalImage.size.height;
    if (self.contentMode == UIViewContentModeCenter) {
        w = w*model.XZoom;
        h = h*model.YZoom;
    }else
        return originalImage;
    
    CGSize size = CGSizeMake(w, h);
    
    UIImage *image = [doUIModuleHelper imageWithImageSimple:originalImage scaledToSize:size];
    
    return image;
}

- (void)setImage:(UIImage *)image
{
    if (_animationType == AnimationFade) {
        self.alpha = 0;
        [super setImage:image];
        [UIView animateWithDuration:.3 animations:^{
            self.alpha = 1;
        }];
    }else
        [super setImage:image];
}

- (void) clearImage
{
    if(defaultImage!=nil)
        self.image = [self getZoomImage:defaultImage];
    else
        self.image = nil;
}
- (void)getImageFromNetwork :(NSString *)path cache:(BOOL)_cache show:(BOOL)_show
{
    [myqueue addOperationWithBlock:^{
        UIImage *img = [self getImageFromCache:path];
        if(!img){
            NSURL *url = [NSURL URLWithString:path];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
            NSData *dataImg = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
            img = [UIImage imageWithData:dataImg];
            
            if(img&&_cache)
                [self writeDataToCache:path :dataImg: img];
        }
        if (img) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if(_show&&[_imageName isEqualToString:path]){
                    self.image = [self getZoomImage:img];
                }

                //加载网络后，需要处理宽高为-1
                [self autoSize];

                _isChangeSource = YES;
                [doUIModuleHelper generateBorder:model :[model GetPropertyValue:@"border"]];
            }];
            
        }
        
        _imageSource = img;
    }];
}


- (void)writeDataToCache:(NSString *)path :(NSData*) _data :(UIImage*) img
{
    NSString *_dataRoot = [NSString stringWithFormat:@"%@/main/%@/data", [doServiceContainer Instance].Global.DataRootPath, @"app"];
    //不存在缓存文件夹，则创建缓存文件夹
    NSString *cachePath = [NSString stringWithFormat:@"%@/sys/imagecache",_dataRoot];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath ])
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *strName = [[doTextHelper Instance] MD5:path];
    if(![dict objectForKey:strName] )
        [dict setObject:img forKey:strName];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.jpg",cachePath,strName];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:_data attributes:nil];
}

- (UIImage *)getImageFromCache :(NSString *)path
{
    NSString *_dataRoot = [NSString stringWithFormat:@"%@/main/%@/data", [doServiceContainer Instance].Global.DataRootPath ,@"app"];
    NSString *cachePath = [NSString stringWithFormat:@"%@/sys/imagecache",_dataRoot];
    NSString *strName = [[doTextHelper Instance] MD5:path];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.jpg",cachePath,strName];
    return [self getImageFromCacheDict:strName :filePath];
}
-(UIImage*) getImageFromCacheDict:(NSString*) key :(NSString*) filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        UIImage* temp = [UIImage imageWithContentsOfFile:filePath];
        if (temp) {
            [dict setObject:temp forKey:key];
            if (!_isClearBorder) {
                [doUIModuleHelper generateBorder:model :[model GetPropertyValue:@"border"]];
            }
        }
    }
    else
        return nil;
    return [dict objectForKey:key];
}
#pragma mark - override UIView method
- (void)tapClick
{
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"touch":_invokeResult];
}

#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL)InvokeSyncMethod:(NSString *)_methodName :(NSDictionary *)_dicParas :(id<doIScriptEngine>)_scriptEngine :(doInvokeResult *)_invokeResult
{
    return [doScriptEngineHelper InvokeSyncSelector:self :_methodName :_dicParas :_scriptEngine :_invokeResult];
}

- (BOOL)InvokeAsyncMethod:(NSString *)_methodName :(NSDictionary *)_dicParas :(id<doIScriptEngine>)_scriptEngine :(NSString *)_callbackFuncName
{
    return [doScriptEngineHelper InvokeASyncSelector:self :_methodName :_dicParas :_scriptEngine :_callbackFuncName];
}

- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    if([_changedValues.allKeys containsObject:@"source"])
    {
        _isChangeSource = YES;
    }
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :model : _changedValues ];
    if([_changedValues.allKeys containsObject:@"defaultImage"] || [_changedValues.allKeys containsObject:@"source"])
    {
        BOOL isAutoHeight = [[model GetPropertyValue:@"height"] isEqualToString:@"-1"];
        BOOL isAutoWidth = [[model GetPropertyValue:@"width"] isEqualToString:@"-1"];
        if(isAutoHeight||isAutoWidth)
        {
            [self autoSize];
            [doUIModuleHelper generateBorder:model :[model GetPropertyValue:@"border"]];
        }
    }
}
- (doUIModule *) GetModel
{
    //获取model对象
    return model;
}
#pragma mark - 重写该方法，动态选择事件的施行或无效
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    //这里的BOOL值，可以设置为int的标记。从model里获取。
    if([model.EventCenter GetEventCount:@"touch"] <= 0 || isEnabled == NO)
        if(view == self)
            view = nil;
    return view;
}
- (UIImage *)getImageFromImage:(UIImage *)image
{
    if (image == nil) {
        return nil;
    }
    return [self cutImage:image];
}

- (UIImage *)cutImage:(UIImage*)image
{
    //压缩图片
    CGSize newSize;
    CGImageRef imageRef = nil;
    
    if ((image.size.width / image.size.height) < (model.RealWidth / model.RealHeight)) {
        newSize.width = image.size.width;
        newSize.height = image.size.width *model.RealHeight/model.RealWidth;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, fabs(image.size.height - newSize.height) / 2, newSize.width, newSize.height));
        
    } else {
        newSize.height = image.size.height;
        newSize.width = image.size.height * model.RealWidth/model.RealHeight;
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(fabs(image.size.width - newSize.width) / 2, 0, newSize.width, newSize.height));
        
    }
    
    return [UIImage imageWithCGImage:imageRef];
}


#pragma mark - 
- (BOOL)isSupportDiffBorder
{
    return YES;
}
- (void)clearBorder
{
    if (_isChangeSource) {
        return;
    }
    if(CGRectGetHeight(self.frame) == 0 || CGRectGetWidth(self.frame) == 0)
    {
        return;
    }
    self.backgroundColor = [doUIModuleHelper GetColorFromString:[model GetPropertyValue:@"bgColor"] : [UIColor clearColor]];
    if ([model GetPropertyValue:@"defaultImage"].length>0) {
        _isClearBorder = YES;
        if (defaultImage) {
            self.image = defaultImage;
        }
    }
    if ([model GetPropertyValue:@"source"].length>0) {
        _isClearBorder = YES;
        [self change_source:[model GetPropertyValue:@"source"]];
    }
    [self autoSize];
}
- (void)generateBorderWithPath:(UIBezierPath *)path :(CAShapeLayer *)shape;
{
    _isClearBorder = NO;
    if (shape) {
        [shape removeFromSuperlayer];
        shape.fillColor = [UIColor clearColor].CGColor;
    }

    UIColor *bgColor = [doUIModuleHelper GetColorFromString:[model GetPropertyValue:@"bgColor"] : [UIColor clearColor]];
    self.backgroundColor = bgColor;
    CGRect rect = self.bounds;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if(!currentContext){
        UIGraphicsEndImageContext();
        return;
    }
    CGContextAddPath(currentContext,path.CGPath);
    CGContextClip(currentContext);

    [self.layer renderInContext:currentContext];
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    self.backgroundColor = [UIColor clearColor];
    
    [self.layer insertSublayer:shape atIndex:0];

    self.image = output;
}
@end
