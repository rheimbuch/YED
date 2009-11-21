@import <Foundation/CPObject.j>
@import <Foundation/CPSet.j>
@import <Foundation/CPException.j>

// Constants
YEDNodeCycleException = "YEDNodeCycleException";
YEDNodeNotAllowedException = "YEDNodeNotAllowedException";

/*
 * Performs a depth-first-search of an edge set,
 *  tracking each node encountered. If a node is
 *  encountered more than once, then a cycle has 
 *  been found.
 */
YEDNodeGraphHasCycles = function(aNode, traverseParents) 
{
    CPLog.trace("YEDNodeGraphHasCycles: Testing for cycles starting at %s", [aNode name]);
    traverseParents = traverseParents || NO;
    var stack = []
    function isAcyclic(node)
    {
        if([stack containsObject:node])
        {
            return false;
        }
        stack.push(node);
        CPLog.trace("YEDNodeGraphHasCycles: at node %s", [node name]);
        
        var targetNode = nil;
        var nodeIter = traverseParents ? [[node inEdges] objectEnumerator] : 
                                         [[node outEdges] objectEnumerator];
        
        traverseParents ? CPLog.trace("YEDNodeGraphHasCycles: Traversing inEdges") : 
                          CPLog.trace("YEDNodeGraphHasCycles: Travering outEdges");
        
        while(targetNode = [nodeIter nextObject])
        {
            if(!isAcyclic(targetNode, traverseParents))
            {
                return false;
            }
        }
        stack.pop();
        return true;
    }
    
    var result = isAcyclic(aNode);
    CPLog.trace("YEDNodeGraphHasCycles: Graph staring at %s is acyclic: %s", [aNode name], result);
    return !result;
};

@implementation YEDNode : CPObject
{
    CPString    name                    @accessors;
    CPSet       outEdges                @accessors(readonly);
    CPSet       inEdges                 @accessors(readonly);
    CPSet       allowsConnectionsTo      @accessors(readonly);
    CPSet       allowsConnectionsFrom    @accessors(readonly);
    
    BOOL        isAcyclic     @accessors;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        outEdges = [CPSet set];
        inEdges = [CPSet set];
        allowsConnectionsTo = [CPSet setWithObject:[self className]];
        allowsConnectionsFrom = [CPSet setWithObject:[self className]];
        isAcyclic = NO;
    }
    return self;
}

- (id)initAcyclic
{
    self = [self init]
    if(self)
    {
        isAcyclic = YES;
    }
    return self;
}

+ (id)node
{
    return [[self alloc] init];
}

+ (id)nodeWithName:(CPString)aName
{
    var node = [self node];
    [node setName:aName];
    return node;
}

+ (id)acyclicNode
{
    return [[self alloc] initAcyclic];
}

+ (id)acyclicNodeWithName:(CPString)aName
{
    var node = [self acyclicNode];
    [node setName:aName]
    return node;
}

- (BOOL)isNode
{
    return YES;
}

- (BOOL)isEqual:(id)other
{
    if(other === self)
        return YES;
    if(!other || ![other isKindOfClass:[self class]])
        return NO
    return [self isEqualToNode:other];
}

- (BOOL)isEqualToNode:(YEDNode)otherNode
{
    if(otherNode === self)
        return YES;
    if(![[self name] isEqual:[otherNode name]])
        return NO;
    if(![[self isAcyclic] isEqual:[otherNode isAcyclic]])
        return NO;
    if(![[self allowsConnectionsTo] isEqualToSet:[otherNode allowsConnectionsTo]])
        return NO;
    if(![[self allowsConnectionsFrom] isEqualToSet:[otherNode allowsConnectionsFrom]])
        return NO;
    return YES;
}

- (BOOL)hasOutgoingEdgeTo:(YEDNode)otherNode
{
    return [outEdges containsObject:otherNode];
}

- (BOOL)hasIncomingEdgeFrom:(YEDNode)otherNode
{
    return [otherNode hasOutgoingEdgeTo:self];
}

- (void)directedEdgeTo:(YEDNode)otherNode
{
    if([self canConnectTo:otherNode])
    {
        CPLog.trace("directedEdgeTo: %s allowed to connect to %s", [self name], [otherNode name]);
        
        // If the otherNode has no incoming or outgoing edges, then it cannot introduce
        //  any cycles into the graph. We test because adding a single, indepedent node 
        //  is a common case.
        var otherNodeCouldIntroduceCycles = [[otherNode inEdges] anyObject] || [[otherNode outEdges] anyObject];
        CPLog.trace("directedEdgeTo: %s could introduce a cycle?: %s", [otherNode name], otherNodeCouldIntroduceCycles);
        
        //Add the node to the graph first
        [[self outEdges] addObject:otherNode];
        [[otherNode inEdges] addObject:self];
        
        if(isAcyclic && otherNodeCouldIntroduceCycles)
        {

            if([self cycleInDescendents] || [self cycleInParents])
            {
                CPLog.warn("directedEdgeTo: detected a cycle! removing edge from %s to %s", [self name], [otherNode name]);
                //If adding the edge/connection introduces cycles, we should remove it.
                [[self outEdges] removeObject:otherNode];
                [[otherNode inEdges] removeObject:self];
                
                [CPException raise:YEDNodeCycleException reason:"Connecting the node would introduce a cycle."];
            }
            
        }
    }
    else
    {
        CPLog.warn("directedEdgeTo: %s not allowed to connect to %s", [self name], [otherNode name]);      
        [CPException raise:YEDNodeNotAllowedException reason:"Connecting to this node type is not allowed."];
    }
}

