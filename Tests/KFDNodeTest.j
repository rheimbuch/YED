@import "../KFDNode.j"

// CPLogRegister(CPLogPrint);

@implementation KFDNodeTest : OJTestCase

- (void)testKFDNodeCanConnectToAnotherKFDNode
{
    var node1 = [KFDNode nodeWithName:"node1"];
    var node2 = [KFDNode nodeWithName:"node2"];
    [self assertTrue:([node1 canConnectTo:node2])
          message:"node1 should be able to connect to node2"];
    
    [self assertTrue:([node2 canConnectTo:node2])
          message:"node2 should be able to connect to node1"];
}

- (void)testKFDNodeAllDescendents
{
    // Create nodes
    var n1 = [KFDNode nodeWithName:"n1"],
        n2 = [KFDNode nodeWithName:"n2"],
        n3 = [KFDNode nodeWithName:"n3"],
        n4 = [KFDNode nodeWithName:"n4"],
        n5 = [KFDNode nodeWithName:"n5"],
        n6 = [KFDNode nodeWithName:"n6"],
        n7 = [KFDNode nodeWithName:"n7"];
        
    //Construct Graph (See ./KFDNodeTestGraph.dot)
                            // digraph KFDNodeTest
                            // {
    [n1 directedEdgeTo:n2]; //  n1 -> n2
    [n1 directedEdgeTo:n3]; //  n1 -> n3
    [n2 directedEdgeTo:n3]; //  n2 -> n3
    [n2 directedEdgeTo:n4]; //  n2 -> n4
    [n3 directedEdgeTo:n5]; //  n3 -> n5
    [n5 directedEdgeTo:n6]; //  n5 -> n6
    [n5 directedEdgeTo:n7]; //  n5 -> n7
    [n4 directedEdgeTo:n7]; //  n4 -> n7
                            // }
    
    // Setup what the descendents should be
    var n1Descendents = [CPSet setWithArray:[n2,n3,n4,n5,n6,n7]],
        n2Descendents = [CPSet setWithArray:[n3,n4,n5,n6,n7]],
        n3Descendents = [CPSet setWithArray:[n5,n6,n7]],
        n4Descendents = [CPSet setWithArray:[n7]],
        n5Descendents = [CPSet setWithArray:[n6,n7]],
        n6Descendents = [CPSet set],
        n7Descendents = [CPSet set];
        
    [self assertTrue:([[n1 allDescendents] isEqualToSet:n1Descendents])
          message:"n1 should have all other nodes as it's descendents"];
    [self assertTrue:([[n2 allDescendents] isEqualToSet:n2Descendents])
          message:"n2 should have n3-n7 as descendents"];
    [self assertTrue:([[n3 allDescendents] isEqualToSet:n3Descendents])
          message:"n3 should have n5-n7 as descendents"];
    [self assertTrue:([[n4 allDescendents] isEqualToSet:n4Descendents])
          message:"n4 should have n7 as its descendent"];
    [self assertTrue:([[n5 allDescendents] isEqualToSet:n5Descendents])
          message:"n5 should have n6 & n7 as descendents"];
    [self assertTrue:([[n6 allDescendents] isEqualToSet:n6Descendents])
          message:"n6 should have no nodes as descendents"];
    [self assertTrue:([[n7 allDescendents] isEqualToSet:n7Descendents])
          message:"n7 should have no nodes as descendents"];
}

