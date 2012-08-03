/*
Copyright (c) 2012 Noel Cower

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#import "NSArray+Filters.h"

static NSString *const SPNilObjectMappingException = @"SPNilObjectMappingException";
static NSString *const SPNilObjectMappingExceptionReason = @"Objects returned by map blocks must not be nil.";
static NSString *const SPNoMemoryException = @"SPNoMemoryException";
static NSString *const SPNoMemoryExceptionReason = @"Unable to allocate objects array.";

@implementation NSArray (SPImmutableFilters)

- (NSArray *)mappedArrayUsingBlock:(SPMapBlock)block
{
  NSArray *result = nil;
  __unsafe_unretained id *objects = NULL;
  NSUInteger index = 0;
  const NSUInteger self_len = [self count];
  const NSRange range = NSMakeRange(0, self_len);

  if (self_len == 0)
    return [self copy];

  objects = (__unsafe_unretained id *)malloc(sizeof(id) * self_len);

  if (objects == NULL) {
    @throw [NSException exceptionWithName:SPNoMemoryException
                                   reason:SPNoMemoryExceptionReason
                                 userInfo:nil];
    return nil;
  }

  [self getObjects:objects range:range];

  for (index = 0; index < self_len; ++index)
    if ( ! (objects[index] = block(objects[index])))
      @throw [NSException exceptionWithName:SPNilObjectMappingException
                                     reason:SPNilObjectMappingExceptionReason
                                   userInfo:nil];

  result = [NSArray arrayWithObjects:objects count:self_len];

  free(objects);

  return result;
}

- (NSArray *)rejectedArrayUsingBlock:(SPFilterBlock)block
{
  NSArray *result = nil;
  __unsafe_unretained id *objects = NULL;
  NSUInteger index_filtered = 0;
  NSUInteger index = 0;
  const NSUInteger self_len = [self count];
  const NSRange range = NSMakeRange(0, self_len);

  if (self_len == 0)
    return [self copy];

  objects = (__unsafe_unretained id *)malloc(sizeof(id) * self_len);

  if (objects == NULL) {
    @throw [NSException exceptionWithName:SPNoMemoryException
                                   reason:SPNoMemoryExceptionReason
                                 userInfo:nil];
    return nil;
  }

  [self getObjects:objects range:range];

  for (index = 0, index_filtered = 0; index < self_len; ++index) {
    BOOL filter = block(objects[index]);

    if (filter) {
      objects[index] = NULL;
    } else {
      if (index != index_filtered)
        objects[index_filtered] = objects[index];

      ++index_filtered;
    }
  }

  result = [NSArray arrayWithObjects:objects count:index_filtered];

  free(objects);

  return result;
}

- (NSArray *)selectedArrayUsingBlock:(SPFilterBlock)block
{
  NSArray *result = nil;
  __unsafe_unretained id *objects = NULL;
  NSUInteger index_filtered = 0;
  NSUInteger index = 0;
  const NSUInteger self_len = [self count];
  const NSRange range = NSMakeRange(0, self_len);

  if (self_len == 0)
    return [self copy];

  objects = (__unsafe_unretained id *)malloc(sizeof(id) * self_len);

  if (objects == NULL) {
    @throw [NSException exceptionWithName:SPNoMemoryException
                                   reason:SPNoMemoryExceptionReason
                                 userInfo:nil];
    return nil;
  }

  [self getObjects:objects range:range];

  for (index = 0, index_filtered = 0; index < self_len; ++index) {
    BOOL filter = block(objects[index]);

    if (!filter) {
      objects[index] = NULL;
    } else {
      if (index != index_filtered)
        objects[index_filtered] = objects[index];

      ++index_filtered;
    }
  }

  result = [NSArray arrayWithObjects:objects count:index_filtered];

  free(objects);

  return result;
}

- (id)reduceWithInitialValue:(id)memo usingBlock:(SPReduceBlock)block
{
  __unsafe_unretained id *objects = NULL;
  NSUInteger index = 0;
  const NSUInteger self_len = [self count];
  const NSRange range = NSMakeRange(0, self_len);

  if (self_len == 0)
    return nil;

  objects = (__unsafe_unretained id *)malloc(sizeof(id) * self_len);

  if (objects == NULL) {
    @throw [NSException exceptionWithName:SPNoMemoryException
                                   reason:SPNoMemoryExceptionReason
                                 userInfo:nil];
    return nil;
  }

  [self getObjects:objects range:range];

  if (memo == nil) {
    memo = objects[0];
    index = 1;
  }

  for (; index < self_len; ++index)
    memo = block(memo, objects[index]);

  return memo;
}

- (id)reduceUsingBlock:(SPReduceBlock)block
{
  return [self reduceWithInitialValue:nil usingBlock:block];
}

@end

@implementation NSMutableArray (SPMutableFilters)

- (void)mapUsingBlock:(SPMapBlock)block
{
  __unsafe_unretained id *objects = NULL;
  NSUInteger index = 0;
  const NSUInteger self_len = [self count];
  const NSRange range = NSMakeRange(0, self_len);

  if (self_len == 0)
    return;

  objects = (__unsafe_unretained id *)malloc(sizeof(id) * self_len);

  if (objects == NULL) {
    @throw [NSException exceptionWithName:SPNoMemoryException
                                   reason:SPNoMemoryExceptionReason
                                 userInfo:nil];
    return;
  }

  [self getObjects:objects range:range];

  for (index = 0; index < self_len; ++index)
    if ( ! (objects[index] = block(objects[index])))
      @throw [NSException exceptionWithName:SPNilObjectMappingException
                                     reason:SPNilObjectMappingExceptionReason
                                   userInfo:nil];

  for (index = 0; index < self_len; ++index)
    [self replaceObjectAtIndex:index withObject:objects[index]];

  free(objects);
}

- (void)rejectUsingBlock:(SPFilterBlock)block
{
  __unsafe_unretained id *objects = NULL;
  NSUInteger index = 0;
  NSMutableIndexSet *indices = nil;
  const NSUInteger self_len = [self count];
  const NSRange range = NSMakeRange(0, self_len);

  if (self_len == 0)
    return;

  objects = (__unsafe_unretained id *)malloc(sizeof(id) * self_len);

  if (objects == NULL) {
    @throw [NSException exceptionWithName:SPNoMemoryException
                                   reason:SPNoMemoryExceptionReason
                                 userInfo:nil];
    return;
  }

  indices = [NSMutableIndexSet indexSet];
  [self getObjects:objects range:range];

  for (index = 0; index < self_len; ++index)
    if (block(objects[index]))
      [indices addIndex:index];

  [self removeObjectsAtIndexes:indices];

  free(objects);
}

- (void)selectUsingBlock:(SPFilterBlock)block
{
  __unsafe_unretained id *objects = NULL;
  NSUInteger index = 0;
  NSMutableIndexSet *indices = nil;
  const NSUInteger self_len = [self count];
  const NSRange range = NSMakeRange(0, self_len);

  if (self_len == 0)
    return;

  objects = (__unsafe_unretained id *)malloc(sizeof(id) * self_len);

  if (objects == NULL) {
    @throw [NSException exceptionWithName:SPNoMemoryException
                                   reason:SPNoMemoryExceptionReason
                                 userInfo:nil];
    return;
  }

  indices = [NSMutableIndexSet indexSet];
  [self getObjects:objects range:range];

  for (index = 0; index < self_len; ++index)
    if ( ! block(objects[index]))
      [indices addIndex:index];

  [self removeObjectsAtIndexes:indices];

  free(objects);
}

@end
