SELECT  REPROGRAM.*
FROM dbo.reprogram 
WHERE 1= 1
--and ID_CONT is not null
and auto_desc like '%pogodba.STATUS ![RI -> 08!]%' escape '!'
--and ID_CONT = 68761
order by [time]
-- RI REDOVNI ISTEK  
-- 08 POVRAT PREDMETA FINANCIRANJA  
-- pogodba.STATUS [00 -> 08] 
-- Promjenjena polja: pogodba.STATUS [00 -> RI] 

SELECT id_reprogram, pog.id_cont, pog.id_pog, pog.nacin_leas, pog.pred_naj, pog.id_kupca, partner.naz_kr_kup, rep_type.tuj_1, 
	reprogram.[user] user_desc,[time] as dat_rep, 
/*	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'neto_old')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'neto_old') as decimal(18,2)) else 0.00 end as neto_old,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'neto_new')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'neto_new') as decimal(18,2)) 
		else case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'neto')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'neto') as decimal(18,2))
			else 0.00 END END as neto_new,
	--case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'neto_diff')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'neto_diff') as decimal(18,2)) else 0.00 end as neto_diff,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'obresti_old')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'obresti_old') as decimal(18,2)) else 0.00 end as obresti_old,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'obresti_new')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'obresti_new') as decimal(18,2))		
		ELSE case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'obresti')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'obresti') as decimal(18,2))
			else 0.00 END END as obresti_new,
	--case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'obresti_diff')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'obresti_diff') as decimal(18,2)) else 0.00 end as obresti_diff,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'marza_old')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'marza_old') as decimal(18,2)) else 0.00 end as marza_old,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'marza_new')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'marza_new') as decimal(18,2)) 
		ELSE case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'marza')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'marza') as decimal(18,2))
			ELSE 0.00 END END as marza_new,
	--case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'marza_diff')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'marza_diff') as decimal(18,2)) else 0.00 end as marza_diff,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'regist_old')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'regist_old') as decimal(18,2)) else 0.00 end as regist_old,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'regist_new')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'regist_new') as decimal(18,2)) 
		else case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'regist')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'regist') as decimal(18,2))
			ELSE 0.00 END END as regist_new,
	--case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'regist_diff')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'regist_diff') as decimal(18,2)) else 0.00 end as regist_diff,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'davek_old')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'davek_old') as decimal(18,2)) else 0.00 end as davek_old,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'davek_new')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'davek_new') as decimal(18,2)) 
		ELSE case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'davek')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'davek') as decimal(18,2))
			ELSE 0.00 END END as davek_new,
	--case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'davek_diff')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'davek_diff') as decimal(18,2)) else 0.00 end as davek_diff,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'debit_old')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'debit_old') as decimal(18,2)) else 0.00 end as debit_old,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'debit_new')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'debit_new') as decimal(18,2)) else 0.00 end as debit_new,
	--case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'debit_diff')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'debit_diff') as decimal(18,2)) else 0.00 end as debit_diff,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'robresti_old')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'robresti_old') as decimal(18,2)) else 0.00 end as robresti_old,
	case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'robresti_new')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'robresti_new') as decimal(18,2)) 
		ELSE case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'robresti')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'robresti') as decimal(18,2))
			else 0.00 END END as robresti_new,
	--case when isnumeric(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'robresti_diff')) = 1 then cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'robresti_diff') as decimal(18,2)) else 0.00 end as robresti_diff,
	cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'id_tec') as char(3)) as id_tec,
	ISNULL(cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'id_val') as char(3)), tec.id_val) as id_val, */
	reprogram.comment, 
	LEFT(cast(reprogram.comment as char(250)),250) as comment_short,
	rep_type.[description] as rep_desc,
	REP_CATEGORY.opis as rep_catOpis
	--, ISNULL(ost.OST_glavnica_S, 0) AS OST_glavnica_S, ISNULL(ost.OST_glavnica_N, 0) AS OST_glavnica_N, ISNULL(ost.OST_PPMV_S, 0) AS OST_PPMV_S, ISNULL(ost.OST_PPMV_N, 0) AS OST_PPMV_N
	, REPROGRAM.*
FROM dbo.reprogram 
LEFT JOIN 
	(select id_cont, id_kupca, id_pog, nacin_leas, pred_naj from pogodba
	union all 
	select id_cont, id_kupca, id_pog, nacin_leas, pred_naj from pogodba_deleted
	) pog on reprogram.id_cont=pog.id_cont
LEFT JOIN partner on pog.id_kupca=partner.id_kupca 
INNER JOIN dbo.rep_type ON reprogram.id_rep_type = rep_type.id_rep_type
LEFT JOIN dbo.users ON reprogram.[user] = users.username
LEFT JOIN dbo.REP_CATEGORY ON reprogram.id_rep_category = REP_CATEGORY.id_rep_category
--OUTER APPLY (
--	SELECT SUM(CASE WHEN old = 1 THEN neto ELSE 0 END) as OST_glavnica_S
--		, SUM(CASE WHEN old = 0 THEN neto ELSE 0 END) as OST_glavnica_N
--		, SUM(CASE WHEN old = 1 THEN robresti ELSE 0 END) as OST_PPMV_S
--		, SUM(CASE WHEN old = 0 THEN robresti ELSE 0 END) as OST_PPMV_N 
--	FROM dbo.rep_planp 
--	WHERE id_terj = @id_terj_opc AND id_reprogram = reprogram.id_reprogram
--	) ost
LEFT JOIN dbo.tecajnic tec ON cast(dbo.gfn_GetElementValueFromXMLDesc(auto_desc_xml, 'id_tec') as char(3)) = tec.id_tec

WHERE 1= 1
and auto_desc like '%pogodba.STATUS ![00 -> RI!]%' escape '!'
and pog.ID_CONT = 68761
order by [time]
-- RI REDOVNI ISTEK  
-- 08 POVRAT PREDMETA FINANCIRANJA  
-- pogodba.STATUS [00 -> 08] 
-- Promjenjena polja: pogodba.STATUS [00 -> RI] 