/**
 * Pure formatting helpers. Values that are not recognizable U.S. formats
 * are returned unchanged rather than guessed at.
 */
public with sharing class FormatUtils {
  /** 9195550123, 919.555.0123, +1 919 555 0123 -> (919) 555-0123 */
  public static String usPhone(String raw) {
    if (String.isBlank(raw)) {
      return raw;
    }
    String digits = raw.replaceAll('[^0-9]', '');
    if (digits.length() == 11 && digits.startsWith('1')) {
      digits = digits.substring(1);
    }
    if (digits.length() != 10) {
      return raw;
    }
    return '(' +
      digits.substring(0, 3) +
      ') ' +
      digits.substring(3, 6) +
      '-' +
      digits.substring(6);
  }

  /** 27601, 276011234, 27601 1234 -> 27601 or 27601-1234 */
  public static String usZip(String raw) {
    if (String.isBlank(raw)) {
      return raw;
    }
    String digits = raw.replaceAll('[^0-9]', '');
    if (digits.length() == 5) {
      return digits;
    }
    if (digits.length() == 9) {
      return digits.substring(0, 5) + '-' + digits.substring(5);
    }
    return raw.trim();
  }
}
