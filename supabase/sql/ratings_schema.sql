-- ─── ratings table columns ───────────────────────────────────────────────────

alter table public.ratings
  add column if not exists is_edited boolean not null default false;

-- ─── FK from ratings.user_id → profiles.id so PostgREST can resolve the
--     profiles(...) embedded join in getMealDetails() ────────────────────────

alter table public.ratings
  drop constraint if exists ratings_user_id_profiles_fkey;

alter table public.ratings
  add constraint ratings_user_id_profiles_fkey
  foreign key (user_id) references public.profiles(id) on delete cascade;

-- ─── unique constraint required for upsert(onConflict: 'user_id,meal_id') ───

alter table public.ratings
  drop constraint if exists ratings_user_meal_unique;

alter table public.ratings
  add constraint ratings_user_meal_unique unique (user_id, meal_id);

-- ─── denormalized avg_overall / total_ratings on meals ───────────────────────

alter table public.meals
  add column if not exists avg_overall float not null default 0,
  add column if not exists total_ratings int not null default 0;

create or replace function public.refresh_meal_stats()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_meal_id uuid;
begin
  v_meal_id := coalesce(new.meal_id, old.meal_id);

  update public.meals
  set
    avg_overall   = coalesce((
      select avg(overall_score) from public.ratings where meal_id = v_meal_id
    ), 0),
    total_ratings = (
      select count(*) from public.ratings where meal_id = v_meal_id
    )
  where id = v_meal_id;

  return coalesce(new, old);
end;
$$;

drop trigger if exists trg_refresh_meal_stats on public.ratings;

create trigger trg_refresh_meal_stats
after insert or update or delete on public.ratings
for each row
execute function public.refresh_meal_stats();

-- ─── RLS on ratings ──────────────────────────────────────────────────────────

alter table public.ratings enable row level security;

drop policy if exists "Users can read all ratings" on public.ratings;
create policy "Users can read all ratings"
on public.ratings for select
to authenticated
using (true);

drop policy if exists "Users can insert own ratings" on public.ratings;
create policy "Users can insert own ratings"
on public.ratings for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update own ratings" on public.ratings;
create policy "Users can update own ratings"
on public.ratings for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete own ratings" on public.ratings;
create policy "Users can delete own ratings"
on public.ratings for delete
to authenticated
using (auth.uid() = user_id);
