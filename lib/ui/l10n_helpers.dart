import '../app/l10n/generated/app_localizations.dart';
import '../domain/grading/assessment.dart';
import '../game/level_setup.dart';

extension AssessmentNames on AppLocalizations {
  String assessmentName(AssessmentType t) => switch (t) {
    AssessmentType.quiz1 => assessmentQuiz1,
    AssessmentType.midterm => assessmentMidterm,
    AssessmentType.quiz2 => assessmentQuiz2,
    AssessmentType.project => assessmentProject,
    AssessmentType.finalExam => assessmentFinal,
  };

  GameStrings get gameStrings => GameStrings(
    finalStretch: gameFinalStretch,
    notificationTitle: gameNotificationTitle,
    notificationBody: gameNotificationBody,
    friendBubble: gameFriendBubble,
    extraCredit: gameExtraCredit('{n}'),
    doublePoints: gameDoublePoints,
    focusMode: gameFocusMode,
    inkRefill: gameInkRefill('{n}'),
    pageEnd: gamePageEnd,
  );
}

/// "72.5" / "100" gibi kısa skor gösterimi.
String formatScore(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
