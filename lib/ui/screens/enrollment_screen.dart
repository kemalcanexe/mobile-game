import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/generated/app_localizations.dart';
import '../../app/palette.dart';
import '../../app/progress_controller.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../widgets/paper_backdrop.dart';
import '../widgets/post_it_button.dart';
import '../widgets/torn_card.dart';

/// Dönem başı ders seçimi (Ekle-Bırak haftası).
class EnrollmentScreen extends ConsumerStatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  ConsumerState<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends ConsumerState<EnrollmentScreen> {
  List<String>? _selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final content = ref.watch(contentProvider).requireValue;
    final controller = ref.read(progressProvider.notifier);
    final offer = controller.offerFor(content.curriculum, content.grading);
    // başlangıçta: zorunlu retake'ler + kalan yere sırayla dersler
    final selected = _selected ??= offer.available.take(offer.max).toList();
    final issues = controller.checkEnrollment(
      selected,
      content.curriculum,
      content.grading,
    );

    void toggle(String id) {
      if (offer.requiredRetakes.contains(id)) return;
      setState(() {
        selected.contains(id) ? selected.remove(id) : selected.add(id);
      });
    }

    return Scaffold(
      body: PaperBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(56, 8, 20, 32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Palette.ink),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Text(l.enrollTitle, style: AppTheme.hand(48)),
              Text(
                l.enrollSubtitle(controller.semesterIndex),
                style: AppTheme.ui(17, color: Palette.pencil),
              ),
              if (offer.onProbation)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l.probationHint(offer.max),
                    style: AppTheme.ui(15, color: Palette.teacherRed),
                  ),
                ),
              const SizedBox(height: 18),
              if (offer.available.isEmpty)
                Text(l.enrollNone, style: AppTheme.hand(26)),
              for (final id in offer.available)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CourseOption(
                    courseId: id,
                    selected: selected.contains(id),
                    retake: offer.requiredRetakes.contains(id),
                    onTap: () => toggle(id),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                l.enrollCounter(selected.length, offer.min, offer.max),
                textAlign: TextAlign.center,
                style: AppTheme.ui(
                  16,
                  color: issues.isEmpty ? Palette.darkText : Palette.teacherRed,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: PostItButton(
                  label: l.enrollConfirm,
                  onPressed: issues.isEmpty && offer.available.isNotEmpty
                      ? () async {
                          await controller.enroll(
                            selected,
                            content.curriculum,
                            content.grading,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseOption extends ConsumerWidget {
  const _CourseOption({
    required this.courseId,
    required this.selected,
    required this.retake,
    required this.onTap,
  });

  final String courseId;
  final bool selected;
  final bool retake;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final course = ref.read(contentProvider).requireValue.course(courseId);
    return Semantics(
      checked: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: TornCard(
          color: selected ? Colors.white : const Color(0xFFF2EFE6),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: retake ? Palette.teacherRed : Palette.ink,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.code, style: AppTheme.hand(30)),
                    Text(
                      '"${course.nickname}" · ${l.credits(course.credits)}',
                      style: AppTheme.ui(15, color: Palette.pencil),
                    ),
                    if (retake)
                      Text(
                        l.enrollRetakeTag,
                        style: AppTheme.ui(15, color: Palette.teacherRed),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
