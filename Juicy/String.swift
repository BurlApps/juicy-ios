//
//  String.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/20/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import Foundation

extension String {
    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }
}

//-(NSString*) suffixNumber:(NSNumber*)number
//{
//    if (!number)
//    return @"";
//    
//    long long num = [number longLongValue];
//    
//    int s = ( (num < 0) ? -1 : (num > 0) ? 1 : 0 );
//    NSString* sign = (s == -1 ? @"-" : @"" );
//    
//    num = llabs(num);
//    
//    if (num < 1000)
//    return [NSString stringWithFormat:@"%@%lld",sign,num];
//    
//    int exp = (int) (log(num) / log(1000));
//    
//    NSArray* units = @[@"K",@"M",@"G",@"T",@"P",@"E"];
//    
//    return [NSString stringWithFormat:@"%@%.1f%@",sign, (num / pow(1000, exp)), [units objectAtIndex:(exp-1)]];
//}