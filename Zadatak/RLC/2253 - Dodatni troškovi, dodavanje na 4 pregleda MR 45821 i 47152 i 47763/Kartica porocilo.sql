-- 12.09.2021 g_tomislav MID 47152 - created based on gfn_GL_Overview2_Current
declare @from datetime = '20200101'
declare @to datetime = '20210909'
declare @enabled_id_vrst_dod_str bit = 0
declare @id_vrst_dod_str varchar(2) = '01'
declare @from_archive bit = 0

SELECT --g.id_gl,  
  g.konto,  
  g.id_kupca, 
  c.naz_kr_kup,
  g.vrsta_dok,  
  g.debit_dom,  
  g.kredit_dom,  
  g.protikonto,  
  g.st_dok,  
  g.datum_dok,  
  str(month(g.datum_dok),2,0)+'.'+str(year(g.datum_dok),4,0) as obdobje,  
  g.debit_val,  
  g.kredit_val,  
  g.id_val,  
  g.veza,  
  g.interna_veza,
  g.id_strm,  
  isnull(p1.id_pog, p2.id_pog) as id_pog,  
  irk.id_vrst_dod_str,
  vds.naziv as vrst_dod_str_naziv,
  g.opisdok,  
  g.dur,  
  g.njihova_st,
  a.naziv as konto_naziv
  --g.kljuc,  
  --g.valuta,  
  --g.tecaj,  
  --g.id_tec,  
  --g.st_tem,  
  --g.id_dnevnik,  
  --g.debit_dom-g.debit_dom as komulativa,  --??  
  --g.debit_dom-g.kredit_dom as saldo_dom,  
  --g.id_cont,  
  --g.dat_vnosa,  
  --c.vr_osebe,  
  --c.sif_dej,  
  --g.vnesel,  
  --u.user_desc as users_vnesel,  
  --(case when left(g.id_dnevnik, 2) = 'FA' then f.naziv else v.opis_dok end) as vrstadokopis,  
  --isnull(p1.id_tec, '') as pid_tec,  
  --isnull(p1.id_val, '') as pid_val,  
  --c.id_skis,  
  --h.opis as skis_opis,  
  --g.id_parent,  
  --g.source_tbl,  
  --g.id_source,  
  --ap.naziv as protikonto_naziv,  
  --cast(0 as bit) as changed,  
  --g.id_project, p.projectnumber, p.projectname  
from dbo.gl g
LEFT JOIN dbo.partner C ON G.id_kupca = C.id_kupca   
--LEFT JOIN dbo.vrstedok V ON G.vrsta_dok = V.vrsta_dok  
--LEFT JOIN dbo.fa_vrst_spr F ON G.vrsta_dok = F.vrsta_dok  
LEFT JOIN dbo.akonplan A ON G.konto = A.konto  
--LEFT JOIN dbo.sif_skis H ON C.id_skis = H.id_skis  
LEFT JOIN dbo.pogodba p1 ON G.id_cont = P1.id_cont  
LEFT JOIN dbo.pogodba_deleted p2 ON G.id_cont = P2.id_cont  
--LEFT JOIN dbo.akonplan AP ON G.protikonto = AP.konto  
--LEFT JOIN dbo.users U ON G.vnesel = U.username  
--LEFT JOIN dbo.projects P on P.id_project = G.id_project
left join dbo.GL_RAZ_PLAN rp on g.ID_SOURCE = rp.ID_GL_RAZ_PLAN
left join dbo.gl_razmej r on r.ID_GL_RAZMEJ = rp.ID_GL_RAZMEJ
inner join dbo.ARH_GL_INPUT_RK irk on r.id_source = irk.ID_GL_INPUT_RK
inner join dbo.vrst_dod_str vds on irk.id_vrst_dod_str = vds.id_vrst_dod_str
where datum_dok between @from and @to
and g.vrsta_dok != 'OTV'
and (g.SOURCE_TBL = 'gl_input_rk' or r.SOURCE_TBL = 'gl_input_rk')
and irk.id_vrst_dod_str is not null
and (0 = @enabled_id_vrst_dod_str OR charindex(@id_vrst_dod_str, irk.id_vrst_dod_str) > 0)

