//
//  TextureManager.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 10/05/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "TextureManager.h"
#import "SPView+ShareGroup.h"
#import "ThreadSafetyManager.h"
#import "Globals.h"

#define TM_RESERVED_CATEGORY @"_TMShared_"

@interface TextureManager ()

- (void)setAtlasCheckout:(AtlasCheckout *)co  name:(NSString *)name category:(NSString *)category;
- (void)removeAtlasCheckoutForName:(NSString *)name category:(NSString *)category;
- (NSArray *)mergeWithSharedCategory:(NSString *)category;
- (AtlasCheckout *)atlasCheckoutForName:(NSString *)name category:(NSString *)category;
- (AtlasCheckout *)atlasCheckoutForName:(NSString *)name categories:(NSArray *)categories;
- (AtlasCheckout *)retrieveCachedAtlasCheckoutByName:(NSString *)name;
- (AtlasCheckout *)persistentAtlasCheckoutByName:(NSString *)name;
- (AtlasCheckout *)permanentAtlasCheckoutByName:(NSString *)name;
- (void)queueCheckout:(AtlasCheckout *)checkout;
- (void)dequeueCheckouts;
- (void)notifyOfAtlasCheckout:(NSDictionary *)args;
- (void)asyncCheckoutAtlas:(NSDictionary *)args;

@end


@implementation TextureManager

@synthesize memoryMode = mMemoryMode;
@synthesize debugEnabled = mDebugEnabled;

- (id)initWithView:(SPView *)view
{
	return [self initWithView:view memoryMode:TMMemModeConservative];
}

- (id)initWithView:(SPView *)view memoryMode:(TMMemMode)mode
{
	if (self = [super init])
	{
		mView = [view retain];
		mMemoryMode = mode;
		mDebugEnabled = YES;
		mCheckouts = [[NSMutableDictionary alloc] init];
		mTextureCache = [[NSMutableDictionary alloc] init];
		mQueuedCheckouts = [[NSMutableSet alloc] init];
		mPersistentCheckouts = [[NSMutableSet alloc] init];
		mPermanentCheckouts = [[NSMutableSet alloc] init];
	}
	return self;
}

- (void)dealloc
{
	@synchronized(mQueuedCheckouts)
	{
		[mQueuedCheckouts release];
	}
	
	[mPermanentCheckouts release];
	[mPersistentCheckouts release];
	[mCheckouts release];
	[mTextureCache release];
	[mView release];
	[super dealloc];
}

- (void)setAtlasCheckout:(AtlasCheckout *)co name:(NSString *)name category:(NSString *)category
{
	assert(co && category && name);
	NSMutableDictionary *catDict = [mCheckouts objectForKey:category];
	
	if (catDict == nil)
	{
		catDict = [NSMutableDictionary dictionary];
		[mCheckouts setObject:catDict forKey:category];
	}
	
	[catDict setObject:co forKey:name];
}

- (void)removeAtlasCheckoutForName:(NSString *)name category:(NSString *)category
{
	NSMutableDictionary *catDict = [mCheckouts objectForKey:category];
	
	if (catDict)
	{
		AtlasCheckout *co = [catDict objectForKey:name];
		
		if (co)
		{
			[[co retain] autorelease];
			[catDict removeObjectForKey:name];
		}
		
		if (catDict.count == 0)
		{
			[[catDict retain] autorelease];
			[mCheckouts removeObjectForKey:category];
		}
	}
}

- (NSArray *)mergeWithSharedCategory:(NSString *)category
{
	NSArray *categories = nil;
	
	if (category)
		categories = [NSArray arrayWithObjects:category,TM_RESERVED_CATEGORY,nil];
	else
		categories = [NSArray arrayWithObjects:TM_RESERVED_CATEGORY,nil];
	return categories;
}

- (AtlasCheckout *)atlasCheckoutForName:(NSString *)name category:(NSString *)category
{
	AtlasCheckout *co = nil;
	NSString *cat = (category) ? category : TM_RESERVED_CATEGORY;
	
	NSDictionary *catDict = (NSDictionary *)[mCheckouts objectForKey:cat];
	
	if (catDict)
		co = (AtlasCheckout *)[catDict objectForKey:name];
	return co;
}

