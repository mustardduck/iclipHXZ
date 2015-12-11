//
//  ZLBaseTableViewController.m
//  ZLPeoplePickerViewControllerDemo
//
//  Created by Zhixuan Lai on 11/5/14.
//  Copyright (c) 2014 Zhixuan Lai. All rights reserved.
//

#import "ZLBaseTableViewController.h"
#import "LRIndexedCollationWithSearch.h"

#import "APContact.h"
#import "APContact+Sorting.h"
#import "UICommon.h"

@implementation ZLBaseTableViewController

#pragma mark - Properties
- (NSMutableArray *)partitionedContacts {
    if (!_partitionedContacts) {
        _partitionedContacts = [[self emptyPartitionedArray] mutableCopy];
    }
    return _partitionedContacts;
}
- (NSMutableSet *)selectedPeople {
    if (!_selectedPeople) {
        _selectedPeople = [NSMutableSet set];
    }
    return _selectedPeople;
}

- (NSMutableSet *)selectedPeopleRecordID {
    if (!_selectedPeopleRecordID) {
        _selectedPeopleRecordID = [NSMutableSet set];
    }
    return _selectedPeopleRecordID;
}

- (void)setPartitionedContactsWithContacts:(NSArray *)contacts {
    self.partitionedContacts = [[self emptyPartitionedArray] mutableCopy];

    NSMutableSet *allPhoneNumbers = [NSMutableSet set];
    for (APContact *contact in contacts) {

        // only display one linked contacts        
        if(contact.phones && [contact.phones count] > 0 && ![allPhoneNumbers containsObject:contact.phones[0]]) {
            [allPhoneNumbers addObject:contact.phones[0]];
        }

        // add new contact
        SEL selector = @selector(lastName);
        if (contact.lastName.length == 0) {
            selector = @selector(compositeName);
        }
        NSInteger index = [[LRIndexedCollationWithSearch currentCollation]
                   sectionForObject:contact
            collationStringSelector:selector];
        // contact.sectionIndex = index;
        [self.partitionedContacts[index] addObject:contact];
    }

    // sort sections
    NSUInteger sectionCount =
        [[[LRIndexedCollationWithSearch currentCollation] sectionTitles] count];
    int sectionCountInt =
        [[NSNumber numberWithUnsignedInteger:sectionCount] intValue];
    for (NSInteger i = 0; i < sectionCountInt; i++) {
        NSArray *section = self.partitionedContacts[i];
        NSArray *sortedSectionByLastName =
            [[LRIndexedCollationWithSearch currentCollation]
                   sortedArrayFromArray:section
                collationStringSelector:@selector(lastNameOrCompositeName)];

        NSMutableArray *sortedSection = [NSMutableArray array];
        {
            NSMutableArray *subSection = [NSMutableArray array];
            NSString *currentLastName = [NSString string];
            for (int i = 0; i < sortedSectionByLastName.count; i++) {
                APContact *contact = (APContact *)sortedSectionByLastName[i];
                NSString *lastName = [contact lastNameOrCompositeName];

                if ([lastName isEqualToString:currentLastName]) {
                    [subSection addObject:contact];
                } else {
                    if (subSection.count > 0) {
                        NSArray *sortedSubSectionByFirstName =
                            [[LRIndexedCollationWithSearch currentCollation]
                                   sortedArrayFromArray:subSection
                                collationStringSelector:
                                    @selector(firstNameOrCompositeName)];
                        [sortedSection
                            addObjectsFromArray:sortedSubSectionByFirstName];
                        [subSection removeAllObjects];
                    }
                    currentLastName = lastName;
                    [subSection addObject:contact];
                }
            }

            NSArray *sortedSubSectionByFirstName = [
                [LRIndexedCollationWithSearch currentCollation]
                   sortedArrayFromArray:subSection
                collationStringSelector:@selector(firstNameOrCompositeName)];
            [sortedSection addObjectsFromArray:sortedSubSectionByFirstName];
        }

        self.partitionedContacts[i] = sortedSection;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 0;
    if (self.partitionedContacts.count > 0) {
        
        NSInteger count = [[[LRIndexedCollationWithSearch
                             currentCollation] sectionTitles] count];
        return count;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    if((NSInteger)[[self.partitionedContacts
                    objectAtIndex:(NSUInteger)section] count] != 0)
    {
        height = 24;
    }
    
    return height;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    myView.frame = CGRectMake(0, 0, SCREENWIDTH, 24);
    myView.backgroundColor = [UIColor colorWithRed:0.40 green:0.48 blue:0.94 alpha:1.0];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 90, 15)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    NSString * text = @"";
    if((NSInteger)[[self.partitionedContacts
                    objectAtIndex:(NSUInteger)section] count] != 0)
    {
        text = [[[LRIndexedCollationWithSearch currentCollation] sectionTitles]
         objectAtIndex:section];
    }

    titleLabel.text= text;
    [titleLabel setFont:[UIFont systemFontOfSize:10]];
    [myView addSubview:titleLabel];
    
    return myView;
}

//- (NSString *)tableView:(UITableView *)tableView
//    titleForHeaderInSection:(NSInteger)section {
//    if ((NSInteger)[[self.partitionedContacts
//            objectAtIndex:(NSUInteger)section] count] == 0) {
//        return @"";
//    }
//    return [[[LRIndexedCollationWithSearch currentCollation] sectionTitles]
//        objectAtIndex:section];
//}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[LRIndexedCollationWithSearch currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView
    sectionForSectionIndexTitle:(NSString *)title
                        atIndex:(NSInteger)index {
    NSInteger ret = [[LRIndexedCollationWithSearch currentCollation]
        sectionForSectionIndexTitleAtIndex:index];
    if (ret == NSNotFound) {
        [self.tableView
            setContentOffset:CGPointMake(0.0,
                                         -self.tableView.contentInset.top)];
    }
    return ret;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)[
        [self.partitionedContacts objectAtIndex:(NSUInteger)section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = (UITableViewCell *)
        [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

    if (cell == nil) {
        cell =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:kCellIdentifier];
        // cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        // cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    APContact *contact = [self contactForRowAtIndexPath:indexPath];
    [self configureCell:cell forContact:contact];

    if(contact.phones.count)
    {
        NSString * phoneStr = contact.phones[0];
        phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSNumber * phone = [NSNumber numberWithLongLong:[phoneStr longLongValue]];
        
        
        UIImageView* choseImg = [[UIImageView alloc] initWithFrame:CGRectMake(14, 30, 22, 22)];
        
        [cell.contentView addSubview:choseImg];
        
        UILabel* name= [cell viewWithTag:121];
        if(!name)
        {
            name = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 140, 22, 100, 15)];
            [name setBackgroundColor:[UIColor clearColor]];
            [name setTextColor:[UIColor grayTitleColor]];
            [name setFont:[UIFont systemFontOfSize:14]];
            name.tag = 121;
            [cell.contentView addSubview:name];
        }
        
        if ([self.selectedPeople containsObject:phone])
        {
            choseImg.image = [UIImage imageNamed:@"btn_xuanzhe_2"];
            
            if(![self.selectedPeopleRecordID containsObject:contact.recordID])
            {
                NSString * phoneStr = contact.phones[0];
                phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
                NSNumber * phone = [NSNumber numberWithLongLong:[phoneStr longLongValue]];
                if(![self.selectedPeople containsObject:phone])
                {
                    [self.selectedPeopleRecordID addObject:contact.recordID];
                }
            }
            
            [name setText:@"(已加入)"];
        }
        else
        {
            choseImg.image = [UIImage imageNamed:@"btn_xuanzhe_1"];
            [name setText:@""];

        }
//
//        if ([self.selectedPeople containsObject:phone]) {//contact.recordID
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        } else {
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        }
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

#pragma mark - ()
- (void)configureCell:(UITableViewCell *)cell forContact:(APContact *)contact {
    NSString *stringToHightlight =
        contact.lastName ? contact.lastName : contact.compositeName;
    NSRange rangeToHightlight =
        [contact.compositeName rangeOfString:stringToHightlight];
    NSMutableAttributedString *attributedString = [
        [NSMutableAttributedString alloc] initWithString:contact.compositeName];

    [attributedString beginEditing];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont boldSystemFontOfSize:18]
                             range:rangeToHightlight];
    if (![self shouldEnableCellforContact:contact]) {
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor grayColor]
                                 range:NSMakeRange(0, attributedString.length)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    [attributedString endEditing];

//    cell.textLabel.attributedText = attributedString;
    
    UILabel * titleLbl = [cell viewWithTag:100];
    
    if(!titleLbl)
    {
        titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(50, 18, SCREENWIDTH - 70, 20)];
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.font = Font(17);
        titleLbl.textColor = [UIColor whiteColor];
        titleLbl.tag = 100;
        [cell addSubview:titleLbl];
    }
    
    titleLbl.text = contact.compositeName;

    
    UILabel * phoneLbl = [cell viewWithTag:101];
    
    if(!phoneLbl)
    {
        phoneLbl = [[UILabel alloc] initWithFrame:CGRectMake(50, YH(titleLbl) + 10, SCREENWIDTH - 70, 14)];
        phoneLbl.backgroundColor = [UIColor clearColor];
        phoneLbl.font = Font(12);
        phoneLbl.textColor = [UIColor grayTitleColor];
        phoneLbl.tag = 101;
        [cell addSubview:phoneLbl];
    }
    
    if(contact.phones.count)
    {
        NSString * str = [contact.phones[0] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        phoneLbl.text = str;
    }
    cell.backgroundColor = [UIColor backgroundColor];
}

- (BOOL)shouldEnableCellforContact:(APContact *)contact {
    if(self.filedMask == ZLContactFieldAll) {
        return YES;
    }
    else {
    return ((self.filedMask & ZLContactFieldPhones) &&
            contact.phones.count > 0) ||
           ((self.filedMask & ZLContactFieldEmails) &&
            contact.emails.count > 0) ||
           ((self.filedMask & ZLContactFieldPhoto) && contact.thumbnail) ||
           ((self.filedMask & ZLContactFieldAddresses) &&
            contact.addresses.count > 0);
    }
}

- (APContact *)contactForRowAtIndexPath:(NSIndexPath *)indexPath {
    return
        [[self.partitionedContacts objectAtIndex:(NSUInteger)indexPath.section]
            objectAtIndex:(NSUInteger)indexPath.row];
}

- (NSMutableArray *)emptyPartitionedArray {
    NSUInteger sectionCount =
        [[[LRIndexedCollationWithSearch currentCollation] sectionTitles] count];
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    for (int i = 0; i < sectionCount; i++) {
        [sections addObject:[NSMutableArray array]];
    }
    return sections;
}

@end
