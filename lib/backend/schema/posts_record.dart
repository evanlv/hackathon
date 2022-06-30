import 'dart:async';

import 'index.dart';
import 'serializers.dart';
import 'package:built_value/built_value.dart';

part 'posts_record.g.dart';

abstract class PostsRecord implements Built<PostsRecord, PostsRecordBuilder> {
  static Serializer<PostsRecord> get serializer => _$postsRecordSerializer;

  @nullable
  String get content;

  @nullable
  String get uid;

  @nullable
  @BuiltValueField(wireName: 'created_at')
  DateTime get createdAt;

  @nullable
  @BuiltValueField(wireName: 'updated_at')
  DateTime get updatedAt;

  @nullable
  @BuiltValueField(wireName: 'deleted_at')
  DateTime get deletedAt;

  @nullable
  @BuiltValueField(wireName: 'user_id')
  String get userId;

  @nullable
  @BuiltValueField(wireName: kDocumentReferenceField)
  DocumentReference get reference;

  static void _initializeBuilder(PostsRecordBuilder builder) => builder
    ..content = ''
    ..uid = ''
    ..userId = '';

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('posts');

  static Stream<PostsRecord> getDocument(DocumentReference ref) => ref
      .snapshots()
      .map((s) => serializers.deserializeWith(serializer, serializedData(s)));

  static Future<PostsRecord> getDocumentOnce(DocumentReference ref) => ref
      .get()
      .then((s) => serializers.deserializeWith(serializer, serializedData(s)));

  static PostsRecord fromAlgolia(AlgoliaObjectSnapshot snapshot) => PostsRecord(
        (c) => c
          ..content = snapshot.data['content']
          ..uid = snapshot.data['uid']
          ..createdAt = safeGet(() =>
              DateTime.fromMillisecondsSinceEpoch(snapshot.data['created_at']))
          ..updatedAt = safeGet(() =>
              DateTime.fromMillisecondsSinceEpoch(snapshot.data['updated_at']))
          ..deletedAt = safeGet(() =>
              DateTime.fromMillisecondsSinceEpoch(snapshot.data['deleted_at']))
          ..userId = snapshot.data['user_id']
          ..reference = PostsRecord.collection.doc(snapshot.objectID),
      );

  static Future<List<PostsRecord>> search(
          {String term,
          FutureOr<LatLng> location,
          int maxResults,
          double searchRadiusMeters}) =>
      FFAlgoliaManager.instance
          .algoliaQuery(
            index: 'posts',
            term: term,
            maxResults: maxResults,
            location: location,
            searchRadiusMeters: searchRadiusMeters,
          )
          .then((r) => r.map(fromAlgolia).toList());

  PostsRecord._();
  factory PostsRecord([void Function(PostsRecordBuilder) updates]) =
      _$PostsRecord;

  static PostsRecord getDocumentFromData(
          Map<String, dynamic> data, DocumentReference reference) =>
      serializers.deserializeWith(serializer,
          {...mapFromFirestore(data), kDocumentReferenceField: reference});
}

Map<String, dynamic> createPostsRecordData({
  String content,
  String uid,
  DateTime createdAt,
  DateTime updatedAt,
  DateTime deletedAt,
  String userId,
}) =>
    serializers.toFirestore(
        PostsRecord.serializer,
        PostsRecord((p) => p
          ..content = content
          ..uid = uid
          ..createdAt = createdAt
          ..updatedAt = updatedAt
          ..deletedAt = deletedAt
          ..userId = userId));
