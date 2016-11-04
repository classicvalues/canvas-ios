
//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import "UIImage+CanvasKit1.h"
#import "CKModelObject.h"

@implementation UIImage (CanvasKit1)
+ (instancetype)canvasKit1ImageNamed:(NSString *)name {
    static NSBundle *canvasKit1Bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        canvasKit1Bundle = [NSBundle bundleForClass:[CKModelObject class]];
    });
    return [self imageNamed:name inBundle:canvasKit1Bundle compatibleWithTraitCollection:nil];
}

@end
