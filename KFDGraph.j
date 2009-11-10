@import <Foundation/CPObject.j>
@import <Foundation/CPSet.j>
@import <Foundation/CPException.j>
@import <Foundation/CPNotificationCenter.j>
@import "YEDNode.j"

// Exceptions
YEDGraphCannotCreateDirectedEdgeException = @"YEDGraphCannotCreateDirectedEdgeException";
YEDGraphNodeTypeNotAllowedException = @"YEDGraphNodeTypeNotAllowedException";

// Notifications
YEDGraphNodeAddedNotification = @"YEDGraphNodeAddedNotification";
YEDGraphNodeRemovedNotification = @"YEDGraphNodeRemovedNotification";
YEDGraphEdgeNotAllowedNotification = @"YEDGraphEdgeNotAllowedNotification";
YEDGraphEdgeWouldCauseCycleNotification = @"YEDGraphEdgeWouldCauseCycleNotification";
YEDGraphEdgeAddedNotification = @"YEDGraphEdgeAddedNotification";
YEDGraphEdgeRemovedNotification = @"YEDGraphEdgeRemovedNotification"

/*! @class YEDGraph
    ** Delegate Protocol **
    - (void)willAddNode:(YEDNode)aNode toGraph:(YEDGraph)aGraph
    - (void)didAddNode(YEDNode)aNode toGraph:(YEDGraph)aGraph
    - (void)willRemoveNode:(YEDNode)aNode fromGraph:(YEDGraph)aGraph
    - (void)didRemoveNode:(YEDNode)aNode fromGraph:(YEDGraph)aGraph
    - (void)willAddEdgeFromNode:(YEDNode)startNode toNode:(YEDNode)endNode inGraph:(YEDGraph)aGraph
    - (void)didAddEdge:(BOOL)edgeAdded fromNode:(YEDNode)startNode toNode:(YEDNode)endNode inGraph:(YEDGraph)aGraph
    - (void)willRemoveEdgeFromNode:(YEDNode)startNode toNode:(YEDNode)endNode inGraph:(YEDGraph)aGraph
    - (void)didRemoveEdge:(BOOL)edgeRemoved fromNode:(YEDNode)startNode toNode:(YEDNode)endNode inGraph:(YEDGraph)aGraph

*/

@implementation YEDGraph : CPObject
{
    CPSet   nodes       @accessors;
    CPSet   allowedNodeTypes;
    id      delegate    @accessors;
}


- (id)init
{
    self = [super init];
    if(self)
    {
        nodes = [CPSet set];
        allowedNodeTypes = [CPSet setWithObject:YEDNode];
    }
    return self;
}

- (id)initWithNodes:(CPArray)otherNodes
{
    var self = [self init];
    if(self)
    {
        var nodeIter = [otherNodes objectEnumerator];
        var otherNode = nil;
    
        while(otherNode = [nodeIter nextObject])
        {
            [self addNode:otherNode];
        }
    }
    return self;
}

+ (id)graph
{
    return [[self alloc] init];
}

+ (id)graphWithNodes:(CPArray)nodes
{
    return [[self alloc] initWithNodes:nodes];
}

- (void)addNode:(YEDNode)aNode
{
    if([self allowsNode:aNode]) 
    {
        if([delegate respondsToSelector:@selector(willAddNode:toGraph:)])
            [delegate willAddNode:aNode toGraph:self];
            
        [nodes addObject:aNode];
        
        [[CPNotificationCenter defaultCenter] 
            postNotificationName:YEDGraphNodeAddedNotification
            object:self
            userInfo:[CPDictionary dictionaryWithJSObject:{
                node:aNode
            }]];
        
        if([delegate respondsToSelector:@selector(didAddNode:toGraph:)])
            [delegate didAddNode:aNode toGraph:self];
    }
    else 
    {
        [CPException raise:YEDGraphNodeTypeNotAllowedException message:"The type of the added node is not allowed in this graph."];
    }
}

- (void)removeNode:(YEDNode)aNode
{
    if([nodes containsObject:aNode])
    {
        if([delegate respondsToSelector:@selector(willRemoveNode:fromGraph:)])
            [delegate willRemoveNode:aNode fromGraph:self];
        
        var outEdges = [aNode outEdges];
        var inEdges = [aNode inEdges];
        
        var edgeIter = [outEdges objectEnumerator];
        var edgeNode = nil;
        while(edgeNode = [edgeIter nextObject])
        {
            [self removeDirectedEdgeFrom:aNode to:edgeNode];
        }
        edgeIter = [inEdges objectEnumerator];
        while(edgeNode = [edgeIter nextObject])
        {
            [self removeDirectedEdgeFrom:edgeNode to:aNode];
        }
            
        [aNode disconnectFromAllNodes];
        [nodes removeObject:aNode];
        
        [[CPNotificationCenter defaultCenter] 
            postNotificationName:YEDGraphNodeRemovedNotification
            object:self
            userInfo:[CPDictionary dictionaryWithJSObject:{
                node:aNode
            }]];
        
        if([delegate respondsToSelector:@selector(didRemoveNode:fromGraph:)])
            [delegate didRemoveNode:aNode fromGraph:self];
    }
}

