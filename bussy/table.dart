typedef Holiday = Map<String, String>;

Map<String, List<int>> stops = {
  "NSch": [0738, 0805, 1005, 1135, 1305, 1435, 1610, 1710, 1855],
  "Sch": [0738, 0836, 1005, 1135, 1305, 1435, 1610, 1710, 1855],
  "Wknd": [0805, 1005, 1135, 1305, 1435, 1610, 1855],
};

List<Holiday> schoolHolidays = [
  {"name": "February half term", "start": "12/02/2024", "end": "16/02/2024"},
  {"name": "Easter ", "start": "29/03/2024", "end": "12/04/2024"},
  {"name": "Spring half term", "start": "27/05/2024", "end": "31/05/2024"},
  {"name": "Summer ", "start": "25/07/2024", "end": "30/08/2024"},
  {"name": "Autumn half term", "start": "28/10/2024", "end": "01/11/2024"},
  {"name": "Christmas", "start": "23/12/2024", "end": "03/01/2025"}
];

List<Holiday> publicHolidays = [
  {"name": "New Year's Day", "date": "01/01/2024"},
  {"name": "Good Friday", "date": "29/03/2024"},
  {"name": "Easter Monday", "date": "01/04/2024"},
  {"name": "Early May bank holiday", "date": "06/05/2024"},
  {"name": "Spring bank holiday", "date": "27/05/2024"},
  {"name": "Summer bank holiday", "date": "26/08/2024"},
  {"name": "Christmas Day", "date": "25/12/2024"},
  {"name": "Boxing Day", "date": "26/12/2024"}
];
