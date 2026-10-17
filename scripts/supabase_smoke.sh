#!/usr/bin/env bash
# ============================================================================
# HeratMap — چک سلامت اتصال به Supabase (فاز ۱)
# بدون اجرای اپ، سلامت REST و Storage را چک می‌کند.
#   استفاده:  bash scripts/supabase_smoke.sh
#   با محیط دلخواه:  SUPABASE_URL=... SUPABASE_ANON_KEY=... bash scripts/supabase_smoke.sh
# ============================================================================
set -u

BASE_URL="${SUPABASE_URL:-https://uphftjsckmyrxjubfsal.supabase.co}"
KEY="${SUPABASE_ANON_KEY:-sb_publishable_sOE66rlBH_WmeulXr8ExcQ_lt99mjOX}"
REST="$BASE_URL/rest/v1"

pass=0
fail=0

# check <label> <expected-code> <curl args...>
check() {
  local label="$1"; shift
  local expected="$1"; shift
  local code
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 "$@")
  if [ "$code" = "$expected" ]; then
    printf '  OK    %-44s HTTP %s\n' "$label" "$code"
    pass=$((pass + 1))
  else
    printf '  FAIL  %-44s HTTP %s (انتظار: %s)\n' "$label" "$code" "$expected"
    fail=$((fail + 1))
  fi
}

# check_blocked <label> <curl args...> — نوشتن باید رد شود (هر کد 4xx/5xx قبول است)
check_blocked() {
  local label="$1"; shift
  local code
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 "$@")
  case "$code" in
    4*|5*)
      printf '  OK    %-44s HTTP %s\n' "$label" "$code"
      pass=$((pass + 1))
      ;;
    *)
      printf '  FAIL  %-44s HTTP %s — نوشتن با کلید عمومی ممکن است!\n' "$label" "$code"
      fail=$((fail + 1))
      ;;
  esac
}

printf 'Supabase: %s\n\n' "$BASE_URL"

check "auth health" \
  200 "$BASE_URL/auth/v1/health" -H "apikey: $KEY"

check "factories: select all" \
  200 "$REST/factories?select=*" -H "apikey: $KEY" -H "Authorization: Bearer $KEY"

check "phases: select ordered" \
  200 "$REST/phases?select=*&order=number.asc" -H "apikey: $KEY" -H "Authorization: Bearer $KEY"

check "factories: filter by phase name" \
  200 -G "$REST/factories" --data-urlencode 'phase=eq.فاز 1' -H "apikey: $KEY" -H "Authorization: Bearer $KEY"

check "factories: text search (name/address/category)" \
  200 -G "$REST/factories" --data-urlencode 'or=(name.ilike.%زلال%,address.ilike.%زلال%,category.ilike.%زلال%)' \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY"

check "storage: public image" \
  200 "$BASE_URL/storage/v1/object/public/images/zolal.jpg" -H "apikey: $KEY"

# نوشتن با کلید عمومی باید رد شود. بعد از اعمال migration پاسخ RLS (401/403) است؛
# پیش از آن هم به دلیل محدودیت‌ها رد می‌شود — نکته‌ی مهم «رد شدن» است، نه کد خاص.
check_blocked "write must be blocked for anon (RLS)" \
  -X POST "$REST/factories" -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
  -H 'Content-Type: application/json' -H 'Prefer: tx=rollback,return=minimal' \
  --data '{"name":"__rls_probe__","category":"x","phase":"فاز 1","lat":34.2,"lon":62.2}'

# ── خلاصه‌ی داده ─────────────────────────────────────────────────────────────
factories=$(curl -s "$REST/factories?select=id" -H "apikey: $KEY" -H "Authorization: Bearer $KEY" | grep -o '"id"' | wc -l | tr -d ' ')
phases=$(curl -s "$REST/phases?select=id" -H "apikey: $KEY" -H "Authorization: Bearer $KEY" | grep -o '"id"' | wc -l | tr -d ' ')

printf '\nداده: %s شرکت، %s فاز\n' "$factories" "$phases"
printf 'نتیجه: %s موفق، %s ناموفق\n' "$pass" "$fail"

[ "$fail" -eq 0 ] || exit 1
