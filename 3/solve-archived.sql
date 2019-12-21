-- this doesn't work, keeping it around for the blog post.

create table inputs (id serial PRIMARY KEY, ival int);
\copy inputs(ival) from 'inp1.txt';
update inputs set id=id-1 ;

--select * from inputs;


create table registers(reg text, val int, unique(reg));
insert into registers(reg, val) values ('PC', 0);

create view at_offset as
  select inputs.id-registers.val as offset,
         inputs.ival,
	 registers.val+4 as nextpc
  from inputs,registers
  where registers.reg='PC'
    and inputs.id>=registers.val;

select * from at_offset limit 10;
update registers set val=0 where reg='PC';
select * from at_offset limit 10;
select 'beforeinp',* from inputs order by id;
with recursive driver as (
     update inputs set ival=1;
     update inputs
     set ival=case cmd.ival
         when 1 then i1.ival+i2.ival
         when 2 then i1.ival*i2.ival
       end,
         nextpc = cmd.nextpc
     from inputs i1
     join inputs i2 on true
     join at_offset cmd on (cmd.offset=0 and cmd.ival != 99)
     join at_offset p1 on p1.offset=1
     join inputs v1 on p1.ival=i1.id
     join at_offset p2 on p2.offset=2
     join inputs v2 on p2.ival=i2.id
     join at_offset target on target.offset=3
     where target.ival=inputs.id
     returning cmd.*,i1.ival as p1ival ,i2.ival as p2ival,target.ival
)
select 'driver',* from driver;
select 'inputs',* from inputs order by id;
-- select 1;
-- select * from driver limit 10;
--select * from registers;
