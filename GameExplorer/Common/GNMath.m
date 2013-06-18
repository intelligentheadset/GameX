//
//  GNMath.m
//
//  Created by Martin Lobger on 27/09/12.
//  Copyright (c) 2012 GN. All rights reserved.
//

#import "GNMath.h"

double frand(double min, double max)
{
    int c;
    double f =  (max - min)*((double)(c = random()))/((double)LONG_MAX);
    
    return min + f;
}

