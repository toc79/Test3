provjerili smo podatke nevedenih restruktura te je za svaku restruktutu stvarno dodijeljen taj broj ugovora. 
Testirao sam mogućnosti popravka restruktura i na svakoj se može promijeniti boroj ugovora. Da li vam odgovara da ručno popravite te podatke?  
Za provjeru kako je do toga došlo potrebno je napraviti detaljniju analizu, a s obzirom da se podaci restruktura mogu unositi ručno i ručno mijnjati, na prvi pogled se čini da bi za provjeru takvih podataka trebalo dosta vremena. Za restrukture ručno unesene bi zaključak bio da je korisnik tako unio i da se radi i grešci unosa.
Možda je najbolje da nam definirate jednu restrukturu koju da provjerimo, a ta bi morala biti automatski uvezena iz odobrenja, pa da za nju napravimo analizu. Predviđamo da nam je za analizu navedenog slučaja potrebno 1 do 3 sata. Ako se pokaže da je riječ o grešci u I.S. NOVA, analiza neće biti naplaćena dok u suprotnom ćemo naplatiti stvarno utrošeno vrijeme analize maksimalno do iznosa 3 sata (po 79€).

6595 057
099 2782 226

0043137  

nakon reprograma s eautomatski doda u resturuture 

I treba vidjeti kako rade, ako ide automatski onda treba provjeriti 
<?xml version='1.0' encoding='utf-8' ?>
<odobrit_2_restructuring_transfer xmlns="urn:gmi:nova:leasing"></odobrit_2_restructuring_transfer>
------------------------------------------------------------------------------------------------------------  
-- Function for getting data for restructuring  
--   
--  
-- History:  
-- 23.03.2016 Jelena; Task 9469 - created  
-- 30.09.2016 Jelena; Task 9656 - handling null for numeric fields  
-- 04.10.2017 Blaz; TID 11514 - added new fields  
-- 06.10.2017 Blaz; TID 11514 - added another field  
-- 09.10.2017 Blaz; TID 11514 - changed to display id_pog  
-- 11.10.2017 Blaz; BID 33384 - implemented gfn_StringToFOX  
-- 13.10.2017 Blaz; BID 33394 - changed the aneks_pogodba display  
-- 23.11.2017 MatjazB; Task 11642 - added type_description  
-- 01.03.2018; Jelena; TID 12921 - GDPR  
-- 24.08.2020; Thor; TID 19715 - Added criteria for end_date and probation_start_date, @par_end_enabled, @par_poskus_start_enabled  
-- 28.08.2020; Thor; TID 19715 - Added criteria for probation_end_date, @par_poskus_end_enabled  
------------------------------------------------------------------------------------------------------------  
CREATE PROCEDURE [dbo].[grp_restructuring_view]   
    @par_pogodba_enabled int,  
    @par_pogodba_value varchar(8000),   
    @par_partner_enabled int,  
    @par_partner_value char(6),  
    @par_type_enabled int,  
    @par_type int,  
 @par_end_enabled  int,   
 @par_end_datumod datetime,  
    @par_end_datumdo datetime,  
 @par_poskus_start_enabled  int,   
 @par_poskus_start_datumod datetime,  
    @par_poskus_start_datumdo datetime,  
 @par_poskus_end_enabled  int,   
 @par_poskus_end_datumod datetime,  
    @par_poskus_end_datumdo datetime  