- (AtlasCheckout *)atlasCheckoutForName:(NSString *)name categories:(NSArray *)categories
{
	AtlasCheckout *co = nil;
	
	for (NSString *catKey in categories)
	{
		co = [self atlasCheckoutForName:name category:catKey];
		
		if (co)
			break;
	}

	return co;
}

- (AtlasCheckout *)retrieveCachedAtlasCheckoutByName:(NSString *)name {
	NSMutableSet *cache = mPersistentCheckouts;
	AtlasCheckout *co = [self persistentAtlasCheckoutByName:name];
	
	if (co == nil) {
		cache = mPermanentCheckouts;
		co = [self permanentAtlasCheckoutByName:name];
	}
	
	if (co != nil) {
		[[co retain] autorelease];
		[cache removeObject:co];
	}
	return co;
}

- (SPTexture *)cachedTextureByName:(NSString *)name {
	return [mTextureCache objectForKey:name];
}

- (void)cacheTexture:(SPTexture *)texture byName:(NSString *)name {
	[mTextureCache setObject:texture forKey:name];
}

- (void)emptyTextureCache {
	[mTextureCache removeAllObjects];
}

- (SPTexture *)textureByName:(NSString *)name category:(NSString *)category
{
	SPTexture *texture = [mTextureCache objectForKey:name];
	
	if (texture == nil)
		texture = [self textureByName:name atlasName:nil category:category];
	return texture;
}

- (SPTexture *)textureByName:(NSString *)name atlasName:(NSString *)atlasName category:(NSString *)category
{
	return [self textureByName:name atlasName:atlasName cacheGroup:nil category:nil];
}

- (SPTexture *)textureByName:(NSString *)name cacheGroup:(NSString *)groupName category:(NSString *)category
{
	return [self textureByName:name atlasName:nil cacheGroup:groupName category:category];
}

- (SPTexture *)textureByName:(NSString *)name atlasName:(NSString *)atlasName cacheGroup:(NSString *)groupName category:(NSString *)category
{
	SPTexture *texture = nil;
	NSArray *keys = nil;
	NSArray *categories = [self mergeWithSharedCategory:category];
	
	if (atlasName != nil)
		keys = [NSArray arrayWithObject:atlasName];
	
	for (NSString *catKey in categories)
	{
		NSArray *atlasKeys = keys;
		
		if (atlasKeys == nil) {
			NSDictionary *catDict = [mCheckouts objectForKey:catKey];
			atlasKeys = [catDict allKeys];
		}
		
		for (NSString *atlasKey in atlasKeys)
		{
			AtlasCheckout *co = [self atlasCheckoutForName:atlasKey category:catKey];
			texture = [co textureByName:name cacheGroup:groupName];
			
			if (texture != nil)
				break;
		}
		
		if (texture != nil)
			break;
	}
	
	if (texture == nil)
	{
		NSLog(@"Texture with name %@ was nil.", name);
		
		if (mDebugEnabled == YES)
			texture = [Globals debugTexture];
	}

	return texture;
}

- (NSArray *)texturesStartingWith:(NSString *)name category:(NSString *)category
{
	return [self texturesStartingWith:name atlasName:nil category:category];
}

- (NSArray *)texturesStartingWith:(NSString *)name atlasName:(NSString *)atlasName category:(NSString *)category
{
	return [self texturesStartingWith:name atlasName:atlasName cacheGroup:nil category:category];
}

- (NSArray *)texturesStartingWith:(NSString *)name cacheGroup:(NSString *)groupName category:(NSString *)category
{
	return [self texturesStartingWith:name atlasName:nil cacheGroup:groupName category:category];
}

- (NSArray *)texturesStartingWith:(NSString *)name atlasName:(NSString *)atlasName cacheGroup:(NSString *)groupName category:(NSString *)category
{
	NSArray *textures = nil;
	NSArray *keys = nil;
	NSArray *categories = [self mergeWithSharedCategory:category];
	
	if (atlasName != nil)
		keys = [NSArray arrayWithObject:atlasName];
	
	for (NSString *catKey in categories)
	{
		NSArray *atlasKeys = keys;
		
		if (atlasKeys == nil) {
			NSDictionary *catDict = [mCheckouts objectForKey:catKey];
			atlasKeys = [catDict allKeys];
		}
		
		for (NSString *atlasKey in atlasKeys)
		{
			AtlasCheckout *co = [self atlasCheckoutForName:atlasKey category:catKey];
			textures = [co texturesStartingWith:name cacheGroup:groupName];
			
			if (textures && textures.count > 0)
				break;
		}
		
		if (textures && textures.count > 0)
			break;
	}
	
	if (textures == nil || textures.count == 0)
	{
		NSLog(@"Textures with prefix %@ was nil.", name);
		
		if (mDebugEnabled == YES)
			textures = [NSArray arrayWithObject:[Globals debugTexture]];
	}
	
	return textures;
}

