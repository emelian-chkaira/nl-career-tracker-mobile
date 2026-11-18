import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/format.dart';
import '../../../global/widgets/widgets.dart';
import '../models/job_model.dart';

class CompanyLogo extends StatelessWidget {
  const CompanyLogo(this.c, {super.key, this.size = 48});
  final CompanyModel c;
  final double size;
  @override
  Widget build(BuildContext context) {
    final line = Theme.of(context).dividerColor;
    final fallback = Container(width: size, height: size, alignment: Alignment.center, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(size * .24)), child: Text(c.name.isEmpty ? '?' : c.name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: size * .4, color: Theme.of(context).colorScheme.onSurfaceVariant)));
    final logo = c.logo;
    if (logo == null || logo.isEmpty) return fallback;
    final url = logo.startsWith('http') ? logo : '${AppConfig.apiUrl}$logo';
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(size * .24), border: Border.all(color: line)),
      child: Image.network(url, fit: BoxFit.contain, errorBuilder: (_, _, _) => fallback),
    );
  }
}

bool _isNew(String? iso) {
  final d = iso == null ? null : DateTime.tryParse(iso);
  return d != null && DateTime.now().difference(d).inDays < 3;
}

class JobTile extends StatelessWidget {
  const JobTile({super.key, required this.job, required this.onTap});
  final JobModel job;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final place = [job.company.name, if (job.location?.isNotEmpty == true) job.location!.split(';').first.trim(), if (job.remote) 'Remote'].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CompanyLogo(job.company),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(job.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.25)),
                  const SizedBox(height: 2),
                  Text(place, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.bodySmall?.copyWith(color: muted)),
                  if (job.snippet != null && stripMarks(job.snippet).trim().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 5), child: Text(stripMarks(job.snippet), maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodySmall?.copyWith(color: muted))),
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 5, children: [
                    if (_isNew(job.date)) const Pill('New', color: Colors.green),
                    Pill(label(job.jobType)),
                    if (job.company.sponsor) const Pill('IND sponsor', color: Color(0xFF0E8A5F)),
                    if (job.stage != null) Pill(label(job.stage!), color: Colors.orange),
                    if (job.fit != null) Pill('${job.fit}% fit', color: Colors.teal),
                    ...job.skills.take(2).map((e) => Pill(e, outlined: true)),
                  ]),
                ]),
              ),
              const SizedBox(width: 8),
              Text(ago(job.date), style: t.labelSmall?.copyWith(color: muted)),
            ]),
          ),
        ),
      ),
    );
  }
}