- (void)createDirectedEdgeFrom:(YEDNode)fromNode to:(YEDNode)toNode
{ 
    // if(![nodes containsObject:fromNode])
    //     [self addNode:fromNode];
    // 
    // if(![nodes containsObject:toNode])
    //     [self addNode:toNode];
    
    // If the nodes aren't in the nodes set, then they aren't allowed
    if(![nodes containsObject:fromNode] || ![nodes containsObject:toNode])
    {
        [CPException raise:YEDGraphCannotCreateDirectedEdgeException reason:"One of the nodes is not in the graph."];
        return;
    }
        
    if([delegate respondsToSelector:@selector(willAddEdgeFromNode:toNode:inGraph:)])
        [delegate willAddEdgeFromNode:fromNode toNode:toNode inGraph:self];
    
    try
    {    
        [fromNode directedEdgeTo:toNode];
    }
    catch(err)
    {
        if([err name] === YEDNodeNotAllowedException)
        {
            if([delegate respondsToSelector:@selector(directedEdgeFromNode:toNode:isNotAllowedInGraph:)])
                [delegate directedEdgeFromNode:fromNode toNode:toNode isNotAllowedInGraph:self];
            
            [[CPNotificationCenter defaultCenter] 
                postNotificationName:YEDGraphEdgeNotAllowedNotification
                object:self
                userInfo:[CPDictionary dictionaryWithJSObject:{
                    fromNode:fromNode,
                    toNode:toNode
                }]];
                
            if([delegate respondsToSelector:@selector(didAddEdge:fromNode:toNode:inGraph:)])
                [delegate didAddEdge:NO fromNode:fromNode toNode:toNode inGraph:self];
            
            return;
        }
        else if([err name] === KFNodeCycleException)
        {
            if([delegate respondsToSelector:@selector(directedEdgeFromNode:toNode:wouldIntroduceCycleInGraph:)])
                [delegate directedEdgeFromNode:fromNode toNode:toNode wouldIntroduceCycleInGraph:self];
            
            [[CPNotificationCenter defaultCenter] 
                postNotificationName:YEDGraphEdgeWouldCauseCycleNotification
                object:self
                userInfo:[CPDictionary dictionaryWithJSObject:{
                    fromNode:fromNode,
                    toNode:toNode
                }]];
                
            if([delegate respondsToSelector:@selector(didAddEdge:fromNode:toNode:inGraph:)])
                [delegate didAddEdge:NO fromNode:fromNode toNode:toNode inGraph:self];
            
            return;
        }
        else
        {
            // Otherwise rethrow the error
            throw err;
        }
    }
    
    if([delegate respondsToSelector:@selector(didAddEdge:fromNode:toNode:inGraph:)])
        [delegate didAddEdge:YES fromNode:fromNode toNode:toNode inGraph:self];
    
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:YEDGraphEdgeAddedNotification
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            fromNode:fromNode,
            toNode:toNode
        }]];
}

- (void)removeDirectedEdgeFrom:(YEDNode)fromNode to:(YEDNode)toNode
{
    // Only remove the edge if both nodes are in the graph
    if(![nodes containsObject:fromNode] || ![nodes containsObject:toNode])
        return;
    
    if([delegate respondsToSelector:@selector(willRemoveEdgeFromNode:toNode:inGraph:)])
        [delegate willRemoveEdgeFromNode:fromNode toNode:toNode inGraph:self];
        
    [fromNode removeDirectedEdgeTo:toNode];
    
    if([delegate respondsToSelector:@selector(didRemoveEdge:fromNode:toNode:inGraph:)])
        [delegate didRemoveEdge:YES fromNode:fromNode toNode:toNode inGraph:self];
    
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:YEDGraphEdgeRemovedNotification
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            fromNode:fromNode,
            toNode:toNode
        }]];
}

- (BOOL)containsNode:(YEDNode)aNode
{
    return [nodes containsObject:aNode];
}

- (BOOL)containsEdgeFromNode:(YEDNode)startNode toNode:endNode
{
    return [startNode hasOutgoingEdgeTo:endNode];
}

- (void)allowsNode:(YEDNode)aNode
{
    var isAllowed = NO,
        allowedNodeTypeIter = [allowedNodeTypes objectEnumerator],
        allowedNodeType = nil;
    
    while(allowedNodeType = [allowedNodeTypeIter nextObject])
    {
        if([aNode isKindOfClass:allowedNodeType])
        {
            isAllowed = YES;
            break;
        }
    }
    return isAllowed;
}



@end