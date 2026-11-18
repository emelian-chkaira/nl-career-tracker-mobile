import 'package:career_tracker/app/features/jobs/models/job_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('JobFilters builds the API query and counts active filters', () {
    const f = JobFilters(q: 'flutter', city: ['Eindhoven'], remote: true, kind: 'internship');
    final q = f.toQuery();
    expect(q['q'], 'flutter');
    expect(q['city'], ['Eindhoven']);
    expect(q['remote'], true);
    expect(q['kind'], 'internship');
    expect(f.activeCount, 2);
    expect(f.copyWith(remote: null).toQuery().containsKey('remote'), false);
  });

  test('JobModel parses an API job', () {
    final j = JobModel.fromJson({'id': 1, 'title': 'Flutter Dev', 'url': 'https://x', 'job_type': 'job', 'language': 'english_ok', 'company': {'id': 2, 'name': 'Acme', 'sponsor_status': 'recognised'}, 'skills': ['flutter']});
    expect(j.company.sponsor, true);
    expect(j.skills, ['flutter']);
  });

  test('search result ignores scalar facets', () {
    final r = JobSearchResult.fromJson({'items': [], 'total': 0, 'page': 1, 'facets': {'city': [{'value': 'Delft', 'count': 2}], 'sponsor': 857}});
    expect(r.facets['city']!.single.value, 'Delft');
    expect(r.facets.containsKey('sponsor'), false);
  });
}
