class SharedElementRepository {
  SharedElementRepository();

  DateTime _displayDate  = DateTime.now();
  DateTime get displayDate => _displayDate;

  void updateDisplayDate(DateTime newDate) {
    _displayDate = newDate;
  }

}