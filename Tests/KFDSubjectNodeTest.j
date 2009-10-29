@import "../KFDNode.j"
@import "../KFDSubjectNode.j"
@import "../KFDOperationNode.j"

@implementation KFDSubjectNodeTest : OJTestCase

- (void)testKFDSubjectNodeShouldNotConnectToAnotherKFDSubjectNode
{
    var node1 = [KFDSubjectNode node],
        node2 = [KFDSubjectNode node];
    
    [self assertFalse:([node1 canConnectTo:node2])
          message:"A subject node1 should not connect to another subject node2"];
    
    [self assertFalse:([node2 canConnectTo:node1])
          message:"A subject node2 should not connect to another subject node1"];
}

- (void)testKFDSubjectNodeShouldConnectToAKFDOperationNode
{
    var node1 = [KFDSubjectNode node],
        node2 = [KFDOperationNode node];
    
    [self assertTrue:([node1 canConnectTo:node2])
          message:"A Subject node can connect to an operation node"];
}
@end