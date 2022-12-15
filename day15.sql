with ins as (select 'Sensor at x=3729579, y=1453415: closest beacon is at x=4078883, y=2522671
Sensor at x=3662668, y=2749205: closest beacon is at x=4078883, y=2522671
Sensor at x=257356, y=175834: closest beacon is at x=1207332, y=429175
Sensor at x=2502777, y=3970934: closest beacon is at x=3102959, y=3443573
Sensor at x=24076, y=2510696: closest beacon is at x=274522, y=2000000
Sensor at x=3163363, y=3448163: closest beacon is at x=3102959, y=3443573
Sensor at x=1011369, y=447686: closest beacon is at x=1207332, y=429175
Sensor at x=3954188, y=3117617: closest beacon is at x=4078883, y=2522671
Sensor at x=3480746, y=3150039: closest beacon is at x=3301559, y=3383795
Sensor at x=2999116, y=3137910: closest beacon is at x=3102959, y=3443573
Sensor at x=3546198, y=462510: closest beacon is at x=3283798, y=-405749
Sensor at x=650838, y=1255586: closest beacon is at x=274522, y=2000000
Sensor at x=3231242, y=3342921: closest beacon is at x=3301559, y=3383795
Sensor at x=1337998, y=31701: closest beacon is at x=1207332, y=429175
Sensor at x=1184009, y=3259703: closest beacon is at x=2677313, y=2951659
Sensor at x=212559, y=1737114: closest beacon is at x=274522, y=2000000
Sensor at x=161020, y=2251470: closest beacon is at x=274522, y=2000000
Sensor at x=3744187, y=3722432: closest beacon is at x=3301559, y=3383795
Sensor at x=2318112, y=2254019: closest beacon is at x=2677313, y=2951659
Sensor at x=2554810, y=56579: closest beacon is at x=3283798, y=-405749
Sensor at x=1240184, y=897870: closest beacon is at x=1207332, y=429175
Sensor at x=2971747, y=2662873: closest beacon is at x=2677313, y=2951659
Sensor at x=3213584, y=3463821: closest beacon is at x=3102959, y=3443573
Sensor at x=37652, y=3969055: closest beacon is at x=-615866, y=3091738
Sensor at x=1804153, y=1170987: closest beacon is at x=1207332, y=429175'::text as inputs,
/*with ins as (select 'Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3'::text as inputs,*/
                           2000000 as targety)
, rounds as (select regexp_split_to_table(inputs, '\n') as sensors,targety
               from ins i)
 ,coors as(  select * ,
        row_number() over () as sensor_id,
        (regexp_matches(sensors,'Sensor at x=(-?\d+),'))[1]::int as sensor_x,
        (regexp_matches(sensors,'Sensor at x=-?\d+, y=(-?\d+)'))[1]::int as sensor_y,
        (regexp_matches(sensors,'is at x=(-?\d+),'))[1]::int as beacon_x,
        (regexp_matches(sensors,'is at x=-?\d+, y=(-?\d+)'))[1]::int as beacon_y
   from rounds)
,dists as (select * ,
       case when sensor_x < beacon_x then beacon_x - sensor_x
           else sensor_x - beacon_x end as dx,
       case when sensor_y < beacon_y then beacon_y - sensor_y
           else sensor_y - beacon_y end as dy
from coors)
,skadoosh as (select distinct
--  *,
--     dx + dy - abs(targety - sensor_y) as extra_dx,
    sensor_x + generate_series(-1 * (dx + dy - abs(targety - sensor_y)),dx + dy - abs(targety - sensor_y)) extraxs
from dists d
-- inner join (select generate_series(-1 * (dx + dy - abs(targety - sensor_y)),dx + dy - abs(targety - sensor_y)) extraxs) ex
--     on true
where targety between sensor_y - (dx + dy) and sensor_y + (dx + dy)
)
,part1 as (select count(s.*) as part1
           from skadoosh s
                    left join dists d on d.beacon_y = d.targety and d.beacon_x = extraxs
           where d.beacon_x is null)
,skadoosh2 as (select *,
                      greatest(0,least(4000000,
                          generate_series(sensor_x + (-1 * (dx + dy + 1 - abs(impossible_y - sensor_y))),
                                          sensor_x + (dx + dy + 1 - abs(impossible_y - sensor_y)),
                              greatest(2*(dx + dy + 1 - abs(impossible_y - sensor_y)),1)
                          ))) as extraxs
--                       greatest(0,least(4000000,sensor_x + (-1 * (dx + dy + 1 - abs(impossible_y - sensor_y))))) extraxs1,
--                       greatest(0,least(4000000,sensor_x + (dx + dy + 1 - abs(impossible_y - sensor_y)))) extraxs2
from dists d
inner join (select generate_series(0,4000000) as impossible_y) py
    on impossible_y between sensor_y - (dx + dy + 1) and sensor_y + (dx + dy + 1)
-- where sensor_id = 2
)
select s.impossible_y,s.extraxs,4000000*s.extraxs::bigint + s.impossible_y::bigint
from skadoosh2 s
left join dists d
    on abs(d.sensor_y - s.impossible_y) + abs(d.sensor_x - s.extraxs) <= d.dx + d.dy
where d.sensor_x is null
limit 1
;
