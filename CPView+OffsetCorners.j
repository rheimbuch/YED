@import <AppKit/CPView.j>

@implementation CPView (OffsetCorners)

- (void)offsetFrameTopLeft:(CGPoint)delta
{    
    var currentFrame = [self frame],
        currentLocation = currentFrame.origin;
            
    var newFrame = CGRectMake(currentLocation.x+delta.x , currentLocation.y+delta.y, CGRectGetWidth(currentFrame) - delta.x, CGRectGetHeight(currentFrame) - delta.y);
    [self setFrame:newFrame];
    
    [self setNeedsDisplay:YES];
}

- (void)offsetFrameTopRight:(CGPoint)delta
{
    var currentFrame = [self frame],
        currentLocation = currentFrame.origin;
        
            
    var newFrame = CGRectMake(currentLocation.x , currentLocation.y+delta.y, CGRectGetWidth(currentFrame) + delta.x, CGRectGetHeight(currentFrame) - delta.y);
    [self setFrame:newFrame];
    
    [self setNeedsDisplay:YES];

}

- (void)offsetFrameBottomRight:(CGPoint)delta
{
    var currentFrame = [self frame],
        currentLocation = currentFrame.origin;
        
            
    var newFrame = CGRectMake(currentLocation.x , currentLocation.y, CGRectGetWidth(currentFrame) + delta.x, CGRectGetHeight(currentFrame) + delta.y);
    [self setFrame:newFrame];
    
    [self setNeedsDisplay:YES];
}

- (void)offsetFrameBottomLeft:(CGPoint)delta
{
    var currentFrame = [self frame],
        currentLocation = currentFrame.origin;
        
            
    var newFrame = CGRectMake(currentLocation.x + delta.x , currentLocation.y, CGRectGetWidth(currentFrame) - delta.x, CGRectGetHeight(currentFrame) + delta.y);
    [self setFrame:newFrame];
    
    [self setNeedsDisplay:YES];
}
@end