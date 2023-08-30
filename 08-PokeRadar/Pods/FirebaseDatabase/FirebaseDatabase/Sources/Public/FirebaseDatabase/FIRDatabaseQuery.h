/*
 * Copyright 2017 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FIRDataEventType.h"
#import "FIRDataSnapshot.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A `DatabaseHandle` is used to identify listeners of Firebase Database
 * events. These handles are returned by `observe(_:with:)` and can later be
 * passed to `removeObserver(withHandle:)` to stop receiving updates.
 */
typedef NSUInteger FIRDatabaseHandle NS_SWIFT_NAME(DatabaseHandle);

/**
 * A `DatabaseQuery` instance represents a query over the data at a particular
 * location.
 *
 * You create one by calling one of the query methods (`queryOrdered(byChild:)`,
 * `queryStarting(atValue:)`, etc.) on a `DatabaseReference`. The query methods
 * can be chained to further specify the data you are interested in observing.
 */
NS_SWIFT_NAME(DatabaseQuery)
@interface FIRDatabaseQuery : NSObject

#pragma mark - Attach observers to read data

/**
 * This method is used to listen for data changes at a particular location.
 * This is the primary way to read data from the Firebase Database. Your
 * block will be triggered for the initial data and again whenever the
 * data changes.
 *
 * Use removeObserverWithHandle: to stop receiving updates.
 *
 * @param eventType The type of event to listen for.
 * @param block The block that should be called with initial data and updates.
 *     It is passed the data as a `DataSnapshot`.
 * @return A handle used to unregister this block later using
 *     `removeObserver(withHandle:)`
 */
- (FIRDatabaseHandle)observeEventType:(FIRDataEventType)eventType
                            withBlock:
                                (void (^)(FIRDataSnapshot *snapshot))block;

/**
 * This method is used to listen for data changes at a particular location.
 * This is the primary way to read data from the Firebase Database. Your
 * block will be triggered for the initial data and again whenever the data
 * changes. In addition, for `DataEventTypeChildAdded`,
 * `DataEventTypeChildMoved`, and `DataEventTypeChildChanged` events, your
 * block will be passed the key of the previous node by priority order.
 *
 * Use `removeObserver(withHandle:)` to stop receiving updates.
 *
 * @param eventType The type of event to listen for.
 * @param block The block that should be called with initial data and updates.
 * It is passed the data as a `DataSnapshot` and the previous child's key.
 * @return A handle used to unregister this block later using
 * `removeObserver(withHandle:)`
 */
- (FIRDatabaseHandle)observeEventType:(FIRDataEventType)eventType
       andPreviousSiblingKeyWithBlock:
           (void (^)(FIRDataSnapshot *snapshot,
                     NSString *__nullable prevKey))block;

/**
 * This method is used to listen for data changes at a particular location.
 * This is the primary way to read data from the Firebase Database. Your
 * block will be triggered for the initial data and again whenever the data
 * changes.
 *
 * The `cancelBlock` will be called if you will no longer receive new events
 * due to no longer having permission.
 *
 * Use `removeObserver(withHandle:)` to stop receiving updates.
 *
 * @param eventType The type of event to listen for.
 * @param block The block that should be called with initial data and updates.
 *     It is passed the data as a `DataSnapshot`.
 * @param cancelBlock The block that should be called if this client no longer
 *     has permission to receive these events
 * @return A handle used to unregister this block later using
 *     `removeObserver(withHandle:)`
 */
- (FIRDatabaseHandle)observeEventType:(FIRDataEventType)eventType
                            withBlock:(void (^)(FIRDataSnapshot *snapshot))block
                      withCancelBlock:
                          (nullable void (^)(NSError *error))cancelBlock;

