declare @id_oc_report int = 318
--select * from dbo.oc_reports where id_oc_report = @id_oc_report
--DECLARE	@id_oc_report int
DECLARE @id_tec char(3)
DECLARE @id_val char(3)
DECLARE @target_date datetime
DECLARE @entity_code char (5)
DECLARE @target_tecaj decimal (10,6)
DECLARE @sporna_potrazivanja char(8)

DECLARE @id_oc_report_orig int
DECLARE @id_prov_report_NRT int
DECLARE @id_prov_report_RET int
--DECLARE @db_name varchar(20)

--SET    	@id_oc_report = {1}
SET     @id_tec= '000'
SET     @id_val = 'eur'
--SET     @db_name = '{9}' it is used directly in SELECT

DECLARE @odjel VARCHAR(100)
SET @odjel=''

SELECT @entity_code = entity_code FROM dbo.gv_OcReports WHERE id_oc_report = @id_oc_report

Select @target_date=date_to from dbo.gv_OcReports Where id_oc_report=@id_oc_report
SET @target_tecaj = dbo.gfn_VrednostTecaja(@id_tec, @target_date,@id_oc_report)

Select @target_date=date_to, @id_oc_report_orig = id_oc_report_orig from dbo.gv_OcReports Where id_oc_report=@id_oc_report