AS  
BEGIN  
  
 DECLARE @id_kupca char(8)  
  if @par_partner_enabled = 1   
   set @id_kupca = @par_partner_value   
  else  
   set @id_kupca = null  
  
    select   
        r.id_restructuring, r.id_restructuring_type, rt.[type], po.id_cont, po.id_pog, r.approval_date, r.implementation_date, rt.concession,   
        isnull(r.dpd_value_at_start, 0) as dpd_value_at_start,  
        isnull(r.exposure_value_at_start, 0) as exposure_value_at_start,  
        isnull(r.odr_at_start, 0) as odr_at_start,  
        isnull(r.future_capital_at_start, 0) as future_capital_at_start,   
        r.financial_difficulties, r.[description], dbo.gfn_StringToFOX(r.[description]) as description_short, r.id_odobrit, o.id_doc, r.approved_by, ua.USER_DESC as approved_by_desc,  
        r.kategorija1, k1.value as kategorija1_naziv, r.kategorija2, k2.value as kategorija2_naziv, r.kategorija3, k3.value as kategorija3_naziv, r.kategorija4, k4.value as kategorija4_naziv,  
        r.kategorija5, k5.value as kategorija5_naziv, r.kategorija6, k6.value as kategorija6_naziv, r.vnesel, uv.user_desc as vnesel_desc, r.inactive, r.dat_vnosa,  pr.id_kupca, pr.naz_kr_kup,  
        r.id_tec, t.id_val, r.znesek_odpisa as znesek_odpisa, r.znesek_izgube as znesek_izgube, r.moratorij as moratorij,   
        case when r.aneks_pogodba = 'P' then 'P - Nova pogodba' when r.aneks_pogodba = 'A' then 'A - Aneks' else '' end as aneks_pogodba, pop.id_pog as id_cont_prej,  
        r.dopolni_vnos as dopolni_vnos,   
        rt.[description] as type_description, dbo.gfn_StringToFOX(rt.[description]) as type_description_short,  
  r.end_date as end_date,r.probation_start_date as probation_start_date,r.probation_end_date as probation_end_date   
    from   
        dbo.restructuring r  
        inner join dbo.restructuring_type rt on rt.id_restructuring_type = r.id_restructuring_type  
        inner join dbo.pogodba po on po.id_cont = r.id_cont  
  inner join dbo.gfn_Partner_Pseudo('grp_restructuring_view', @id_kupca) pr ON pr.id_kupca = po.ID_KUPCA  
        left join dbo.pogodba pop on pop.id_cont = r.id_cont_prej  
        left join dbo.Odobrit o on o.id_odobrit = r.id_odobrit  
        left join dbo.users uv on uv.username = r.vnesel  
        left join dbo.users ua on ua.username = r.approved_by  
        left join dbo.TECAJNIC t ON t.id_tec = r.id_tec  
        left join dbo.gfn_g_register('RESTRUKTURE_KATEGORIJA1') k1 on k1.id_key = r.kategorija1  
        left join dbo.gfn_g_register('RESTRUKTURE_KATEGORIJA2') k2 on k2.id_key = r.kategorija2  
        left join dbo.gfn_g_register('RESTRUKTURE_KATEGORIJA3') k3 on k3.id_key = r.kategorija3  
        left join dbo.gfn_g_register('RESTRUKTURE_KATEGORIJA4') k4 on k4.id_key = r.kategorija4  
        left join dbo.gfn_g_register('RESTRUKTURE_KATEGORIJA5') k5 on k5.id_key = r.kategorija5  
        left join dbo.gfn_g_register('RESTRUKTURE_KATEGORIJA6') k6 on k6.id_key = r.kategorija6  
    where  
        (@par_pogodba_enabled = 0 OR po.id_pog like @par_pogodba_value) AND  
        (@par_partner_enabled = 0 OR pr.id_kupca = @par_partner_value) AND  
        (@par_type_enabled = 0 OR rt.id_restructuring_type = @par_type) AND  
  (@par_end_enabled = 0 OR r.end_date BETWEEN convert(varchar(30), @par_end_datumod, 126) AND convert(varchar(30), @par_end_datumdo, 126)) AND  
  (@par_poskus_start_enabled = 0 OR r.probation_start_date BETWEEN convert(varchar(30), @par_poskus_start_datumod, 126) AND convert(varchar(30), @par_poskus_start_datumdo, 126)) AND  
  (@par_poskus_end_enabled = 0 OR r.probation_end_date BETWEEN convert(varchar(30), @par_poskus_end_datumod, 126) AND convert(varchar(30), @par_poskus_end_datumdo, 126))   
  
END  