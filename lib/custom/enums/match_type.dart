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
