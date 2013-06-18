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
    return self.opponents.count + 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.name;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"OpponentCell"];

    GXPlayer* opponent = indexPath.row == 0 ? self.myself : self.opponents[indexPath.row - 1];
    cell.textLabel.text = opponent.name;

    return cell;
}



@end
