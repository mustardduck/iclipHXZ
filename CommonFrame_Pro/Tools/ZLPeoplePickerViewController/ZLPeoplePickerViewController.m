//
//  ZLPeoplePickerViewController.m
//  ZLPeoplePickerViewControllerDemo
//
//  Created by Zhixuan Lai on 11/4/14.
//  Copyright (c) 2014 Zhixuan Lai. All rights reserved.
//

#import "ZLPeoplePickerViewController.h"
#import "ZLResultsTableViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "ZLAddressBook.h"
#import "APContact+Sorting.h"
#import "Member.h"
#import "UICommon.h"
#import "MQCreateGroupSecondController.h"

@interface ZLPeoplePickerViewController () <
    ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate,
    ABNewPersonViewControllerDelegate, ABUnknownPersonViewControllerDelegate,
    UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
{
    UILabel * _countLbl;
}
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic)
    ZLResultsTableViewController *resultsTableViewController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation ZLPeoplePickerViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _numberOfSelectedPeople = ZLNumSelectionNone;
    self.filedMask = ZLContactFieldDefault;
    self.allowAddPeople = YES;
}

+ (void)initializeAddressBook {
    [[ZLAddressBook sharedInstance] loadContacts:nil];
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor backgroundColor];
    self.tableView.sectionIndexColor = [UIColor whiteColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    if(_invitedArr.count)
    {
        for(Member * member in _invitedArr)
        {
            if(member.mobile)
            {
                NSNumber * mobile = [NSNumber numberWithLongLong:[member.mobile longLongValue]];
                [self.selectedPeople addObject:mobile];
            }
            if(member.recordId)
            {
                [self.selectedPeopleRecordID addObject:member.recordId];
            }
        }
        
        [self setCountLbl];
    }
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [leftButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 10, 18)];
    [imgview setImage:[UIImage imageNamed:@"btn_fanhui"]];
    [leftButton addSubview:imgview];
    UILabel* ti = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 50, 20)];
    [ti setBackgroundColor:[UIColor clearColor]];
    [ti setTextColor:[UIColor whiteColor]];
    [ti setText:@"返回"];
    [ti setFont:[UIFont systemFontOfSize:17]];
    [leftButton addSubview:ti];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    UIView * rightView = [[UIView alloc] init];
    rightView.frame = CGRectMake(0, 0, 100, 64);
    rightView.backgroundColor = [UIColor clearColor];
    
    UIButton * doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 100, 64)];
    doneBtn.backgroundColor = [UIColor clearColor];
    [doneBtn addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitle:@"邀请" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = Font(16);
    [doneBtn setTitleColor:RGBCOLOR(76, 215, 100) forState:UIControlStateNormal];
    
    [rightView addSubview:doneBtn];
    
    _countLbl = [[UILabel alloc] initWithFrame:CGRectMake(10 + 52, 16, 14, 14)];
    _countLbl.backgroundColor = RGBCOLOR(76, 215, 100);
    [_countLbl setRoundCorner:W(_countLbl)/ 2];
    _countLbl.textColor = RGBCOLOR(31, 31, 31);
    _countLbl.font = Font(10);
    _countLbl.textAlignment = NSTextAlignmentCenter;
    _countLbl.hidden = YES;
    
    [doneBtn addSubview:_countLbl];
    
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    
//    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"邀请" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
//    [rightBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor greenColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
    
//    UIImageView * iconGreen = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 9, 9)];
//    iconGreen.image = [UIImage imageNamed:@"icon_yaoqiangshu"];
//    
//    UIBarButtonItem* iconViewItem = [[UIBarButtonItem alloc] initWithCustomView:iconGreen];
//
//    NSMutableArray *tright = [NSMutableArray array];
//    [tright addObject:iconViewItem];
//    [tright addObject:rightBarButton];
//    self.navigationItem.rightBarButtonItems = tright;
    self.navigationItem.rightBarButtonItem = rightBarButton;

    _resultsTableViewController = [[ZLResultsTableViewController alloc] init];
    _searchController = [[UISearchController alloc]
        initWithSearchResultsController:self.resultsTableViewController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;

    // we want to be the delegate for our filtered table so
    // didSelectRowAtIndexPath is called for both tables
    self.resultsTableViewController.tableView.delegate = self;
    self.searchController.delegate = self;
    //    self.searchController.dimsBackgroundDuringPresentation = NO; //
    //    default is YES
    self.searchController.searchBar.delegate =
        self; // so we can monitor text changes + others

    // Search is now just presenting a view controller. As such, normal view
    // controller
    // presentation semantics apply. Namely that presentation will walk up the
    // view controller
    // hierarchy until it finds the root view controller or one that defines a
    // presentation context.
    //
    self.definesPresentationContext =
        YES; // know where you want UISearchController to be displayed

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor backgroundColor];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self
                            action:@selector(refreshControlAction:)
                  forControlEvents:UIControlEventValueChanged];
    [self refreshControlAction:self.refreshControl];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    self.navigationItem.title = self.title.length > 0 ? self.title : NSLocalizedString(@"手机通讯录", nil);

    