/**
 * This method is used to listen for data changes at a particular location.
 * This is the primary way to read data from the Firebase Database. Your block
 * will be triggered for the initial data and again whenever the data changes.
 * In addition, for `FIRDataEventTypeChildAdded`, `FIRDataEventTypeChildMoved`,
 * and FIRDataEventTypeChildChanged events, your block will be passed the key
 * of the previous node by priority order.
 *
 * The `cancelBlock` will be called if you will no longer receive new events due
 * to no longer having permission.
 *
 * Use `removeObserver(withHandle:)` to stop receiving updates.
 *
 * @param eventType The type of event to listen for.
 * @param block The block that should be called with initial data and updates.
 *     It is passed the data as a `DataSnapshot` and the previous child's key.
 * @param cancelBlock The block that should be called if this client no longer
 *     has permission to receive these events
 * @return A handle used to unregister this block later using
 *     `removeObserver(withHandle:)`
 */
- (FIRDatabaseHandle)observeEventType:(FIRDataEventType)eventType
       andPreviousSiblingKeyWithBlock:
           (void (^)(FIRDataSnapshot *snapshot,
                     NSString *__nullable prevKey))block
                      withCancelBlock:
                          (nullable void (^)(NSError *error))cancelBlock;

/**
 * This method is used to get the most up-to-date value for this query. This
 * method updates the cache and raises events if successful. If
 * not connected, it returns a locally-cached value.
 *
 * @param block The block that should be called with the most up-to-date value
 *     of this query, or an error if no such value could be retrieved.
 */
- (void)getDataWithCompletionBlock:
    (void (^_Nonnull)(NSError *__nullable error,
                      FIRDataSnapshot *__nullable snapshot))block
    NS_SWIFT_NAME(getData(completion:));

/**
 * This is equivalent to `observe(_:with:)`, except the block is
 * immediately canceled after the initial data is returned.
 *
 * @param eventType The type of event to listen for.
 * @param block The block that should be called.  It is passed the data as a
 *     `DataSnapshot`.
 */
- (void)observeSingleEventOfType:(FIRDataEventType)eventType
                       withBlock:(void (^)(FIRDataSnapshot *snapshot))block;

/**
 * This is equivalent to `observe(_:with:)`, except the block is
 * immediately canceled after the initial data is returned. In addition, for
 * `DataEventTypeChildAdded`, `DataEventTypeChildMoved`, and
 * `DataEventTypeChildChanged` events, your block will be passed the key of the
 * previous node by priority order.
 *
 * @param eventType The type of event to listen for.
 * @param block The block that should be called.  It is passed the data as a
 *     `DataSnapshot` and the previous child's key.
 */
- (void)observeSingleEventOfType:(FIRDataEventType)eventType
    andPreviousSiblingKeyWithBlock:
        (void (^)(FIRDataSnapshot *snapshot,
                  NSString *__nullable prevKey))block;

/**
 * This is equivalent to `observe(_:with:)`, except the block is
 * immediately canceled after the initial data is returned.
 *
 * The `cancelBlock` will be called if you do not have permission to read data
 * at this location.
 *
 * @param eventType The type of event to listen for.
 * @param block The block that should be called.  It is passed the data as a
 *     `DataSnapshot`.
 * @param cancelBlock The block that will be called if you don't have permission
 *     to access this data
 */
- (void)observeSingleEventOfType:(FIRDataEventType)eventType
                       withBlock:(void (^)(FIRDataSnapshot *snapshot))block
                 withCancelBlock:(nullable void (^)(NSError *error))cancelBlock;

/**
 * This is equivalent to `observe(_:with:)`, except the block is
 * immediately canceled after the initial data is returned. In addition, for
 * `DataEventTypeChildAdded`, `DataEventTypeChildMoved`, and
 * `DataEventTypeChildChanged` events, your block will be passed the key of the
 * previous node by priority order.
 *
 * The `cancelBlock` will be called if you do not have permission to read data
 * at this location.
 *
 * @param eventType The type of event to listen for.
 * @param block The block that should be called.  It is passed the data as a
 *     `DataSnapshot` and the previous child's key.
 * @param cancelBlock The block that will be called if you don't have permission
 *     to access this data
 */