// Atlases
- (SPTextureAtlas *)atlasByName:(NSString *)name category:(NSString *)category
{
	if (name == nil)
		return nil;
	SPTextureAtlas *atlas = nil;
	NSArray *categories = [self mergeWithSharedCategory:category];
	AtlasCheckout *co = [self atlasCheckoutForName:name categories:categories];
	
	if (co)
		atlas = co.atlas;
	return atlas;
}

- (void)setFlags:(int)flags forAtlasNamed:(NSString *)name inCategory:(NSString *)category
{
	if (name == nil)
		return;
	NSString *cat = (category) ? category : TM_RESERVED_CATEGORY;
	NSDictionary *catDict = [mCheckouts objectForKey:cat];
	
	if (catDict)
	{
		AtlasCheckout *co = [catDict objectForKey:name];
		co.flags = flags;
	}
}

- (AtlasCheckout *)persistentAtlasCheckoutByName:(NSString *)name
{
	AtlasCheckout *persistentAtlas = nil;
	
	for (AtlasCheckout *co in mPersistentCheckouts) {
		if ([co.name isEqualToString:name]) {
			persistentAtlas = co;
			break;
		}
	}
	return persistentAtlas;
}

- (AtlasCheckout *)permanentAtlasCheckoutByName:(NSString *)name
{
	AtlasCheckout *permanentAtlas = nil;
	
	for (AtlasCheckout *co in mPermanentCheckouts) {
		if ([co.name isEqualToString:name]) {
			permanentAtlas = co;
			break;
		}
	}
	return permanentAtlas;
}

// Called from all threads but the main thread
- (void)queueCheckout:(AtlasCheckout *)checkout
{
	@synchronized(mQueuedCheckouts)
	{
		[mQueuedCheckouts addObject:checkout];
	}
}

// Only called from main thread
- (void)dequeueCheckouts
{
	NSMutableArray *array = nil;
	
	@synchronized(mQueuedCheckouts)
	{
		array = [NSMutableArray arrayWithCapacity:mCheckouts.count];
		
		for (AtlasCheckout *checkout in mQueuedCheckouts)
			[array addObject:checkout];
		[mQueuedCheckouts removeAllObjects];
	}
	
	for (AtlasCheckout *co in array)
		[self setAtlasCheckout:co name:co.name category:co.category];
}

- (void)checkoutAtlasByName:(NSString *)name category:(NSString *)category;
{
	[self checkoutAtlasByName:name path:name category:category];
}

- (void)checkoutAtlasByName:(NSString *)name path:(NSString *)path category:(NSString *)category;
{
	
	NSArray *categories = [self mergeWithSharedCategory:category];
	NSString *masterCat = [categories objectAtIndex:0];
	AtlasCheckout *co = [self atlasCheckoutForName:name categories:categories];
	
	if (co == nil) {
		co = [self retrieveCachedAtlasCheckoutByName:name];
		
		if (co)
			[self setAtlasCheckout:co name:name category:masterCat];
	}
	
	if (co == nil)
	{
		co = [[AtlasCheckout alloc] initWithCategory:masterCat name:name path:path];
		[self setAtlasCheckout:co name:name category:masterCat];
		[co release];
		co = nil;
	}
	else
		[co checkout];

	NSLog(@"Atlas Checkout: %@", name);
}

- (void)checkoutAtlasByName:(NSString *)name category:(NSString *)category caller:(id)caller callback:(NSString *)callback
{
	[self checkoutAtlasByName:name path:name category:category caller:caller callback:callback];
}

- (void)notifyOfAtlasCheckout:(NSDictionary *)args
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	id caller = [args objectForKey:@"caller"];
	[caller performSelectorOnMainThread:NSSelectorFromString([args objectForKey:@"callback"])
																withObject:[args objectForKey:@"atlasName"]
															 waitUntilDone:YES];
	[pool release];
}

