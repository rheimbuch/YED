@import <Foundation/CPObject.j>
@import <Foundation/CPDictionary.j>
@import <Foundation/CPKeyedArchiver.j>
@import <Foundation/CPKeyedUnarchiver.j>

@import "YEDNode.j"

var DefaultRegistry = nil;

@implementation YEDNodeViewRegistry : CPObject
{
    CPDictionary       nodeViewPrototypes;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        nodeViewPrototypes = [CPDictionary dictionary];
    }
    return self;
}

+ (id)registry
{
   return [[self alloc] init];
}

+ (id)defaultRegistry
{
    if(!DefaultRegistry)
        DefaultRegistry = [[self alloc] init];
    
    return DefaultRegistry;
}

- (void)registerPrototype:(CPView)aView for:(id)aNodeOrClass
{
    var data = [CPKeyedArchiver archivedDataWithRootObject:aView];
    [nodeViewPrototypes setObject:data forKey:[aNodeOrClass className]];
}

- (CPView)viewFor:(id)aNodeOrClass
{
    CPLog.trace("YEDNodeViewRegistry: finding view for " + [aNodeOrClass className]);
    var data = [nodeViewPrototypes objectForKey:[aNodeOrClass className]];
    if(data)
    {
        var view = [CPKeyedUnarchiver unarchiveObjectWithData:data];
        if([aNodeOrClass isKindOfClass:YEDNode] && [aNodeOrClass respondsToSelector:@selector(isNode)] && [aNodeOrClass isNode])
        {
            [view setRepresentedObject:aNodeOrClass];
        }
        else if([aNodeOrClass isKindOfClass:YEDNode] && [aNodeOrClass respondsToSelector:@selector(nodeWithName:)])
        {
            [view setRepresentedObject:[aNodeOrClass nodeWithName:[aNodeOrClass className]]];
        }
        return view;
    }
}

@end