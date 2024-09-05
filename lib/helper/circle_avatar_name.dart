String getInitialsFromName(String username) {
  List<String> nameComponents = username.split(' ');

  if (nameComponents.length == 1) {
    return nameComponents.first.toUpperCase()[0];
  } else {
    return '${nameComponents.first.toUpperCase()[0]}${nameComponents.elementAt(1).toUpperCase()[0]}';
  }
}
