@import <AppKit/CPView.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPBox.j>

@import "CPBox+CPCoding.j"
@import "CPView+OffsetCorners.j"
@import "KFDEditorView.j"
@import "KFDNode.j"

@implementation KFDNodeView : CPView
{
    KFDNode     representedObject       @accessors;
    CPView      contentView;
    CPTextField nameField;
    CPView      decorator;
    
    CGPoint     dragLocation;
}

- (id)initWithFrame:aFrame
{
    self = [super initWithFrame:aFrame];
    if(self)
    {
        decorator = [[CPBox alloc] initWithFrame:(CPRectMake(0,0,
                                                        CPRectGetWidth(aFrame),
                                                        CPRectGetHeight(aFrame)))];
        [decorator setAutoresizingMask:(CPViewWidthSizable | CPViewHeightSizable)];
        [decorator setBorderType:CPLineBorder];
        console.debug("KFDNodeView decorator box");
        console.debug(decorator);
        [self addSubview:decorator];
        
        contentView = [[CPView alloc] initWithFrame:(CPRectMake(0,0,
                                                        CPRectGetWidth(aFrame),
                                                        CPRectGetHeight(aFrame)))];
        [contentView setAutoresizingMask:(CPViewWidthSizable | CPViewHeightSizable)];
        [decorator setContentView:contentView];
        
        
        
        nameField = [CPTextField labelWithTitle:[self hash]];
        [nameField setValue:CPCenterTextAlignment forThemeAttribute:@"alignment"];
        [nameField setCenter:[self convertPoint:[self center] fromView:nil]];
        [nameField setAutoresizingMask:(CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin)];
        // console.log("NodeView Center:");
        // console.log([self center]);
        [nameField setCenter:[contentView convertPoint:[contentView center] fromView:nil]];
        [contentView addSubview:nameField];
        
        
        [self setPostsFrameChangedNotifications:YES];
        // representedObject = [KFDNode node];
    }
    return self;
}

- (id)initWithNode:(KFDNode)aNode
{
    self = [self initWithFrame:CPRectMakeZero()];
    if(self)
    {
        [self setRepresentedObject:aNode];
    }
    return self;
}

- (CPString)name
{
    return [representedObject name];
}

- (void)setRepresentedObject:(id)object
{
    if(representedObject === object)
        return;
    
    [self willChangeValueForKey:@"representedObject"];
    [representedObject removeObserver:self forKeyPath:@"name"];
    representedObject = object;
    [self syncWithRepresentedObject];
    [representedObject addObserver:self forKeyPath:@"name" options:CPKeyValueObservingOptionNew context:nil];
    [self didChangeValueForKey:@"representedObject"];
}

- (void)syncWithRepresentedObject
{
    CPLog.trace("NodeView is updating from representedObject");
    CPLog.trace("NodeView nameField was: " + [nameField stringValue]);
    CPLog.trace("Node name is: " + [representedObject name]);
    console.debug(self);
    [nameField setStringValue:[representedObject name]];
    [nameField sizeToFit];
    
    [self setNeedsDisplay:YES];
}

- (void)observeValueForKeyPath:(CPString) path ofObject:(id)object change:(CPDictionary)change context:(id)context
{
    if(object === representedObject)
    {
        [self syncWithRepresentedObject];
    }
}

- (void)mouseDown:(CPEvent)anEvent
{
    dragLocation = [anEvent locationInWindow];
    [[KFDEditorView sharedEditor] setNodeView:self];
}

- (void)mouseDragged:(CPEvent)anEvent
{    
    var location = [anEvent locationInWindow],
        origin = [self frame].origin;
    
    [self setFrameOrigin:CGPointMake(origin.x + location.x - dragLocation.x,
                                     origin.y + location.y - dragLocation.y)];
    dragLocation = location;
}



@end

var KFDNodeViewContentViewKey   = @"KFDNodeViewContentViewKey",
    KFDNodeViewNameFieldKey     = @"KFDNodeViewNameFieldKey",
    KFDNodeViewDecoratorKey     = @"KFDNodeViewDecoratorKey";

@implementation KFDNodeView (CPCoding)

- (id)initWithCoder:(CPCoder)coder
{
    self = [super initWithCoder:coder];
    if(self)
    {
        contentView = [coder decodeObjectForKey:KFDNodeViewContentViewKey];
        nameField   = [coder decodeObjectForKey:KFDNodeViewNameFieldKey];
        decorator   = [coder decodeObjectForKey:KFDNodeViewDecoratorKey];
        
        [self setPostsFrameChangedNotifications:YES];
    }
    return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:contentView forKey:KFDNodeViewContentViewKey];
    [coder encodeObject:nameField forKey:KFDNodeViewNameFieldKey];
    [coder encodeObject:decorator forKey:KFDNodeViewDecoratorKey];
}
    
@end

@implementation KFDNodeView (DecoratorProtocol)
    - (CPColor)borderColor
    {
        if([decorator respondsToSelector:@selector(borderColor)])
            return [decorator borderColor];

    }

    - (void)setBorderColor:(CPColor)color
    {
        if([decorator respondsToSelector:@selector(setBorderColor:)])
            [decorator setBorderColor:color];
    }

    - (float)borderWidth
    {
        if([decorator respondsToSelector:@selector(borderWidth)])
            return [decorator borderWidth];
    }

    - (void)setBorderWidth:(float)width
    {
        if([decorator respondsToSelector:@selector(setBorderWidth:)])
            [decorator setBorderWidth:width];
    }

    - (float)cornerRadius
    {
        if([decorator respondsToSelector:@selector(cornerRadius)])
            return [decorator cornerRadius];
    }

    - (void)setCornerRadius:(float)radius
    {
        if([decorator respondsToSelector:@selector(setCornerRadius:)])
            [decorator setCornerRadius:radius];
    }

    - (CPColor)fillColor
    {
        if([decorator respondsToSelector:@selector(fillColor)])
            return [decorator fillColor];
    }

    - (void)setFillColor:(CPColor)color
    {
        if([decorator respondsToSelector:@selector(setFillColor:)])
            [decorator setFillColor:color];
    }
@end