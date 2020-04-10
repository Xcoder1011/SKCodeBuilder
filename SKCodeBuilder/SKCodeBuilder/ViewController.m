//
//  ViewController.m
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/8.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSTextFieldDelegate,NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSPopUpButton *reqTypeBtn;
@property (weak) IBOutlet NSTextField *urlTF;
@property (weak) IBOutlet NSSegmentedControl *segment;
@property (weak) IBOutlet NSScrollView *keyValueScrollView;
@property (weak) IBOutlet NSTableView *keyValueTableView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.reqTypeBtn removeAllItems];
    [self.reqTypeBtn addItemsWithTitles:@[@"GET",@"POST"]];
    [self.reqTypeBtn selectItemAtIndex:0];
    

    [self.segment setSelectedSegment:0];
    
    self.keyValueTableView.dataSource = self;
    self.keyValueTableView.delegate = self;
    
    [self.keyValueTableView editedRow];
        
}

- (IBAction)requestURLBtnClicked:(NSButton *)sender {
     NSLog(@"URL = %@",self.urlTF.stringValue);
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSLog(@"tableColumn.identifier = %@, row = %zd",tableColumn.identifier,row);
    NSTableCellView *cellView = [[NSTableCellView alloc] init];
    NSRect rect = CGRectMake(0, 0, tableColumn.width, 25);
    NSTextField *textF = [[NSTextField alloc] initWithFrame:rect];
    textF.textColor = [NSColor redColor];
    textF.editable = NO;
    [cellView addSubview:textF];
    textF.stringValue = @"wushangkun";
    return cellView;
}

//- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
//
//}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    return 20;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 25;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    return @"4567890-=";
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    
    NSLog(@"didSelectTabViewItem = %@",tabViewItem.label);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}


@end
