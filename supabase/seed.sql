-- ============================================================================
-- HeratMap — دادهی اولیه (فاز ۱ تا ۶)
-- این فایل وضعیت «شناختهشده»ی پروژه را قابلبازسازی میکند: ۶ فاز + ۱۲ شرکت.
-- idempotent است: اجرای دوباره داده را تکرار نمیکند و مقدار را بهروز میکند.
-- ============================================================================

begin;

-- ── فازها ───────────────────────────────────────────────────────────────────
insert into public.phases (id, name, number, image) values
  (1, 'فاز 1', 1, null),
  (2, 'فاز 2', 2, null),
  (3, 'فاز 3', 3, null),
  (4, 'فاز 4', 4, null),
  (5, 'فاز 5', 5, null),
  (6, 'فاز 6', 6, null)
on conflict (id) do update
  set name   = excluded.name,
      number = excluded.number;

-- ── شرکتها ─────────────────────────────────────────────────────────────────
insert into public.factories
  (id, name, category, phase, lat, lon, address, phone, work_start, work_end, description, image)
values
  -- فاز 1
  (1, 'زلال موفق', 'برق و قدرت', 'فاز 1', 34.217654, 62.207864, 'خیابان اول', '0791323424', '07:00', '19:00', 'شرکت تولید کننده نوشیدنی', ''),
  (2, 'صنایع نساجی هرات', 'پوشاک', 'فاز 1', 34.216800, 62.206500, 'کوچه سوم فاز 1', '0792111222', '08:00', '17:00', 'تولید پارچه و لباس', ''),
  -- فاز 2
  (3, 'آجر سفالی کنده حیات', 'ساخت و ساز', 'فاز 2', 34.213200, 62.209100, 'بلوار اصلی فاز 2', '0793445566', '07:00', '16:00', 'تولید آجر و کاشی', ''),
  (4, 'کارخانه سیمان هرات', 'سیمان', 'فاز 2', 34.212100, 62.210500, 'جاده کشک', '0794778899', '06:00', '18:00', 'تولید سیمان نوع یک', ''),
  -- فاز 3
  (5, 'موبایل سازی هرات', 'الکترونیک', 'فاز 3', 34.210500, 62.213200, 'خیابان پنجم فاز 3', '0795001122', '08:00', '18:00', 'تعمیر و ساخت موبایل', ''),
  (6, 'قوطی سازی هرات', 'فلزات', 'فاز 3', 34.209800, 62.214000, 'خیابان هفتم فاز 3', '0796334455', '07:00', '17:00', 'تولید قوطی و ورق فلزی', ''),
  -- فاز 4
  (7, 'صابون سازی امید', 'شیمیایی', 'فاز 4', 34.207500, 62.216800, 'بلوار چهارم فاز 4', '0797667788', '07:00', '16:00', 'تولید صابون و شوینده', ''),
  (8, 'خمیرسازی هرات', 'کاغذ', 'فاز 4', 34.206200, 62.217500, 'کوچه نهم فاز 4', '0798990011', '08:00', '17:00', 'تولید کاغذ و مقوا', ''),
  -- فاز 5
  (9, 'رنگ سازی نوین', 'شیمیایی', 'فاز 5', 34.204800, 62.219200, 'خیابان دوم فاز 5', '0791223344', '07:00', '17:00', 'تولید رنگ و پوشش فلز', ''),
  (10, 'یخچال سازی هرات', 'لوازم خانگی', 'فاز 5', 34.203500, 62.220100, 'بلوار اصلی فاز 5', '0795566778', '08:00', '18:00', 'تولید یخچال و فریزر', ''),
  -- فاز 6
  (11, 'کنجد آسیاب هرات', 'غذایی', 'فاز 6', 34.201200, 62.221800, 'جاده جدید فاز 6', '0799900112', '06:00', '15:00', 'آسیاب کنجد و روغن', ''),
  (12, 'چرمدوزی هرات', 'چرم', 'فاز 6', 34.200100, 62.222500, 'خیابان سوم فاز 6', '0793344556', '08:00', '17:00', 'تولید کیف و کفش چرم', '')
on conflict (id) do update
  set name          = excluded.name,
      category      = excluded.category,
      phase         = excluded.phase,
      lat           = excluded.lat,
      lon           = excluded.lon,
      address       = excluded.address,
      phone         = excluded.phone,
      work_start    = excluded.work_start,
      work_end      = excluded.work_end,
      description   = excluded.description,
      image         = excluded.image;

-- ── همترازی sequenceها با idهای دستی ──────────────────────────────────────
select setval(pg_get_serial_sequence('public.phases', 'id'),
              coalesce((select max(id) from public.phases), 1));
