extension PsqlIntervalFormatter on String {
  Duration parseInterval() {
    // Split the interval string into hours, minutes, and seconds
    List<String> timeParts = split(':');

    if (timeParts.length != 3) {
      throw const FormatException('Invalid interval format. Expected format: HH:mm:ss');
    }

    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);
    int seconds = int.parse(timeParts[2]);

    // Create and return a Duration object
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }
}
