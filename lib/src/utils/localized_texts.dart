class LocalizedTexts {
  const LocalizedTexts();

  String required() => 'Required';
  String minLength({required int minLength}) =>
      'Should not be shorter than $minLength characters';
  String select() => 'Select';
  String removeItem() => 'Remove item';
  String addItem() => 'Add item';
  String addFile() => 'Add file';
  String shouldBeUri() => 'Should be a valid URL';
}
