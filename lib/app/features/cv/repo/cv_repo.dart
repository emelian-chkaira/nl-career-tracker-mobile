import 'package:dio/dio.dart' show Options;

import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/api/errors/executer.dart';

class CvRepo {
  final _api = ApiClient();
  Future<Map<String, dynamic>> extract(List<int> bytes, String filename) =>
      Executer.execute(() async => Map<String, dynamic>.from(await _api.uploadFile(Endpoints.cvExtract, bytes, query: {'filename': filename})), name: 'cvExtract');
  Future<Map<String, dynamic>> tailor(Map<String, dynamic> cv, String latex, int jobId) =>
      Executer.execute(() async => Map<String, dynamic>.from(await _api.request(Endpoints.cvTailor, method: HttpMethod.post, data: {'cv': cv, 'latex': latex, 'job_id': jobId}, withToken: false)), name: 'cvTailor');
  Future<String> coverLetter(Map<String, dynamic> cv, int jobId) =>
      Executer.execute(() async => (await _api.request(Endpoints.cvCoverLetter, method: HttpMethod.post, data: {'cv': cv, 'job_id': jobId}, withToken: false))['text'] as String, name: 'coverLetter');
  Future<String> latex(Map<String, dynamic> cv) =>
      Executer.execute(() async => (await _api.request(Endpoints.cvLatex, method: HttpMethod.post, data: {'cv': cv}, withToken: false))['latex'] as String, name: 'cvLatex');
  Future<Map<String, dynamic>> compilers() => Executer.execute(() async => Map<String, dynamic>.from(await _api.request(Endpoints.cvCompilers, withToken: false)), name: 'cvCompilers');
  Future<Map<String, dynamic>> aiTailor(Map<String, dynamic> cv, int jobId, bool consent) =>
      Executer.execute(() async => Map<String, dynamic>.from(await _api.request(Endpoints.cvAiTailor, method: HttpMethod.post, data: {'cv': cv, 'job_id': jobId, 'consent': consent}, withToken: false, options: Options(receiveTimeout: const Duration(seconds: 120)))), name: 'cvAiTailor');
  /// -> {pdf_b64, engine, bytes}. mode 'public' sends the CV to a third-party LaTeX service and needs [consent].
  Future<Map<String, dynamic>> pdf(String latex, {required String mode, required bool consent}) =>
      Executer.execute(() async => Map<String, dynamic>.from(await _api.request(Endpoints.cvPdf, method: HttpMethod.post, data: {'latex': latex, 'mode': mode, 'allow_public': consent}, withToken: false)), name: 'cvPdf');
}
