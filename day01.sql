with ins as (select '1000
2000
3000

4000

5000
6000

7000
8000
9000

10000'::text as inputs)
, elvis as (select regexp_split_to_table(inputs, '\n\n') as elves
               from ins i)
,items as (select elves,
       regexp_split_to_table(elves, '\n') as items,
        row_number() over () as elf_id
from elvis)
,top3 as (select elf_id,
       sum(items::int) as carried
from items
group by 1
order by 2 desc
limit 3)
select max(carried) as max_carried,
       sum(carried) as top3_carried
from top3;
