//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjectFileNameSymbol.m
//|
//|             D.V.
//|             Copyright (c) 2014-2015 D.V. All rights reserved.
//|
//| Permission is hereby granted, free of charge, to any person obtaining a
//| copy of this software and associated documentation files (the "Software"),
//| to deal in the Software without restriction, including without limitation
//| the rights to use, copy, modify, merge, publish, distribute, sublicense,
//| and/or sell copies of the Software, and to permit persons to whom the
//| Software is furnished to do so, subject to the following conditions:
//|
//| The above copyright notice and this permission notice shall be included
//| in all copies or substantial portions of the Software.
//|
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------------//

#import "MKObjectFileNameSymbol.h"
#import "MKInternal.h"

//----------------------------------------------------------------------------//
@implementation MKObjectFileNameSymbol

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithEntry:(struct nlist_64)nlist
{
    if (self != MKObjectFileNameSymbol.class)
        return 0;
    
    return (nlist.n_type & N_STAB) != 0 && nlist.n_type == N_OSO ? 75 : 0;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (cpu_subtype_t)cpuSubType
{ return self.sect; }

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)modificationTime
{ return self.value; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKResult*)section
{
    // The 'n_sect' field is used to store the cpuSubType.  N_OSO stabs do not
    // have an associated section.
    return [MKResult result];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_sectFieldBuilder
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    MKNodeFieldBuilder *desc = [super _sectFieldBuilder];
#pragma clang diagnostic pop
    desc.alternateFieldName = MK_PROPERTY(cpuSubType);
    desc.options |= MKNodeFieldOptionShowAlternateFieldDescription | MKNodeFieldOptionSubstituteAlternateFieldValue;
    
    return desc;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldBuilder*)_valueFieldBuilder
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
    MKNodeFieldBuilder *value = [super _valueFieldBuilder];
#pragma clang diagnostic pop
    value.alternateFieldName = MK_PROPERTY(modificationTime);
    value.options |= MKNodeFieldOptionShowAlternateFieldDescription | MKNodeFieldOptionSubstituteAlternateFieldValue;
    
    return value;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *cpuSubType = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(cpuSubType)
        type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance // TODO
    ];
    cpuSubType.description = @"CPU SubType";
    cpuSubType.options = MKNodeFieldOptionHidden;
    
    MKNodeFieldBuilder *modificationTime = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(modificationTime)
        type:MKNodeFieldTypeQuadWord.sharedInstance
    ];
    modificationTime.description = @"Modification Time";
    modificationTime.options = MKNodeFieldOptionHidden;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        cpuSubType.build,
        modificationTime.build
    ]];
}

@end
