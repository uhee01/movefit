extension DatetimeOperation on DateTime {
  bool isDayEqual(DateTime compareDate) {
    if (year == compareDate.year &&
        month == compareDate.month &&
        day == compareDate.day) {
      return true;
    } else {
      return false;
    }
  }
}