- (void)asyncCheckoutAtlas:(NSDictionary *)args
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *category = [args objectForKey:@"category"];
	NSString *atlasName = [args objectForKey:@"atlasName"];
	NSString *path = [args objectForKey:@"path"];
	EAGLContext *context = (EAGLContext *)[args objectForKey:@"context"];

#ifdef CC_THREADED_MEMORY_POOLING
	[[NSThread currentThread] setName:@"Loading"];
	[[ThreadSafetyManager threadSafetyManager] threadDidStartWithName:[[NSThread currentThread] name]];
#endif

	if (context != nil)
	{
		[EAGLContext setCurrentContext:context];
		
		AtlasCheckout *checkout = [[AtlasCheckout alloc] initWithCategory:category name:atlasName path:path];
		[self queueCheckout:checkout];
		[checkout release];
		checkout = nil;
		
		[self performSelectorOnMainThread:@selector(dequeueCheckouts) withObject:nil waitUntilDone:YES];
		
		glFlush();
		[EAGLContext setCurrentContext:nil];
	}
	else
		atlasName = nil; // Caller interprets as error
	
#ifdef CC_THREADED_MEMORY_POOLING
	[pool release]; // We want the memory pools drained before we checkin our thread name and access the pools from a new thread.
	
	pool = [[NSAutoreleasePool alloc] init];
	
	[[ThreadSafetyManager threadSafetyManager] threadWillExitWithName:[[NSThread currentThread] name]];
	[(NSObject *)[args objectForKey:@"caller"] performSelectorOnMainThread:NSSelectorFromString([args objectForKey:@"callback"])
																withObject:[args objectForKey:@"atlasName"]
															 waitUntilDone:YES];
	[pool release];
#else
	[(NSObject *)[args objectForKey:@"caller"] performSelectorOnMainThread:NSSelectorFromString([args objectForKey:@"callback"])
																withObject:[args objectForKey:@"atlasName"]
															 waitUntilDone:YES];
	[pool release];
#endif
}

- (void)checkoutAtlasByName:(NSString *)name path:(NSString *)path category:(NSString *)category caller:(id)caller callback:(NSString *)callback
{
	assert(name && path && caller && callback);
	NSArray *categories = [self mergeWithSharedCategory:category];
	NSString *masterCat = [categories objectAtIndex:0];
	AtlasCheckout *co = [self atlasCheckoutForName:name categories:categories];
	
	if (co == nil)
		co = [self retrieveCachedAtlasCheckoutByName:name];
		
	if (co != nil)
	{
		[self setAtlasCheckout:co name:name category:masterCat];
		[co checkout];
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  caller, @"caller",
							  callback, @"callback",
							  name, @"atlasName",
							  nil];
		[NSThread detachNewThreadSelector:@selector(notifyOfAtlasCheckout:) toTarget:self withObject:dict];
	}
	else
	{
		NSLog(@"Atlas Checkout: %@", name);
		EAGLContext *context = [mView shareGroupContext]; // TODO: check for nil and send error to caller
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  context, @"context",
							  caller, @"caller",
							  callback, @"callback",
							  path, @"path",
							  name, @"atlasName",
							  category, @"category",
							  nil];
		[NSThread detachNewThreadSelector:@selector(asyncCheckoutAtlas:) toTarget:self withObject:dict];
	}
}

- (void)checkinAtlasByName:(NSString *)name category:(NSString *)category;
{
	NSArray *categories = [self mergeWithSharedCategory:category];
	AtlasCheckout *co = [self atlasCheckoutForName:name categories:categories];
	
	if (co != nil)
	{
		[co checkin];
		
		if (co.checkoutCount == 0 && mMemoryMode == TMMemModeConservative) {
			if (co.flags & TM_FLAG_PERSISTENT_ATLAS)
				[mPersistentCheckouts addObject:co];
			if (co.flags & TM_FLAG_PERMANENT_ATLAS)
				[mPermanentCheckouts addObject:co];
			[self purgeAtlasNamed:name category:co.category];
		}
	}
}

- (void)purgeAtlasNamed:(NSString *)name category:(NSString *)category;
{
	[self removeAtlasCheckoutForName:name category:category];
}

- (void)purgeAtlases
{
	[mCheckouts removeAllObjects];
}