- (void)directedEdgeFrom:(YEDNode)otherNode
{
    [otherNode directedEdgeTo:self];
}


- (void)removeDirectedEdgeTo:(YEDNode)otherNode
{       
    [[self outEdges] removeObject:otherNode];
    [[otherNode inEdges] removeObject:self];
}

- (void)disconnectFromAllNodes
{
    var node = nil,
        outIter = [outEdges objectEnumerator],
        inIter = [inEdges objectEnumerator];
    
    while(node = [outIter nextObject])
    {
        [self removeDirectedEdgeTo:node];
    }
    
    while(node = [inIter nextObject])
    {
        [node removeDirectedEdgeTo:self];
    }
}

/*
 * Is the node allowed to connect to another node.
 * By default all YEDNodes can connect to any other node.
 */
- (BOOL)canConnectTo:(YEDNode)otherNode
{
    var allowTo = false;
    var allowToIter = [allowsConnectionsTo objectEnumerator];
    
    var allowedNodeClass = nil;
    while(allowedNodeClass = objj_lookUpClass([allowToIter nextObject]))
    {
        if([otherNode isKindOfClass:allowedNodeClass])
            allowTo = true;
    }
    
    
    
    var allowFrom = false;
    var allowFromIter = [[otherNode allowsConnectionsFrom] objectEnumerator];
    
    var allowedNodeClass = nil;
    while(allowedNodeClass = objj_lookUpClass([allowFromIter nextObject]))
    {
        if([self isKindOfClass:allowedNodeClass])
            allowFrom = true;
    }
    
    return allowTo && allowFrom;
}

- (BOOL)canRecieveConnectionFrom:(YEDNode)otherNode
{
    return [otherNode canConnectTo:self];
}

- (CPSet)allDescendents
{
    var descendents = [CPSet set];
    
    function traverse(node) {
        [descendents unionSet:[node outEdges]];
        var iter = [[node outEdges] objectEnumerator];
        while(node = [iter nextObject])
        {
            traverse(node);
        }
    }
    traverse(self);
    return descendents;
}

- (BOOL)cycleInDescendents
{
    return YEDNodeGraphHasCycles(self,NO);
}

- (BOOL)cycleInParents
{
    return YEDNodeGraphHasCycles(self,YES);
}

@end

// Coding Keys
var YEDNodeNameKey = @"YEDNodeNameKey",
    YEDNodeIsAcyclicKey = @"YEDNodeIsAcyclicKey",
    YEDNodeOutEdgesKey = @"YEDNodeOutEdgesKey",
    YEDNodeInEdgesKey = @"YEDNodeInEdgesKey",
    YEDNodeAllowsConnectionsToKey = @"YEDNodeAllowsConnectionsToKey",
    YEDNodeAllowsConnectionsFromKey = @"YEDNodeAllowsConnectionsFromKey";

@implementation YEDNode (CPCoding)

- (id)initWithCoder:(CPCoder)coder
{
    self = [super init];
    if(self)
    {
        name        = [coder decodeObjectForKey:YEDNodeNameKey];
        isAcyclic   = [coder decodeObjectForKey:YEDNodeIsAcyclicKey];
        outEdges    = [coder decodeObjectForKey:YEDNodeOutEdgesKey];
        inEdges     = [coder decodeObjectForKey:YEDNodeInEdgesKey];
        allowsConnectionsTo     = [coder decodeObjectForKey:YEDNodeAllowsConnectionsToKey];
        allowsConnectionsFrom   = [coder decodeObjectForKey:YEDNodeAllowsConnectionsFromKey];
    }
    return self;
}

- (void)encodeWithCoder:(CPCoder)coder
{
    // [super encodeWithCoder:coder];
    
    [coder encodeObject:name forKey:YEDNodeNameKey];
    [coder encodeObject:isAcyclic forKey:YEDNodeIsAcyclicKey];
    [coder encodeObject:outEdges forKey:YEDNodeOutEdgesKey];
    [coder encodeObject:inEdges forKey:YEDNodeInEdgesKey];
    [coder encodeObject:allowsConnectionsTo forKey:YEDNodeAllowsConnectionsToKey];
    [coder encodeObject:allowsConnectionsFrom forKey:YEDNodeAllowsConnectionsFromKey];
}
@end