import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('tr')];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'TÜKENMEZ'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'GPA Run'**
  String get appSubtitle;

  /// No description provided for @tagline.
  ///
  /// In tr, this message translates to:
  /// **'Mürekkebin bitebilir, hırsın bitmez.'**
  String get tagline;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Defter açılıyor…'**
  String get loading;

  /// No description provided for @loadError.
  ///
  /// In tr, this message translates to:
  /// **'Veriler yüklenemedi:\n{error}'**
  String loadError(String error);

  /// No description provided for @menuCourses.
  ///
  /// In tr, this message translates to:
  /// **'Dersler'**
  String get menuCourses;

  /// No description provided for @menuCgpa.
  ///
  /// In tr, this message translates to:
  /// **'Kümülatif GPA'**
  String get menuCgpa;

  /// No description provided for @menuSemester.
  ///
  /// In tr, this message translates to:
  /// **'{n}. dönem'**
  String menuSemester(int n);

  /// No description provided for @menuReset.
  ///
  /// In tr, this message translates to:
  /// **'İlerlemeyi sıfırla'**
  String get menuReset;

  /// No description provided for @resetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Her şey silinsin mi?'**
  String get resetTitle;

  /// No description provided for @resetBody.
  ///
  /// In tr, this message translates to:
  /// **'Transkript ve yarım kalan sınavlar silinir. Geri alınamaz.'**
  String get resetBody;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @resetConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırla'**
  String get resetConfirm;

  /// No description provided for @credits.
  ///
  /// In tr, this message translates to:
  /// **'{n} kredi'**
  String credits(int n);

  /// No description provided for @statusNotStarted.
  ///
  /// In tr, this message translates to:
  /// **'Başlanmadı'**
  String get statusNotStarted;

  /// No description provided for @statusInProgress.
  ///
  /// In tr, this message translates to:
  /// **'{done}/{total} sınav bitti'**
  String statusInProgress(int done, int total);

  /// No description provided for @statusPassed.
  ///
  /// In tr, this message translates to:
  /// **'Geçti'**
  String get statusPassed;

  /// No description provided for @statusFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kaldı: tekrar alınmalı'**
  String get statusFailed;

  /// No description provided for @attempt.
  ///
  /// In tr, this message translates to:
  /// **'{n}. deneme'**
  String attempt(int n);

  /// No description provided for @assessmentQuiz1.
  ///
  /// In tr, this message translates to:
  /// **'Quiz 1'**
  String get assessmentQuiz1;

  /// No description provided for @assessmentMidterm.
  ///
  /// In tr, this message translates to:
  /// **'Midterm'**
  String get assessmentMidterm;

  /// No description provided for @assessmentQuiz2.
  ///
  /// In tr, this message translates to:
  /// **'Quiz 2'**
  String get assessmentQuiz2;

  /// No description provided for @assessmentProject.
  ///
  /// In tr, this message translates to:
  /// **'Proje / Lab'**
  String get assessmentProject;

  /// No description provided for @assessmentFinal.
  ///
  /// In tr, this message translates to:
  /// **'Final'**
  String get assessmentFinal;

  /// No description provided for @syllabus.
  ///
  /// In tr, this message translates to:
  /// **'İzlence'**
  String get syllabus;

  /// No description provided for @colAssessment.
  ///
  /// In tr, this message translates to:
  /// **'Sınav'**
  String get colAssessment;

  /// No description provided for @colWeight.
  ///
  /// In tr, this message translates to:
  /// **'Ağırlık'**
  String get colWeight;

  /// No description provided for @colDuration.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get colDuration;

  /// No description provided for @colScore.
  ///
  /// In tr, this message translates to:
  /// **'Skor'**
  String get colScore;

  /// No description provided for @colContribution.
  ///
  /// In tr, this message translates to:
  /// **'Katkı'**
  String get colContribution;

  /// No description provided for @seconds.
  ///
  /// In tr, this message translates to:
  /// **'{n} sn'**
  String seconds(int n);

  /// No description provided for @startAssessment.
  ///
  /// In tr, this message translates to:
  /// **'Sınava gir: {name}'**
  String startAssessment(String name);

  /// No description provided for @retakeCourse.
  ///
  /// In tr, this message translates to:
  /// **'Dersi tekrar al'**
  String get retakeCourse;

  /// No description provided for @retakeQuip.
  ///
  /// In tr, this message translates to:
  /// **'Herkes bir dersi iki kere alır. Bazıları üç.'**
  String get retakeQuip;

  /// No description provided for @courseDone.
  ///
  /// In tr, this message translates to:
  /// **'Ders tamamlandı'**
  String get courseDone;

  /// No description provided for @readyTitle.
  ///
  /// In tr, this message translates to:
  /// **'{name}'**
  String readyTitle(String name);

  /// No description provided for @readyHintLanes.
  ///
  /// In tr, this message translates to:
  /// **'← → sola/sağa kaydır: satır atla'**
  String get readyHintLanes;

  /// No description provided for @readyHintJump.
  ///
  /// In tr, this message translates to:
  /// **'↑ yukarı kaydır: kalemi kaldır (zıpla)'**
  String get readyHintJump;

  /// No description provided for @readyHintDuck.
  ///
  /// In tr, this message translates to:
  /// **'↓ aşağı kaydır: yatık yazı (eğil)'**
  String get readyHintDuck;

  /// No description provided for @readyHintInk.
  ///
  /// In tr, this message translates to:
  /// **'Dikkat dağıtıcılar mürekkebini bitirir!'**
  String get readyHintInk;

  /// No description provided for @start.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get start;

  /// No description provided for @hudPause.
  ///
  /// In tr, this message translates to:
  /// **'Duraklat'**
  String get hudPause;

  /// No description provided for @effectDouble.
  ///
  /// In tr, this message translates to:
  /// **'x2'**
  String get effectDouble;

  /// No description provided for @effectFocus.
  ///
  /// In tr, this message translates to:
  /// **'Odak'**
  String get effectFocus;

  /// No description provided for @effectReversed.
  ///
  /// In tr, this message translates to:
  /// **'Ters!'**
  String get effectReversed;

  /// No description provided for @pauseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mola'**
  String get pauseTitle;

  /// No description provided for @resume.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get resume;

  /// No description provided for @quitAssessment.
  ///
  /// In tr, this message translates to:
  /// **'Sınavdan çık'**
  String get quitAssessment;

  /// No description provided for @quitWarning.
  ///
  /// In tr, this message translates to:
  /// **'Çıkarsan bu sınav baştan başlar.'**
  String get quitWarning;

  /// No description provided for @summaryPageEnd.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa sonu!'**
  String get summaryPageEnd;

  /// No description provided for @summaryInkOut.
  ///
  /// In tr, this message translates to:
  /// **'Mürekkep bitti!'**
  String get summaryInkOut;

  /// No description provided for @rowCollected.
  ///
  /// In tr, this message translates to:
  /// **'Toplanan puan'**
  String get rowCollected;

  /// No description provided for @rowPenalty.
  ///
  /// In tr, this message translates to:
  /// **'Ceza'**
  String get rowPenalty;

  /// No description provided for @rowMax.
  ///
  /// In tr, this message translates to:
  /// **'Sayfadaki maksimum'**
  String get rowMax;

  /// No description provided for @rowBase.
  ///
  /// In tr, this message translates to:
  /// **'Ham skor'**
  String get rowBase;

  /// No description provided for @rowBonus.
  ///
  /// In tr, this message translates to:
  /// **'Bonus Soru'**
  String get rowBonus;

  /// No description provided for @rowCleanPaper.
  ///
  /// In tr, this message translates to:
  /// **'Temiz Kağıt'**
  String get rowCleanPaper;

  /// No description provided for @rowInkCap.
  ///
  /// In tr, this message translates to:
  /// **'Mürekkep bitti: tavan 50'**
  String get rowInkCap;

  /// No description provided for @rowLevelScore.
  ///
  /// In tr, this message translates to:
  /// **'Level skoru'**
  String get rowLevelScore;

  /// No description provided for @continueButton.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get continueButton;

  /// No description provided for @seeCourseResult.
  ///
  /// In tr, this message translates to:
  /// **'Ders sonucunu gör'**
  String get seeCourseResult;

  /// No description provided for @courseResult.
  ///
  /// In tr, this message translates to:
  /// **'Ders Sonucu'**
  String get courseResult;

  /// No description provided for @total.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get total;

  /// No description provided for @gpaLabel.
  ///
  /// In tr, this message translates to:
  /// **'GPA'**
  String get gpaLabel;

  /// No description provided for @backToCourse.
  ///
  /// In tr, this message translates to:
  /// **'Derse dön'**
  String get backToCourse;

  /// No description provided for @backToMenu.
  ///
  /// In tr, this message translates to:
  /// **'Ana menü'**
  String get backToMenu;

  /// No description provided for @gameFinalStretch.
  ///
  /// In tr, this message translates to:
  /// **'SON 5 DAKİKA'**
  String get gameFinalStretch;

  /// No description provided for @gameNotificationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayşe'**
  String get gameNotificationTitle;

  /// No description provided for @gameNotificationBody.
  ///
  /// In tr, this message translates to:
  /// **'hikaye paylaştı 👀'**
  String get gameNotificationBody;

  /// No description provided for @gameFriendBubble.
  ///
  /// In tr, this message translates to:
  /// **'Kantin?'**
  String get gameFriendBubble;

  /// No description provided for @gameExtraCredit.
  ///
  /// In tr, this message translates to:
  /// **'+{n} ekstra kredi'**
  String gameExtraCredit(String n);

  /// No description provided for @gameDoublePoints.
  ///
  /// In tr, this message translates to:
  /// **'Fosforlu x2!'**
  String get gameDoublePoints;

  /// No description provided for @gameFocusMode.
  ///
  /// In tr, this message translates to:
  /// **'Odak modu'**
  String get gameFocusMode;

  /// No description provided for @gameInkRefill.
  ///
  /// In tr, this message translates to:
  /// **'+{n} mürekkep'**
  String gameInkRefill(String n);

  /// No description provided for @gamePageEnd.
  ///
  /// In tr, this message translates to:
  /// **'— sayfa sonu —'**
  String get gamePageEnd;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