select setval(pg_get_serial_sequence('public.factories', 'id'),
              coalesce((select max(id) from public.factories), 1));

-- ── اخبار نمونه ───────────────────────────────────────────────────────────────
insert into public.news (id, title, summary, body, image, cover_image, published_at)
values
  (1,
   'افتتاح فاز هفتم شهرک صنعتی هرات',
   'مراسم افتتاحیه فاز هفتم با حضور مسئولین محلی برگزار شد.',
   'فاز هفتم شهرک صنعتی هرات شامل ۲۰ قطعه صنعتی استاندارد می‌باشد که آماده تحویل به سرمایه‌گذاران است. این فاز در مساحت ۱۵ هکتار احداث شده و دارای زیرساخت‌های کامل آبرسانی، برق و گاز می‌باشد. مسئولین شهرک اعلام کردند که تا پایان سال آینده تمام قطعات فاز هفتم به سرمایه‌گذاران تحویل خواهد شد.',
   '',
   '',
   now() - interval '3 days'),
  (2,
   'تفاهمنامه همکاری با شرکت‌های ترکیه‌ای',
   'دو تفاهمنامه همکاری بین شهرک صنعتی هرات و شرکت‌های ترکیه‌ای امضا شد.',
   'در مراسمی که به مناسبت بازدید هیئت تجاری ترکیه از شهرک صنعتی هرات برگزار شد، دو تفاهمنامه همکاری صنعتی میان شرکت‌های دو کشور به امضا رسید. این تفاهمنامه‌ها زمینه‌ساز انتقال تکنولوژی و ایجاد اشتغال جدید در شهرک خواهند بود.',
   '',
   '',
   now() - interval '7 days')
on conflict (id) do update
  set title         = excluded.title,
      summary       = excluded.summary,
      body          = excluded.body,
      image         = excluded.image,
      cover_image   = excluded.cover_image,
      published_at  = excluded.published_at;

-- ── اطلاعیه‌های نمونه ────────────────────────────────────────────────────────
insert into public.announcements (id, title, body, image, published_at, expires_at)
values
  (1,
   'قطع آب شهرک — اطلاعیه مهم',
   'به اطلاع کلیه شرکت‌های محترم شهرک صنعتی هرات می‌رساند، به‌منظول تعمیرات شبکه آبرسانی، روز چهارشنبه مورخ ۱۴۰۳/۰۷/۱۵ از ساعت ۸ صبح تا ۲ بعدازظهر، آب شهرک قطع خواهد شد. لطفاً arrangements لازم را مبذول فرمایید.',
   '',
   now() - interval '1 day',
   now() + interval '5 days'),
  (2,
   'ثبت‌نام کارگاه آموزشی ایمنی',
   'کارگاه آموزشی ایمنی و بهداشت شغلی برای کارکنان شرکت‌های شهرک صنعتی هرات برگزار می‌شود. متقاضیان تا پایان هفته آینده می‌توانند نسبت به ثبت‌نام اقدام نمایند.',
   '',
   now() - interval '2 days',
   now() + interval '10 days')
on conflict (id) do update
  set title      = excluded.title,
      body       = excluded.body,
      image      = excluded.image,
      published_at = excluded.published_at,
      expires_at = excluded.expires_at;

-- ── شماره‌های ضروری ─────────────────────────────────────────────────────────
insert into public.emergency_contacts (id, name, phone, icon, sort_order)
values
  (1, 'پلیس', '+93791000000', 'policy', 1),
  (2, 'آمبولانس', '+93792000000', 'local_hospital', 2),
  (3, 'آتشنشانی', '+93793000000', 'fire_truck', 3),
  (4, 'اداره برق', '+93794000000', 'electric_car', 4),
  (5, 'اداره آب', '+93795000000', 'water_drop', 5),
  (6, 'مدیریت شهرک', '+93796000000', 'factory', 6)
on conflict (id) do update
  set name        = excluded.name,
      phone       = excluded.phone,
      icon        = excluded.icon,
      sort_order  = excluded.sort_order;

-- ── همترازی sequenceهای جدید ─────────────────────────────────────────────────
select setval(pg_get_serial_sequence('public.news', 'id'),
              coalesce((select max(id) from public.news), 1));
select setval(pg_get_serial_sequence('public.announcements', 'id'),
              coalesce((select max(id) from public.announcements), 1));
select setval(pg_get_serial_sequence('public.emergency_contacts', 'id'),
              coalesce((select max(id) from public.emergency_contacts), 1));

commit;
