-- Ejecuta este archivo UNA SOLA VEZ en Supabase > SQL Editor.
-- La cuenta del navegador solo puede consultar y canjear hasta tres masajes.
create table if not exists public.bono_maria_estado (
  id integer primary key check (id = 1),
  canjeados integer not null default 0 check (canjeados between 0 and 3)
);
insert into public.bono_maria_estado (id, canjeados) values (1, 0)
on conflict (id) do nothing;
alter table public.bono_maria_estado enable row level security;
revoke all on public.bono_maria_estado from public, anon, authenticated;

create or replace function public.bono_maria_consultar()
returns integer language sql security definer
set search_path = ''
as $$ select canjeados from public.bono_maria_estado where id = 1 $$;

create or replace function public.bono_maria_canjear()
returns integer language plpgsql security definer
set search_path = ''
as $$
declare total integer;
begin
  update public.bono_maria_estado
     set canjeados = canjeados + 1
   where id = 1 and canjeados < 3
   returning canjeados into total;
  if total is null then
    select canjeados into total from public.bono_maria_estado where id = 1;
  end if;
  return total;
end $$;

revoke all on function public.bono_maria_consultar() from public;
revoke all on function public.bono_maria_canjear() from public;
grant execute on function public.bono_maria_consultar() to anon, authenticated;
grant execute on function public.bono_maria_canjear() to anon, authenticated;

-- REINICIO PRIVADO: ejecútalo desde SQL Editor SOLO después de probarlo:
-- update public.bono_maria_estado set canjeados = 0 where id = 1;
