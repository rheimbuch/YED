@import <AppKit/CPView.j>
@import <Foundation/CPNotificationCenter.j>

@import "YEDEdgeView.j"
@import "YEDNodeView.j"

YEDGraphViewNodeViewAddedNotification       = @"YEDGraphViewNodeViewAddedNotification",
YEDGraphViewNodeViewRemovedNotification     = @"YEDGraphViewNodeViewRemovedNotification",
YEDGraphViewEdgeViewAddedNotification       = @"YEDGraphViewEdgeViewAddedNotification",
YEDGraphViewEdgeViewRemovedNotification     = @"YEDGraphViewEdgeViewRemovedNotification";

@implementation YEDGraphView : CPView
{

}

- (id)init
{
    self = [super init];
    if(self)
    {
        [self registerForDraggedTypes:[YEDNodeViewDragType]];
    }
    return self;
}

- (CPArray)edgeViews
{
    var edgeViews   = [CPArray array],
        viewIter    = [[self subviews] objectEnumerator],
        view        = nil;
    
    while(view = [viewIter nextObject])
    {
        if([view isKindOfClass:YEDEdgeView])
            [edgeViews addObject:view];
    }
    return edgeViews;
}

- (CPArray)nodeViews
{
    var nodeViews   = [CPArray array],
        viewIter    = [[self subviews] objectEnumerator],
        view        = nil;
    
    while(view = [viewIter nextObject])
    {
        if([view isKindOfClass:YEDNodeView])
            [nodeViews addObject:view];
    }
    return nodeViews;
}

- (void)addNodeView:(YEDNodeView)aNodeView
{
    if([[self nodeViews] containsObject:aNodeView])
        return;
    
    [self addSubview:aNodeView];
    
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:YEDGraphViewNodeViewAddedNotification
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            "nodeView": aNodeView,
            "node": [aNodeView representedObject]
        }]];
}

- (void)removeNodeView:(YEDNodeView)aNodeView
{
    if(![[self nodeViews] containsObject:aNodeView])
        return;
    [aNodeView removeFromSuperview];
    
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:YEDGraphViewNodeViewRemovedNotification
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            "nodeView": aNodeView,
            "node": [aNodeView representedObject]
        }]];
}

- (void)addEdgeView:(YEDEdgeView)edgeView
{
    CPLog.trace("YEDGraphView: addEdgeView: starting");
    //console.debug(edgeView);
    if([[self edgeViews] containsObject:edgeView])
    {
        //console.debug("edgeView aready in graphView");
        return;
    }
    
    // var subViews = [self subviews],
    //     viewIter = [subViews objectEnumerator],
    //     subView = nil;
    // while(subView = [viewIter nextObject])
    // {
    //     if([subView isKindOfClass:YEDEdgeView])
    //     {
    //         // If an equivalent edgeview is already in the graphview, bail
    //         if([subView startNodeView] === [edgeView startNodeView] && [subView endNodeView] === [edgeView endNodeView])
    //         {
    //             //console.trace("YEDGraphView: addEdgeView: found an equivalent edgeview in the graphview");
    //             //console.debug(subView);
    //             //console.debug(edgeView);
    //             return;
    //         }
    //     }
    // }
    
    CPLog.trace("YEDGraphView: addEdgeView: adding edge view");
    [[edgeView startNodeView] removeFromSuperview];
    [[edgeView endNodeView] removeFromSuperview];
    [self addSubview:edgeView];
    [self addSubview:[edgeView startNodeView]];
    [self addSubview:[edgeView endNodeView]];
    
    CPLog.trace("YEDGraphView: addEdgeView: sending notification");
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:YEDGraphViewEdgeViewAddedNotification
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            "edgeView": edgeView,
            "startNode": [[edgeView startNodeView] representedObject],
            "endNode": [[edgeView endNodeView] representedObject]
        }]];
}

- (void)removeEdgeView:(YEDEdgeView)edgeView
{
    if(![[self edgeViews] containsObject:edgeView])
        return
        
    [edgeView removeFromSuperview];
    
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:YEDGraphViewEdgeViewRemovedNotification
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            "edgeView": edgeView,
            "startNode": [[edgeView startNodeView] node],
            "endNode": [[edgeView endNodeView] node]
        }]];
}

- (void)removeAllSubviews
{
    var viewIter = [[self subviews] objectEnumerator];
    var view = nil;
    
    while(view = [viewIter nextObject])
    {
        [view removeFromSuperview];
    }
}

- (void)connectNodeView:(YEDNodeView)startView toNodeView:(YEDNodeView)endView
{
    CPLog.trace("YEDGraphView: connectNodeView");
    var edgeView = [YEDEdgeView edgeFromView:startView toView:endView];
    [self addEdgeView:edgeView];
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{
    CPLog.trace("YEDGraphView: performDragOperation:");
    var nodeView = [CPKeyedUnarchiver unarchiveObjectWithData:[[aSender draggingPasteboard] dataForType:YEDNodeViewDragType]],
        location = [self convertPoint:[aSender draggingLocation] fromView:nil];
        
    [nodeView setFrameOrigin:CGPointMake(location.x - CGRectGetWidth([nodeView frame])/2.0, location.y - CGRectGetHeight([nodeView frame])/2.0)];
    CPLog.trace("YEDGraphView: a nodeView was dropped on the view:");
    [self addNodeView:nodeView];
}

- (void)mouseDown:(CPEvent)anEvent
{
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:"YEDSelectedItemNotification"
        object:nil
        userInfo:[CPDictionary dictionaryWithJSObject:{
            "mouseDown":anEvent
        }]];
}

@end