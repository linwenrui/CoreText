//
//  PicView.m
//  CoreText图文混排
//
//  Created by XH-LWR on 2018/2/27.
//  Copyright © 2018年 XH-LWR. All rights reserved.
//

#import "PicView.h"
#import <CoreText/CoreText.h>

@implementation PicView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // 获取当前绘制上下文, 所有操作都是在上下文中进行绘制的
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 设置字形的变换矩阵为不做图像变换
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    // 平移方法, 将画布向上平移一个屏幕高
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    // 缩放方法, x轴缩放系数为1, 则不变, y轴缩放系数为-1, 则相当一以x轴为轴旋转180度.
    CGContextScaleCTM(context, 1.0, -1.0);
    // 以上三句就是将系统坐标转换为ios的屏幕坐标, 固定写法
    
#pragma mark - 图片代理的设置
    // 事实上, 图文混排就是在要插入的位置插入一个富文本类型的占位符, 通过CTRUNDelegate设置图片
    
    // 创建可变富文本
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"\n这里在测试图文混排，\n我是一个富文本"];
    
    // 设置一个回调结构体, 告诉代理该回调哪些方法
    CTRunDelegateCallbacks callBacks; // 创建一个回调结构体, 设置相关参数
    memset(&callBacks, 0, sizeof(CTRunDelegateCallbacks)); // memset将已开辟的内存空间, callbacks的首 n 个字节的值设为0, 相当于对CTRunDelegateCallbacks内存空间初始化
    callBacks.version = kCTRunDelegateVersion1; // 设置回到版本, 默认这个
    callBacks.getAscent = ascentCallBacks; // 设置图片顶部距离基线的距离
    callBacks.getDescent = descentCallBacks; // 设置图片底距距离基线的距离
    callBacks.getWidth = widthCallBacks; // 设置图片的宽度
    
#pragma mark - 创建一个代理
    
    // 创建一个图片尺寸的字典, 初始化代理对象需要
    NSDictionary *dicPic = @{@"height" : @129, @"width" : @400};
    // 创建代理
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callBacks, (__bridge void*)dicPic);
    
#pragma mark - 图片的插入
    // 创建UI个富文本类型的图片占位符, 绑定我们的代理
    unichar placeHolder = 0xFFFC; // 创建空白字符串
    NSString *placeHolderStr = [NSString stringWithCharacters:&placeHolder length:1]; // 空白字符生成字符串
    NSMutableAttributedString *placeHolderAttrStr = [[NSMutableAttributedString alloc] initWithString:placeHolderStr]; // 用字符串初始化占位符的富文本
    // 给字符串中的范围中字符串设置代理
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)placeHolderAttrStr, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate); // 释放(__bridge继续c与oc数据类型的转换, c为非arc, 需要手动管理)
    // 将占位符插入到我们的富文本中
    [attributeStr insertAttributedString:placeHolderAttrStr atIndex:12];
    
#pragma mark - 绘制
    
#pragma Mark - 绘制文本
    // 一个frame的工厂, 负责生成frame
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeStr);
    CGMutablePathRef path = CGPathCreateMutable(); // 创建绘制区域
    CGPathAddRect(path, NULL, self.bounds); // 添加绘制尺寸
    NSInteger length = attributeStr.length;
    // 工程根据绘制区域及富文本(可选范围, 多次设置) 设置frame
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, length), path, NULL);
    CTFrameDraw(frame, context); // 根据frame绘制文字
    
#pragma mark - 绘制图片
    // 绘制图片
    UIImage *image = [UIImage imageNamed:@"oldDriver"];
    // 获取frame
    CGRect imgFrm = [self calculateImageRectWithFrame:frame];
    
    CGContextDrawImage(context, imgFrm, image.CGImage);
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
}

// ref即是创建代理也是绑定的对象, 所以在这里, 我们从字典中分别取出图片的宽和高
// ref是一个指针类型的数据, 不过oc的对象其实也就是c的结构体, 我们可以通过类型转换获得oc中的字典
// __bridge即是c的结构体转换成OC对象时需要的一个修饰词
static CGFloat ascentCallBacks(void *ref) {
    
    return [(NSNumber *)[(__bridge NSDictionary*)ref valueForKey:@"height"] floatValue];
}

