import 'package:equatable/equatable.dart';

class CompanyModel extends Equatable {
  final int id;
  final String name, sponsorStatus;
  final String? logo, website, careersUrl, city;
  final int openJobs;
  const CompanyModel({required this.id, required this.name, this.sponsorStatus = 'unchecked', this.logo, this.website, this.careersUrl, this.city, this.openJobs = 0});
  factory CompanyModel.fromJson(Map<String, dynamic> j) => CompanyModel(
      id: j['id'], name: j['name'], sponsorStatus: j['sponsor_status'] ?? 'unchecked', logo: j['logo'], website: j['website'], careersUrl: j['careers_url'], city: j['city'], openJobs: j['open_jobs'] ?? 0);
  bool get sponsor => sponsorStatus == 'recognised';
  @override
  List<Object?> get props => [id];
}

class JobModel extends Equatable {
  final int id;
  final String title, url, jobType, language;
  final CompanyModel company;
  final String? location, postedAt, firstSeen, snippet, description, stage, fitReason;
  final bool remote;
  final List<String> skills;
  final int? fit;
  final Map<String, dynamic>? salary;

  const JobModel({required this.id, required this.title, required this.url, required this.jobType, required this.language, required this.company, this.location, this.postedAt, this.firstSeen, this.snippet, this.description, this.stage, this.fitReason, this.remote = false, this.skills = const [], this.fit, this.salary});

  factory JobModel.fromJson(Map<String, dynamic> j) => JobModel(
        id: j['id'], title: j['title'], url: j['url'], jobType: j['job_type'] ?? 'job', language: j['language'] ?? 'unknown', company: CompanyModel.fromJson(j['company']),
        location: j['location'], postedAt: j['posted_at'], firstSeen: j['first_seen'], snippet: j['snippet'], description: j['description'], stage: j['stage'], fitReason: j['fit_reason'],
        remote: j['remote'] ?? false, skills: ((j['skills'] as List?) ?? []).map((e) => e.toString()).toList(), fit: j['fit'], salary: j['salary'] == null ? null : Map<String, dynamic>.from(j['salary']),
      );

  String? get date => postedAt ?? firstSeen;
  @override
  List<Object?> get props => [id, stage, description];
}

class Facet extends Equatable {
  final String value;
  final int count;
  const Facet(this.value, this.count);
  @override
  List<Object?> get props => [value, count];
}

class JobSearchResult {
  final List<JobModel> items;
  final int total, page;
  final Map<String, List<Facet>> facets;
  JobSearchResult(this.items, this.total, this.page, this.facets);
  factory JobSearchResult.fromJson(Map<String, dynamic> j) => JobSearchResult(
        (j['items'] as List).map((e) => JobModel.fromJson(e)).toList(), j['total'], j['page'],
        {for (final e in ((j['facets'] as Map?) ?? {}).entries) if (e.value is List) e.key: (e.value as List).map((f) => Facet(f['value'].toString(), f['count'])).toList()},
      );
}

/// Search criteria shared by the jobs screen, saved searches and alerts.
class JobFilters extends Equatable {
  final String q, mode;
  final String? sort, kind;
  final List<String> jobType, city, skills, language;
  final bool? remote, sponsor;
  final int? days;
  const JobFilters({this.q = '', this.mode = 'hybrid', this.sort, this.kind, this.jobType = const [], this.city = const [], this.skills = const [], this.language = const [], this.remote, this.sponsor, this.days});

  JobFilters copyWith({String? q, String? mode, Object? sort = _k, Object? kind = _k, List<String>? jobType, List<String>? city, List<String>? skills, List<String>? language, Object? remote = _k, Object? sponsor = _k, Object? days = _k}) => JobFilters(
        q: q ?? this.q, mode: mode ?? this.mode, sort: identical(sort, _k) ? this.sort : sort as String?, kind: identical(kind, _k) ? this.kind : kind as String?, jobType: jobType ?? this.jobType, city: city ?? this.city,
        skills: skills ?? this.skills, language: language ?? this.language, remote: identical(remote, _k) ? this.remote : remote as bool?, sponsor: identical(sponsor, _k) ? this.sponsor : sponsor as bool?, days: identical(days, _k) ? this.days : days as int?);
  static const _k = Object();

  Map<String, dynamic> toQuery() => {
        if (q.isNotEmpty) 'q': q, 'mode': mode, if (sort != null) 'sort': sort, if (kind != null) 'kind': kind, if (jobType.isNotEmpty) 'job_type': jobType, if (city.isNotEmpty) 'city': city,
        if (skills.isNotEmpty) 'skills': skills, if (language.isNotEmpty) 'language': language, if (remote == true) 'remote': true, if (sponsor == true) 'sponsor': true, if (days != null) 'days': days,
      };
  int get activeCount => [jobType, city, skills, language].where((l) => l.isNotEmpty).length + (remote == true ? 1 : 0) + (sponsor == true ? 1 : 0) + (days != null ? 1 : 0);
  @override
  List<Object?> get props => [q, mode, sort, kind, jobType, city, skills, language, remote, sponsor, days];
}
