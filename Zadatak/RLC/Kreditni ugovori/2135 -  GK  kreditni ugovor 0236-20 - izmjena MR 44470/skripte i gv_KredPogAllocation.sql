begin tran
--STARO
--UPDATE kred_pog set tip_pog='2', sit_znes=tecaj*crpan_znes,krov_pog_val_znes=crpan_znes, id_krov_pog='0126 12', val_znes=crpan_znes
--where id_kredpog='0124 12' 

--NOVO

select tip_pog, status_akt , id_krov_pog , dat_aktiv, krov_pog_val_znes, dat_poprave , val_znes, * from kred_pog where id_kredpog = '0236 20'

begin tran
UPDATE kred_pog set tip_pog = 2, status_akt = 'A', id_krov_pog = '0180 16', dat_aktiv = '2016-12-21', krov_pog_val_znes = val_znes, dat_poprave = getdate() 
--output inserted.*, deleted.*
where id_kredpog = '0236 20'
select tip_pog, status_akt , id_krov_pog , dat_aktiv, krov_pog_val_znes, dat_poprave , val_znes, * from kred_pog where id_kredpog = '0236 20'
--rollback
--commit



--backup
select * from kred_pog where id_kredpog = '0180 16' 
select * from kred_pog where id_kredpog = '0236 20' 

exec dbo.tsp_generate_inserts 'kred_pog', 'dbo', 'FALSE', '##inserts', 'where id_kredpog=''0236 20'''
select * from ##inserts
--drop table ##inserts


select * from kred_pog where id_kredpog in ('0236 20','0180 16')
--testirati promejnu crpan_znes ma krovnom, zapravo bolje je neka oni testiraju pa neka jave


PROCEDURE preveri_podatke
		LPARAMETERS toObjekt
		LOCAL llVrni
		
		DODEFAULT(toObjekt)
		
		SELECT kp_pogodba_alloc
		LOCATE
		
		* Check for allocations
		IF RECCOUNT("kp_pogodba_alloc") = 0 THEN
			obvesti("Najprej je potrebno alocirati sredstva.")
			RETURN .F.
		ENDIF
		
		* Check for allocation amount sum
		SELECT SUM(allocated_amount_lp) as sum_allocated_amount_lp, SUM(NVL(amount_return_lp, 0)) as sum_amount_return_lp FROM kp_pogodba_alloc INTO CURSOR _tmp_sum
		
		IF _tmp_sum.sum_allocated_amount_lp != thisform.amount_for_allocation THEN
			pozor("Znesek alociranih sredstev se razlikuje od zneska predvidenega za alociranje na pogodbi.")
			RETURN .F.
		ENDIF
		
		* Check for returned amount sum
		IF sum_amount_return_lp != 0 AND _tmp_sum.sum_amount_return_lp > _tmp_sum.sum_allocated_amount_lp THEN
			pozor("Znesek vrnjenih sredstev je večji od zneska alociranih sredstev.")
			RETURN .F.
		ENDIF
		
		* Check for allocation according to cred. contract assets availibility
		SELECT COUNT(*) as no ;
		FROM kp_pogodba_alloc ;
		WHERE availible_amount_for_allocation_lp_tmp + IIF(id_kredpog = id_kredpog_return, amount_return_lp, 0) - allocated_amount_lp < 0  INTO CURSOR _tmp_cnt
		
		IF _tmp_cnt.no > 0 THEN
			pozor("Znesek alociranih sredstev je večji od razpoložljivosti sredstev za alociranje na kreditni pogodbi.")
			RETURN .F.
		ENDIF
		
		* Custom validations
		llVrni = GF_EXT_FUNC("CCONTRACT_ALLOC_PREVERI_PODATKE")
		IF llVrni = .F. THEN
			RETURN .F.
		ENDIF
	ENDPROC


------------------------------------------------------------------------------------------------------------
-- Procedure returns all credit contracts
--
-- History:
-- 10.08.2012 Uros; created TID 6941
-- 20.09.2012 Ziga; Tasks ID 6940, 6941 - improvement, modifications and reorganization
-- 24.10.2012 Ziga; Tasks ID 6940, 6941 - repaired calculation of field alloc_percent
-- 24.05.2013 Ziga; Task ID 7266 - added support for different currencies and alos added field passive_interest_rate_npm_zac
-- 27.08.2013 Ziga; Task ID 7492 - modification for field alloc_percent
-- 13.04.2018 Nejc; TID 13113 - GDPR
-- 02.07.2019 Ziga; MID 82697 - added fields is_canceled, date_canceled, canceled_amount and canceled_amount_lp
------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[grp_askp_krediti_leasing]
    @par_id_kredpog varchar(15)
