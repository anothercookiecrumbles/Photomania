//
//  PhotomaniaPhotosCDTVC.m
//  Photomania
//
//  Created by Priyanjana Bengani on 27/12/2013.
//  Copyright (c) 2013 anothercookiecrumbles. All rights reserved.
//

#import "PhotomaniaPhotosCDTVC.h"
#import "Photo.h"
#import "ImaginariumImageViewController.h"

@interface PhotomaniaPhotosCDTVC ()

@end

@implementation PhotomaniaPhotosCDTVC

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photo Cell"];
    
    Photo* photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.description;
    
    return cell;
}

#pragma mark - Navigation

- (void) prepareViewController:(id) vc forSegue:(NSString*) segueIdentifier fromIndexPath:(NSIndexPath*) indexPath {
    Photo* photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([vc isKindOfClass:[ImaginariumImageViewController class]]) {
        ImaginariumImageViewController* ivc = (ImaginariumImageViewController*) vc;
        ivc.imageUrl = [NSURL URLWithString:photo.imageUrl];
        ivc.title = photo.title;
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
