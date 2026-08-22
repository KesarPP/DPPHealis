import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../screens/food_analysis_screen.dart';

class FfqExcelService {
  static final FfqExcelService _instance = FfqExcelService._internal();

  factory FfqExcelService() => _instance;

  FfqExcelService._internal();

  Excel? _excel;
  String? _filePath;
  final String _sheetName = 'FFQ Report';

  Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _filePath = '${dir.path}/ffq_latest.xlsx';
      
      final file = File(_filePath!);
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        _excel = Excel.decodeBytes(bytes);
        if (!_excel!.tables.keys.contains(_sheetName)) {
          _excel!.rename('Sheet1', _sheetName);
          _setupHeaders();
        }
      } else {
        _excel = Excel.createExcel();
        _excel!.rename('Sheet1', _sheetName);
        _setupHeaders();
        await saveToDisk();
      }
    } catch (e) {
      print('Error initializing FfqExcelService: $e');
    }
  }

  void _setupHeaders() {
    if (_excel == null) return;
    final sheet = _excel![_sheetName];
    sheet.appendRow([
      TextCellValue('Food Name'),
      TextCellValue('Frequency'),
      TextCellValue('Size'),
      TextCellValue('Quantity'),
      TextCellValue('Calories (kcal)')
    ]);
  }

  Future<void> updateRow(String foodName, FfqAnswer answer, double calories) async {
    if (_excel == null || _filePath == null) {
      await init();
    }
    
    if (_excel == null) return;

    final sheet = _excel![_sheetName];
    
    // Find if the food already exists in the sheet
    int existingRowIndex = -1;
    for (int i = 1; i < sheet.maxRows; i++) { // Start from 1 to skip header
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
      if (cell.value != null && cell.value.toString() == foodName) {
        existingRowIndex = i;
        break;
      }
    }

    final rowData = [
      TextCellValue(foodName),
      TextCellValue('${answer.frequency} × ${answer.timesPerDay}x'),
      TextCellValue(answer.size),
      TextCellValue(answer.quantityAtTime.toString()),
      TextCellValue(calories.toStringAsFixed(2)),
    ];

    if (existingRowIndex != -1) {
      // Update existing row
      sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: existingRowIndex), rowData[0]);
      sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: existingRowIndex), rowData[1]);
      sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: existingRowIndex), rowData[2]);
      sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: existingRowIndex), rowData[3]);
      sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: existingRowIndex), rowData[4]);
    } else {
      // Append new row
      sheet.appendRow(rowData);
    }

    // Save changes incrementally
    await saveToDisk();
  }

  Future<void> saveToDisk() async {
    try {
      if (_excel != null && _filePath != null) {
        final bytes = _excel!.encode();
        if (bytes != null) {
          final file = File(_filePath!);
          await file.writeAsBytes(bytes);
        }
      }
    } catch (e) {
      print('Error saving FFQ excel to disk: $e');
    }
  }
  
  String? get filePath => _filePath;
}