AS
BEGIN
	SELECT kpa.id_kred_pog_pogodba_alloc, po.id_cont, po.id_pog,
			kpa.allocated_amount_lp + kpa.reserved_amount_lp as allocated_reserved_amount_lp,
			case when kpa.amount_for_allocation != 0
					then round(((kpa.reserved_amount + kpa.allocated_amount - case when kpa.id_kredpog_return is not null and kpa.id_kredpog_return = kpa.id_kredpog then kpa.amount_return else 0 end)
								 / (kpa.amount_for_allocation + kpav.amount_return_other)) * 100, 4)
					else 0
			end as alloc_percent,
			kpa.is_canceled, kpa.date_canceled, kpa.canceled_amount_lp,
			kpa.amount_return_lp, kpa.reserved, kpa.id_kredpog_return, kpa.date_return, po.nacin_leas, po.pred_naj, po.status_akt, po.traj_naj,
			po.vr_val, po.vr_val_zac, po.net_nal, po.net_nal_zac, po.id_tec, po.id_val, po.id_vrste, vo.naziv as vrst_opr_naziv,
			po.id_kupca, po.dat_aktiv, po.dat_sklen, pa.naz_kr_kup,
			kpa.ef_obrm_npm_zac, kpa.ef_obrm_npm,
			kpa.passive_interest_rate_npm_zac, kpa.passive_interest_rate_npm,
			kpa.npm_zac, kpa.npm, kpa.id_val_lp
	FROM dbo.gv_KredPogAllocation kpa
	INNER JOIN gv_KredPogAllocAvailibility kpav ON kpav.id_kredpog = kpa.id_kredpog
	INNER JOIN dbo.pogodba po ON po.id_cont = kpa.id_cont
	INNER JOIN dbo.vrst_opr vo ON vo.id_vrste = po.id_vrste
	INNER JOIN dbo.gfn_Partner_Pseudo('grp_askp_krediti_leasing',null) pa ON pa.id_kupca = po.id_kupca
	WHERE kpa.id_kredpog = @par_id_kredpog
END
/*--------------------------------------------------------------------------------------------------------
 View: shows credit contracts allocations
 History:
 09.07.2012 Ziga; Task ID 6938 - Created
 24.05.2013 Ziga; Task ID 7266 - modifications according to support for different currencies
 26.09.2013 Ziga; Bug ID 30395 - repaired calculation of field amount_return_lp
 01.07.2019 Ziga; MID 82697 - added fields is_canceled, date_canceled, canceled_amount and canceled_amount_lp
--------------------------------------------------------------------------------------------------------*/
CREATE VIEW [dbo].[gv_KredPogAllocation]
AS
SELECT a.id_kred_pog_pogodba_alloc, a.id_kredpog, a.id_pogodba_kp_npm,
		case when p.status_akt in ('A','Z') and a.is_canceled = 0 then a.allocated_amount else 0 end as allocated_amount,
		case when p.status_akt in ('A','Z') and a.is_canceled = 0
			then case when t.id_val = tl.id_val
						then a.allocated_amount
						else dbo.gfn_Xchange(dbo.gfn_GetSredTec(tl.id_tec), a.allocated_amount, t.id_tec, p.dat_sklen)
				 end
			 else 0
		end as allocated_amount_lp,
		case when p.status_akt not in ('A', 'Z') and a.is_canceled = 0 then a.allocated_amount else 0 end as reserved_amount,
		case when p.status_akt not in ('A','Z') and a.is_canceled = 0
			then case when t.id_val = tl.id_val
						then a.allocated_amount
						else dbo.gfn_Xchange(dbo.gfn_GetSredTec(tl.id_tec), a.allocated_amount, t.id_tec, p.dat_sklen)
				 end
			 else 0
		end as reserved_amount_lp,
		case when p.status_akt in ('A','Z') then cast(0 as bit) else cast(1 as bit) end as reserved,
		a.date_updated, a.user_updated, a.id_kredpog_return,
		a.amount_return,
		case when t.id_val = tl.id_val
				then a.amount_return
				else dbo.gfn_Xchange(dbo.gfn_GetSredTec(tl.id_tec), a.amount_return, t.id_tec, p.dat_sklen)
		end as amount_return_lp,
		a.date_return,
		a.is_canceled,
		a.date_canceled,
		case when a.is_canceled = 1 then a.allocated_amount else 0 end as canceled_amount,
		case when a.is_canceled = 1
			then case when t.id_val = tl.id_val
						then a.allocated_amount
						else dbo.gfn_Xchange(dbo.gfn_GetSredTec(tl.id_tec), a.allocated_amount, t.id_tec, p.dat_sklen)
				 end
			 else 0
		end as canceled_amount_lp,
		p.id_pog, d.for_allocation,
		d.amount_for_allocation,
		case when t.id_val = tl.id_val
				then d.amount_for_allocation
				else dbo.gfn_Xchange(dbo.gfn_GetSredTec(tl.id_tec), d.amount_for_allocation, t.id_tec, p.dat_sklen)
		end as amount_for_allocation_lp,
		d.all_in_price_for_NPM, a.all_in_price_for_NPM_zac, d.id_purpose, e.value as purpose_desc,
		c.id_cont, c.ef_obrm_npm_zac, c.ef_obrm_npm, c.passive_interest_rate_npm_zac, c.passive_interest_rate_npm, c.npm_zac, c.npm,
		p.dat_sklen as dat_sklen_lp, p.dat_aktiv as dat_aktiv_lp,
		t.id_tec as id_tec_kp, t.id_val as id_val_kp, dbo.gfn_GetSredTec(tl.id_tec) as id_tec_lp, tl.id_val as id_val_lp
FROM dbo.kred_pog_pogodba_allocation a
INNER JOIN dbo.pogodba_kp_npm c ON c.id_pogodba_kp_npm = a.id_pogodba_kp_npm
INNER JOIN dbo.pogodba p on p.id_cont = c.id_cont
INNER JOIN dbo.kred_pog d ON d.id_kredpog = a.id_kredpog
INNER JOIN dbo.tecajnic t on t.id_tec = dbo.gfn_GetNewTec(d.id_tec)
INNER JOIN dbo.tecajnic tl on tl.id_tec = dbo.gfn_GetNewTec(p.id_tec)
LEFT JOIN dbo.gfn_g_register('KRED_POG_ALLOC_PURPOSE') e ON e.id_key = d.id_purpose