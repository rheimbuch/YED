@import <AppKit/CPView.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPBox.j>

@import "CPBox+CPCoding.j"
@import "KFDNode.j"

@implementation KFDNodeView : CPView
{
    KFDNode     representedObject       @accessors;
    CPView      contentView;
    CPTextField nameField;
    CPBox       decorator;
    
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
        [nameField setAutoresizingMask:(CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin)];
        // console.log("NodeView Center:");
        // console.log([self center]);
        [nameField setCenter:[contentView convertPoint:[contentView center] fromView:nil]];
        [contentView addSubview:nameField];
        
        
        
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
    
    [self setNeedsDisplay:YES];
}

- (void)observeValueForKeyPath:(CPString) path ofObject:(id)object change:(CPDictionary)change context:(id)context
{
    if(object === representedObject)
    {
        [self syncWithRepresentedObject];
    }
}

- (CPColor)borderColor
{
    return [decorator borderColor];
}

- (void)setBorderColor:(CPColor)color
{
    [decorator setBorderColor:color];
}

- (float)borderWidth
{
    return [decorator borderWidth];
}

- (void)setBorderWidth:(float)width
{
    [decorator setBorderWidth:width];
}

- (float)cornerRadius
{
    return [decorator cornerRadius];
}

- (void)setCornerRadius:(float)radius
{
    [decorator setCornerRadius:radius];
}

- (CPColor)fillColor
{
    return [decorator fillColor];
}

- (void)setFillColor:(CPColor)color
{
    [decorator setFillColor:color];
}


- (void)mouseDown:(CPEvent)anEvent
{
    dragLocation = [anEvent locationInWindow];
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