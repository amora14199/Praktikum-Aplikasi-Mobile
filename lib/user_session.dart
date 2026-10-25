class UserSession {
  static int id = 0;
  static String name = '';
  static String email = '';

  static void clear() {
    id = 0;
    name = '';
    email = '';
  }
}