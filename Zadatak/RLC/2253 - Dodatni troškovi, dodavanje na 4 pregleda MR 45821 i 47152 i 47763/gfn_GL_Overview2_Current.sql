------------------------------------------------------------------------------------------------------------  
-- Function for getting data for GL_pregled (kartica saldakontov)  
--   
--  
-- History:  
-- 04.10.2004 Muri; created  
-- 08.10.2004 Muri; deleted field "Obdobje".   
-- 16.12.2004 Vilko; added field "id_gl"  
-- 25.01.2005 Darko: modified: added join on akonplan, field konto_naziv  
-- 04.02.2005 Matjaz; modified ON SITE: replaced = with LIKE for @par_stdok_value condition  
-- 18.02.2005 Darko; added parameters @par_datum_enabled, @par_datum_datum. Added IF clause and new select for archive  
-- 16.03.2005 Darko; added fields id_skis, skis_opis, join to table sif_skis  
-- 10.08.2005 Josip; added field interna veza  
-- 20.09.2005 Vilko; added join on pogodba_deleted  
-- 11.10.2005 Vilko; added field dat_vnosa  
-- 17.11.2005 Darko; changed order of paramters due: (konto container must depend of year of request)  
-- 29.11.2005 Darko; fields kumulativa, saldo_dom changed from decimal(18,6) to decimal(18,2)  
-- 19.12.2005 Matjaz; changed result.njihova_st to chanr(30) due to table structure change  
-- 13.06.2006 Vilko; resized field sif_dej from C(5) to C(6)  
-- 08.11.2006 Matjaz; changed declaration of exchange rate to decimal(20,10) (EUR project)  
-- 12.12.2006 Jasna; added new parameters @par_stpog_enabled and @par_stpog_value  
-- 16.01.2007 Jasna; changed field length naz_kr_kup (40-->80)  
-- 25.04.2007 Jasna; MID 8161 - added id_parent to select  
-- 22.06.2007 Ziga; MID 8937 - removed conditions in select statements -> conditions are added in stored procedure grp_GL_Overview  
-- 08.11.2007 Vik; Bug id 26924 - created as separate function that accesses only GL table  
-- 05.05.2009 Vilko; Bug ID 27808 - added field changed to mark modified bookings  
-- 14.08.2009 Ziga; MID 22011 - added field protikonto_naziv  
-- 09.09.2010 Vilko; MID 25605 - added field source_tbl and id_source  
-- 24.09.2010 Vilko; MID 25605 - added field users_vnesel  
-- 04.11.2010 Vilko; TID 6082 - modified field vrstadokopis  
-- 04.09.2013 Jelena; TID 7509 - added fields id_project, projectnumber and projectname  
-- 21.03.2018 Nejc; TID 12991 - GDPR  
------------------------------------------------------------------------------------------------------------  
  
CREATE FUNCTION [dbo].[gfn_GL_Overview2_Current]  
(  
 @id_kupca varchar(6),  
    @funcName varchar(100)  
)  
RETURNS TABLE  
AS  
RETURN (  
 SELECT   
  g.id_gl,  
  g.konto,  
  g.id_kupca,  
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
  g.id_strm,  
  g.opisdok,  
  g.dur,  
  g.kljuc,  
  g.valuta,  
  g.tecaj,  
  g.id_tec,  
  g.st_tem,  
  g.njihova_st,  
  g.interna_veza,  
  g.id_dnevnik,  
  g.debit_dom-g.debit_dom as komulativa,  --??  
  g.debit_dom-g.kredit_dom as saldo_dom,  
  g.id_cont,  
  g.dat_vnosa,  
  isnull(p1.id_pog, p2.id_pog) as id_pog,  
  c.vr_osebe,  
  c.sif_dej,  
  c.naz_kr_kup,  
  g.vnesel,  
  u.user_desc as users_vnesel,  
  (case when left(g.id_dnevnik, 2) = 'FA' then f.naziv else v.opis_dok end) as vrstadokopis,  
  isnull(p1.id_tec, '') as pid_tec,  
  isnull(p1.id_val, '') as pid_val,  
  a.naziv as konto_naziv,  
  c.id_skis,  
  h.opis as skis_opis,  
  g.id_parent,  
  g.source_tbl,  
  g.id_source,  
  ap.naziv as protikonto_naziv,  
        cast(0 as bit) as changed,  
        g.id_project, p.projectnumber, p.projectname  
           
       FROM   
  dbo.gl G   
  LEFT JOIN dbo.gfn_Partner_Pseudo(@funcName,@id_kupca) C ON G.id_kupca = C.id_kupca   
  LEFT JOIN dbo.vrstedok V ON G.vrsta_dok = V.vrsta_dok  
  LEFT JOIN dbo.fa_vrst_spr F ON G.vrsta_dok = F.vrsta_dok  
  LEFT JOIN dbo.akonplan A ON G.konto = A.konto  
  LEFT JOIN dbo.sif_skis H ON C.id_skis = H.id_skis  
  LEFT JOIN dbo.pogodba p1 ON G.id_cont = P1.id_cont  
  LEFT JOIN dbo.pogodba_deleted p2 ON G.id_cont = P2.id_cont  
  LEFT JOIN dbo.akonplan AP ON G.protikonto = AP.konto  
  LEFT JOIN dbo.users U ON G.vnesel = U.username  
  LEFT JOIN dbo.projects P on P.id_project = G.id_project  
)  
  