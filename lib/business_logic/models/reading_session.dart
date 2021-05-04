import 'package:uuid/uuid.dart';

class ReadingSession {
  String id;
  DateTime started;
  DateTime ended;
  bool isReading = false;
  Duration timePassed;

  ReadingSession({
    this.started,
    this.ended,
    this.isReading = false,
    this.timePassed,
  }) {
    id = Uuid().v1();
  }

  ReadingSession.fromSession(ReadingSession session) {
    id = session.id;
    started = session.started;
    ended = session.ended;
    isReading = session.isReading;
    timePassed = session.timePassed;
  }

  ReadingSession.basic() {
    id = Uuid().v1();
    timePassed = Duration(seconds: 0);
  }

  ReadingSession.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    started = DateTime.parse(json['started']);
    ended = DateTime.parse(json['ended']);
    isReading = json['isReading'];
    timePassed = Duration(seconds: json['timePassed']);
  }

  void updateTimePassed() {
    timePassed = DateTime.now().difference(started);
  }

  String displayTimePassed() {
    int hours = timePassed.inHours;
    int minutes = timePassed.inMinutes - (60 * hours);
    int seconds = timePassed.inSeconds - (60 * minutes);

    if (hours >= 1) {
      return '$hours:${minutes >= 10 ? minutes : '0' + minutes.toString()}:${seconds >= 10 ? seconds : '0' + seconds.toString()}';
    } else
      return '${minutes >= 10 ? minutes : '0' + minutes.toString()}:${seconds >= 10 ? seconds : '0' + seconds.toString()}';
  }

  Stream<String> maintainSession() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      if (isReading) updateTimePassed();
      yield displayTimePassed();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'started': started.toString(),
      'ended': ended.toString(),
      'isReading': isReading,
      'timePassed': timePassed.inSeconds,
    };
  }
}
