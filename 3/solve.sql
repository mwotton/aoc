create table inputs (id serial, ival int);
-- \copy inputs(ival) from 'inp1.txt';

-- tests
-- insert into inputs(ival) values (1),(0),(0),(0),(99);-- success
--insert into inputs(ival) values (2),(3),(0),(3),(99);-- success
-- insert into inputs(ival) values (2),(4),(4),(5),(99),(0); -- success
-- insert into inputs(ival) select x from unnest(ARRAY[1,1,1,4,99,5,6,0,99]) x; -- success

-- answer
\copy inputs(ival) from 'input.text';
--update inputs set ival=12 where id=2;
--update inputs set ival=2 where id=3;

create table params(x int, y int);
-- insert into params (x,y) values (12,2);
insert into params select x,y from generate_series(0,10) as x, generate_series(0,10) as y;
select * from params;

create view compute_fp as (
with recursive driver as (
  select 1 as pc,
         array_agg(case id
	             when 2 then params.x
		     when 3 then params.y
		     else inputs.ival
		   end order by id asc) as mem
	 from inputs, params
union all
  select pc + 4, mem[1:mem[pc+3]] ||
     case mem[pc]
       when 1 then mem[mem[pc+1]+1] + mem[mem[pc+2]+1]
       when 2 then mem[mem[pc+1]+1] * mem[mem[pc+2]+1]
     end
     || mem[mem[pc+3]+2:]
  from driver
  where mem[pc] != 99
--) select pc,mem,mem[pc:pc+3] from driver;
--) select pc,mem,mem[pc:pc+3] from driver;
) select * from driver order by pc desc limit 1
);


create view compute as (
with recursive driver as (
  select 1 as pc,
         array_agg(case id
	             when 2 then params.x
		     when 3 then params.y
		     else inputs.ival
		   end order by id asc) as mem
	 from inputs, params
union all
  select pc + 4, mem[1:mem[pc+3]] ||
     case mem[pc]
       when 1 then mem[mem[pc+1]+1] + mem[mem[pc+2]+1]
       when 2 then mem[mem[pc+1]+1] * mem[mem[pc+2]+1]
     end
     || mem[mem[pc+3]+2:]
  from driver
  where mem[pc] != 99
--) select pc,mem,mem[pc:pc+3] from driver;
--) select pc,mem,mem[pc:pc+3] from driver;
) select * from driver order by pc desc limit 1
);

-- select * from compute;
-- select * from generate_series(0,100);

-- with updates as
--   ( update inputs
--     set ival=i.x, where id=2;
-- update inputs set ival=2 where id=3;

--select mem[1] from compute,(select x from generate_series(0,100) x)
