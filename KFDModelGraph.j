@import "YEDGraph.j"
@import "YEDOperationNode.j"
@import "YEDSubjectNode.j"

@implementation YEDModelGraph : YEDGraph

- (id)init
{
    self = [super init];
    if(self)
    {
        allowedNodeTypes = [CPSet setWithArray:[YEDOperationNode, YEDSubjectNode]];
    }
    return self;
}

@end