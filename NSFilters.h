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

#ifndef __SNOW_NSFILTERS_H__
#define __SNOW_NSFILTERS_H__

#import <Foundation/Foundation.h>

typedef id (^SPMapBlock)(id obj);
typedef BOOL (^SPFilterBlock)(id obj);
typedef id (^SPReduceBlock)(id memo, id obj);

extern const NSUInteger NSFiltersDefaultStride;

/*
All map/select/reject operations can be performed asynchronously (provided your
block is fine under those conditions). They will block execution of the calling
thread until complete - if you want to run them without blocking, use
dispatch_async to call them.

map blocks must return non-nil objects.

Async array map/reject/select will allow you to use an arbitrary stride. This
currently doesn't apply to the NSSet categories. By default, if you exclude the
stride, it will use the NSFiltersDefaultStride of 256.
*/

@interface NSArray (SPImmutableArrayFilters)

// map
- (NSArray *)mappedArrayUsingBlock:(SPMapBlock)block;
- (NSArray *)mappedArrayUsingBlock:(SPMapBlock)block queue:(dispatch_queue_t)queue;
- (NSArray *)mappedArrayUsingBlock:(SPMapBlock)block queue:(dispatch_queue_t)queue stride:(NSUInteger)stride;
// reject
- (NSArray *)rejectedArrayUsingBlock:(SPFilterBlock)block;
- (NSArray *)rejectedArrayUsingBlock:(SPFilterBlock)block queue:(dispatch_queue_t)queue;
- (NSArray *)rejectedArrayUsingBlock:(SPFilterBlock)block queue:(dispatch_queue_t)queue stride:(NSUInteger)stride;
// select
- (NSArray *)selectedArrayUsingBlock:(SPFilterBlock)block;
- (NSArray *)selectedArrayUsingBlock:(SPFilterBlock)block queue:(dispatch_queue_t)queue;
- (NSArray *)selectedArrayUsingBlock:(SPFilterBlock)block queue:(dispatch_queue_t)queue stride:(NSUInteger)stride;

// reduce
- (id)reduceWithInitialValue:(id)memo usingBlock:(SPReduceBlock)block;
// reduce (memo is nil)
- (id)reduceUsingBlock:(SPReduceBlock)block;

@end

@interface NSMutableArray (SPMutableArrayFilters)

// map
- (void)mapUsingBlock:(SPMapBlock)block;
- (void)mapUsingBlock:(SPMapBlock)block queue:(dispatch_queue_t)queue;
- (void)mapUsingBlock:(SPMapBlock)block queue:(dispatch_queue_t)queue stride:(NSUInteger)stride;
// reject
- (void)rejectUsingBlock:(SPFilterBlock)block;
- (void)rejectUsingBlock:(SPFilterBlock)block queue:(dispatch_queue_t)queue;
- (void)rejectUsingBlock:(SPFilterBlock)block queue:(dispatch_queue_t)queue stride:(NSUInteger)stride;
// select
- (void)selectUsingBlock:(SPFilterBlock)block;
- (void)selectUsingBlock:(SPFilterBlock)block queue:(dispatch_queue_t)queue;
- (void)selectUsingBlock:(SPFilterBlock)block queue:(dispatch_queue_t)queue stride:(NSUInteger)stride;

@end

@interface NSSet (SPImmutableSetFilters)

// map
- (NSSet *)mappedSetUsingBlock:(SPMapBlock)block;
- (NSSet *)mappedSetUsingBlock:(SPMapBlock)block queue:(dispatch_queue_t)queue;
// reject
- (NSSet *)rejectedSetUsingBlock:(SPFilterBlock)block;
- (NSSet *)rejectedSetUsingBlock:(SPFilterBlock)block queue:(dispatch_queue_t)queue;
// select
- (NSSet *)selectedSetUsingBlock:(SPFilterBlock)block;
- (NSSet *)selectedSetUsingBlock:(SPFilterBlock)block queue:(dispatch_queue_t)queue;

// reduce
- (id)reduceWithInitialValue:(id)memo usingBlock:(SPReduceBlock)block;
// reduce (memo is nil)
- (id)reduceUsingBlock:(SPReduceBlock)block;

@end

@interface NSMutableSet (SPMutableSetFilters)

// map
- (void)mapUsingBlock:(SPMapBlock)block;
- (void)mapUsingBlock:(SPMapBlock)block queue:(dispatch_queue_t)queue;
// reject
- (void)rejectUsingBlock:(SPFilterBlock)block;
- (void)rejectUsingBlock:(SPFilterBlock)block queue:(dispatch_queue_t)queue;
// select
- (void)selectUsingBlock:(SPFilterBlock)block;
- (void)selectUsingBlock:(SPFilterBlock)block queue:(dispatch_queue_t)queue;

@end

#endif /* end __SNOW_NSFILTERS_H__ include guard */

