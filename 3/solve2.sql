create table inputs (mass int,used int default 0);
\copy inputs(mass) from 'input.text';

with recursive totals as (
  select mass,used from inputs
  union all
  select greatest(0,((mass / 3) - 2)), used+1
    from totals
    where  mass > 0)
select sum(totals.mass) from totals where used > 0;
-- select * from totals;
