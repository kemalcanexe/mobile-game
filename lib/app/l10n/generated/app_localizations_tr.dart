// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'TÜKENMEZ';

  @override
  String get appSubtitle => 'GPA Run';

  @override
  String get tagline => 'Mürekkebin bitebilir, hırsın bitmez.';

  @override
  String get loading => 'Defter açılıyor…';

  @override
  String loadError(String error) {
    return 'Veriler yüklenemedi:\n$error';
  }

  @override
  String get menuCourses => 'Dersler';

  @override
  String get menuCgpa => 'Kümülatif GPA';

  @override
  String menuSemester(int n) {
    return '$n. dönem';
  }

  @override
  String get menuReset => 'İlerlemeyi sıfırla';

  @override
  String get resetTitle => 'Her şey silinsin mi?';

  @override
  String get resetBody =>
      'Transkript ve yarım kalan sınavlar silinir. Geri alınamaz.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get resetConfirm => 'Sıfırla';

  @override
  String credits(int n) {
    return '$n kredi';
  }

  @override
  String get statusNotStarted => 'Başlanmadı';

  @override
  String statusInProgress(int done, int total) {
    return '$done/$total sınav bitti';
  }

  @override
  String get statusPassed => 'Geçti';

  @override
  String get statusFailed => 'Kaldı: tekrar alınmalı';

  @override
  String attempt(int n) {
    return '$n. deneme';
  }

  @override
  String get assessmentQuiz1 => 'Quiz 1';

  @override
  String get assessmentMidterm => 'Midterm';

  @override
  String get assessmentQuiz2 => 'Quiz 2';

  @override
  String get assessmentProject => 'Proje / Lab';

  @override
  String get assessmentFinal => 'Final';

  @override
  String get syllabus => 'İzlence';

  @override
  String get colAssessment => 'Sınav';

  @override
  String get colWeight => 'Ağırlık';

  @override
  String get colDuration => 'Süre';

  @override
  String get colScore => 'Skor';

  @override
  String get colContribution => 'Katkı';

  @override
  String seconds(int n) {
    return '$n sn';
  }

  @override
  String startAssessment(String name) {
    return 'Sınava gir: $name';
  }

  @override
  String get retakeQuip => 'Herkes bir dersi iki kere alır. Bazıları üç.';

  @override
  String get courseDone => 'Ders tamamlandı';

  @override
  String readyTitle(String name) {
    return '$name';
  }

  @override
  String get readyHintLanes => 'Sola/sağa kaydır: satır atla';

  @override
  String get readyHintJump => 'Yukarı kaydır: kalemi kaldır (zıpla)';

  @override
  String get readyHintDuck => 'Aşağı kaydır: yatık yazı (eğil)';

  @override
  String get readyHintInk => 'Dikkat dağıtıcılar mürekkebini bitirir!';

  @override
  String get start => 'Başla';

  @override
  String get hudPause => 'Duraklat';

  @override
  String get effectDouble => 'x2';

  @override
  String get effectFocus => 'Odak';

  @override
  String get effectReversed => 'Ters!';

  @override
  String get pauseTitle => 'Mola';

  @override
  String get resume => 'Devam';

  @override
  String get quitAssessment => 'Sınavdan çık';

  @override
  String get quitWarning => 'Çıkarsan bu sınav baştan başlar.';

  @override
  String get summaryPageEnd => 'Sayfa sonu!';

  @override
  String get summaryInkOut => 'Mürekkep bitti!';

  @override
  String get rowCollected => 'Toplanan puan';

  @override
  String get rowPenalty => 'Ceza';

  @override
  String get rowMax => 'Sayfadaki maksimum';

  @override
  String get rowBase => 'Ham skor';

  @override
  String get rowBonus => 'Bonus Soru';

  @override
  String get rowCleanPaper => 'Temiz Kağıt';

  @override
  String get rowInkCap => 'Mürekkep bitti: tavan 50';

  @override
  String get rowLevelScore => 'Level skoru';

  @override
  String get continueButton => 'Devam';

  @override
  String get seeCourseResult => 'Ders sonucunu gör';

  @override
  String get courseResult => 'Ders Sonucu';

  @override
  String get total => 'Toplam';

  @override
  String get gpaLabel => 'GPA';

  @override
  String get backToCourse => 'Derse dön';

  @override
  String get backToMenu => 'Ana menü';

  @override
  String get gameFinalStretch => 'SON 5 DAKİKA';

  @override
  String get gameNotificationTitle => 'Ayşe';

  @override
  String get gameNotificationBody => 'hikaye paylaştı';

  @override
  String get gameFriendBubble => 'Kantin?';

  @override
  String gameExtraCredit(String n) {
    return '+$n ekstra kredi';
  }

  @override
  String get gameDoublePoints => 'Fosforlu x2!';

  @override
  String get gameFocusMode => 'Odak modu';

  @override
  String gameInkRefill(String n) {
    return '+$n mürekkep';
  }

  @override
  String get gamePageEnd => '— sayfa sonu —';

  @override
  String get statusNotEnrolled => 'Bu dönem alınmadı';

  @override
  String get failedNextTerm =>
      'Bir sonraki dönemin ders seçiminde tekrar alınacak.';

  @override
  String get menuThisTerm => 'Bu dönemin dersleri';

  @override
  String get menuEnrollCta => 'Ders seçimine git';

  @override
  String menuEnrollHint(int n) {
    return '$n. dönem başlıyor. Önce derslerini seç.';
  }

  @override
  String get menuNoCourses =>
      'Bu dönem için yeni ders yok. Yeni dersler yakında!';

  @override
  String get menuTermReport => 'Dönem karnesini gör';

  @override
  String get menuTranscript => 'Transkript';

  @override
  String get probationBadge => 'Academic Probation';

  @override
  String probationHint(int n) {
    return 'CGPA 2.00\'ın altında, bir dönemde en fazla $n ders alabilirsin.';
  }

  @override
  String get enrollTitle => 'Ders Seçimi';

  @override
  String enrollSubtitle(int n) {
    return '$n. dönem · Ekle-Bırak haftası';
  }

  @override
  String enrollCounter(int selected, int min, int max) {
    return '$selected ders seçildi · en az $min, en fazla $max';
  }

  @override
  String get enrollRetakeTag => 'Tekrar (zorunlu)';

  @override
  String get enrollConfirm => 'Kaydımı yap';

  @override
  String get enrollNone => 'Seçilebilecek ders yok.';

  @override
  String get termReportTitle => 'Dönem Karnesi';

  @override
  String termReportSubtitle(int n) {
    return '$n. dönem';
  }

  @override
  String get colCourse => 'Ders';

  @override
  String get colCredits => 'Kredi';

  @override
  String get colLetter => 'Not';

  @override
  String get semesterGpa => 'Dönem GPA';

  @override
  String get deansList => 'Dean\'s List';

  @override
  String get deansListHint =>
      'Dönem GPA\'in 3.50 ve üstü: defter kapağına altın yıldız!';

  @override
  String get probationStamp => 'PROBATION';

  @override
  String get nextTerm => 'Sonraki döneme geç';

  @override
  String get seeTermReport => 'Dönem karnesini gör';

  @override
  String get transcriptTitle => 'Transkript';

  @override
  String get transcriptEmpty => 'Henüz tamamlanmış ders yok.';

  @override
  String get transcriptReplaced => 'R: tekrar alındı, CGPA\'e girmez';

  @override
  String honorCandidate(String honor) {
    return 'Onur derecesi adayı: $honor';
  }

  @override
  String get honorCum => 'Cum Laude';

  @override
  String get honorMagna => 'Magna Cum Laude';

  @override
  String get honorSumma => 'Summa Cum Laude';

  @override
  String requiredSemesters(int done, int total) {
    return 'Mezuniyet: $done/$total dönem';
  }
}
