--04.05.2021 g_tomislav MID 46878 - dodan kriterij pretrage BPM database name

select 
cast(1 as bit) as selected,
ez.*,
case when ez.ext_id_type is null or rtrim(ez.ext_id_type) <> 'BPM' then 'NOVA' else rtrim(ez.ext_id_type) end as mesto_nastanka,
par.dav_stev, 
par.emso, 
par.naz_kr_kup, 
dbo.gfn_stringtofox(gr.value) as oall_ratin_desc
from 
dbo.p_eval ez
inner join (
		select id_kupca
		from dbo.p_eval
		where eval_type='Z'
		group by id_kupca
		having count(*)=1
		) z on ez.id_kupca = z.id_kupca
inner join 
		(
		select distinct(id_kupca) as id_kupca
		from dbo.pogodba
		where status_akt='A' and datediff(m,dat_podpisa,getdate())<=6 and dat_aktiv>'20181017'
		) c on ez.id_kupca=c.id_kupca
left join dbo.partner par on ez.id_kupca = par.id_kupca
left join dbo.general_register gr on rtrim(ez.oall_ratin) = rtrim(gr.id_key) and gr.id_register = 'OVALL_RAT' and gr.val_char='Z'
where ez.eval_type='Z' and (ez.OALL_RATIN='3' or ez.OALL_RATIN='3H')
and ez.id_kupca not in (                 
					Select b.val_str as id_kupca
                    From (
                          Select a.def_name, a.val_str, a.process_instance_id
                          From {1}.dbo.gv_bpm_data_field_instance a
                          where a.def_name = 'customer_oib' and a.val_str is not null and a.val_str <> ''
                          and a.process_id = 'zspnft_parent_rlhr'
                          and a.process_instance_is_finished = 0
                      ) a
                      inner join (
                          Select a.def_name, a.val_str, a.process_instance_id
                          From {1}.dbo.gv_bpm_data_field_instance a
                          where a.def_name = 'customer_id' and a.val_str is not null and a.val_str <> ''
                          and a.process_id = 'zspnft_parent_rlhr'
                          and a.process_instance_is_finished = 0
					) b on a.process_instance_id = b.process_instance_id
                  where a.val_str = par.dav_stev and b.val_str = par.id_kupca)

- partneri kojiimaju samo jednu Z evaluaciju s Ukupnim ratingom 3 ili 3H
- aktivini ugovori čiji datum potpisa je nije manji od 6. mjeseci (ugovori aktivirani od 17.10.20181)
- partner nema nezavršenu instancu procesa ZSPNFT 

Poštovana/i, 

napravio sam provjeru u arhivi verzija izvještaja koja postoji za taj izvještaj od 2020-09-25 te je od tog datuma do 05.04.2021 bilo podešeno da izvještaj gleda podatke s BPM_TESTa te je to razlog zašto sada nema zapisa za tog partnera.
Logika se dakle nije mijenjala te se podaci prikazuju za: 
- partnere koji imaju samo jednu Z evaluaciju s Ukupnim ratingom 3 ili 3H
- koji imaju aktivni ugovor čiji datum potpisa je unutar 6. mjeseci za ugovore aktivirane od 17.10.20181)
- partner nema nezavršenu instancu procesa ZSPNFT.
Uvjet u zadnjoj natuknici je naveden u zahtjevu 
1478 - Proces ZSPNFT (Zakon o sprečavanju pranja novca i financiranja terorizma) MR 42123
u odgovoru 9.04.2019 je da 
"Dodatno, u izvještaju postoji kontrola koja ne otvara instance za partnere za koje postoji aktivna instanca u BPM-u (možda je netko ručno pokrenuo instancu u BPM i nije ju još završio, pa da nemate duple instance procesa)." 

