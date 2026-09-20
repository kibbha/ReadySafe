import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/first_aid_guide.dart';

typedef FirstAidTextResolver = String Function(String key);

class FirstAidPdfService {
  const FirstAidPdfService._();

  static final _blue = PdfColor.fromHex('#1268D8');
  static final _red = PdfColor.fromHex('#D92D36');
  static final _orange = PdfColor.fromHex('#E98A15');
  static final _ink = PdfColor.fromHex('#172126');
  static final _muted = PdfColor.fromHex('#5D6A70');
  static final _line = PdfColor.fromHex('#D7E1E6');
  static final _softBlue = PdfColor.fromHex('#EDF5FF');
  static final _softRed = PdfColor.fromHex('#FFF0F1');

  static String _safe(String value) => value
      .replaceAll('’', "'")
      .replaceAll('‘', "'")
      .replaceAll('“', '"')
      .replaceAll('”', '"')
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll('…', '...')
      .replaceAll('·', '-')
      .replaceAll('\u00a0', ' ');

  static Future<Map<String, String>> _loadSvgs(FirstAidGuide guide) async {
    final result = <String, String>{};
    for (final step in guide.steps) {
      if (result.containsKey(step.illustrationAsset)) continue;
      try {
        result[step.illustrationAsset] =
            await rootBundle.loadString(step.illustrationAsset);
      } catch (_) {
        // PDF generation must remain available even if one optional
        // illustration asset cannot be decoded.
      }
    }
    return result;
  }

