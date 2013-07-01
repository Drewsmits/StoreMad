//
//  RootViewController.m
//  StoreMadApp
//
//  Created by Andrew Smith on 7/1/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@property (nonatomic, strong) SMStoreController *storeController;
@property (nonatomic, strong) SMTableViewDataSource *storeMadDataSource;

@end

@implementation RootViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.storeController = [[AppDelegate sharedInstance] storeController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.storeMadDataSource = [SMTableViewDataSource new];
    
    [self.storeMadDataSource setupWithFetchRequest:nil
                                           context:self.storeController.managedObjectContext
                                sectionNameKeyPath:nil
                                         cacheName:nil];
    
    [self.storeMadDataSource performFetch];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.storeMadDataSource.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.storeMadDataSource numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - SMTableViewController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