- (void)observeSingleEventOfType:(FIRDataEventType)eventType
    andPreviousSiblingKeyWithBlock:(void (^)(FIRDataSnapshot *snapshot,
                                             NSString *__nullable prevKey))block
                   withCancelBlock:
                       (nullable void (^)(NSError *error))cancelBlock;

#pragma mark - Detaching observers

/**
 * Detach a block previously attached with `observe(_:with:)`, or another query
 * observation method. After this method is called, the associated block
 * registered to receive snapshot updates will no longer be invoked.
 *
 * @param handle The handle returned by the call to `observe(_:with:)`
 *     which we are trying to remove.
 */
- (void)removeObserverWithHandle:(FIRDatabaseHandle)handle;

/**
 * Detach all blocks previously attached to this Firebase Database location with
 * `observe(_:with:)` and other query observation methods.
 */
- (void)removeAllObservers;

/**
 * By calling `keepSynced(true)` on a location, the data for that location will
 * automatically be downloaded and kept in sync, even when no listeners are
 * attached for that location. Additionally, while a location is kept synced, it
 * will not be evicted from the persistent disk cache.
 *
 * @param keepSynced Pass true to keep this location synchronized, or false to
 *     stop synchronization.
 */
- (void)keepSynced:(BOOL)keepSynced;

#pragma mark - Querying and limiting

/**
 * This method is used to generate a reference to a limited view of the
 * data at this location. The `DatabaseQuery` instance returned by
 * `queryLimited(toFirst:)` will respond to at most the first limit child nodes.
 *
 * @param limit The upper bound, inclusive, for the number of child nodes to
 *     receive events for
 * @return A `DatabaseQuery` instance, limited to at most limit child nodes.
 */
- (FIRDatabaseQuery *)queryLimitedToFirst:(NSUInteger)limit;

/**
 * `queryLimited(toLast:)` is used to generate a reference to a limited view of
 * the data at this location. The `DatabaseQuery` instance returned by
 * this method will respond to at most the last limit child nodes.
 *
 * @param limit The upper bound, inclusive, for the number of child nodes to
 *     receive events for
 * @return A `DatabaseQuery` instance, limited to at most limit child nodes.
 */
- (FIRDatabaseQuery *)queryLimitedToLast:(NSUInteger)limit;

/**
 * This method is used to generate a reference to a view of the data that's
 * been sorted by the values of a particular child key. This method is intended
 * to be used in combination with `queryStarting(atValue:)`,
 * `queryEnding(atValue:)`, or `queryEqual(toValue:)`.
 *
 * @param key The child key to use in ordering data visible to the returned
 *     `DatabaseQuery`
 * @return A `DatabaseQuery` instance, ordered by the values of the specified
 * child key.
 */
- (FIRDatabaseQuery *)queryOrderedByChild:(NSString *)key;

/**
 * `queryOrdered(byKey:) is used to generate a reference to a view of the data
 * that's been sorted by child key. This method is intended to be used in
 * combination with `queryStarting(atValue:)`, `queryEnding(atValue:)`, or
 * `queryEqual(toValue:)`.
 *
 * @return A `DatabaseQuery` instance, ordered by child keys.
 */
- (FIRDatabaseQuery *)queryOrderedByKey;

/**
 * `queryOrdered(byValue:)` is used to generate a reference to a view of the
 * data that's been sorted by child value. This method is intended to be used in
 * combination with `queryStarting(atValue:)`, `queryEnding(atValue:)`, or
 * `queryEqual(toValue:)`.
 *
 * @return A `DatabaseQuery` instance, ordered by child value.
 */
- (FIRDatabaseQuery *)queryOrderedByValue;

