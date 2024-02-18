import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import 'package:firebase_auth/firebase_auth.dart';

class Task {
  bool deleted = false;
  bool draft = false;
  String description = "";
  bool systemCreated = false;
  bool done = false;
  String name = "babo";
  String owner = "dave";
  int priority = 3;
  String project = "inbox";
  String id = "";
  int utcOffset;
  String timeZoneName;
  bool dueDateWithTime = false;
  Timestamp created;
  Timestamp updated;
  Timestamp? dueDate; // nullable DateTime

  List order = [];
  Task({
    this.name = '',
    this.done = false,
    this.deleted = false,
    this.owner = "dave",
    this.description = "",
    this.draft = false,
    this.priority = 3,
    this.timeZoneName = "",
    this.dueDateWithTime = false,
    this.utcOffset = 0,
    this.id = "",
    this.systemCreated = false,
    this.project = 'inbox',
    required this.created,
    required this.updated,
    this.dueDate, // optional DateTime parameter
  });

  static bool areTasksEqual(Task task1, Task task2) {
    return task1.deleted == task2.deleted &&
        task1.draft == task2.draft &&
        task1.description == task2.description &&
        task1.systemCreated == task2.systemCreated &&
        task1.done == task2.done &&
        task1.name == task2.name &&
        task1.owner == task2.owner &&
        task1.dueDateWithTime == task2.dueDateWithTime &&
        task1.timeZoneName == task2.timeZoneName &&
        task1.utcOffset == task2.utcOffset &&
        task1.priority == task2.priority &&
        task1.project == task2.project &&
        task1.id == task2.id &&
        task1.created == task2.created &&
        task1.updated == task2.updated &&
        task1.dueDate == task2.dueDate;
  }

  static Task fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Task(
      dueDateWithTime: data['dueDateWithTime'] ?? false,
      timeZoneName: data['timeZoneName'] ?? '',
      utcOffset: data['utcOffset'] ?? 0,
      name: data['name'] ?? '',
      done: data['done'] ?? false,
      deleted: data['deleted'] ?? false,
      owner: data['owner'] ?? 'dave',
      priority: data['priority'] ?? 3,
      project: data['project'] ?? 'inbox',
      description: data['description'] ?? '',
      systemCreated: data['systemCreated'] ?? false,
      draft: data['draft'] ?? false,
      id: snapshot.id,
      created: data['created'] ?? Timestamp.now(),
      updated: data['updated'] ?? Timestamp.now(),
      dueDate: data['dueDate'], // nullable DateTime
    );
  }

  static Task fromJson(Map<String, dynamic> json, String sDocID) => Task(
        name: json['name'],
        done: json['done'],
        deleted: json['deleted'],
        owner: json['owner'],
        priority: json['priority'],
        project: json['project'],
        description: json['description'] ?? "",
        timeZoneName: json['timeZoneName'] ?? "",
        utcOffset: json['utcOffset'] ?? 0,
        dueDateWithTime: json['dueDateWithTime'] ?? false,
        systemCreated: json['systemCreated'] ?? false,
        draft: json['draft'] ?? false,
        id: sDocID,
        created: json['created'] ?? Timestamp.now(),
        updated: json['updated'] ?? Timestamp.now(),
        dueDate: json[
            'dueDate'], // parse the date string to DateTime or set it to null
      );

  Map<String, dynamic> toJson() => {
        'deleted': deleted,
        'done': done,
        'name': name,
        'owner': owner,
        'draft': draft,
        'timeZoneName': timeZoneName,
        'utcOffset': utcOffset,
        'dueDateWithTime': dueDateWithTime,
        'description': description,
        'systemCreated': systemCreated,
        'priority': priority,
        'project': project,
        'created': FieldValue.serverTimestamp(),
        'updated': FieldValue.serverTimestamp(),
        'dueDate': dueDate,
      };
}

class Project {
  bool deleted = false;
  bool pinned = false;
  bool showDetails = false;
  bool systemCreated = false;
  bool done = false;
  String name = "babo";
  String owner = "dave";
  String id = "";
  Timestamp created;
  Timestamp updated;
  bool home = false;
  List order = [];