- (void)testKFDNodeGraphHasCyclesFunctionDetectsSimpleCycles
{
    var n1 = [KFDNode nodeWithName:"n1"],
        n2 = [KFDNode nodeWithName:"n2"];
    
    // simplest acyclical graph
    [n1 directedEdgeTo:n2];
    [self assertFalse:KFDNodeGraphHasCycles(n1)
            message:"Starting at n1, cycle between n1, n2 SHOULD NOT be detected"];
    [self assertFalse:KFDNodeGraphHasCycles(n2)
            message:"Starting at n2, cycle between n1, n2 SHOULD NOT be detected"];
    
    [self assertFalse:KFDNodeGraphHasCycles(n1,YES) //Reverse search for cycles through inEdges
            message:"Starting at n1, cycle between n1, n2 SHOULD NOT be detected"];
    [self assertFalse:KFDNodeGraphHasCycles(n2,YES) //Reverse search for cycles through inEdges
            message:"Starting at n2, cycle between n1, n2 SHOULD NOT be detected"];
    
    // Now create a cycle
    [n2 directedEdgeTo:n1];
    
    [self assertTrue:KFDNodeGraphHasCycles(n1)
            message:"Starting at n1, cycle between n1, n2 SHOULD be detected"];
    [self assertTrue:KFDNodeGraphHasCycles(n2)
            message:"Starting at n2, cycle between n1, n2 SHOULD be detected"];
            
    [self assertTrue:KFDNodeGraphHasCycles(n1,YES) //Search for cycles through inEdges
            message:"Starting at n1, cycle between n1, n2 SHOULD be detected"];
    [self assertTrue:KFDNodeGraphHasCycles(n2,YES) //Search for cycles through inEdges
            message:"Starting at n2, cycle between n1, n2 SHOULD be detected"];
}

- (void)testKFDNodeGraphHasCyclesFunctionDetectsComplexCycles
{
    // Create nodes
    var n1 = [KFDNode nodeWithName:"n1"],
        n2 = [KFDNode nodeWithName:"n2"],
        n3 = [KFDNode nodeWithName:"n3"],
        n4 = [KFDNode nodeWithName:"n4"],
        n5 = [KFDNode nodeWithName:"n5"],
        n6 = [KFDNode nodeWithName:"n6"],
        n7 = [KFDNode nodeWithName:"n7"];
        
    //Construct Graph with cycles
                            // digraph KFDNodeTestCycles
                            // {
    [n1 directedEdgeTo:n2]; //  n1 -> n2
    [n1 directedEdgeTo:n3]; //  n1 -> n3
    [n2 directedEdgeTo:n3]; //  n2 -> n3
    [n2 directedEdgeTo:n4]; //  n2 -> n4
    [n3 directedEdgeTo:n5]; //  n3 -> n5
    [n5 directedEdgeTo:n6]; //  n5 -> n6
    [n6 directedEdgeTo:n4]; //  n6 -> n4
    [n5 directedEdgeTo:n7]; //  n5 -> n7
    [n4 directedEdgeTo:n7]; //  n4 -> n7
    [n7 directedEdgeTo:n2]; //  n7 -> n2
                            // }
    
    //Starting at n1 we should detect a cycle
    [self assertTrue:KFDNodeGraphHasCycles(n1)
            message:"Starting at n1, cycle should be detected"];
    [self assertTrue:KFDNodeGraphHasCycles(n7)
            message:"Starting at n7, cycle should be detected"];
}

- (void)testKFDNodeCyclePrevention
{
    var n1 = [KFDNode acyclicNodeWithName:"n1"],
        n2 = [KFDNode acyclicNodeWithName:"n2"],
        n3 = [KFDNode acyclicNodeWithName:"n3"];
    
    // Setup acyclic graph
    
    [n1 directedEdgeTo:n2];
    [n2 directedEdgeTo:n3];
    
    [self assertFalse:[n1 cycleInDescendents]
            message:"n1 should not have any cycles in its descendents"];
    
    // Try to introduce a cycle
    try
    {
        CPLog.info("Introducing a cycle: n3 -> n1");
        [n3 directedEdgeTo:n1];
    }
    catch(err)
    {
        CPLog.info("Caught Error: %s", err);
    }
    // The edge should not have been introduced
    [self assertFalse:([[n3 outEdges] containsObject:n1])
            message:"n1 should not be in n3's outgoing edges"];
    [self assertFalse:([[n1 inEdges] containsObject:n3])
            message:"n3 should not be in n1's incoming edges"];
    // Therefore there should not be a cycle
    [self assertFalse:[n1 cycleInDescendents]
            message:"n1 should not have any cycles in its descendents"];
}
@end