- (void)purgeUnusedAtlases
{
	NSMutableArray *idleAtlases = [[NSMutableArray alloc] initWithCapacity:mCheckouts.count];
	
	for (NSString *catKey in mCheckouts)
	{
		NSDictionary *catDict = [mCheckouts objectForKey:catKey];
		
		for (NSString *atlasKey in catDict)
		{
			AtlasCheckout *co = [self atlasCheckoutForName:atlasKey category:catKey];
			
			if (co.checkoutCount == 0) {
				if (co.flags & TM_FLAG_PERSISTENT_ATLAS)
					[mPersistentCheckouts addObject:co];
				if (co.flags & TM_FLAG_PERMANENT_ATLAS)
					[mPermanentCheckouts addObject:co];
				[idleAtlases addObject:co];
			}
		}
	}
	
	for (AtlasCheckout *co in idleAtlases)
		[self removeAtlasCheckoutForName:co.name category:co.category];
	[idleAtlases release];
}

- (void)purgePersistentAtlases {
	[mPersistentCheckouts removeAllObjects];
}

@end

// -----------------------------------------------------------------------------------------

@implementation AtlasCheckout

@synthesize category = mCategory;
@synthesize name = mName;
@synthesize flags = mFlags;
@synthesize checkoutCount = mCheckoutCount;
@synthesize atlas = mAtlas;

- (id)initWithCategory:(NSString *)category name:(NSString *)name path:(NSString *)path
{
	if (self = [super init]) {
		mCategory = [category copy];
		mName = [name copy];
		mFlags = 0;
		mCheckoutCount = 1;
		mAtlas = [[SPTextureAtlas alloc] initWithContentsOfFile:path];
		mTextureCacheGroups = nil;
		mAnimCacheGroups = nil;
		NSLog(@"+++++++++++ Atlas created with path: %@ +++++++++++", path);
	}
	return self;
}

- (id)init
{
	[self release];
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:@"- init is not a valid initialier for class AtlasCheckout"
								 userInfo:nil];
	return nil;
}

- (void)dealloc
{
	if (mCheckoutCount != 0)
		[NSException raise:TM_EXC_INVALID_ATLAS_RELEASE format:@"Attempt to purge atlas while it is still in use."];
	//NSLog(@"---------- DEALLOC'ING AtlasCheckout: %@ -----------", mName);
	[mCategory release];
	[mName release];
	[mTextureCacheGroups release];
	[mAnimCacheGroups release];
	[mAtlas release];
	[super dealloc];
}

- (void)setFlags:(int)flags
{
	mFlags = flags;
	
	if ((mFlags & TM_FLAG_CACHE_ALL_TEX) == 0)
		[self clearTextureCacheGroup:TM_CACHE_ALL_TEX_GROUP_NAME];
	if ((mFlags & TM_FLAG_CACHE_ALL_ANIM) == 0)
		[self clearAnimCacheGroup:TM_CACHE_ALL_ANIM_GROUP_NAME];
		
}

- (void)checkout
{
	++mCheckoutCount;
}

- (void)checkin
{
	if (mCheckoutCount == 0)
		[NSException raise:TM_EXC_ATLAS_CHECKIN_EXCEEDED format:@"Attempt to checkin an atlas that was not checked out."];
	else
		--mCheckoutCount;
}

- (void)clearTextureCacheGroup:(NSString *)groupName
{
	if (mTextureCacheGroups && [mTextureCacheGroups objectForKey:groupName] != nil)
		[mTextureCacheGroups removeObjectForKey:groupName];
}
		
- (void)clearAnimCacheGroup:(NSString *)groupName
{
	if (mAnimCacheGroups && [mAnimCacheGroups objectForKey:groupName] != nil)
		[mAnimCacheGroups removeObjectForKey:groupName];
}

- (SPTexture *)textureByName:(NSString *)name
{
	return [self textureByName:name cacheGroup:nil];
}

