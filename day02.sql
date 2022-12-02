with ins as (select 'A Y
B X
C Z'::text as inputs)
, rounds as (select regexp_split_to_table(inputs, '\n') as plays
               from ins i)
,splits as (select plays,
       left(plays,1) as opp_play_raw,
       case when left(plays,1) = 'A' then 1 --rock
           when left(plays,1) = 'B' then 2 --paper
           else 3 end as opp_play_num, --scissor
       right(plays,1) as my_play_raw,
       case when right(plays,1) = 'X' then 1 --rock/lose
           when right(plays,1) = 'Y' then 2 --paper/draw
           else 3 end as my_play_num, --scissor/win
        row_number() over () as round_id
from rounds)
,results as (select * ,
    case when opp_play_num = my_play_num then my_play_num + 3
        when my_play_num%3 = (opp_play_num+1)%3 then my_play_num+6
        when my_play_num%3 = (opp_play_num+2)%3 then my_play_num
    end as points1,
    case when my_play_num = 1 then coalesce(nullif((opp_play_num+2)%3,0),3)
         when my_play_num = 2 then opp_play_num + 3
         when my_play_num = 3 then coalesce(nullif((opp_play_num+1)%3,0),3) + 6
        else 9999 end as points2
from splits)
select sum(points1),
       sum(points2)
from results
;