//    if (self.allowAddPeople) {
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
//                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
//                                                  target:self
//                                                  action:@selector(showNewPersonViewController)];
//    }
    
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(addressBookDidChangeNotification:)
               name:ZLAddressBookDidChangeNotification
             object:nil];
}

- (void) doneButtonClicked:(id)sender
{
    ABAddressBookRef addressRef = ABAddressBookCreateWithOptions(NULL, NULL);

    NSMutableArray * inviteArr = [NSMutableArray array];
    
    for (NSString * recordId in self.selectedPeopleRecordID)
    {
        NSNumber * recordNumId = [NSNumber numberWithInteger:[recordId integerValue]];
                                
        NSString * name = [UICommon compositeNameForPerson:recordNumId withAddressBookRef:addressRef];
        
        NSArray * phones = [UICommon phonesArrForPerson:recordNumId withAddressBookRef:addressRef];
        
        Member * me = [Member new];
        
        me.name = name;
        
        me.recordId = recordNumId;
        
        if(phones.count > 1)
        {
            for (NSString * phone in phones)
            {
                for (NSNumber * phNum in self.selectedPeople) {
                    
                    if([[phNum stringValue] isEqualToString:phone])
                    {
                        me.mobile = phone;
                    }
                }
            }
        }
        else if(phones.count == 1)
        {
            me.mobile = phones[0];
        }
        
        [inviteArr addObject:me];
    }
    
    if ([self.icCreateGroupSecondController respondsToSelector:@selector(setInviteArr:)]) {
        
        NSMutableArray * allInvitedArr = [NSMutableArray array];
        
        NSMutableArray * inviteFromInnerArr = [NSMutableArray array];
        for (Member * m in _invitedArr)
        {
            if(!m.recordId)
            {
                [inviteFromInnerArr addObject:m];
            }
        }

        [allInvitedArr addObjectsFromArray:inviteArr];
        if(inviteFromInnerArr.count)
        {
            [allInvitedArr addObjectsFromArray:inviteFromInnerArr];
        }
        
        [self.icCreateGroupSecondController setValue:allInvitedArr forKey:@"inviteArr"];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;

        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (![parent isEqual:self.parentViewController]) {
        [self invokeReturnDelegate];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:ZLAddressBookDidChangeNotification
                object:nil];
}

#pragma mark - Action
+ (instancetype)presentPeoplePickerViewControllerForParentViewController:
                    (UIViewController *)parentViewController {
    UINavigationController *navController =
        [[UINavigationController alloc] init];
    ZLPeoplePickerViewController *peoplePicker =
        [[ZLPeoplePickerViewController alloc] init];
    [navController pushViewController:peoplePicker animated:NO];
    peoplePicker.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:peoplePicker
                             action:@selector(doneButtonAction:)];
    peoplePicker.delegate = parentViewController;
    [parentViewController presentViewController:navController
                                       animated:YES
                                     completion:nil];
    return peoplePicker;
}

