SELECT a.id_dokum, round(ocen_vred * dbo.gfn_GetValueTableFactor(case WHEN a.dat_korig_vred IS NOT NULL THEN a.dat_korig_vred ELSE CASE WHEN b.status_akt='A' THEN b.dat_aktiv ELSE b.dat_sklen END END,GETDATE(), null, id_hipot, 2)/100,2) as korig_vred
FROM dbo.dokument a
join pogodba b on a.id_cont=b.id_cont
where id_hipot is not null 


SELECT a.id_dokum, a.id_hipot, a.ocen_vred, b.status_akt, b.id_pog, id_obl_zav, dat_korig_vred,
case WHEN a.dat_korig_vred IS NOT NULL THEN a.dat_korig_vred ELSE CASE WHEN b.status_akt='N' THEN b.dat_sklen ELSE b.dat_aktiv END END as datum_izracuna,
dbo.gfn_GetValueTableFactor(case WHEN a.dat_korig_vred IS NOT NULL THEN a.dat_korig_vred ELSE CASE WHEN b.status_akt='A' THEN b.dat_aktiv ELSE b.dat_sklen END END,GETDATE(), null, id_hipot, 2) as si, 
round(ocen_vred * dbo.gfn_GetValueTableFactor(case WHEN a.dat_korig_vred IS NOT NULL THEN a.dat_korig_vred ELSE CASE WHEN b.status_akt='A' THEN b.dat_aktiv ELSE b.dat_sklen END END,GETDATE(), null, id_hipot, 2)/100,2)
as korig_vred
FROM dbo.dokument a
join pogodba b on a.id_cont=b.id_cont
where id_hipot is not null
--and b.status_akt=''
order by id_dokum desc

SELECT dbo.gfn_GetValueTableFactor('20110415', GETDATE(), null, 'C5', 2) as si

--FOX dodatna rutina dodavanja kolone na grid
local lcList_Condition, list, lcSql

LcList_condition = ""
list = GF_CreateDelimitedList("rezultat", "id_dokum", LcList_condition, ",",.t.)

TEXT TO lcSql NOSHOW
SELECT a.id_dokum, dbo.gfn_GetValueTableFactor(case WHEN a.dat_korig_vred IS NOT NULL THEN a.dat_korig_vred ELSE CASE WHEN b.status_akt='A' THEN b.dat_aktiv ELSE b.dat_sklen END END,GETDATE(), null, id_hipot, 2) * ocen_vred/100 as korig_vred
FROM dbo.dokument a
join pogodba b on a.id_cont=b.id_cont
where id_hipot is not null AND id_dokum in (
ENDTEXT

GF_SQLEXEC(lcSql+iif(len(alltrim(list))=0,"0",list)+")","_CUR_KOR_VRED")

GF_AddColumnsToGrid("frmdokument_vsi", "BGridResult", "Korigirana vrijednost", "ROUND(LOOK(_CUR_KOR_VRED.korig_vred,REZULTAT.ID_DOKUM,_CUR_KOR_VRED.ID_DOKUM),2)", 130 , "")
