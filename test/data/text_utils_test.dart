import 'package:flutter_test/flutter_test.dart';
import 'package:heratmap/core/text_utils.dart';

void main() {
  group('normalizeSearchText', () {
    test('ارقام فارسی و عربی را به لاتین تبدیل می‌کند', () {
      // ۱۲۳ فارسی (U+06F1..) و ٠١ عربی (U+0660..)
      expect(normalizeSearchText('\u06F1\u06F2\u06F3'), '123');
      expect(normalizeSearchText('\u0660\u0661'), '01');
    });

    test('انواع ی و ک را یکسان می‌کند', () {
      // ي عربی (U+064A) ≡ ی فارسی (U+06CC) و ك عربی (U+0643) ≡ ک (U+06A9)
      expect(normalizeSearchText('\u064A'), normalizeSearchText('\u06CC'));
      expect(normalizeSearchText('\u0643'), normalizeSearchText('\u06A9'));
    });

    test('نیم‌فاصله، کشیدگی و نویسه‌های جهت را حذف می‌کند', () {
      expect(normalizeSearchText('a\u200Cb'), 'ab'); // نیم‌فاصله
      expect(normalizeSearchText('a\u200Db'), 'ab'); // ZWJ
      expect(normalizeSearchText('a\u0640b'), 'ab'); // کشیدگی
      expect(normalizeSearchText('\u200F\u200Ea'), 'a'); // RLM/LRM
    });

    test('حرکات را حذف می‌کند', () {
      expect(normalizeSearchText('a\u064E\u0650b'), 'ab');
      expect(normalizeSearchText('a\u0670b'), 'ab');
    });

    test('هم‌ارزهای الف را یکسان می‌کند', () {
      expect(normalizeSearchText('\u0622'), '\u0627'); // آ ≡ ا
      expect(normalizeSearchText('\u0623'), '\u0627'); // أ ≡ ا
      expect(normalizeSearchText('\u0625'), '\u0627'); // إ ≡ ا
    });

    test('فاصله‌های تکراری را جمع و حروف لاتین را کوچک می‌کند', () {
      expect(normalizeSearchText('  Zolal   Mowaffaq '), 'zolal mowaffaq');
      expect(normalizeSearchText('a\n\tb'), 'a b');
    });

    test('متن خالی و فقط فاصله', () {
      expect(normalizeSearchText(''), '');
      expect(normalizeSearchText('   '), '');
    });
  });

  group('matchesQuery', () {
    const haystack = 'زلال موفق';

    test('جستجوی خالی با همه چیز مطابقت دارد', () {
      expect(matchesQuery(haystack, ''), isTrue);
      expect(matchesQuery(haystack, '   '), isTrue);
    });

    test('زیررشته را پیدا می‌کند', () {
      expect(matchesQuery(haystack, 'زلال'), isTrue);
    });

    test('ترتیب کلمات مهم نیست', () {
      expect(matchesQuery(haystack, 'موفق زلال'), isTrue);
    });

    test('کلمه‌ی ناموجود را رد می‌کند', () {
      expect(matchesQuery(haystack, 'زلال برق'), isFalse);
    });

    test('با ارقام فارسی هم فاز پیدا می‌شود', () {
      expect(matchesQuery('فاز 1', 'فاز \u06F1'), isTrue);
    });
  });

  group('phaseNamesMatch', () {
    test('نگارش‌های مختلف یک نام فاز را یکسان می‌بیند', () {
      expect(phaseNamesMatch('فاز \u06F1', 'فاز 1'), isTrue);
      expect(phaseNamesMatch('  فاز 1 ', 'فاز 1'), isTrue);
    });

    test('فازهای مختلف یکسان نیستند', () {
      expect(phaseNamesMatch('فاز 1', 'فاز 2'), isFalse);
    });
  });

  group('sanitizePostgrestTerm', () {
    test('کاراکترهای شکست‌دهنده‌ی گرامر or را حذف می‌کند', () {
      // کاما در گرامر or جداکننده است و کل درخواست را 400 می‌کند
      expect(sanitizePostgrestTerm('a,b'), 'a b');
      expect(sanitizePostgrestTerm('a(b)c'), 'a b c');
      expect(sanitizePostgrestTerm('a*b'), 'a b');
    });

    test('فاصله‌های تکراری را جمع می‌کند', () {
      expect(sanitizePostgrestTerm('  زلال   موفق  '), 'زلال موفق');
      expect(sanitizePostgrestTerm('a,,b'), 'a b');
    });

    test('عبارت‌های معمولی دست‌نخورده می‌مانند', () {
      expect(sanitizePostgrestTerm('زلال موفق'), 'زلال موفق');
      expect(sanitizePostgrestTerm('فاز 1'), 'فاز 1');
      expect(sanitizePostgrestTerm('100%'), '100%');
    });

    test('عبارت فقط-نویسه‌ی ممنوع، خالی می‌شود', () {
      expect(sanitizePostgrestTerm('*,,*'), '');
      expect(sanitizePostgrestTerm('   '), '');
    });
  });

  group('postgrestIlikeFilter', () {
    test('الگو با wildcard مستندشده‌ی PostgREST ساخته می‌شود', () {
      // در like/ilike نویسه‌ی * به % تبدیل می‌شود؛ پس الگو اصلاً % ندارد.
      final filter = postgrestIlikeFilter('زلال')!;
      expect(filter, contains('name.ilike.*زلال*'));
      expect(filter, isNot(contains('%')));
    });

    test('عبارت حاوی کاما پاک می‌شود تا گرامر or نشکند', () {
      // کاما در گرامر or جداکننده است؛ بدون پاک‌سازی، درخواست ۴۰۰ می‌شود
      final filter = postgrestIlikeFilter('a,b')!;
      expect(filter, contains('name.ilike.*a b*'));
      expect(filter.split(',').length, 4);
    });

    test('همه‌ی ستون‌های متنی را پوشش می‌دهد و بدون پرانتز است', () {
      final filter = postgrestIlikeFilter('برق')!;
      expect(filter, isNot(startsWith('(')));
      expect(
        filter.split(','),
        containsAll([
          'name.ilike.*برق*',
          'category.ilike.*برق*',
          'address.ilike.*برق*',
          'phase.ilike.*برق*',
        ]),
      );
    });

    test('ستون‌های دلخواه قابل انتخاب‌اند', () {
      expect(
        postgrestIlikeFilter('x', columns: const ['name']),
        'name.ilike.*x*',
      );
    });

    test('عبارت غیرقابل‌استفاده، null می‌دهد', () {
      expect(postgrestIlikeFilter('   '), isNull);
      expect(postgrestIlikeFilter(',,*'), isNull);
    });
  });
}
