/*
 * AppController.j
 * YEDDiagram
 *
 * Created by You on October 27, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

@import <AppKit/CPCollectionView.j>
@import <Foundation/CPObject.j>
@import "YEDEdgeView.j"
@import "YEDGraph.j"
@import "YEDGraphViewController.j"
@import "YEDNode.j"
@import "YEDNodeView.j"
@import "YEDNodeViewRegistry.j"
@import "YEDOperationNode.j"
@import "YEDSubjectNode.j"


CPLogRegister(CPLogConsole);

@implementation AppController : CPObject
{
    CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    CPView      contentView;
    CPView      sideView;
    CPView      canvasView;
    YEDNodeViewRegistry registry;
    CPCollectionView nodeCollectionView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
    // [[YEDEditorView sharedEditor] setBackgroundColor:[CPColor blueColor]];
    // Setup default Node Views
    CPLog.trace("Setting up view registry");
    registry = [YEDNodeViewRegistry registry];
    var subjectNodeView = [[YEDNodeView alloc] initWithFrame:CPRectMake(0,0,150,50)];
    [subjectNodeView setBorderWidth:4.0];
    [subjectNodeView setBorderColor:[CPColor redColor]];
    [subjectNodeView setCornerRadius:0];
    [subjectNodeView setFillColor:[CPColor whiteColor]];
    [registry registerPrototype:subjectNodeView
                for:YEDSubjectNode];
    
    var operationNodeView = [[YEDNodeView alloc] initWithFrame:CPRectMake(0,0,100,80)];
    [operationNodeView setBorderWidth:3.0];
    [operationNodeView setBorderColor:[CPColor greenColor]];
    [operationNodeView setCornerRadius:20];
    [operationNodeView setFillColor:[CPColor whiteColor]];
    [registry registerPrototype:operationNodeView
                for:YEDOperationNode];
    // Setup graph and graph controller
    graph = [YEDGraph graph];
    
     graphViewController = [[YEDGraphViewController alloc] init];
    [graphViewController setNodeViewRegistry:registry];
    [graphViewController setRepresentedObject:graph];
    
    var selectionManager = [[YEDSelectionManager alloc] init];
    [selectionManager setDelegate:graphViewController];
    [graphViewController setSelectionManager:selectionManager];
    
    var canvasScroll = [[CPScrollView alloc] initWithFrame:CGRectMakeCopy([canvasView bounds])];
    [canvasScroll setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [canvasScroll setAutohidesScrollers:YES];
    [canvasView addSubview:canvasScroll];
    
     graphView = [graphViewController view];
    [graphView setFrame:CPRectMake(0,0,1000,1000)];
    // [graphView setAutoresizingMask:(CPViewWidthSizable | CPViewHeightSizable)];
    [canvasScroll setDocumentView:graphView];
    
    
    
    //console.debug("Registry");
    //console.debug(registry);
    
    // rat1 = [YEDSubjectNode nodeWithName:"Rat1"];
    // [graph addNode:rat1];
    // fed1 = [YEDOperationNode nodeWithName:"Fed 5cc glucose"];
    // [graph addNode:fed1];
    // fedRat1 = [YEDSubjectNode nodeWithName:"Rat1 Fed"];
    // [graph addNode:fedRat1];
    // 
    // [graph createDirectedEdgeFrom:rat1 to:fed1];
    // [graph createDirectedEdgeFrom:fed1 to:fedRat1];

    
    
    
    // var nodeCollectionView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0,0,200,400)];
    // [nodeCollectionView setBackgroundColor:[CPColor greenColor]];
    [nodeCollectionView setMinItemSize:CGSizeMake(200, 50)];
    [nodeCollectionView setMaxItemSize:CGSizeMake(10000, 50)];
    // [sideView addSubview:nodeCollectionView];
    var nodeItemPrototype = [[CPCollectionViewItem alloc] init];
    [nodeItemPrototype setView:[[NodeViewCollectionItem alloc] initWithFrame:CGRectMakeZero()]];
    [nodeCollectionView setItemPrototype:nodeItemPrototype];
    [nodeCollectionView setDelegate:self];
    
    preparedNodeViews = [[registry viewFor:[YEDOperationNode nodeWithName:@"Operation"]], [registry viewFor:[YEDSubjectNode nodeWithName:@"Subject"]]];
    [nodeCollectionView setContent:preparedNodeViews];
    //console.debug(nodeCollectionView);
    
}

- (CPData)collectionView:(CPCollectionView)collectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)type
{
    return [CPKeyedArchiver archivedDataWithRootObject:[preparedNodeViews objectAtIndex:[indices firstIndex]]];
}

- (CPArray)collectionView:(CPCollectionView)collectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
    return [YEDNodeViewDragType];
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things. 
    
    // In this case, we want the window from Cib to become our full browser window
    [theWindow setFullBridge:YES];
}

- (void)newNode:(id)sender
{
    var name = prompt("Node Name:");
    if(name)
    {
        var node = [YEDSubjectNode nodeWithName:name];
        [graph addNode:node];
    }
}

- (void)delete:(id)sender
{
    CPLog.trace("delete:");
    [graphViewController deleteSelected];
    
}

@end

@implementation NodeViewCollectionItem : CPView
{
    CPTextField nameField;
}

- (void)setRepresentedObject:(id)object
{
    if(!nameField)
    {
        nameField = [[CPTextField alloc] initWithFrame:CGRectMake(50,15,145,20)];
        [nameField setFont:[CPFont boldSystemFontOfSize:12.0]];
        [self addSubview:nameField];
    }
    
    [nameField setStringValue:[[object representedObject] name]];
}

- (void)setSelected:(BOOL)isSelected
{
    [self setBackgroundColor:isSelected ? [CPColor blueColor] : nil];
    [nameField setTextColor:isSelected ? [CPColor whiteColor] : [CPColor blackColor]];
}

@end
