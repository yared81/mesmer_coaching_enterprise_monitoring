import 'enterprise_entity.dart';
import 'enterprise_model.dart';

class CsvImportService {
  /// Parses a CSV string into a list of partial EnterpriseEntity objects for bulk import.
  /// Assumes the first row is the header.
  static List<EnterpriseEntity> parseEnterpriseCsv(String csvContent, {required String coachId, required String institutionId}) {
    final List<List<String>> rows = _parseCustomCsv(csvContent);
    if (rows.isEmpty) return [];

    final header = rows.first.map((e) => e.toLowerCase().trim()).toList();
    final dataRows = rows.skip(1);

    return dataRows.map((row) {
      final map = <String, String>{};
      for (var i = 0; i < header.length; i++) {
        if (i < row.length) {
          map[header[i]] = row[i];
        }
      }

      return EnterpriseEntity(
        id: '', // Will be assigned by backend/repo
        businessName: _val(map, ['enterprise name', 'business name', 'name']) ?? 'Unknown Business',
        ownerName: _val(map, ['owner name', 'owner']) ?? 'Unknown Owner',
        sector: _parseSector(_val(map, ['sector'])),
        employeeCount: int.tryParse(_val(map, ['employees', 'staff count', 'baseline employees']) ?? '0') ?? 0,
        location: _val(map, ['location', 'address', 'city']) ?? 'N/A',
        phone: _val(map, ['contact number', 'phone', 'contact']) ?? '',
        ownerAge: int.tryParse(_val(map, ['age', 'owner age']) ?? ''),
        businessActivity: _val(map, ['business activity', 'activity description', 'activity']),
        baselineEmployees: int.tryParse(_val(map, ['employees', 'baseline employees']) ?? '0') ?? 0,
        baselineRevenue: double.tryParse(_val(map, ['monthly revenue', 'baseline revenue', 'revenue']) ?? '0') ?? 0.0,
        recordKeepingSystem: _parseRecordKeeping(_val(map, ['record keeping', 'system'])),
        challenges: _val(map, ['key business challenges identified', 'challenges', 'pain points']),
        ownerGender: _parseGender(_val(map, ['gender'])),
        coachId: coachId,
        institutionId: institutionId,
        registeredAt: DateTime.now(),
        status: EnterpriseStatus.active,
      );
    }).toList();
  }

  /// Dependency-free CSV parser that handles quoted cells and commas.
  static List<List<String>> _parseCustomCsv(String content) {
    final List<List<String>> result = [];
    final lines = content.split(RegExp(r'\r?\n'));
    
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      
      final List<String> cells = [];
      bool inQuotes = false;
      StringBuffer currentCell = StringBuffer();
      
      for (int i = 0; i < line.length; i++) {
        String char = line[i];
        
        if (char == '"') {
          inQuotes = !inQuotes;
        } else if (char == ',' && !inQuotes) {
          cells.add(currentCell.toString().trim());
          currentCell.clear();
        } else {
          currentCell.write(char);
        }
      }
      cells.add(currentCell.toString().trim());
      result.add(cells);
    }
    return result;
  }

  static String? _val(Map<String, String> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key)) return map[key]?.trim();
    }
    return null;
  }

  static Sector _parseSector(String? val) {
    if (val == null) return Sector.other;
    final lower = val.toLowerCase();
    if (lower.contains('agri')) return Sector.agriculture;
    if (lower.contains('manuf')) return Sector.manufacturing;
    if (lower.contains('trade')) return Sector.trade;
    if (lower.contains('serv')) return Sector.services;
    if (lower.contains('const')) return Sector.construction;
    return Sector.other;
  }

  static OwnerGender? _parseGender(String? val) {
    if (val == null) return null;
    final lower = val.toLowerCase();
    if (lower.startsWith('m')) return OwnerGender.male;
    if (lower.startsWith('f')) return OwnerGender.female;
    return OwnerGender.other;
  }

  static RecordKeepingSystem? _parseRecordKeeping(String? val) {
    if (val == null) return RecordKeepingSystem.none;
    final lower = val.toLowerCase();
    if (lower.contains('none')) return RecordKeepingSystem.none;
    if (lower.contains('paper')) return RecordKeepingSystem.paper;
    if (lower.contains('digit')) return RecordKeepingSystem.digital;
    if (lower.contains('prof')) return RecordKeepingSystem.professional;
    return RecordKeepingSystem.none;
  }
}
