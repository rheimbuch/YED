@import <AppKit/CPBox.j>
@import <Foundation/CPCoder.j>

var CPBoxBorderTypeKey      = @"CPBoxBorderTypeKey",
    CPBoxBorderColorKey     = @"CPBoxBorderColorKey",
    CPBoxFillColorKey       = @"CPBoxFillColorKey",
    CPBoxCornerRadiusKey    = @"CPBoxCornerRadiusKey",
    CPBoxBorderWidthKey     = @"CPBoxBorderWidthKey",
    CPBoxContentMarginKey   = @"CPBoxContentMarginKey",
    CPBoxContentViewKey     = @"CPBoxContentViewKey";

@implementation CPBox (CPCoding)

- (id)initWithCoder:(CPCoder)coder
{
    self = [super initWithCoder:coder];
    if(self)
    {
        _borderType = [coder decodeObjectForKey:CPBoxBorderTypeKey];
        
        _borderColor = [coder decodeObjectForKey:CPBoxBorderColorKey];
        _fillColor = [coder decodeObjectForKey:CPBoxFillColorKey];
        
        _cornerRadius = [coder decodeObjectForKey:CPBoxCornerRadiusKey];
        _borderWidth = [coder decodeObjectForKey:CPBoxBorderWidthKey];
        
        _contentMargin = [coder decodeObjectForKey:CPBoxContentMarginKey];
        _contentView = [coder decodeObjectForKey:CPBoxContentViewKey];
    }
    return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeInt:_borderType forKey:CPBoxBorderTypeKey];
    
    [coder encodeObject:_borderColor forKey:CPBoxBorderColorKey];
    [coder encodeObject:_fillColor forKey:CPBoxFillColorKey];
    
    [coder encodeFloat:_cornerRadius forKey:CPBoxCornerRadiusKey];
    [coder encodeFloat:_borderWidth forKey:CPBoxBorderWidthKey];
    
    [coder encodeSize:_contentMargin forKey:CPBoxContentMarginKey];
    [coder encodeObject:_contentView forKey:CPBoxContentViewKey];
}

@end