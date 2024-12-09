text to lcSQL noshow
Select a.def_name, a.val_str, a.process_instance_id
From dbo.gv_bpm_data_field_instance a
where a.def_name = 'customer_oib' and a.val_str is not null and a.val_str <> ''
and a.process_id = 'zspnft_parent_rlhr'
and a.process_instance_is_finished = 0
endtext
*lcSQL = "select * from dbo.dejavnos"
GF_SQLEXEC(lcSQL, "_test", "bpm")
select * from _test

* ide prema name
<connection type="SqlServer" name="bpm" >


text to lcSQL noshow
Select a.def_name, a.val_str, a.process_instance_id
From dbo.gv_bpm_data_field_instance a
where a.def_name = 'customer_oib' and a.val_str is not null and a.val_str <> ''
and a.process_id = 'zspnft_parent_rlhr'
and a.process_instance_is_finished = 0
endtext
*lcSQL = "select * from dbo.dejavnos"
GF_SQLEXEC(lcSQL, "_test", "bpm")
select * from _test

* ide prema name
<connection type="SqlServer" name="bpm" >

--11.05.2021 g_tomislav MID 46878 - dodan kriterij pretrage NOVA database name; maknuta provjera da li partner ima nezavršenu instancu u BPMu te dodana kolona koja prikazuje taj podatak; maknut izraz  ez.eval_type='Z' jer je sadržan u prvom join-u

select cast(1 as bit) as selected,
	ez.*,
	case when ez.ext_id_type is null or rtrim(ez.ext_id_type) <> 'BPM' then 'NOVA' else rtrim(ez.ext_id_type) end as mesto_nastanka,
	par.dav_stev, 
	par.emso, 
	par.naz_kr_kup, 
	NOVA_TEST.dbo.gfn_stringtofox(gr.value) as oall_ratin_desc
	, case when bpm.id_kupca is not null then 'Da' else 'Ne' end as ima_nezavrsenu_instancu
from NOVA_TEST.dbo.p_eval ez
inner join (
		select id_kupca
		from NOVA_TEST.dbo.p_eval
		where eval_type='Z'
		group by id_kupca
		having count(*)=1
		) z on ez.id_kupca = z.id_kupca
inner join (
		select distinct(id_kupca) as id_kupca
		from NOVA_TEST.dbo.pogodba
		where status_akt='A' and datediff(m,dat_podpisa,getdate())<=6 and dat_aktiv>'20181017'
		) c on ez.id_kupca=c.id_kupca
left join NOVA_TEST.dbo.partner par on ez.id_kupca = par.id_kupca
left join NOVA_TEST.dbo.general_register gr on rtrim(ez.oall_ratin) = rtrim(gr.id_key) and gr.id_register = 'OVALL_RAT' and gr.val_char='Z'
outer apply (Select distinct b.val_str as id_kupca
                    From (
                          Select a.def_name, a.val_str, a.process_instance_id
                          From dbo.gv_bpm_data_field_instance a
                          where a.def_name = 'customer_oib' and a.val_str is not null and a.val_str <> ''
                          and a.process_id = 'zspnft_parent_rlhr'
                          and a.process_instance_is_finished = 0
                      ) a
                      inner join (
                          Select a.def_name, a.val_str, a.process_instance_id
                          From dbo.gv_bpm_data_field_instance a
                          where a.def_name = 'customer_id' and a.val_str is not null and a.val_str <> ''
                          and a.process_id = 'zspnft_parent_rlhr'
                          and a.process_instance_is_finished = 0
					) b on a.process_instance_id = b.process_instance_id
                  where a.val_str = par.dav_stev and b.val_str = par.id_kupca
			) bpm
where (ez.OALL_RATIN='3' or ez.OALL_RATIN='3H')