- (void)doneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self invokeReturnDelegate];
}

- (void)refreshControlAction:(UIRefreshControl *)aRefreshControl {
    [aRefreshControl beginRefreshing];
    [self reloadData:^(BOOL succeeded, NSError *error) {
        [aRefreshControl endRefreshing];
    }];
}

- (void)addressBookDidChangeNotification:(NSNotification *)note {
    [self performSelector:@selector(reloadData) withObject:nil];
}

- (void)reloadData {
    [self reloadData:nil];
}

- (void)reloadData:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    __weak __typeof(self) weakSelf = self;
    if ([ZLAddressBook sharedInstance].contacts.count > 0) {
        [weakSelf
            setPartitionedContactsWithContacts:[ZLAddressBook sharedInstance]
                                                   .contacts];
        [weakSelf.tableView reloadData];
    }
    [[ZLAddressBook sharedInstance]
        loadContacts:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [weakSelf setPartitionedContactsWithContacts:
                              [ZLAddressBook sharedInstance].contacts];
                [weakSelf.tableView reloadData];
                if (completionBlock) {
                    completionBlock(YES, nil);
                }
            } else {
                if (completionBlock) {
                    completionBlock(NO, nil);
                }
            }
        }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar {
    [aSearchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    [aSearchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    [aSearchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    APContact *contact = [self contactForRowAtIndexPath:indexPath];

    if (![tableView isEqual:self.tableView]) {
        contact = [(ZLResultsTableViewController *)
                       self.searchController.searchResultsController
            contactForRowAtIndexPath:indexPath];
    }

    if (![self shouldEnableCellforContact:contact]) {
        return;
    }

    if (self.delegate &&
        [self.delegate
            respondsToSelector:@selector(peoplePickerViewController:
                                                    didSelectPerson:)]) {
        [self.delegate peoplePickerViewController:self
                                  didSelectPerson:contact.recordID];
    }
    if(contact.phones.count)
    {
        NSString * phoneStr = contact.phones[0];
        phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSNumber * phone = [NSNumber numberWithLongLong:[phoneStr longLongValue]];

        if ([self.selectedPeople containsObject:phone]) {
            [self.selectedPeople removeObject:phone];
        } else {
            if (self.selectedPeople.count < self.numberOfSelectedPeople) {
                [self.selectedPeople addObject:phone];
            }
        }
    }

    if ([self.selectedPeopleRecordID containsObject:contact.recordID]) {
        [self.selectedPeopleRecordID removeObject:contact.recordID];
    } else {
        if (self.selectedPeopleRecordID.count < self.numberOfSelectedPeople) {
            [self.selectedPeopleRecordID addObject:contact.recordID];
        }
    }

    //    NSLog(@"heree");
    
    [self setCountLbl];

    [tableView reloadData];
    [self.tableView reloadData];
}

- (void) setCountLbl
{
    if(self.selectedPeople.count)
    {
        _countLbl.hidden = NO;
        
        _countLbl.text = [NSString stringWithFormat:@"%ld", self.selectedPeople.count];
        
        CGFloat width = [UICommon getWidthFromLabel:_countLbl].width;
        
        if(width > 14)
        {
            _countLbl.width = width;
            _countLbl.height = width;
        }
        
        [_countLbl setRoundCorner:W(_countLbl)/ 2];
        
    }
    else
    {
        _countLbl.hidden = YES;
    }
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:
            (UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [[self.partitionedContacts
        valueForKeyPath:@"@unionOfArrays.self"] mutableCopy];

    // strip out all the leading and trailing spaces
    NSString *strippedStr =
        [searchText stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceCharacterSet]];

    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedStr.length > 0) {
        searchItems = [strippedStr componentsSeparatedByString:@" "];
    }
    // build all the "AND" expressions for each value in the searchString
    NSMutableArray *andMatchPredicates = [NSMutableArray array];

    for (NSString *searchString in searchItems) {
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];

        // TODO: match phone number matching

        // name field matching
        NSPredicate *finalPredicate = [NSPredicate
            predicateWithFormat:@"compositeName CONTAINS[c] %@", searchString];
        [searchItemsPredicate addObject:finalPredicate];

        NSPredicate *predicate =
            [NSPredicate predicateWithFormat:@"ANY SELF.emails CONTAINS[c] %@",
                                             searchString];
        [searchItemsPredicate addObject:predicate];

        predicate = [NSPredicate
            predicateWithFormat:@"ANY SELF.addresses.street CONTAINS[c] %@",
                                searchString];
        [searchItemsPredicate addObject:predicate];
        predicate = [NSPredicate
            predicateWithFormat:@"ANY SELF.addresses.city CONTAINS[c] %@",
                                searchString];
        [searchItemsPredicate addObject:predicate];
        predicate = [NSPredicate
            predicateWithFormat:@"ANY SELF.addresses.zip CONTAINS[c] %@",
                                searchString];
        [searchItemsPredicate addObject:predicate];
        predicate = [NSPredicate
            predicateWithFormat:@"ANY SELF.addresses.country CONTAINS[c] %@",
                                searchString];
        [searchItemsPredicate addObject:predicate];
        predicate = [NSPredicate
            predicateWithFormat:
                @"ANY SELF.addresses.countryCode CONTAINS[c] %@", searchString];
        [searchItemsPredicate addObject:predicate];

        //        NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc]
        //        init];
        //        [numFormatter setNumberStyle:NSNumberFormatterNoStyle];
        //        NSNumber *targetNumber = [numFormatter
        //        numberFromString:searchString];
        //        if (targetNumber != nil) {   // searchString may not convert
        //        to a number
        //            predicate = [NSPredicate predicateWithFormat:@"ANY
        //            SELF.sanitizePhones CONTAINS[c] %@", searchString];
        //            [searchItemsPredicate addObject:predicate];
        //        }

        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates =
            (NSCompoundPredicate *)[NSCompoundPredicate
                orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }

    NSCompoundPredicate *finalCompoundPredicate = nil;

    // match up the fields of the Product object
    finalCompoundPredicate = (NSCompoundPredicate *)
        [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];

    searchResults = [[searchResults
        filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];

    // hand over the filtered results to our search results table
    ZLResultsTableViewController *tableController =
        (ZLResultsTableViewController *)
            self.searchController.searchResultsController;
    tableController.filedMask = self.filedMask;
    tableController.selectedPeople = self.selectedPeople;  //momo
//    tableController.selectedPeople = self.selectedPeopleRecordID;
    
    [tableController setPartitionedContactsWithContacts:searchResults];
    [tableController.tableView reloadData];
}

#pragma mark - ABAdressBookUI

#pragma mark Create a new person
- (void)showNewPersonViewController {
    ABNewPersonViewController *picker =
        [[ABNewPersonViewController alloc] init];
    picker.newPersonViewDelegate = self;

    UINavigationController *navigation =
        [[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:navigation animated:YES completion:nil];
}
#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller.
- (void)newPersonViewController:
            (ABNewPersonViewController *)newPersonViewController
       didCompleteWithNewPerson:(ABRecordRef)person {
    [self dismissViewControllerAnimated:YES completion:NULL];
    if (self.delegate &&
        [self.delegate
         respondsToSelector:@selector(newPersonViewControllerDidCompleteWithNewPerson:)]) {
            [self.delegate newPersonViewControllerDidCompleteWithNewPerson:person];
         }
}

#pragma mark - ()
- (void)invokeReturnDelegate {
    if (self.delegate &&
        [self.delegate
            respondsToSelector:@selector(peoplePickerViewController:
                                        didReturnWithSelectedPeople:)]) {
                [self.delegate peoplePickerViewController:self
                              didReturnWithSelectedPeople:[self.selectedPeopleRecordID copy]];
//        [self.delegate peoplePickerViewController:self
//                      didReturnWithSelectedPeople:[self.selectedPeople copy]];
    }
}

@end
