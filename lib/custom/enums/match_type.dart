enum StringMatchType {
  contain("contains"),
  notContain("does not contain"),
  match("matches"),
  notMatch("does not matches"),
  startWith("starts with"),
  notStartWith("does not start with"),
  endWith("ends with"),
  notEndWith("does not end with");

  final String text;

  const StringMatchType(this.text);
}

enum NumRangeMatchType {
  lt("larger than"),
  st("smaller than"),
  lte("larger than or equal"),
  ste("smaller than or equal"),
  btn("between");

  final String text;
  const NumRangeMatchType(this.text);
}
