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

@end
