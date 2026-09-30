import 'course_record.dart';

/// Hangi notların tekrar alınabileceğini belirler (grading.json → retake).
class RetakePolicy {
  const RetakePolicy(this.retakeableLetters);

  final Set<String> retakeableLetters;

  bool canRetake(CourseRecord record) =>
      !record.replaced && retakeableLetters.contains(record.letter);
}
