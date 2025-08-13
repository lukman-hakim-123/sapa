class ValidationHelper {
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Masukkan $fieldName';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Masukkan email dengan benar';
    }
    return null;
  }

  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return 'Masukkan $fieldName';
    }
    if (value.length < minLength) {
      return '$fieldName harus minimal $minLength huruf';
    }
    return null;
  }

  // Fungsi untuk menggabungkan beberapa validator
  static String? validateMultiple(String? value, List<Function> validators) {
    for (var validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}