union all 

SELECT --g.id_gl,  
  g.konto,  
  g.id_kupca, 
  c.naz_kr_kup,
  g.vrsta_dok,  
  g.debit_dom,  
  g.kredit_dom,  
  g.protikonto,  
  g.st_dok,  
  g.datum_dok,  
  str(month(g.datum_dok),2,0)+'.'+str(year(g.datum_dok),4,0) as obdobje,  
  g.debit_val,  
  g.kredit_val,  
  g.id_val,  
  g.veza,  
  g.interna_veza,
  g.id_strm,  
  isnull(p1.id_pog, p2.id_pog) as id_pog,  
  irk.id_vrst_dod_str,
  vds.naziv as vrst_dod_str_naziv,
  g.opisdok,  
  g.dur,  
  g.njihova_st,
  a.naziv as konto_naziv
  --g.kljuc,  
  --g.valuta,  
  --g.tecaj,  
  --g.id_tec,  
  --g.st_tem,  
  --g.id_dnevnik,  
  --g.debit_dom-g.debit_dom as komulativa,  --??  
  --g.debit_dom-g.kredit_dom as saldo_dom,  
  --g.id_cont,  
  --g.dat_vnosa,  
  --c.vr_osebe,  
  --c.sif_dej,  
  --g.vnesel,  
  --u.user_desc as users_vnesel,  
  --(case when left(g.id_dnevnik, 2) = 'FA' then f.naziv else v.opis_dok end) as vrstadokopis,  
  --isnull(p1.id_tec, '') as pid_tec,  
  --isnull(p1.id_val, '') as pid_val,  
  --c.id_skis,  
  --h.opis as skis_opis,  
  --g.id_parent,  
  --g.source_tbl,  
  --g.id_source,  
  --ap.naziv as protikonto_naziv,  
  --cast(0 as bit) as changed,  
  --g.id_project, p.projectnumber, p.projectname  
from dbo.gl_arhiv g
LEFT JOIN dbo.partner C ON G.id_kupca = C.id_kupca   
--LEFT JOIN dbo.vrstedok V ON G.vrsta_dok = V.vrsta_dok  
--LEFT JOIN dbo.fa_vrst_spr F ON G.vrsta_dok = F.vrsta_dok  
LEFT JOIN dbo.akonplan A ON G.konto = A.konto  
--LEFT JOIN dbo.sif_skis H ON C.id_skis = H.id_skis  
LEFT JOIN dbo.pogodba p1 ON G.id_cont = P1.id_cont  
LEFT JOIN dbo.pogodba_deleted p2 ON G.id_cont = P2.id_cont  
--LEFT JOIN dbo.akonplan AP ON G.protikonto = AP.konto  
--LEFT JOIN dbo.users U ON G.vnesel = U.username  
--LEFT JOIN dbo.projects P on P.id_project = G.id_project
left join dbo.GL_RAZ_PLAN rp on g.ID_SOURCE = rp.ID_GL_RAZ_PLAN
left join dbo.gl_razmej r on r.ID_GL_RAZMEJ = rp.ID_GL_RAZMEJ
inner join dbo.ARH_GL_INPUT_RK irk on r.id_source = irk.ID_GL_INPUT_RK
inner join dbo.vrst_dod_str vds on irk.id_vrst_dod_str = vds.id_vrst_dod_str
where 1 = @from_archive
and datum_dok between @from and @to
and g.vrsta_dok != 'OTV'
and (g.source_tbl = 'gl_input_rk' or r.source_tbl = 'gl_input_rk')
and irk.id_vrst_dod_str is not null
and (0 = @enabled_id_vrst_dod_str OR charindex(@id_vrst_dod_str, irk.id_vrst_dod_str) > 0)

order by datum_dok



and datum_dok between @from and @to
and g.vrsta_dok != 'OTV'
and (g.source_tbl = 'gl_input_rk' or r.source_tbl = 'gl_input_rk')
and irk.id_vrst_dod_str is not null
and (0 = @enabled_id_vrst_dod_str OR irk.id_vrst_dod_str = @id_vrst_dod_str)