select sum(ex_saldo_val_claim) as sum_ex_saldo_val_claim, cl.id_oc_report, cl.id_cont,
		--POTRAŽIVANJA 'POLO','OPC','LOBR','VARS'
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj),2) else 0 end) as overdue,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.neto/cl.debit),2) else 0 end) as otv_glav,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.obresti/cl.debit),2) else 0 end) as otv_kamata,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.regist/cl.debit),2) else 0 end) as otv_dodusl,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.davek/cl.debit),2) else 0 end) as otv_porez,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.robresti/cl.debit),2) else 0 end) as otv_robresti,

		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as debit_nedospj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_glavnica_nedospj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.obresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_kamata_nedospj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_robresti_nedospj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as debit_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_glavnica_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_robresti_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.obresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_kamata_neproknj,

		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as glavnica_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.obresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as kamata_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.regist, cl.id_tec, @target_date, @id_oc_report) else 0 end) as dodusl_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.davek, cl.id_tec, @target_date, @id_oc_report) else 0 end) as porez_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as robresti_neproknj,
		
		sum(case when cl.evident='' and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as otkup_neproknj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as otkup_nedospj,

		sum(case when cl.evident='' and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as rotkup_neproknj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as rotkup_nedospj,

		--OSTALA POTRAŽIVANJA
		sum(case when cl.evident = '*' and cl.dat_zap > @target_date And vt.sif_terj not in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.ex_debit_val_claim, cl.id_tec, @target_date, @id_oc_report) else 0 end) as ost_nedospj,
		sum(case when cl.evident = '*' and cl.dat_zap > @target_date And vt.sif_terj not in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as ost_debit_nedospj1,		
		sum(case when cl.evident = '' And vt.sif_terj not in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as ost_neproknj,
		sum(case when cl.evident = '*' and cl.dat_zap <= @target_date And vt.sif_terj not in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj),2) else 0 end) as otv_ostalo,
		--SVA POTRAŽIVANJA
		max(Case when cl.evident = '*' And cl.dat_zap <= @target_date then cl.ex_dni_zamude else 0 end) as max_dni_zamude
		from dbo.oc_claims cl
		inner join dbo.vrst_ter vt on vt.id_oc_report = cl.id_oc_report and vt.id_terj = cl.id_terj
		where cl.id_oc_report = @id_oc_report
		--and charindex(cl.id_terj,@sporna_potrazivanja)=0
		and ST_DOK = '73545/23-21-003AVT'

		group by cl.id_cont, cl.id_oc_report


select sum(ex_saldo_val_claim) as sum_ex_saldo_val_claim, cl.id_oc_report, cl.id_cont,
		--POTRAŽIVANJA 'POLO','OPC','LOBR','VARS'
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj),2) else 0 end) as overdue,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.neto/cl.debit),2) else 0 end) as otv_glav,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.obresti/cl.debit),2) else 0 end) as otv_kamata,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.regist/cl.debit),2) else 0 end) as otv_dodusl,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.davek/cl.debit),2) else 0 end) as otv_porez,
		sum(case when cl.evident = '*' And cl.dat_zap <= @target_date 
			And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj) * (cl.robresti/cl.debit),2) else 0 end) as otv_robresti,

		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as debit_nedospj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_glavnica_nedospj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.obresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_kamata_nedospj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_robresti_nedospj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as debit_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_glavnica_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_robresti_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.obresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as uk_kamata_neproknj,

		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as glavnica_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.obresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as kamata_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.regist, cl.id_tec, @target_date, @id_oc_report) else 0 end) as dodusl_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.davek, cl.id_tec, @target_date, @id_oc_report) else 0 end) as porez_neproknj,
		sum(case when cl.evident='' And vt.sif_terj in ('POLO','OPC','LOBR','VARS') and NOT(vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as robresti_neproknj,
		
		sum(case when cl.evident='' and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as otkup_neproknj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.neto, cl.id_tec, @target_date, @id_oc_report) else 0 end) as otkup_nedospj,

		sum(case when cl.evident='' and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as rotkup_neproknj,
		sum(case when cl.evident='*' and cl.dat_zap > @target_date and (vt.sif_terj = 'OPC' OR (vt.sif_terj = 'LOBR' And cl.obresti = 0)) then dbo.gfn_Xchange(@id_tec, cl.robresti, cl.id_tec, @target_date, @id_oc_report) else 0 end) as rotkup_nedospj,

		--OSTALA POTRAŽIVANJA
		sum(case when cl.evident = '*' and cl.dat_zap > @target_date And vt.sif_terj not in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.ex_debit_val_claim, cl.id_tec, @target_date, @id_oc_report) else 0 end) as ost_nedospj,
		sum(case when cl.evident = '*' and cl.dat_zap > @target_date And vt.sif_terj not in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as ost_debit_nedospj1,		
		sum(case when cl.evident = '' And vt.sif_terj not in ('POLO','OPC','LOBR','VARS') then dbo.gfn_Xchange(@id_tec, cl.debit, cl.id_tec, @target_date, @id_oc_report) else 0 end) as ost_neproknj,
		sum(case when cl.evident = '*' and cl.dat_zap <= @target_date And vt.sif_terj not in ('POLO','OPC','LOBR','VARS') then ROUND((cl.ex_saldo_dom/@target_tecaj),2) else 0 end) as otv_ostalo,
		--SVA POTRAŽIVANJA
		max(Case when cl.evident = '*' And cl.dat_zap <= @target_date then cl.ex_dni_zamude else 0 end) as max_dni_zamude
		from dbo.oc_claims cl
		inner join dbo.vrst_ter vt on vt.id_oc_report = cl.id_oc_report and vt.id_terj = cl.id_terj
		where cl.id_oc_report = @id_oc_report
		--and charindex(cl.id_terj,@sporna_potrazivanja)=0
and cl.id_cont = 81725

		group by cl.id_cont, cl.id_oc_report
select ex_g1_neto, * from dbo.oc_contracts where id_cont = 81725 and id_oc_report = @id_oc_report
select * from dbo.oc_claims where id_cont = 81725 and id_oc_report = @id_oc_report
select * from dbo.oc_claims_future where id_cont = 81725 and id_oc_report = @id_oc_report --
select sum(neto) as sum_neto from dbo.oc_claims_future where id_cont = 81725 and id_oc_report = @id_oc_report -- 

declare @report_id int = @id_oc_report
-- REV, RFO  
-- dued not paied  
select fp.ID_CONT, f.id_frame,   
 sum(  
  case when upper(IsNull(cs.val, '')) = 'TRUE' and FT.sif_frame_type = 'REV' then  
    case when p.status_akt in ('N','D') then 0 else (case when oc.datum_dok <= @target_date then ov.znesek else 0 end) end  
  else  
   CASE WHEN oc.datum_dok <= @target_date AND (FT.sif_frame_type <> 'RNE' OR T.sif_terj = 'DDV')  
   THEN ov.znesek  
   ELSE 0 END  
  end  
 ) as Obligo_val,  
 sum(  
  case when upper(IsNull(cs.val, '')) = 'TRUE' and FT.sif_frame_type = 'REV' then  
    case when p.status_akt in ('N','D') then 0 else (case when oc.datum_dok <= @target_date then ov.znesek else 0 end) end  
  else     CASE WHEN oc.datum_dok <= @target_date AND (FT.sif_frame_type <> 'RNE' OR T.sif_terj = 'DDV')  
   THEN od.znesek  
   ELSE 0 END  
  end  
 ) as Obligo_dom  
--into #oc_claims  
from nova_prod.dbo.frame_list f   
INNER JOIN nova_prod.dbo.frame_type FT ON F.frame_type = FT.id_frame_type  
inner join dbo.frame_pogodba fp on f.id_frame = fp.id_frame and fp.id_oc_report = @report_id 
inner join dbo.oc_claims oc on oc.id_cont = fp.id_cont  and oc.id_oc_report = @report_id
inner join dbo.oc_contracts p on p.id_oc_report = oc.id_oc_report and p.id_cont = oc.id_cont   and p.id_oc_report = @report_id
inner join dbo.vrst_ter T on T.id_terj = oc.id_terj and t.id_oc_report = @report_id  
left join (select entity_name from dbo.loc_nast where id_oc_report = @report_id) ln on 1 = 1  
left join (select /*'false' as val*/ val from dbo.custom_settings where code = 'Nova.LE.FrameViewUseBookedNotDuedDebitAll4ObligoCalc' and id_oc_report = @report_id) cs on 1 = 1  
outer apply dbo.gfn_xchange_table(f.id_tec, oc.ex_saldo_val_claim, oc.id_tec, @target_date, @report_id) ov  
outer apply dbo.gfn_xchange_table('000', oc.ex_saldo_val_claim, oc.id_tec, @target_date, @report_id) od  
where   
FT.sif_frame_type in ('REV', 'RFO', 'RNE')   
and oc.id_oc_report = @report_id  
and f.id_frame = 2837
group by f.id_frame, fp.id_cont 


