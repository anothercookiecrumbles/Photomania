//
//  PhotomaniaCDTVC.m
//  Photomania
//
//  Created by Priyanjana Bengani on 27/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "PhotomaniaCDTVC.h"
#import "Photographer+Create.h"
#import "PhotoDatabaseAvailability.h"
#import "PhotosByPhotographerCDTVC.h"

@interface PhotomaniaCDTVC ()

@end

@implementation PhotomaniaCDTVC

- (void) awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification* notification){
        self.context = notification.userInfo[PhotoDatabaseAvailabilityContext];
    }];
}

- (void) setContext:(NSManagedObjectContext *)context {
    _context = context;
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    request.predicate = nil; // all photographers
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]];
    request.fetchLimit = 1000;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

//This is not implemented, and has to be implemented by us! 
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photographer Cell"];
    Photographer* photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photographer.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos",[photographer.photos count]];
    
    return cell;
}

#pragma mark - Navigation

- (void) prepareViewController:(id) vc forSegue:(NSString*) segueIdentifier fromIndexPath:(NSIndexPath*) indexPath {
    Photographer* photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([vc isKindOfClass:[PhotosByPhotographerCDTVC class]]) {
        if (![segueIdentifier length] || [segueIdentifier isEqualToString:@"Show Photos By Photographer"]) {
            PhotosByPhotographerCDTVC* pbp = (PhotosByPhotographerCDTVC*) vc;
            pbp.photographer = photographer;
        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath* indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController forSegue:segue.identifier fromIndexPath:indexPath];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id detailvc = [self.splitViewController.viewControllers lastObject];
    if ([detailvc isKindOfClass:[UINavigationController class]]) {
        detailvc = [((UINavigationController*)detailvc).viewControllers firstObject];
        [self prepareViewController:detailvc forSegue:nil fromIndexPath:indexPath];
    }
}

@end