- (SPTexture *)textureByName:(NSString *)name cacheGroup:(NSString *)groupName
{
	if (name == nil)
		return nil;
	NSString *gName = groupName;
	SPTexture *texture = nil;
	
	if (gName == nil)
	{
		if (mFlags & TM_FLAG_CACHE_ALL_TEX)
			gName = TM_CACHE_ALL_TEX_GROUP_NAME;
		
		if (gName == nil)
		{
			texture = [mAtlas textureByName:name];
			return texture;
		}
	}
	
	if (mTextureCacheGroups == nil)
		mTextureCacheGroups = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *cacheGroup = [mTextureCacheGroups objectForKey:gName];
	
	if (cacheGroup == nil)
	{
		texture = [mAtlas textureByName:name];
		
		if (texture)
		{
			cacheGroup = [NSMutableDictionary dictionaryWithObject:texture forKey:name];
			[mTextureCacheGroups setValue:cacheGroup forKey:gName];
		}
	} 
	else
	{
		texture = [cacheGroup objectForKey:name];
		
		if (texture == nil)
		{
			texture = [mAtlas textureByName:name];
			
			if (texture)
				[cacheGroup setValue:texture forKey:name];
		}
	}
	return texture;
}

- (NSArray *)texturesStartingWith:(NSString *)name
{
	return [self texturesStartingWith:name cacheGroup:nil];
}

- (NSArray *)texturesStartingWith:(NSString *)name cacheGroup:(NSString *)groupName
{
	if (name == nil)
		return nil;
	NSString *gName = groupName;
	NSArray *textures = nil;
	
	if (gName == nil)
	{
		if (mFlags & TM_FLAG_CACHE_ALL_ANIM)
			gName = TM_CACHE_ALL_ANIM_GROUP_NAME;
		
		if (gName == nil)
		{
			textures = [mAtlas texturesStartingWith:name];
			return textures;
		}
	}
	
	if (mAnimCacheGroups == nil)
		mAnimCacheGroups = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *cacheGroup = [mAnimCacheGroups objectForKey:gName];
	
	if (cacheGroup == nil)
	{
		textures = [mAtlas texturesStartingWith:name];
		
		if (textures && textures.count > 0)
		{
			cacheGroup = [NSMutableDictionary dictionaryWithObject:textures forKey:name];
			[mAnimCacheGroups setValue:cacheGroup forKey:gName];
		}
	} 
	else
	{
		textures = [cacheGroup objectForKey:name];
		
		if (textures == nil)
		{
			textures = [mAtlas texturesStartingWith:name];
			
			if (textures && textures.count > 0)
				[cacheGroup setValue:textures forKey:name];
		}
	}
	return textures;
}

@end




// --------------------------------------------------------------------------------------------------------




#if 0
- (void)checkoutAtlasByName:(NSString *)name path:(NSString *)path caller:(id)caller callback:(SEL)callback
{
	NSString *nameCopy = [name copy];
	NSString *pathCopy = [path copy];
	[caller retain];
	AtlasCheckout *co = [[mCheckouts objectForKey:nameCopy] retain];
	
	if (co != nil)
	{
		[co checkout];
		[co release];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			dispatch_sync(dispatch_get_main_queue(), ^(void) {
				NSString *atlasName = nameCopy;
				NSString *errorMsg = nil;
				
				NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:[caller methodSignatureForSelector:callback]];
				[invoc setTarget:caller];
				[invoc setSelector:callback];
				[invoc setArgument:&atlasName atIndex:2];
				[invoc setArgument:&errorMsg atIndex:3];
				[invoc invoke];
				[nameCopy release];
				[pathCopy release];
				[caller release];
			});
			
			[pool release];
		});
	}
	else
	{
		EAGLContext *context = [[mView shareGroupContext] retain];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			if (context != nil)
			{
				[EAGLContext setCurrentContext:context];
				
				AtlasCheckout *checkout = [[AtlasCheckout alloc] initWithName:nameCopy path:path];
				[self queueCheckout:checkout];
				[checkout release];
				checkout = nil;
			}
			
			dispatch_sync(dispatch_get_main_queue(), ^(void) {
				NSString *atlasName = nameCopy;
				NSString *errorMsg = (context) ? nil : [NSString stringWithFormat:
														@"TextureManager could not create EAGLContext. Failed to load atlas named %@.", nameCopy];
				[context release];
				[self dequeueCheckouts]; // Make sure it is available to the caller
				
				NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:[caller methodSignatureForSelector:callback]];
				[invoc setTarget:caller];
				[invoc setSelector:callback];
				[invoc setArgument:&atlasName atIndex:2];
				[invoc setArgument:&errorMsg atIndex:3];
				[invoc invoke];
				[nameCopy release];
				[pathCopy release];
				[caller release];
			});
			
			[EAGLContext setCurrentContext:nil];
			[pool release];
		});
	}
}
#endif