/**
 * `queryOrdered(byPriority:) is used to generate a reference to a view of the
 * data that's been sorted by child priority. This method is intended to be used
 * in combination with `queryStarting(atValue:)`, `queryEnding(atValue:)`, or
 * `queryEqual(toValue:)`.
 *
 * @return A `DatabaseQuery` instance, ordered by child priorities.
 */
- (FIRDatabaseQuery *)queryOrderedByPriority;

/**
 * `queryStarting(atValue:)` is used to generate a reference to a limited view
 * of the data at this location. The `DatabaseQuery` instance returned by
 * `queryStarting(atValue:)` will respond to events at nodes with a value
 * greater than or equal to `startValue`.
 *
 * @param startValue The lower bound, inclusive, for the value of data visible
 *     to the returned `DatabaseQuery`
 * @return A `DatabaseQuery` instance, limited to data with value greater than
 *     or equal to `startValue`
 */
- (FIRDatabaseQuery *)queryStartingAtValue:(nullable id)startValue;

/**
 * `queryStarting(atValue:childKey:)` is used to generate a reference to a
 * limited view of the data at this location. The `DatabaseQuery` instance
 * returned by `queryStarting(atValue:childKey:)` will respond to events at
 * nodes with a value greater than `startValue`, or equal to `startValue` and
 * with a key greater than or equal to `childKey`. This is most useful when
 * implementing pagination in a case where multiple nodes can match the
 * `startValue`.
 *
 * @param startValue The lower bound, inclusive, for the value of data visible
 *     to the returned `DatabaseQuery`
 * @param childKey The lower bound, inclusive, for the key of nodes with value
 *     equal to `startValue`
 * @return A `DatabaseQuery` instance, limited to data with value greater than
 *     or equal to `startValue`
 */
- (FIRDatabaseQuery *)queryStartingAtValue:(nullable id)startValue
                                  childKey:(nullable NSString *)childKey;

/**
 * `queryStarting(afterValue:)` is used to generate a reference to a
 * limited view of the data at this location. The `DatabaseQuery` instance
 * returned by `queryStarting(afterValue:)` will respond to events at nodes
 * with a value greater than startAfterValue.
 *
 * @param startAfterValue The lower bound, exclusive, for the value of data
 *     visible to the returned `DatabaseQuery`
 * @return A `DatabaseQuery` instance, limited to data with value greater
 *     `startAfterValue`
 */
- (FIRDatabaseQuery *)queryStartingAfterValue:(nullable id)startAfterValue;

/**
 * `queryStarting(afterValue:childKey:)` is used to generate a reference to a
 * limited view of the data at this location. The `DatabaseQuery` instance
 * returned by `queryStarting(afterValue:childKey:)` will respond to events at
 * nodes with a value greater than `startAfterValue`, or equal to
 * `startAfterValue` and with a key greater than `childKey`. This is most useful
 * when implementing pagination in a case where multiple nodes can match the
 * `startAfterValue`.
 *
 * @param startAfterValue The lower bound, inclusive, for the value of data
 *     visible to the returned `DatabaseQuery`
 * @param childKey The lower bound, exclusive, for the key of nodes with value
 *     equal to `startAfterValue`
 * @return A `DatabaseQuery` instance, limited to data with value greater than
 *     `startAfterValue`, or equal to `startAfterValue` with a key greater than
 *     `childKey`
 */
- (FIRDatabaseQuery *)queryStartingAfterValue:(nullable id)startAfterValue
                                     childKey:(nullable NSString *)childKey;
/**
 * `queryEnding(atValue:)` is used to generate a reference to a limited view of
 * the data at this location. The DatabaseQuery instance returned by
 * `queryEnding(atValue:)` will respond to events at nodes with a value less
 * than or equal to `endValue`.
 *
 * @param endValue The upper bound, inclusive, for the value of data visible to
 *     the returned `DatabaseQuery`
 * @return A `DatabaseQuery` instance, limited to data with value less than or
 *     equal to `endValue`
 */
