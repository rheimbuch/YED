@import "KFDGraph.j"
@import "KFDOperationNode.j"
@import "KFDSubjectNode.j"

@implementation KFDModelGraph : KFDGraph

- (id)init
{
    self = [super init];
    if(self)
    {
        allowedNodeTypes = [CPSet setWithArray:[KFDOperationNode, KFDSubjectNode]];
    }
    return self;
}

@end