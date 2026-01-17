import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class PdfExportService {
  static Future<void> exportTasksToPdf({
    required DateTime startDate,
    required DateTime endDate,
    required String fileName,
  }) async {
    final dbHelper = DatabaseHelper();
    final pdf = pw.Document();
    
    // Get all dates in the range
    final allDates = await dbHelper.getAllTodoListDates();
    final tasksData = <Map<String, dynamic>>[];
    
    // Collect tasks for each day in the range
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final dateString = DateFormat('yyyy-MM-dd').format(currentDate);
      
      if (!allDates.contains(dateString)) {
        continue; // Skip dates without tasks
      }
      
      final todoList = await dbHelper.getOrCreateTodoList(dateString);
      final todoItems = await dbHelper.getTodoItems(todoList.id!);
      
      if (todoItems.isNotEmpty) {
        final completedCount = todoItems.where((item) => item.isCompleted).length;
        
        tasksData.add({
          'date': currentDate,
          'items': todoItems,
          'completedCount': completedCount,
          'totalCount': todoItems.length,
        });
      }
    }
    
    // Add page to PDF
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 24),
                child: pw.Text(
                  'myDaily Planner',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              
              // Date range
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 32),
                child: pw.Text(
                  'Tasks from ${DateFormat('MMM d, yyyy').format(startDate)} to ${DateFormat('MMM d, yyyy').format(endDate)}',
                  style: const pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
              
              // Tasks section
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Text(
                  'Tasks',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
              ),
              
              // Tasks list
              ...tasksData.map((taskData) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 24),
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Date header
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(taskData['date']),
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue700,
                          ),
                        ),
                        pw.Text(
                          '${taskData['completedCount']}/${taskData['totalCount']} completed',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    
                    pw.SizedBox(height: 12),
                    
                    // Task items
                    ...taskData['items'].map((item) => pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Checkbox
                          pw.Container(
                            width: 12,
                            height: 12,
                            margin: const pw.EdgeInsets.only(right: 8, top: 2),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey400),
                              borderRadius: pw.BorderRadius.circular(2),
                              color: item.isCompleted ? PdfColors.green500 : PdfColors.white,
                            ),
                            child: item.isCompleted
                                ? pw.Icon(
                                    const pw.IconData(0xE876),
                                    color: PdfColors.white,
                                    size: 8,
                                  )
                                : null,
                          ),
                          
                          // Task text
                          pw.Expanded(
                            child: pw.Text(
                              item.title,
                              style: pw.TextStyle(
                                fontSize: 12,
                                decoration: item.isCompleted
                                    ? pw.TextDecoration.lineThrough
                                    : pw.TextDecoration.none,
                                color: item.isCompleted
                                    ? PdfColors.grey500
                                    : PdfColors.grey800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              )).toList(),
            ],
          );
        },
      ),
    );
    
    // Save and print
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }
}
