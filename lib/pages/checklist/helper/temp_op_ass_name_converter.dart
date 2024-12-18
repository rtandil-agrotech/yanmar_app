String opAssNameConverter(String opAssName) {
  switch (opAssName) {
    case 'OP 3/1':
      return 'OP 3';
    case 'OP 3/2':
      return 'OP 4';
    case 'OP 4':
      return 'OP 5';
    case 'OP 5/1':
      return 'OP 6';
    case 'OP 5/2':
      return 'OP 7';
    case 'OP 6':
      return 'OP 8';
    case 'OP 7':
      return 'OP 9';
    case 'OP 8':
      return 'OP 10';
    case 'OP 9':
      return 'OP 11';
    case 'OP 10':
      return 'OP 12';
    case 'OP 11':
      return 'OP 13';
    default:
      return opAssName;
  }
}
