//
//  Constants.h
//  Dating
//
//  Created by Harsh Sharma on 1/5/15.
//  Copyright (c) 2015 IncredTechnologies. All rights reserved.
//

#ifndef Dating_Constants_h
#define Dating_Constants_h

#define _Alert_Title @"Yocty"

#define NO_INERNET_MSG @"No Internet Connection!"

#define User_Preferences_Dict [NSDictionary dictionaryWithObjects:@[@"smoker",@"non-vegetarian",@"religious",@"night_owl",@"adventurous",@"traveler",@"possessive",@"talker",@"sleeper",@"gamer",@"romantic",@"trust",@"sexy",@"foodie",@"entrepreneur",@"workaholic",@"gadgetfreak",@"hippy",@"hugger",@"gymrat",@"techie",@"fashionmonger",@"moviebuff",@"tvjunkie",@"shy",@"humour",@"peacelover",@"punctual",@"lazy",@"dreamer",@"flirtatious",@"cuddle"] forKeys:@[@"Smoker",@"Non Vegetarian",@"Religious",@"Night Owl",@"Adventurous",@"Traveller",@"Possesive",@"Talker",@"Sleeper",@"Gamer",@"Romantic",@"Trust",@"Sexy",@"Foodie",@"Entrepreneur",@"Workaholic",@"Gadget Freak",@"Hippy",@"Hugger",@"Gym Rat",@"Techie",@"Fashion Monger",@"Movie Buff",@"TV Junkie",@"Shy",@"Humour",@"Peace Lover",@"Punctual",@"Lazy",@"Dreamer",@"Flirtatious",@"Cuddler"]]

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define MAWN_HANDWRITING(fontSize) [UIFont fontWithName:@"MAWNSHandwriting" size:fontSize]

#endif
