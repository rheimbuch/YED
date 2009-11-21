@import <AppKit/CPView.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPBox.j>
@import <Foundation/CPNotificationCenter.j>

@import "CPBox+CPCoding.j"
@import "CPView+OffsetCorners.j"
@import "YEDEditorView.j"
@import "YEDNode.j"
@import "YEDNodeViewConnector.j"

YEDNodeViewDragType = "YEDNodeViewDragType";

@implementation YEDNodeView : CPView
{
    YEDNode         representedObject       @accessors;
    CPView          contentView;
    CPTextField     nameField;
    CPView          decorator;
                    
    CGPoint         dragLocation;
                    
    BOOL            isSelected              @accessors;
    YEDEditorView   editorView;
    YEDNodeViewConnector connector;
}

- (id)initWithFrame:aFrame
{
    self = [super initWithFrame:aFrame];
    if(self)
    {
        editorView = [[YEDEditorView alloc] initWithFrame:CPRectMakeZero()];
        
        var bounds = [self bounds],
            connectorSize = 9;

        
        decorator = [[CPBox alloc] initWithFrame:CPRectMake(0,0,
                                                        CPRectGetWidth(aFrame),
                                                        CPRectGetHeight(aFrame))];
        [decorator setAutoresizingMask:(CPViewWidthSizable | CPViewHeightSizable)];
        [decorator setBorderType:CPLineBorder];
        [self addSubview:decorator];
        
        contentView = [[CPView alloc] initWithFrame:(CPRectMake(0,0,
                                                        CPRectGetWidth(aFrame),
                                                        CPRectGetHeight(aFrame)))];
        [contentView setAutoresizingMask:(CPViewWidthSizable | CPViewHeightSizable)];
        [decorator setContentView:contentView];
        
        connector = [[YEDNodeViewConnector alloc] initWithFrame:CPRectMake(CGRectGetMaxX(bounds)-connectorSize,
                                                                            CGRectGetMaxY(bounds)-connectorSize,
                                                                            connectorSize,
                                                                            connectorSize)];
        [connector setAutoresizingMask:(CPViewMinXMargin | CPViewMinYMargin)];
        [connector setNodeView:self];
        [self addSubview:connector]
        
        nameField = [CPTextField labelWithTitle:[self hash]];
        [nameField setValue:CPCenterTextAlignment forThemeAttribute:@"alignment"];
        [nameField setCenter:[self convertPoint:[self center] fromView:nil]];
        [nameField setAutoresizingMask:(CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin)];
        // //console.log("NodeView Center:");
        // //console.log([self center]);
        [nameField setCenter:[contentView convertPoint:[contentView center] fromView:nil]];
        [contentView addSubview:nameField];
        
        [self setPostsFrameChangedNotifications:YES];
        
        [self registerForDraggedTypes:[YEDNodeViewConnectorDragType]];
    }
    return self;
}

- (id)initWithNode:(YEDNode)aNode
{
    self = [self initWithFrame:CPRectMakeZero()];
    if(self)
    {
        [self setRepresentedObject:aNode];
    }
    return self;
}

- (BOOL)isEqual:(id)other
{
    if(other === self)
        return YES;
    if(!other || ![other isKindOfClass:[self class]])
        return NO
    return [self isEqualToNodeView:other];
}

- (BOOL)isEqualToNodeView:(YEDNodeView)otherView
{
    if(otherView === self)
        return YES;
    if(![[self representedObject] isEqual:[otherView representedObject]])
        return NO;
    return YES;
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
    //console.debug(self);
    [nameField setStringValue:[representedObject name]];
    [nameField sizeToFit];
    [nameField setCenter:[contentView convertPoint:[contentView center] fromView:decorator]];
    
    [self setNeedsDisplay:YES];
}

- (void)observeValueForKeyPath:(CPString) path ofObject:(id)object change:(CPDictionary)change context:(id)context
{
    if(object === representedObject)
    {
        [self syncWithRepresentedObject];
    }
}

