-- Bono de María: ejecutar UNA SOLA VEZ en Supabase > SQL Editor.
-- Estado compartido de tres masajes. Reinicio únicamente desde SQL Editor.
create table if not exists public.bono_maria_state (
  id integer primary key check (id = 1),
  canjeados integer not null default 0 check (canjeados between 0 and 3)
);
insert into public.bono_maria_state(id, canjeados)
values (1,0) on conflict (id) do nothing;

alter table public.bono_maria_state enable row level security;
revoke all on public.bono_maria_state from public, anon, authenticated;
grant select on public.bono_maria_state to anon;
drop policy if exists "Consultar masajes disponibles" on public.bono_maria_state;
create policy "Consultar masajes disponibles"
on public.bono_maria_state for select to anon using (id = 1);

create or replace function public.canjear_masaje()
returns integer
language plpgsql security definer set search_path = ''
as $$
declare nuevo integer;
begin
  update public.bono_maria_state
     set canjeados = canjeados + 1
   where id = 1 and canjeados < 3
  returning canjeados into nuevo;
  if nuevo is null then
    raise exception 'Los tres masajes ya están canjeados';
  end if;
  return nuevo;
end;
$$;
revoke all on function public.canjear_masaje() from public, anon, authenticated;
grant execute on function public.canjear_masaje() to anon;

-- PARA REINICIAR (ejecutar más adelante SOLO desde SQL Editor):
-- update public.bono_maria_state set canjeados = 0 where id = 1;
