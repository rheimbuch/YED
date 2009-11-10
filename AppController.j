/*
 * AppController.j
 * KefedDiagram
 *
 * Created by You on October 27, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "KFDGraph.j"
@import "KFDGraphViewController.j"
@import "KFDNode.j"
@import "KFDNodeView.j"
@import "KFDNodeViewRegistry.j"
@import "KFDOperationNode.j"


CPLogRegister(CPLogConsole);

@implementation AppController : CPObject
{
    CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    CPView      contentView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
    // [[KFDEditorView sharedEditor] setBackgroundColor:[CPColor blueColor]];
    // Setup default Node Views
    CPLog.trace("Setting up view registry");
    var registry = [KFDNodeViewRegistry registry];
    var defaultNodeView = [[KFDNodeView alloc] initWithFrame:CPRectMake(0,0,100,50)];
    [defaultNodeView setBorderWidth:2.0];
    [defaultNodeView setBorderColor:[CPColor redColor]];
    [defaultNodeView setCornerRadius:10];
    [defaultNodeView setFillColor:[CPColor whiteColor]];
    [registry registerPrototype:defaultNodeView
                for:KFDNode];
    
    var otherNodeView = [[KFDNodeView alloc] initWithFrame:CPRectMake(0,0,100,80)];
    [otherNodeView setBorderWidth:3.0];
    [otherNodeView setBorderColor:[CPColor greenColor]];
    [otherNodeView setCornerRadius:0];
    [otherNodeView setFillColor:[CPColor whiteColor]];
    [registry registerPrototype:otherNodeView
                for:KFDOperationNode];
    // Setup graph and graph controller
    graph = [KFDGraph graph];
    
    var graphViewController = [[KFDGraphViewController alloc] init];
    [graphViewController setNodeViewRegistry:registry];
    [graphViewController setRepresentedObject:graph];
    
    var graphView = [graphViewController view];
    [graphView setFrame:CPRectMake(0,0,CPRectGetWidth([contentView bounds]),CPRectGetHeight([contentView bounds]))];
    [graphView setAutoresizingMask:(CPViewWidthSizable | CPViewHeightSizable)];
    [contentView addSubview:graphView];
    
    
    
    console.debug("Registry");
    console.debug(registry);
    
    n1 = [KFDNode nodeWithName:"n1"];
    [graph addNode:n1];
    op1 = [KFDOperationNode nodeWithName:"op1"];
    [graph addNode:op1];
    // At this point, the graph should have two nodes, and 
    //  the graph view should show them with the above
    //  registered nodeviews.
    
    // var nodeViewDecorator = [CPBox boxEnclosingView:nodeView];
    // [nodeViewDecorator setBorderType:CPLineBorder];
    // [nodeViewDecorator setBorderWidth:5];
    // [nodeViewDecorator setCornerRadius:20.0];
    // [nodeViewDecorator setFillColor:[CPColor grayColor]];
    // console.log(nodeViewDecorator);
    
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
        var node = [KFDNode nodeWithName:name];
        [graph addNode:node];
    }
}

@end