- (FIRDatabaseQuery *)queryEndingAtValue:(nullable id)endValue;

/**
 * `queryEnding(atValue:childKey:)` is used to generate a reference to a limited
 * view of the data at this location. The `DatabaseQuery` instance returned by
 * `queryEnding(atValue:childKey:)` will respond to events at nodes with a value
 * less than `endValue`, or equal to `endValue` and with a key less than or
 * equal to `childKey`. This is most useful when implementing pagination in a
 * case where multiple nodes can match the `endValue`.
 *
 * @param endValue The upper bound, inclusive, for the value of data visible to
 *     the returned `DatabaseQuery`
 * @param childKey The upper bound, inclusive, for the key of nodes with value
 *     equal to `endValue`
 * @return A `DatabaseQuery` instance, limited to data with value less than or
 *     equal to `endValue`
 */
- (FIRDatabaseQuery *)queryEndingAtValue:(nullable id)endValue
                                childKey:(nullable NSString *)childKey;

/**
 * `queryEnding(beforeValue:) is used to generate a reference to a limited view
 * of the data at this location. The `DatabaseQuery` instance returned by
 * `queryEnding(beforeValue:)` will respond to events at nodes with a value less
 * than `endValue`.
 *
 * @param endValue The upper bound, exclusive, for the value of data visible to
 *     the returned `DatabaseQuery`
 * @return A `DatabaseQuery` instance, limited to data with value less than
 *     `endValue`
 */
- (FIRDatabaseQuery *)queryEndingBeforeValue:(nullable id)endValue;

/**
 * `queryEnding(beforeValue:childKey:)` is used to generate a reference to a
 * limited view of the data at this location. The `DatabaseQuery` instance
 * returned by `queryEnding(beforeValue:childKey:)` will respond to events at
 * nodes with a value less than `endValue`, or equal to `endValue` and with a
 * key less than childKey.
 *
 * @param endValue The upper bound, inclusive, for the value of data visible to
 *     the returned `DatabaseQuery`
 * @param childKey The upper bound, exclusive, for the key of nodes with value
 *     equal to endValue
 * @return A `DatabaseQuery` instance, limited to data with value less than or
 *     equal to endValue
 */
- (FIRDatabaseQuery *)queryEndingBeforeValue:(nullable id)endValue
                                    childKey:(nullable NSString *)childKey;

/**
 * `queryEqual(toValue:)` is used to generate a reference to a limited view of
 * the data at this location. The `DatabaseQuery` instance returned by
 * `queryEqual(toValue:)` will respond to events at nodes with a value equal to
 * the supplied argument.
 *
 * @param value The value that the data returned by this `DatabaseQuery` will
 *     have
 * @return A `DatabaseQuery` instance, limited to data with the supplied value.
 */
- (FIRDatabaseQuery *)queryEqualToValue:(nullable id)value;

/**
 * `queryEqual(toValue:childKey:)` is used to generate a reference to a limited
 * view of the data at this location. The `DatabaseQuery` instance returned by
 * `queryEqual(toValue:childKey:)` will respond to events at nodes with a value
 * equal to the supplied argument and with their key equal to `childKey`. There
 * will be at most one node that matches because child keys are unique.
 *
 * @param value The value that the data returned by this `DatabaseQuery` will
 *     have
 * @param childKey The name of nodes with the right value
 * @return A `DatabaseQuery` instance, limited to data with the supplied value
 *     and the key.
 */
- (FIRDatabaseQuery *)queryEqualToValue:(nullable id)value
                               childKey:(nullable NSString *)childKey;

#pragma mark - Properties

/**
 * Gets a `DatabaseReference` for the location of this query.
 *
 * @return A `DatabaseReference` for the location of this query.
 */
@property(nonatomic, readonly, strong) FIRDatabaseReference *ref;

@end

NS_ASSUME_NONNULL_END
