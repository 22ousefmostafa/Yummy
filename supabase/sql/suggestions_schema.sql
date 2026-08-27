-- ─── suggestions table ────────────────────────────────────────────────────────
-- Backs the Suggest screen (submit) and History → Suggestions tab (read).

create table if not exists public.suggestions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  meal_id uuid references public.meals(id) on delete set null,
  type text not null,
  content text not null,
  priority text not null default 'low',
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

alter table public.suggestions drop constraint if exists suggestions_type_check;
alter table public.suggestions
  add constraint suggestions_type_check
  check (type in ('new_dish', 'improve_existing', 'service_issue', 'other'));

alter table public.suggestions drop constraint if exists suggestions_priority_check;
alter table public.suggestions
  add constraint suggestions_priority_check
  check (priority in ('low', 'medium', 'high'));

alter table public.suggestions drop constraint if exists suggestions_status_check;
alter table public.suggestions
  add constraint suggestions_status_check
  check (status in ('pending', 'under_review', 'in_progress', 'done', 'rejected'));

create index if not exists suggestions_user_id_idx on public.suggestions (user_id);
create index if not exists suggestions_created_at_idx on public.suggestions (created_at desc);

-- ─── RLS on suggestions ────────────────────────────────────────────────────────

alter table public.suggestions enable row level security;

drop policy if exists "Users can read own suggestions" on public.suggestions;
create policy "Users can read own suggestions"
on public.suggestions for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert own suggestions" on public.suggestions;
create policy "Users can insert own suggestions"
on public.suggestions for insert
to authenticated
with check (auth.uid() = user_id);
