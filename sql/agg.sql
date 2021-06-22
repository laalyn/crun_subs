select string_agg(sub3.event_val, E'\n') as result from
(select sub2.show_name, sub2.szn_name, sub2.ep_idx_str::int as ep_idx, sub2.event_val from
  (select sub1.show_name, sub1.szn_name, sub1.ep_name,
    case when sub1.ep_name = '' then '2147483647' else sub1.ep_name end as ep_idx_str,
    sub1.event_idx, sub1.event_val from
    (select sub.show_name, sub.szn_name, regexp_replace(sub.ep_name, '[^0-9]+', '', 'g') as ep_name, sub.event_idx, sub.event_val from
      (select shows.name as show_name, seasons.name as szn_name, regexp_replace(episodes.name, 'PV \d*', '0', 'g') as ep_name, events.idx as event_idx, events.val as event_val from shows
      join seasons on shows.id = seasons.show_id
      join episodes on seasons.id = episodes.season_id
      join subtitles on episodes.id = subtitles.episode_id
      join events on subtitles.id = events.subtitle_id) as sub
      -- where show_name ~ '(show 1|show 2|show 3)'
    ) as sub1
  ) as sub2
  order by sub2.show_name, sub2.szn_name, ep_idx, sub2.event_idx
) as sub3;
-- group by sub3.show_name; -- can change this