  static Future<Uint8List> build({
    required FirstAidGuide guide,
    required FirstAidTextResolver text,
    required bool english,
    required String? emergencyNumber,
  }) async {
    final document = pw.Document(
      title: _safe(text(guide.titleKey)),
      author: 'ReadySafe',
      subject: 'First aid quick reference',
    );
    final svgs = await _loadSvgs(guide);

    final columns = List.generate(3, (_) => <int>[]);
    if (guide.steps.isNotEmpty) {
      for (var i = 0; i < guide.steps.length; i++) {
        final column =
            math.min(2, (i * 3) ~/ math.max(1, guide.steps.length));
        columns[column].add(i);
      }
    }

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.all(7 * PdfPageFormat.mm),
        build: (_) => pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            for (var panelIndex = 0; panelIndex < 3; panelIndex++) ...[
              if (panelIndex > 0)
                pw.SizedBox(width: 4 * PdfPageFormat.mm),
              pw.Expanded(
                child: _panel(
                  guide: guide,
                  text: text,
                  english: english,
                  emergencyNumber: emergencyNumber,
                  indexes: columns[panelIndex],
                  panelIndex: panelIndex,
                  svgs: svgs,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return document.save();
  }

  static pw.Widget _panel({
    required FirstAidGuide guide,
    required FirstAidTextResolver text,
    required bool english,
    required String? emergencyNumber,
    required List<int> indexes,
    required int panelIndex,
    required Map<String, String> svgs,
  }) {
    final title = _safe(text(guide.titleKey));
    final summary = _safe(text(guide.summaryKey));

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _line, width: .8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            color: _red,
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: pw.Text(
              english ? 'QUICK REFERENCE' : 'AIDE-MÉMOIRE',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(9, 8, 9, 7),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title.toUpperCase(),
                  style: pw.TextStyle(
                    color: _blue,
                    fontSize: panelIndex == 0 ? 18 : 12,
                    fontWeight: pw.FontWeight.bold,
                    lineSpacing: 1,
                  ),
                ),
                if (panelIndex == 0) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    summary,
                    style: pw.TextStyle(
                      color: _muted,
                      fontSize: 8.5,
                      lineSpacing: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.Container(height: .8, color: _line),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  for (final stepIndex in indexes)
                    _step(
                      number: stepIndex + 1,
                      step: guide.steps[stepIndex],
                      text: text,
                      svg: svgs[guide.steps[stepIndex].illustrationAsset],
                    ),
                  if (panelIndex == 0 &&
                      guide.definitionTitleKey != null &&
                      guide.definitionBodyKey != null)
                    _definition(
                      _safe(text(guide.definitionTitleKey!)),
                      _safe(text(guide.definitionBodyKey!)),
                    ),
                  if (panelIndex == 2)
                    for (final warning in guide.warningKeys)
                      _warning(_safe(text(warning))),
                  if (panelIndex == 2) pw.Spacer(),
                  if (panelIndex == 2)
                    _sourcesAndEmergency(
                      guide: guide,
                      english: english,
                      emergencyNumber: emergencyNumber,
                    ),
                ],
              ),
            ),
          ),
          pw.Container(
            color: panelIndex == 2 ? _red : _softBlue,
            padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            child: pw.Text(
              panelIndex == 2
                  ? (emergencyNumber == null
                      ? (english
                          ? 'IMMEDIATE DANGER: USE VERIFIED EMERGENCY NUMBERS'
                          : 'DANGER IMMÉDIAT : UTILISER LES NUMÉROS VÉRIFIÉS')
                      : (english
                          ? 'IMMEDIATE DANGER: CALL $emergencyNumber'
                          : 'DANGER IMMÉDIAT : APPELER LE $emergencyNumber'))
                  : 'ReadySafe - ${guide.guidelineVersion}',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                color: panelIndex == 2 ? PdfColors.white : _blue,
                fontSize: 7.4,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _step({
    required int number,
    required FirstAidStep step,
    required FirstAidTextResolver text,
    required String? svg,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _line, width: .6)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 18,
            height: 18,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              color: _blue,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Text(
              '$number',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (step.headingKey != null) ...[
                  pw.Text(
                    _safe(text(step.headingKey!)).toUpperCase(),
                    style: pw.TextStyle(
                      color: _blue,
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                ],
                pw.Text(
                  _safe(text(step.textKey)),
                  style: pw.TextStyle(
                    color: _ink,
                    fontSize: 8.4,
                    fontWeight: pw.FontWeight.bold,
                    lineSpacing: 1.4,
                  ),
                ),
                for (final detailKey in step.detailKeys) ...[
                  pw.SizedBox(height: 3),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 4,
                        height: 4,
                        margin: const pw.EdgeInsets.only(top: 3.5, right: 5),
                        color: PdfColors.black,
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          _safe(text(detailKey)),
                          style: pw.TextStyle(
                            color: _ink,
                            fontSize: 7.3,
                            lineSpacing: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (step.cprPacing) ...[
                  pw.SizedBox(height: 4),
                  pw.Wrap(
                    spacing: 4,
                    runSpacing: 3,
                    children: [
                      _metric('100-120/min', _blue),
                      _metric('5-6 cm', _red),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (svg != null) ...[
            pw.SizedBox(width: 5),
            pw.SizedBox(
              width: 52,
              height: 48,
              child: pw.SvgImage(svg: svg),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _metric(String label, PdfColor color) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: .7),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Text(
          label,
          style: pw.TextStyle(
            color: color,
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );

  static pw.Widget _definition(String title, String body) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 4),
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          color: _softBlue,
          border: pw.Border.all(color: _blue, width: .5),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                color: _blue,
                fontSize: 7.7,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              body,
              style: pw.TextStyle(
                color: _ink,
                fontSize: 7.1,
                lineSpacing: 1.3,
              ),
            ),
          ],
        ),
      );

  static pw.Widget _warning(String text) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 5),
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          color: _softRed,
          border: pw.Border.all(color: _red, width: .5),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            color: _red,
            fontSize: 7.2,
            fontWeight: pw.FontWeight.bold,
            lineSpacing: 1.3,
          ),
        ),
      );

  static pw.Widget _sourcesAndEmergency({
    required FirstAidGuide guide,
    required bool english,
    required String? emergencyNumber,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFF7E8'),
        border: pw.Border.all(color: _orange, width: .6),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            english ? 'VERIFIED REFERENCES' : 'RÉFÉRENCES',
            style: pw.TextStyle(
              color: _orange,
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            '${guide.guidelineVersion} - reviewed ${guide.reviewedOn}',
            style: pw.TextStyle(color: _muted, fontSize: 6.6),
          ),
          for (final source in guide.sourceUris.take(4))
            pw.Text(
              source.host.replaceFirst('www.', ''),
              style: pw.TextStyle(color: _muted, fontSize: 6.3),
            ),
          pw.SizedBox(height: 4),
          pw.Text(
            emergencyNumber == null
                ? (english
                    ? 'Use the verified emergency numbers in ReadySafe.'
                    : 'Utilisez les numéros d’urgence vérifiés dans ReadySafe.')
                : (english
                    ? 'Emergency number: $emergencyNumber'
                    : 'Numéro d’urgence : $emergencyNumber'),
            style: pw.TextStyle(
              color: _red,
              fontSize: 7.2,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> share({
    required FirstAidGuide guide,
    required FirstAidTextResolver text,
    required bool english,
    required String? emergencyNumber,
  }) async {
    final bytes = await build(
      guide: guide,
      text: text,
      english: english,
      emergencyNumber: emergencyNumber,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'ReadySafe_${guide.id}.pdf',
    );
  }

  static Future<void> printGuide({
    required FirstAidGuide guide,
    required FirstAidTextResolver text,
    required bool english,
    required String? emergencyNumber,
  }) async {
    final bytes = await build(
      guide: guide,
      text: text,
      english: english,
      emergencyNumber: emergencyNumber,
    );
    await Printing.layoutPdf(
      name: 'ReadySafe_${guide.id}',
      onLayout: (_) async => bytes,
    );
  }
}