static CGFloat descentCallBacks(void *ref) {
    
    return 0;
}

static CGFloat widthCallBacks(void *ref) {
    
    return [(NSNumber *)[(__bridge NSDictionary*)ref valueForKey:@"width"] floatValue];
}

#pragma mark - 获取图片frame
- (CGRect)calculateImageRectWithFrame:(CTFrameRef)frame {
    
    // 根据frame获取需要绘制的线的数组
    NSArray *arrLines = (NSArray *)CTFrameGetLines(frame);
    NSInteger count = [arrLines count]; // 获取线的数量
    CGPoint points[count]; // 建立起点的数组,(cgpoint类型为结构体, 故用c语言的数组)
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points); // 获取起点
    
#pragma mark - 计算frame
    
    for (int i = 0; i < count; i++) { // 遍历线的数组
        CTLineRef line = (__bridge CTLineRef)arrLines[i];
        NSArray *arrGlyphRun = (NSArray *)CTLineGetGlyphRuns(line); // 获取GlyphRun数组(GlyphRun: 高效的字符绘制方案)
        for (int j = 0; j < arrGlyphRun.count; j ++) { // 遍历CTRun数组
            CTRunRef run = (__bridge CTRunRef)arrGlyphRun[j]; // 获取CTRun
            NSDictionary * attributes = (NSDictionary *)CTRunGetAttributes(run); // 获取CTRun的属性
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName]; // 获取代理
            if (delegate == nil) { // 非空
                continue;
            }
            NSDictionary * dic = CTRunDelegateGetRefCon(delegate); // 判断代理字典
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            CGPoint point = points[i]; // 获取一个起点
            CGFloat ascent; // 获取上距
            CGFloat descent; // 获取下距
            CGRect boundsRun; // 创建一个frame
            boundsRun.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            boundsRun.size.height = ascent + descent; // 取得高
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL); // 获取x的偏移量
            boundsRun.origin.x = point.x + xOffset; // point是行起点位置, 加上每个字的偏移量得到每个字的x
            boundsRun.origin.y = point.y - descent; // 计算原点
            CGPathRef path = CTFrameGetPath(frame); // 获取绘制区域
            CGRect colRect = CGPathGetBoundingBox(path); // 获取剪裁区域边框
            CGRect imageBounds = CGRectOffset(boundsRun, colRect.origin.x, colRect.origin.y);
            return imageBounds;
            /**
             外层for循环呢，是为了取到所有的CTLine。
             类型转换什么的我就不多说了，然后通过CTLineGetGlyphRuns获取一个CTLine中的所有CTRun。
             里层for循环是检查每个CTRun。
             通过CTRunGetAttributes拿到该CTRun的所有属性。
             通过kvc取得属性中的代理属性。
             接下来判断代理属性是否为空。因为图片的占位符我们是绑定了代理的，而文字没有。以此区分文字和图片。
             如果代理不为空，通过CTRunDelegateGetRefCon取得生成代理时绑定的对象。判断类型是否是我们绑定的类型，防止取得我们之前为其他的富文本绑定过代理。
             如果两条都符合，ok，这就是我们要的那个CTRun。
             开始计算该CTRun的frame吧。
             获取原点和获取宽高被。
             通过CTRunGetTypographicBounds取得宽，ascent和descent。有了上面的介绍我们应该知道图片的高度就是ascent+descent了吧。
             接下来获取原点。
             CTLineGetOffsetForStringIndex获取对应CTRun的X偏移量。
             取得对应CTLine的原点的Y，减去图片的下边距才是图片的原点，这点应该很好理解。
             至此，我们已经获得了图片的frame了。因为只绑定了一个图片，所以直接return就好了，如果多张图片可以继续遍历返回数组。
             获取到图片的frame，我们就可以绘制图片了，用上面介绍的方法
             */
        }
    }
    return CGRectZero;
}

@end