  Project({
    this.name = '',
    this.done = false,
    this.home = false,
    this.pinned = false,
    this.showDetails = true,
    this.deleted = false,
    this.systemCreated = false,
    this.owner = "dave",
    this.id = "",
    this.order = const [],
    required this.created,
    required this.updated,
    // this.created = '',
//    this.created = FieldValue.serverTimestamp(),
  });

  static Project fromJson(Map<String, dynamic> json, String sDocID) => Project(
        name: json['name'],
        done: json['done'],
        home: json['home'],
        deleted: json['deleted'],
        systemCreated: json['systemCreated'] ?? false,
        showDetails: json['showDetails'] ?? true,
        owner: json['owner'],
        order: json['order'] ?? [""],
        pinned: json['pinned'] ?? false,
        id: sDocID,
        created: json['created'] ?? Timestamp.now(),
        updated: json['updated'] ?? Timestamp.now(),
      );

  String getTimeStamp() {
    DateTime now = DateTime.now();
    return now.toString();
  }

  Map<String, dynamic> toJson() => {
        'deleted': deleted,
        'pinned': pinned,
        'done': done,
        'home': home,
        'showDetails': showDetails,
        'name': name,
        'owner': owner,
        'systemCreated': systemCreated,
        'order': order,
        'created': FieldValue.serverTimestamp(),
        'updated': FieldValue.serverTimestamp()
      };
}

class Combined {
  List<Project> projects = [];
  List<Task> tasks = [];

  Combined();
}

class DB {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void updateOrder(String projectID, List<String> recs) {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final docUser = usersCollection.doc(_firebaseAuth.currentUser?.uid);
    final sTasksCollection = docUser.collection('projects');

    final json = {'updated': Timestamp.now(), "order": recs};
    if (_firebaseAuth.currentUser?.uid != null) {
      // p.owner = sUID!;
      //p.order = recs;

      sTasksCollection.doc(projectID).update(json);
    }

    return;
  }

  Stream<Combined> combineStreams() {
    return Rx.combineLatest2(streamTasks(), streamProjects(true),
        (List<Task> a, List<Project> b) {
      Combined c = Combined();
      c.tasks = a;
      c.projects = b;

      return c;
    });
  }

  Stream<List<Project>> streamProjects(bool bHome) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseAuth.currentUser?.uid)
        .collection('projects')
        .orderBy("name", descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Task>> streamTasks() => FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('tasks')
          .orderBy("created", descending: true)
          .snapshots()
          .map((snapshot) {
        // Continue to map the snapshot to your Task objects
        return snapshot.docs
            .map((doc) => Task.fromJson(doc.data(), doc.id))
            .toList();
      });

  Future<String> addProjectRecord(String name, bool bSystem) async {
    if (_firebaseAuth.currentUser?.uid == null) "";

    String? sUID = _firebaseAuth.currentUser?.uid;

    final usersCollection = FirebaseFirestore.instance.collection('users');
    final docUser = usersCollection.doc(sUID);
    final sTasksCollection = docUser.collection('projects');

    Project p = Project(created: Timestamp.now(), updated: Timestamp.now());
    p.owner = sUID!;
    p.name = name.trim();
    p.systemCreated = bSystem;

    var ref = sTasksCollection.doc();

    String projectID = ref.id;

    ref.set(p.toJson());

    return projectID;
  }

  Future addTaskRecord(
      String name,
      String description,
      String projectID,
      bool flag,
      bool bSystem,
      int utcOffset,
      String timeZoneName,
      bool dueDateHasTime,
      DateTime? date) async {
    if (_firebaseAuth.currentUser?.uid == null) return;

    String? sUID = _firebaseAuth.currentUser?.uid;
    // incrementProjectCount(projectID, sUID, true);
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final docUser = usersCollection.doc(sUID);
    final sTasksCollection = docUser.collection('tasks');

    int priority = flag ? 1 : 3;

    Timestamp? timestamp = date != null ? Timestamp.fromDate(date) : null;

    Task t = Task(
        created: Timestamp.now(),
        updated: Timestamp.now(),
        dueDate: timestamp,
        timeZoneName: timeZoneName,
        utcOffset: utcOffset,
        dueDateWithTime: dueDateHasTime);
    t.owner = sUID!;

    t.name = name.trim();
    t.project = projectID;
    t.priority = priority;
    t.systemCreated = bSystem;
    t.description = description;

    var rec = await sTasksCollection.add(t.toJson());

    return rec.id;
  }
}
