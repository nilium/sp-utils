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

#import "SPPromise.h"

@implementation SPPromise
{
  dispatch_queue_t _op_queue;
  SPPromiseBlock _block;
  BOOL _loaded;
  id _object;
}

@dynamic promise;

+ (id)promiseWithBlock:(SPPromiseBlock)block
{
  return [[self alloc] initWithBlock:block];
}

- (id)initWithBlock:(SPPromiseBlock)block
{
  _op_queue = dispatch_queue_create("net.spifftastic.promise", DISPATCH_QUEUE_SERIAL);
  _block = [block copy];
  _loaded = false;
  _object = nil;

  return self;
}

- (void)dealloc
{
  _block = nil;
}

- (id)promise
{
  dispatch_sync(_op_queue, ^{
    if ( ! _loaded) {
      _object = _block();
      _loaded = YES;
      _block = nil;
    }
  });

  return _object;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
  [invocation invokeWithTarget:self.promise];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
  return [self.promise methodSignatureForSelector:sel];
}

@end
