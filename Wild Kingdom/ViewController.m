//
//  ViewController.m
//  Wild Kingdom
//
//  Created by Apple on 23/01/14.
//  Copyright (c) 2014 Tablified Solutions. All rights reserved.
//

#import "ViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"
#import "FlickrPhotoCell.h"

@interface ViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet UICollectionView *myCollectionView;
    NSMutableDictionary *searchResults;
    NSMutableArray *searches;
    Flickr *flickr;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    searches = [NSMutableArray new];  //@[] mutableCopy
    searchResults = [NSMutableDictionary new]; //@{} mutableCopy
    flickr = [Flickr new];
    //[myCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FlickrCell"];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [flickr searchFlickrForTerm:searchTextField.text completionBlock:^(NSString *searchTerm, NSArray *results, NSError *error) {
        if (results && results.count > 0) {
            if (![searches containsObject:searchTerm]) {
                NSLog(@"Found %d photos matching %@", results.count, searchTerm);
                [searches insertObject:searchTerm atIndex:0];
                searchResults[searchTerm] = results;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [myCollectionView reloadData];
            });
        } else {
            NSLog(@"Error searching Flickr: %@", error.localizedDescription);
        }
    }];
    [searchTextField resignFirstResponder];
    
    return YES;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSString *searchTerm = searches[section];
    NSLog(@"%i", [searchResults[searchTerm] count]);
    return [searchResults[searchTerm] count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"%i", searches.count);
    return searches.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FlickrPhotoCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
    NSString *searchTerm = searches[indexPath.section];
    cell.photo = searchResults[searchTerm][indexPath.row];
    
    return cell;
}

/*
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [[UICollectionReusableView alloc] init];
}
*/

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // ToDo : Select Item
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // ToDo: Deselect Item
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *searchTerm = searches[indexPath.section];
    FlickrPhoto *photo = searchResults[searchTerm][indexPath.row];
    // 2
    CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
    retval.height += 35;
    retval.width += 35;
    
    return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

@end
