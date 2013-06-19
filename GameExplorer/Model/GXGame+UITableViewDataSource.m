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
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PlayerCell"];

    GXPlayer* player = indexPath.row == 0 ? self.myself : self.opponents[indexPath.row - 1];
    cell.textLabel.text = player.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", player.latitude, player.longitude];
    cell.backgroundColor = [UIColor whiteColor];

    UILabel* fragCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 21)];
    fragCount.text = @(player.fragCount).stringValue;
    fragCount.backgroundColor = [UIColor clearColor];
    fragCount.textAlignment = UITextAlignmentRight;
    cell.accessoryView = fragCount;

    if ([self.lastShot.pid isEqualToString:player.pid]) {
        cell.backgroundColor = [UIColor redColor];
    }

    return cell;
}



@end
