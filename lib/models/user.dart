import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final List<String> childIds;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.childIds,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      childIds: List<String>.from(data['childIds'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'childIds': childIds,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  UserModel copyWith({String? email, List<String>? childIds}) => UserModel(
    uid: uid,
    email: email ?? this.email,
    childIds: childIds ?? this.childIds,
    createdAt: createdAt,
  );
}
