import 'dart:developer';
import 'dart:ui';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import 'asset_loader.dart';

//
// load example/resources/langs/langs.csv
//
class CsvAssetLoader extends AssetLoader {
  CSVParser? csvParser;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    if (csvParser == null) {
      log('easy localization loader: load csv file $path');
      csvParser = CSVParser(await rootBundle.loadString(path));
    } else {
      log('easy localization loader: CSV parser already loaded, read cache');
    }
    return csvParser!.getLanguageMap(locale.toString());
  }
}

class CSVParser {
  final String fieldDelimiter;
  final String strings;
  final List<List<dynamic>> lines;

  CSVParser(this.strings, {this.fieldDelimiter = ','})
      : lines = _convertN(
      CsvToListConverter()
      .convert(strings, fieldDelimiter: fieldDelimiter)
  );

  static List<List<dynamic>> _convertN(List<List<dynamic>> lines) {
    // converts //n to /n
    lines.forEach((lineList) {
      lineList.asMap().forEach((key, value) {
        if ((value is String) && value.contains('\\n')) {
          lineList[key] = value.replaceAll('\\n', '\n');
        }
      });
    });
    return lines;
  }

  List getLanguages() {
    return lines.first.sublist(1, lines.first.length);
  }

  Map<String, dynamic> getLanguageMap(String localeName) {
    final indexLocale = lines.first.indexOf(localeName);
    if (indexLocale < 0) {
      throw Exception("Locale $localeName not found in csv file. Available locales: ${lines.first}");
    }
    var translations = <String, dynamic>{};
    for (var i = 1; i < lines.length; i++) {
      translations.addAll({lines[i][0]: lines[i][indexLocale]});
    }
    return translations;
  }
}
