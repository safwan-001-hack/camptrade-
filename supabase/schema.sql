create extension if not exists pgcrypto;

create table if not exists public.universities(
  id text primary key,
  name text not null,
  short_name text not null,
  theme_color text not null default '#8ecae6',
  created_at timestamptz not null default now()
);

insert into public.universities(id,name,short_name,theme_color) values
('fut-minna','Federal University of Technology, Minna','FUT Minna','#8ecae6'),
('ibbu','Ibrahim Badamasi Babangida University, Lapai','IBBU','#77b255'),
('newgate','Newgate University, Minna','Newgate','#8ecae6')
on conflict(id) do update set name=excluded.name,short_name=excluded.short_name,theme_color=excluded.theme_color;

create table if not exists public.profiles(
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  university_id text references public.universities(id),
  student_id text,
  verification_status text not null default 'unverified' check(verification_status in ('unverified','pending','verified','rejected')),
  role text not null default 'student' check(role in ('student','business','moderator','admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.listings(
  id uuid primary key default gen_random_uuid(),
  campus_id text not null references public.universities(id),
  seller_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text not null,
  price numeric(12,2) not null check(price>=0),
  category text not null default 'Other',
  image_url text,
  status text not null default 'active' check(status in ('active','reserved','sold','removed')),
  created_at timestamptz not null default now()
);

create table if not exists public.wanted_posts(
  id uuid primary key default gen_random_uuid(),
  campus_id text not null references public.universities(id),
  buyer_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text not null,
  budget numeric(12,2),
  status text not null default 'open' check(status in ('open','fulfilled','closed','removed')),
  created_at timestamptz not null default now()
);

create table if not exists public.orders(
  id uuid primary key default gen_random_uuid(),
  buyer_id uuid not null references public.profiles(id),
  seller_id uuid not null references public.profiles(id),
  listing_id uuid references public.listings(id),
  campus_id text not null references public.universities(id),
  total_amount numeric(12,2) not null check(total_amount>=0),
  status text not null default 'pending' check(status in ('pending','paid','processing','completed','cancelled','refunded')),
  payment_status text not null default 'unpaid' check(payment_status in ('unpaid','pending','paid','failed','refunded')),
  payment_reference text unique,
  created_at timestamptz not null default now()
);

create table if not exists public.conversations(
  id uuid primary key default gen_random_uuid(),
  campus_id text not null references public.universities(id),
  created_at timestamptz not null default now()
);

create table if not exists public.conversation_members(
  conversation_id uuid references public.conversations(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  primary key(conversation_id,user_id)
);

create table if not exists public.messages(
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references public.conversations(id) on delete cascade,
  sender_id uuid references public.profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.favorites(
  user_id uuid references public.profiles(id) on delete cascade,
  listing_id uuid references public.listings(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(user_id,listing_id)
);

create table if not exists public.reports(
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references public.profiles(id) on delete set null,
  listing_id uuid references public.listings(id) on delete set null,
  reported_user_id uuid references public.profiles(id) on delete set null,
  reason text not null,
  details text,
  status text not null default 'open' check(status in ('open','reviewing','resolved','dismissed')),
  created_at timestamptz not null default now()
);

create table if not exists public.verification_requests(
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  campus_id text not null references public.universities(id),
  student_id text,
  id_card_path text,
  status text not null default 'pending' check(status in ('pending','approved','rejected')),
  reviewer_id uuid references public.profiles(id),
  reviewer_note text,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);

alter table public.universities enable row level security;
alter table public.profiles enable row level security;
alter table public.listings enable row level security;
alter table public.wanted_posts enable row level security;
alter table public.orders enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;
alter table public.favorites enable row level security;
alter table public.reports enable row level security;
alter table public.verification_requests enable row level security;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path=public
as $$ select exists(select 1 from profiles where id=auth.uid() and role in ('admin','moderator')); $$;

create or replace function public.same_campus(campus text) returns boolean
language sql stable security definer set search_path=public
as $$ select exists(select 1 from profiles where id=auth.uid() and university_id=campus); $$;

drop policy if exists "universities readable" on public.universities;
create policy "universities readable" on public.universities for select using (true);

drop policy if exists "profile own read" on public.profiles;
create policy "profile own read" on public.profiles for select using (id=auth.uid() or public.is_admin());

drop policy if exists "profile own insert" on public.profiles;
create policy "profile own insert" on public.profiles for insert with check (id=auth.uid());

drop policy if exists "profile safe update" on public.profiles;
create policy "profile safe update" on public.profiles for update using (id=auth.uid() or public.is_admin())
with check (id=auth.uid() or public.is_admin());

drop policy if exists "campus listings read" on public.listings;
create policy "campus listings read" on public.listings for select using (public.same_campus(campus_id) or public.is_admin());

drop policy if exists "seller listing insert" on public.listings;
create policy "seller listing insert" on public.listings for insert with check (seller_id=auth.uid() and public.same_campus(campus_id));

drop policy if exists "seller listing update" on public.listings;
create policy "seller listing update" on public.listings for update using (seller_id=auth.uid() or public.is_admin()) with check (seller_id=auth.uid() or public.is_admin());

drop policy if exists "seller listing delete" on public.listings;
create policy "seller listing delete" on public.listings for delete using (seller_id=auth.uid() or public.is_admin());

drop policy if exists "wanted campus read" on public.wanted_posts;
create policy "wanted campus read" on public.wanted_posts for select using (public.same_campus(campus_id) or public.is_admin());

drop policy if exists "wanted insert" on public.wanted_posts;
create policy "wanted insert" on public.wanted_posts for insert with check (buyer_id=auth.uid() and public.same_campus(campus_id));

drop policy if exists "wanted owner update" on public.wanted_posts;
create policy "wanted owner update" on public.wanted_posts for update using (buyer_id=auth.uid() or public.is_admin()) with check (buyer_id=auth.uid() or public.is_admin());

drop policy if exists "favorites own" on public.favorites;
create policy "favorites own" on public.favorites for all using (user_id=auth.uid()) with check (user_id=auth.uid());

drop policy if exists "orders participants" on public.orders;
create policy "orders participants" on public.orders for select using (buyer_id=auth.uid() or seller_id=auth.uid() or public.is_admin());

drop policy if exists "buyer order create" on public.orders;
create policy "buyer order create" on public.orders for insert with check (buyer_id=auth.uid() and public.same_campus(campus_id));

drop policy if exists "order participants update" on public.orders;
create policy "order participants update" on public.orders for update using (buyer_id=auth.uid() or seller_id=auth.uid() or public.is_admin())
with check (buyer_id=auth.uid() or seller_id=auth.uid() or public.is_admin());

drop policy if exists "reports own" on public.reports;
create policy "reports own" on public.reports for insert with check (reporter_id=auth.uid());
create policy "reports read" on public.reports for select using (reporter_id=auth.uid() or public.is_admin());
create policy "reports admin update" on public.reports for update using (public.is_admin()) with check (public.is_admin());

drop policy if exists "verification own" on public.verification_requests;
create policy "verification own" on public.verification_requests for insert with check (user_id=auth.uid());
create policy "verification read" on public.verification_requests for select using (user_id=auth.uid() or public.is_admin());
create policy "verification admin update" on public.verification_requests for update using (public.is_admin()) with check (public.is_admin());

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path=public
as $$ begin insert into public.profiles(id) values(new.id) on conflict(id) do nothing; return new; end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create index if not exists listings_campus_status_idx on public.listings(campus_id,status,created_at desc);
create index if not exists wanted_campus_status_idx on public.wanted_posts(campus_id,status,created_at desc);
create index if not exists orders_buyer_idx on public.orders(buyer_id,created_at desc);
create index if not exists orders_seller_idx on public.orders(seller_id,created_at desc);
