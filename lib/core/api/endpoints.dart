import '../config/app_config.dart';

class Endpoints {
  static const base = '${AppConfig.apiUrl}/api/v1';

  // auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const me = '/auth/me';
  static const profile = '/auth/profile';
  static const password = '/auth/password';
  static const authConfig = '/auth/config';
  static const google = '/auth/google';
  static const forgot = '/auth/forgot';
  static const reset = '/auth/reset';
  static const verify = '/auth/verify';
  static const verifySend = '/auth/verify/send';

  // jobs & companies
  static const jobs = '/jobs';
  static String job(int id) => '/jobs/$id';
  static const suggest = '/jobs/suggest';
  static const companies = '/companies';

  // me
  static const pipeline = '/me/pipeline';
  static String myJob(int id) => '/me/jobs/$id';
  static const searches = '/me/searches';
  static String search(int id) => '/me/searches/$id';
  static const notifications = '/me/notifications';
  static const notificationsReadAll = '/me/notifications/read-all';
  static String notificationRead(int id) => '/me/notifications/$id/read';

  // analytics & cv
  static const analytics = '/analytics/overview';
  static const cvExtract = '/cv/extract';
  static const cvTailor = '/cv/tailor';
  static const cvCoverLetter = '/cv/cover-letter';
  static const cvLatex = '/cv/latex';
  static const cvAiTailor = '/cv/ai-tailor';
  static const cvPdf = '/cv/pdf';
  static const cvCompilers = '/cv/compilers';
}
