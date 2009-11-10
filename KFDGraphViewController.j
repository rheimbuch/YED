@import <AppKit/CPViewController.j>
@import "YEDGraph.j"
@import "YEDGraphView.j"
@import "YEDNodeViewRegistry.j"

@implementation YEDGraphViewController : CPViewController 
{
    CPArray                 nodeViews;
    YEDNodeViewRegistry     nodeViewRegistry    @accessors;
    CPArray                 edgeViews;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        nodeViews = [];
        nodeViewRegistry = [YEDNodeViewRegistry registry];
        edgeViews = [];
    }
    return self;
}

// - (void)loadRepresentedObject
// {
//     [self setRepresentedObject: [YEDGraph graph]];
// }

- (void)loadView
{
    if(_view)
        return;
    
    _view = [[YEDGraphView alloc] init];
}

- (void)_loadNodeViewsFromGraph
{
    if(!_representedObject)
        return;
    
    
    [nodeViews removeAllObjects];
    [[self view] removeAllNodeViews];
    
    var nodeIter = [[[self representedObject] nodes] objectEnumerator];
    var node = nil;
    while(node = [nodeIter nextObject])
    {
        if(![self viewForNode:node])
            [self addNodeToView:node];
        
        var edgeIter = [[node outEdges] objectEnumerator],
            endNode = nil;
        
        while(endNode = [edgeIter nextObject])
        {
            if(![self viewForNode:endNode])
                [self addNodeToView:endNode];
            [self addEdgeToViewFrom:node to:endNode];
        }
    }
}

- (void)_setupObservers
{
    var center = [CPNotificationCenter defaultCenter];
    var graph = [self representedObject];
    
    [center addObserver:self 
            selector:@selector(graphNodeAdded:) 
            name:YEDGraphNodeAddedNotification
            object:graph];
    [center addObserver:self
            selector:@selector(graphNodeRemoved:)
            name:YEDGraphNodeRemovedNotification
            object:graph];
    [center addObserver:self
            selector:@selector(graphEdgeAdded:)
            name:YEDGraphEdgeAddedNotification
            object:graph];
    [center addObserver:self
            selector:@selector(graphEdgeRemoved:)
            name:YEDGraphEdgeRemovedNotification
            object:graph];
}

- (void)_removeObservers
{
    var center = [CPNotificationCenter defaultCenter];
    var graph = [self representedObject];
    
    [center removeObserver:self
            name:YEDGraphNodeAddedNotification
            object:graph];
    [center removeObserver:self
            name:YEDGraphNodeRemovedNotification
            object:graph];
    [center removeObserver:self
            name:YEDGraphEdgeAddedNotification
            object:graph];
    [center removeObserver:self
            name:YEDGraphEdgeRemovedNotification
            object:graph];
}

- (void)graphNodeAdded:(CPNotification)notification
{
    var node = [[notification userInfo] objectForKey:"node"];
    [self addNodeToView:node];
}

- (void)graphNodeRemoved:(CPNotification)notification
{
    var node = [[notification userInfo] objectForKey:"node"];
    [self removeNodeFromView:node];
}

- (void)graphEdgeAdded:(CPNotification)notification
{
    CPLog.trace("YEDGraphViewController: graphEdgeAdded");
    var startNode = [[notification userInfo] objectForKey:"fromNode"],
        endNode = [[notification userInfo] objectForKey:"toNode"];
    [self addEdgeToViewFrom:startNode to:endNode];
}

- (void)graphEdgeRemoved:(CPNotification)notification
{
    CPLog.trace("YEDGraphViewController: graphEdgeRemoved");
    var startNode = [[notification userInfo] objectForKey:"fromNode"],
        endNode = [[notification userInfo] objectForKey:"toNode"];
    [self removeEdgeFromViewFrom:startNode to:endNode];
}

- (void)addNodeToView:(YEDNode)node
{
    // If the node isn't already in the graph, we don't want to add it to the view
    if(![[self graph] containsNode:node])
        return;
    
    var view = [nodeViewRegistry viewFor:node];
    var graphCenter = [[self view] center];
    [view setCenter: [[self view] convertPoint:graphCenter fromView:nil]];
    
    var randPointShift = function(point, scale)
    {
        scale = scale || 100;
        var randX = (Math.random() - 0.5) * scale,
            randY = (Math.random() - 0.5) * scale;
        return CGPointMake(point.x + randX, point.y + randY);
    };
    
    var origin = [view frameOrigin];
    [view setFrameOrigin:randPointShift(origin, 200)];
    [nodeViews addObject:view];
    [[self view] addNodeView:view];
}

- (void)removeNodeFromView:(YEDNode)node
{
    // If the node is still in the graph, we don't want to remove it from the view
    if([[self graph] containsNode:node])
        return;
    // Find the nodeview associated with this node and remove it
    var viewIter = [nodeViews objectEnumerator];
    var view = nil
    while(view = [viewIter nextObject])
    {
        if([view representedObject] === node)
        {
            [view removeFromSuperview];
            [nodeViews removeObject:view];
            [view setRepresentedObject:nil];
            
            return;
        }
    }
}

- (YEDNodeView)viewForNode:(YEDNode)node
{
    if(![[self graph] containsNode:node])
        return;
    
    var viewIter = [nodeViews objectEnumerator];
    var view = nil
    while(view = [viewIter nextObject])
    {
        if([view representedObject] === node)
        {
            return view;
        }
    }
}

- (void)addEdgeToViewFrom:(YEDNode)start to:(YEDNode)end
{
    CPLog.trace("YEDGraphViewController: addEdgeToViewFrom:to:");
    console.debug(start, end);
    CPLog.trace([[self graph] containsEdgeFromNode:start toNode:end]);
    if(![[self graph] containsEdgeFromNode:start toNode:end])
        return;
    
    CPLog.trace("YEDGraphViewController: addEdgeToViewFrom:to: retrieving views");
    var startView = [self viewForNode:start],
        endView = [self viewForNode:end];
    
    if(!startView || !endView)
        return;
    
    CPLog.trace("YEDGraphViewController: addEdgeToViewFrom:to: creating Edge View");
    var edgeView = [YEDEdgeView edgeFromView:startView toView:endView];
    [edgeViews addObject:edgeView];
    [[self view] addEdgeView:edgeView];
}

- (void)removeEdgeFromViewFrom:(YEDNode)start to:(YEDNode)end
{
    if([[self graph] containsEdgeFromNode:start toNode:end])
        return;
    
    var startView = [self viewForNode:start],
        endView = [self viewForNode:end];
    
    if(!startView || !endView)
        return;
    
    var viewIter = [edgeViews objectEnumerator],
        view = nil;
        
    while(view = [viewIter nextObject])
    {
        if([view startNodeView] === startView && [view endNodeView] === endView)
        {
            [edgeViews removeObject:view];
            [view setStartNodeView:nil];
            [view setEndNodeView:nil];
            [view removeFromSuperview];
        }
    }
}

- (void)setRepresentedObject:(id)object
{
    if([self representedObject])
    {
        [self _removeObservers];
    }
    [super setRepresentedObject:object];
    
    [self _loadNodeViewsFromGraph];
    [self _setupObservers];
}

- (void)graph
{
    return [self representedObject];
}

- (void)setGraph:(YEDGraph)aGraph
{
    [self willChangeValueForKey:@"graph"];
    [self setRepresentedObject:aGraph];
    [self didChangeValueForKey:@"graph"];
}



@end