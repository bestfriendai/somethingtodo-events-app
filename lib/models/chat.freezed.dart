// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatSession _$ChatSessionFromJson(Map<String, dynamic> json) {
  return _ChatSession.fromJson(json);
}

/// @nodoc
mixin _$ChatSession {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  List<ChatMessage> get messages => throw _privateConstructorUsedError;
  ChatType get type => throw _privateConstructorUsedError;
  ChatStatus get status => throw _privateConstructorUsedError;
  Map<String, dynamic>? get context => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChatSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatSessionCopyWith<ChatSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatSessionCopyWith<$Res> {
  factory $ChatSessionCopyWith(
    ChatSession value,
    $Res Function(ChatSession) then,
  ) = _$ChatSessionCopyWithImpl<$Res, ChatSession>;
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    List<ChatMessage> messages,
    ChatType type,
    ChatStatus status,
    Map<String, dynamic>? context,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$ChatSessionCopyWithImpl<$Res, $Val extends ChatSession>
    implements $ChatSessionCopyWith<$Res> {
  _$ChatSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? messages = null,
    Object? type = null,
    Object? status = null,
    Object? context = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<ChatMessage>,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ChatType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ChatStatus,
            context: freezed == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatSessionImplCopyWith<$Res>
    implements $ChatSessionCopyWith<$Res> {
  factory _$$ChatSessionImplCopyWith(
    _$ChatSessionImpl value,
    $Res Function(_$ChatSessionImpl) then,
  ) = __$$ChatSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    List<ChatMessage> messages,
    ChatType type,
    ChatStatus status,
    Map<String, dynamic>? context,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$ChatSessionImplCopyWithImpl<$Res>
    extends _$ChatSessionCopyWithImpl<$Res, _$ChatSessionImpl>
    implements _$$ChatSessionImplCopyWith<$Res> {
  __$$ChatSessionImplCopyWithImpl(
    _$ChatSessionImpl _value,
    $Res Function(_$ChatSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? messages = null,
    Object? type = null,
    Object? status = null,
    Object? context = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ChatSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<ChatMessage>,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ChatType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ChatStatus,
        context: freezed == context
            ? _value._context
            : context // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatSessionImpl implements _ChatSession {
  const _$ChatSessionImpl({
    required this.id,
    required this.userId,
    required this.title,
    final List<ChatMessage> messages = const [],
    this.type = ChatType.eventDiscovery,
    this.status = ChatStatus.active,
    final Map<String, dynamic>? context,
    this.createdAt,
    this.updatedAt,
  }) : _messages = messages,
       _context = context;

  factory _$ChatSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  final List<ChatMessage> _messages;
  @override
  @JsonKey()
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final ChatType type;
  @override
  @JsonKey()
  final ChatStatus status;
  final Map<String, dynamic>? _context;
  @override
  Map<String, dynamic>? get context {
    final value = _context;
    if (value == null) return null;
    if (_context is EqualUnmodifiableMapView) return _context;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ChatSession(id: $id, userId: $userId, title: $title, messages: $messages, type: $type, status: $status, context: $context, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._context, _context) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    title,
    const DeepCollectionEquality().hash(_messages),
    type,
    status,
    const DeepCollectionEquality().hash(_context),
    createdAt,
    updatedAt,
  );

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatSessionImplCopyWith<_$ChatSessionImpl> get copyWith =>
      __$$ChatSessionImplCopyWithImpl<_$ChatSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatSessionImplToJson(this);
  }
}

abstract class _ChatSession implements ChatSession {
  const factory _ChatSession({
    required final String id,
    required final String userId,
    required final String title,
    final List<ChatMessage> messages,
    final ChatType type,
    final ChatStatus status,
    final Map<String, dynamic>? context,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$ChatSessionImpl;

  factory _ChatSession.fromJson(Map<String, dynamic> json) =
      _$ChatSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  List<ChatMessage> get messages;
  @override
  ChatType get type;
  @override
  ChatStatus get status;
  @override
  Map<String, dynamic>? get context;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatSessionImplCopyWith<_$ChatSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  MessageRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  MessageSender get sender => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  List<MessageAction> get actions => throw _privateConstructorUsedError;
  List<EventRecommendation> get recommendations =>
      throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String sessionId,
    MessageRole role,
    String content,
    MessageType type,
    MessageSender sender,
    Map<String, dynamic>? metadata,
    List<MessageAction> actions,
    List<EventRecommendation> recommendations,
    DateTime? timestamp,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? role = null,
    Object? content = null,
    Object? type = null,
    Object? sender = null,
    Object? metadata = freezed,
    Object? actions = null,
    Object? recommendations = null,
    Object? timestamp = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as MessageRole,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MessageType,
            sender: null == sender
                ? _value.sender
                : sender // ignore: cast_nullable_to_non_nullable
                      as MessageSender,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            actions: null == actions
                ? _value.actions
                : actions // ignore: cast_nullable_to_non_nullable
                      as List<MessageAction>,
            recommendations: null == recommendations
                ? _value.recommendations
                : recommendations // ignore: cast_nullable_to_non_nullable
                      as List<EventRecommendation>,
            timestamp: freezed == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sessionId,
    MessageRole role,
    String content,
    MessageType type,
    MessageSender sender,
    Map<String, dynamic>? metadata,
    List<MessageAction> actions,
    List<EventRecommendation> recommendations,
    DateTime? timestamp,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? role = null,
    Object? content = null,
    Object? type = null,
    Object? sender = null,
    Object? metadata = freezed,
    Object? actions = null,
    Object? recommendations = null,
    Object? timestamp = freezed,
  }) {
    return _then(
      _$ChatMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as MessageRole,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MessageType,
        sender: null == sender
            ? _value.sender
            : sender // ignore: cast_nullable_to_non_nullable
                  as MessageSender,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        actions: null == actions
            ? _value._actions
            : actions // ignore: cast_nullable_to_non_nullable
                  as List<MessageAction>,
        recommendations: null == recommendations
            ? _value._recommendations
            : recommendations // ignore: cast_nullable_to_non_nullable
                  as List<EventRecommendation>,
        timestamp: freezed == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.type = MessageType.text,
    this.sender = MessageSender.user,
    final Map<String, dynamic>? metadata,
    final List<MessageAction> actions = const [],
    final List<EventRecommendation> recommendations = const [],
    this.timestamp,
  }) : _metadata = metadata,
       _actions = actions,
       _recommendations = recommendations;

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String sessionId;
  @override
  final MessageRole role;
  @override
  final String content;
  @override
  @JsonKey()
  final MessageType type;
  @override
  @JsonKey()
  final MessageSender sender;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<MessageAction> _actions;
  @override
  @JsonKey()
  List<MessageAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  final List<EventRecommendation> _recommendations;
  @override
  @JsonKey()
  List<EventRecommendation> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  @override
  final DateTime? timestamp;

  @override
  String toString() {
    return 'ChatMessage(id: $id, sessionId: $sessionId, role: $role, content: $content, type: $type, sender: $sender, metadata: $metadata, actions: $actions, recommendations: $recommendations, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            const DeepCollectionEquality().equals(
              other._recommendations,
              _recommendations,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sessionId,
    role,
    content,
    type,
    sender,
    const DeepCollectionEquality().hash(_metadata),
    const DeepCollectionEquality().hash(_actions),
    const DeepCollectionEquality().hash(_recommendations),
    timestamp,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String sessionId,
    required final MessageRole role,
    required final String content,
    final MessageType type,
    final MessageSender sender,
    final Map<String, dynamic>? metadata,
    final List<MessageAction> actions,
    final List<EventRecommendation> recommendations,
    final DateTime? timestamp,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get sessionId;
  @override
  MessageRole get role;
  @override
  String get content;
  @override
  MessageType get type;
  @override
  MessageSender get sender;
  @override
  Map<String, dynamic>? get metadata;
  @override
  List<MessageAction> get actions;
  @override
  List<EventRecommendation> get recommendations;
  @override
  DateTime? get timestamp;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageAction _$MessageActionFromJson(Map<String, dynamic> json) {
  return _MessageAction.fromJson(json);
}

/// @nodoc
mixin _$MessageAction {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  ActionType get type => throw _privateConstructorUsedError;
  Map<String, dynamic>? get payload => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this MessageAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageActionCopyWith<MessageAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageActionCopyWith<$Res> {
  factory $MessageActionCopyWith(
    MessageAction value,
    $Res Function(MessageAction) then,
  ) = _$MessageActionCopyWithImpl<$Res, MessageAction>;
  @useResult
  $Res call({
    String id,
    String label,
    ActionType type,
    Map<String, dynamic>? payload,
    bool isCompleted,
  });
}

/// @nodoc
class _$MessageActionCopyWithImpl<$Res, $Val extends MessageAction>
    implements $MessageActionCopyWith<$Res> {
  _$MessageActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? type = null,
    Object? payload = freezed,
    Object? isCompleted = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ActionType,
            payload: freezed == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageActionImplCopyWith<$Res>
    implements $MessageActionCopyWith<$Res> {
  factory _$$MessageActionImplCopyWith(
    _$MessageActionImpl value,
    $Res Function(_$MessageActionImpl) then,
  ) = __$$MessageActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String label,
    ActionType type,
    Map<String, dynamic>? payload,
    bool isCompleted,
  });
}

/// @nodoc
class __$$MessageActionImplCopyWithImpl<$Res>
    extends _$MessageActionCopyWithImpl<$Res, _$MessageActionImpl>
    implements _$$MessageActionImplCopyWith<$Res> {
  __$$MessageActionImplCopyWithImpl(
    _$MessageActionImpl _value,
    $Res Function(_$MessageActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? type = null,
    Object? payload = freezed,
    Object? isCompleted = null,
  }) {
    return _then(
      _$MessageActionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ActionType,
        payload: freezed == payload
            ? _value._payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageActionImpl implements _MessageAction {
  const _$MessageActionImpl({
    required this.id,
    required this.label,
    required this.type,
    final Map<String, dynamic>? payload,
    this.isCompleted = false,
  }) : _payload = payload;

  factory _$MessageActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageActionImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final ActionType type;
  final Map<String, dynamic>? _payload;
  @override
  Map<String, dynamic>? get payload {
    final value = _payload;
    if (value == null) return null;
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool isCompleted;

  @override
  String toString() {
    return 'MessageAction(id: $id, label: $label, type: $type, payload: $payload, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    label,
    type,
    const DeepCollectionEquality().hash(_payload),
    isCompleted,
  );

  /// Create a copy of MessageAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageActionImplCopyWith<_$MessageActionImpl> get copyWith =>
      __$$MessageActionImplCopyWithImpl<_$MessageActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageActionImplToJson(this);
  }
}

abstract class _MessageAction implements MessageAction {
  const factory _MessageAction({
    required final String id,
    required final String label,
    required final ActionType type,
    final Map<String, dynamic>? payload,
    final bool isCompleted,
  }) = _$MessageActionImpl;

  factory _MessageAction.fromJson(Map<String, dynamic> json) =
      _$MessageActionImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  ActionType get type;
  @override
  Map<String, dynamic>? get payload;
  @override
  bool get isCompleted;

  /// Create a copy of MessageAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageActionImplCopyWith<_$MessageActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatRecommendation _$ChatRecommendationFromJson(Map<String, dynamic> json) {
  return _ChatRecommendation.fromJson(json);
}

/// @nodoc
mixin _$ChatRecommendation {
  String get id => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  double get confidenceScore => throw _privateConstructorUsedError;
  List<String> get matchingCriteria => throw _privateConstructorUsedError;
  RecommendationStatus get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ChatRecommendation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatRecommendationCopyWith<ChatRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRecommendationCopyWith<$Res> {
  factory $ChatRecommendationCopyWith(
    ChatRecommendation value,
    $Res Function(ChatRecommendation) then,
  ) = _$ChatRecommendationCopyWithImpl<$Res, ChatRecommendation>;
  @useResult
  $Res call({
    String id,
    String eventId,
    String reason,
    double confidenceScore,
    List<String> matchingCriteria,
    RecommendationStatus status,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$ChatRecommendationCopyWithImpl<$Res, $Val extends ChatRecommendation>
    implements $ChatRecommendationCopyWith<$Res> {
  _$ChatRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? reason = null,
    Object? confidenceScore = null,
    Object? matchingCriteria = null,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            confidenceScore: null == confidenceScore
                ? _value.confidenceScore
                : confidenceScore // ignore: cast_nullable_to_non_nullable
                      as double,
            matchingCriteria: null == matchingCriteria
                ? _value.matchingCriteria
                : matchingCriteria // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RecommendationStatus,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatRecommendationImplCopyWith<$Res>
    implements $ChatRecommendationCopyWith<$Res> {
  factory _$$ChatRecommendationImplCopyWith(
    _$ChatRecommendationImpl value,
    $Res Function(_$ChatRecommendationImpl) then,
  ) = __$$ChatRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String eventId,
    String reason,
    double confidenceScore,
    List<String> matchingCriteria,
    RecommendationStatus status,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$ChatRecommendationImplCopyWithImpl<$Res>
    extends _$ChatRecommendationCopyWithImpl<$Res, _$ChatRecommendationImpl>
    implements _$$ChatRecommendationImplCopyWith<$Res> {
  __$$ChatRecommendationImplCopyWithImpl(
    _$ChatRecommendationImpl _value,
    $Res Function(_$ChatRecommendationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? reason = null,
    Object? confidenceScore = null,
    Object? matchingCriteria = null,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ChatRecommendationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        confidenceScore: null == confidenceScore
            ? _value.confidenceScore
            : confidenceScore // ignore: cast_nullable_to_non_nullable
                  as double,
        matchingCriteria: null == matchingCriteria
            ? _value._matchingCriteria
            : matchingCriteria // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RecommendationStatus,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRecommendationImpl implements _ChatRecommendation {
  const _$ChatRecommendationImpl({
    required this.id,
    required this.eventId,
    required this.reason,
    required this.confidenceScore,
    final List<String> matchingCriteria = const [],
    this.status = RecommendationStatus.pending,
    this.createdAt,
  }) : _matchingCriteria = matchingCriteria;

  factory _$ChatRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRecommendationImplFromJson(json);

  @override
  final String id;
  @override
  final String eventId;
  @override
  final String reason;
  @override
  final double confidenceScore;
  final List<String> _matchingCriteria;
  @override
  @JsonKey()
  List<String> get matchingCriteria {
    if (_matchingCriteria is EqualUnmodifiableListView)
      return _matchingCriteria;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchingCriteria);
  }

  @override
  @JsonKey()
  final RecommendationStatus status;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ChatRecommendation(id: $id, eventId: $eventId, reason: $reason, confidenceScore: $confidenceScore, matchingCriteria: $matchingCriteria, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRecommendationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            const DeepCollectionEquality().equals(
              other._matchingCriteria,
              _matchingCriteria,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    eventId,
    reason,
    confidenceScore,
    const DeepCollectionEquality().hash(_matchingCriteria),
    status,
    createdAt,
  );

  /// Create a copy of ChatRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRecommendationImplCopyWith<_$ChatRecommendationImpl> get copyWith =>
      __$$ChatRecommendationImplCopyWithImpl<_$ChatRecommendationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRecommendationImplToJson(this);
  }
}

abstract class _ChatRecommendation implements ChatRecommendation {
  const factory _ChatRecommendation({
    required final String id,
    required final String eventId,
    required final String reason,
    required final double confidenceScore,
    final List<String> matchingCriteria,
    final RecommendationStatus status,
    final DateTime? createdAt,
  }) = _$ChatRecommendationImpl;

  factory _ChatRecommendation.fromJson(Map<String, dynamic> json) =
      _$ChatRecommendationImpl.fromJson;

  @override
  String get id;
  @override
  String get eventId;
  @override
  String get reason;
  @override
  double get confidenceScore;
  @override
  List<String> get matchingCriteria;
  @override
  RecommendationStatus get status;
  @override
  DateTime? get createdAt;

  /// Create a copy of ChatRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRecommendationImplCopyWith<_$ChatRecommendationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventRecommendation _$EventRecommendationFromJson(Map<String, dynamic> json) {
  return _EventRecommendation.fromJson(json);
}

/// @nodoc
mixin _$EventRecommendation {
  String get id => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get confidenceScore => throw _privateConstructorUsedError;
  List<String> get reasons => throw _privateConstructorUsedError;
  RecommendationStatus get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this EventRecommendation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventRecommendationCopyWith<EventRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventRecommendationCopyWith<$Res> {
  factory $EventRecommendationCopyWith(
    EventRecommendation value,
    $Res Function(EventRecommendation) then,
  ) = _$EventRecommendationCopyWithImpl<$Res, EventRecommendation>;
  @useResult
  $Res call({
    String id,
    String eventId,
    String title,
    String description,
    double confidenceScore,
    List<String> reasons,
    RecommendationStatus status,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$EventRecommendationCopyWithImpl<$Res, $Val extends EventRecommendation>
    implements $EventRecommendationCopyWith<$Res> {
  _$EventRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? title = null,
    Object? description = null,
    Object? confidenceScore = null,
    Object? reasons = null,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            eventId: null == eventId
                ? _value.eventId
                : eventId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            confidenceScore: null == confidenceScore
                ? _value.confidenceScore
                : confidenceScore // ignore: cast_nullable_to_non_nullable
                      as double,
            reasons: null == reasons
                ? _value.reasons
                : reasons // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RecommendationStatus,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventRecommendationImplCopyWith<$Res>
    implements $EventRecommendationCopyWith<$Res> {
  factory _$$EventRecommendationImplCopyWith(
    _$EventRecommendationImpl value,
    $Res Function(_$EventRecommendationImpl) then,
  ) = __$$EventRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String eventId,
    String title,
    String description,
    double confidenceScore,
    List<String> reasons,
    RecommendationStatus status,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$EventRecommendationImplCopyWithImpl<$Res>
    extends _$EventRecommendationCopyWithImpl<$Res, _$EventRecommendationImpl>
    implements _$$EventRecommendationImplCopyWith<$Res> {
  __$$EventRecommendationImplCopyWithImpl(
    _$EventRecommendationImpl _value,
    $Res Function(_$EventRecommendationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? title = null,
    Object? description = null,
    Object? confidenceScore = null,
    Object? reasons = null,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$EventRecommendationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        eventId: null == eventId
            ? _value.eventId
            : eventId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        confidenceScore: null == confidenceScore
            ? _value.confidenceScore
            : confidenceScore // ignore: cast_nullable_to_non_nullable
                  as double,
        reasons: null == reasons
            ? _value._reasons
            : reasons // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RecommendationStatus,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventRecommendationImpl implements _EventRecommendation {
  const _$EventRecommendationImpl({
    required this.id,
    required this.eventId,
    required this.title,
    required this.description,
    this.confidenceScore = 0.0,
    final List<String> reasons = const [],
    this.status = RecommendationStatus.pending,
    this.createdAt,
  }) : _reasons = reasons;

  factory _$EventRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventRecommendationImplFromJson(json);

  @override
  final String id;
  @override
  final String eventId;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey()
  final double confidenceScore;
  final List<String> _reasons;
  @override
  @JsonKey()
  List<String> get reasons {
    if (_reasons is EqualUnmodifiableListView) return _reasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reasons);
  }

  @override
  @JsonKey()
  final RecommendationStatus status;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'EventRecommendation(id: $id, eventId: $eventId, title: $title, description: $description, confidenceScore: $confidenceScore, reasons: $reasons, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventRecommendationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            const DeepCollectionEquality().equals(other._reasons, _reasons) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    eventId,
    title,
    description,
    confidenceScore,
    const DeepCollectionEquality().hash(_reasons),
    status,
    createdAt,
  );

  /// Create a copy of EventRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventRecommendationImplCopyWith<_$EventRecommendationImpl> get copyWith =>
      __$$EventRecommendationImplCopyWithImpl<_$EventRecommendationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EventRecommendationImplToJson(this);
  }
}

abstract class _EventRecommendation implements EventRecommendation {
  const factory _EventRecommendation({
    required final String id,
    required final String eventId,
    required final String title,
    required final String description,
    final double confidenceScore,
    final List<String> reasons,
    final RecommendationStatus status,
    final DateTime? createdAt,
  }) = _$EventRecommendationImpl;

  factory _EventRecommendation.fromJson(Map<String, dynamic> json) =
      _$EventRecommendationImpl.fromJson;

  @override
  String get id;
  @override
  String get eventId;
  @override
  String get title;
  @override
  String get description;
  @override
  double get confidenceScore;
  @override
  List<String> get reasons;
  @override
  RecommendationStatus get status;
  @override
  DateTime? get createdAt;

  /// Create a copy of EventRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventRecommendationImplCopyWith<_$EventRecommendationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