- (void)setIsSelected:(BOOL)selected
{
    if(isSelected === selected)
        return;
    
    [self willChangeValueForKey:@"isSelected"];
    isSelected = selected;
    [self didChangeValueForKey:@"isSelected"];
    
    if(isSelected)
    {
        CPLog.trace("Activating Editor View");
        [editorView setNodeView:self];
        [connector setHidden:NO];
    }
    else
    {
        [editorView setNodeView:nil];
        [connector setHidden:YES];
    }
}

- (void)removeFromSuperview
{
    [self setIsSelected:NO];
    [super removeFromSuperview];
}

- (void)mouseDown:(CPEvent)anEvent
{
    dragLocation = [anEvent locationInWindow];
    
    CPLog.trace("Selecting Node");
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:"YEDSelectedItemNotification"
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            "mouseDown":anEvent
        }]];
}

- (void)mouseDragged:(CPEvent)anEvent
{    
    var location = [anEvent locationInWindow],
        origin = [self frame].origin;
    
    [self setFrameOrigin:CGPointMake(origin.x + location.x - dragLocation.x,
                                     origin.y + location.y - dragLocation.y)];
    dragLocation = location;
}

- (void)mouseUp:(CPEvent)anEvent
{
    // Handle double-click
    if([anEvent clickCount] == 2)
    {
        var newName = prompt("Node Name: ", [[self representedObject] name]);
        if(newName && newName !== [[self representedObject] name])
        {
            [[self representedObject] setName:newName];
            [self syncWithRepresentedObject];
        }
    }
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{
    CPLog.trace("YEDNodeView: performDragOperation:");
    //console.debug([aSender draggingSource]);
    var source = [aSender draggingSource];
    // var nodeView = [CPKeyedUnarchiver unarchiveObjectWithData:[[aSender draggingPasteboard] dataForType:YEDNodeViewConnectorDragType]];
    var nodeView = [[aSender draggingSource] nodeView];
    [[self superview] connectNodeView:nodeView toNodeView:self];
}

@end

var YEDNodeViewContentViewKey   = @"YEDNodeViewContentViewKey",
    YEDNodeViewNameFieldKey     = @"YEDNodeViewNameFieldKey",
    YEDNodeViewDecoratorKey     = @"YEDNodeViewDecoratorKey",
    YEDNodeViewEditorViewKey    = @"YEDNodeViewEditorViewKey",
    YEDNodeViewConnectorKey     = @"YEDNodeViewConnectorKey",
    YEDNodeViewRepresentedObject = @"YEDNodeViewRepresentedObject";

@implementation YEDNodeView (CPCoding)

- (id)initWithCoder:(CPCoder)coder
{
    self = [super initWithCoder:coder];
    if(self)
    {
        contentView = [coder decodeObjectForKey:YEDNodeViewContentViewKey];
        nameField   = [coder decodeObjectForKey:YEDNodeViewNameFieldKey];
        decorator   = [coder decodeObjectForKey:YEDNodeViewDecoratorKey];
        editorView  = [coder decodeObjectForKey:YEDNodeViewEditorViewKey];
        connector   = [coder decodeObjectForKey:YEDNodeViewConnectorKey];
        [connector setNodeView:self];
        representedObject = [coder decodeObjectForKey:YEDNodeViewRepresentedObject];
        
        [self setPostsFrameChangedNotifications:YES];
        [self registerForDraggedTypes:[YEDNodeViewConnectorDragType]];
    }
    return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:contentView forKey:YEDNodeViewContentViewKey];
    [coder encodeObject:nameField forKey:YEDNodeViewNameFieldKey];
    [coder encodeObject:decorator forKey:YEDNodeViewDecoratorKey];
    [coder encodeObject:editorView forKey:YEDNodeViewEditorViewKey];
    [coder encodeObject:connector forKey:YEDNodeViewConnectorKey];
    [coder encodeObject:representedObject forKey:YEDNodeViewRepresentedObject];
}
    
@end

@implementation YEDNodeView (DecoratorProtocol)
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

