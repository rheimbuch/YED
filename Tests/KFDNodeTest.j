@import "../KFDNode.j"

@implementation KFDNodeTest : OJTestCase

- (void)testKFDNodeCanConnectToAnotherKFDNode
{
    var node1 = [KFDNode node];
    var node2 = [KFDNode node];
    [self assertTrue:([node1 canConnectTo:node2])
          message:"node1 should be able to connect to node2"];
    
    [self assertTrue:([node2 canConnectTo:node2])
          message:"node2 should be able to connect to node1"];
}

- (void)testKFDNodeAllDescendents
{
    // Create nodes
    var n1 = [KFDNode node],
        n2 = [KFDNode node],
        n3 = [KFDNode node],
        n4 = [KFDNode node],
        n5 = [KFDNode node],
        n6 = [KFDNode node],
        n7 = [KFDNode node];
        
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
    var n1 = [KFDNode node],
        n2 = [KFDNode node];
    
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
    var n1 = [KFDNode node],
        n2 = [KFDNode node],
        n3 = [KFDNode node],
        n4 = [KFDNode node],
        n5 = [KFDNode node],
        n6 = [KFDNode node],
        n7 = [KFDNode node];
        
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
@end