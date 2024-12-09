*select id_cont, sum(kredit) as iznos from _ss_tdogodki where tip_dogod = 'PLAC' and opis != 'INTERNO PREKNJIŽENJE SSP' group by id_cont into cursor _dod_kolona

*GF_AddColumnsToGrid("TPOGODBA_PREGLED", "grdTPogodbe", "Iznos plaćanja bez SSP", "LOOKUP(_dod_kolona.iznos, SS_TPOGODBA.id_cont, _dod_kolona.id_cont)", 150 , gccif)

select id_cont, id_plac from _ss_tdogodki where tip_dogod = 'PLAC' and opis in ('PLAĆANJE', 'CESIJA', 'KOMPENZACIJE') into cursor _placila

local lcList_Condition, ll_idcont_list

lcList_condition = ""
ll_idcont_list = GF_CreateDelimitedList("ss_tpogodba", "id_cont", LcList_condition, ",",.t.)

GF_SQLEXEC("SELECT id_cont, id_plac, kredit_dom, datum_dok, id_dogodka FROM dbo.lsk WHERE id_dogodka in ('PLAC_IZ_AV','PLAC_ODPIS','PLAC_VRACI', 'PLAC_ZA_OD', 'PLACILO ', 'AV_VRACILO', 'AV_ODPIS', 'AV_ZAC_ODP', '_TMP_AVANS') AND id_cont in  ("+iif(len(alltrim(ll_idcont_list ))=0, "0", ll_idcont_list)+")", "_lsk")

select a.* from _lsk a inner join ss_tpogodba p on a.id_cont = p.id_cont where a.datum_dok > p.dat_v_toz into cursor _lsk

select p.id_cont, sum(l.kredit_dom) as iznos from _placila p inner join _lsk l on p.id_cont = l.id_cont and p.id_plac = l.id_plac group by p.id_cont into cursor _dod_rutina

GF_AddColumnsToGrid("TPOGODBA_PREGLED", "grdTPogodbe", "Iznos plaćanja bez SSP", "LOOKUP(_dod_rutina.iznos, ss_tpogodba.id_cont, _dod_rutina.id_cont)", 150 , gccif)

use in _lsk
use in _placila