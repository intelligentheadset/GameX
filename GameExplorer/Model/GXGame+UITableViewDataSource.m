//
//  GXGame+UITableViewDataSource.m
//  GameExplorer
//
//  Created by Martin Lobger on 18/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GXGame+UITableViewDataSource.h"

@implementation GXGame (UITableViewDataSource)

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // Only one game running
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.opponents.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"OpponentCell"];

    GXPlayer* opponent = self.opponents[indexPath.row];
    cell.textLabel.text = opponent.name;

    return cell;
}



@end
