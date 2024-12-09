------------------------------------------------------------------------------------------------------------  
-- Function for getting data for Approval (odobritve)  
-- Complete read consists of these UDF  
-- 1. gfn_Odobrit_Main_View (this function)  
-- 3. gfn_Odobrit_Stanje_View  
-- 2. gfn_Odobrit_Porok_View  
-- 4. gfn_Odobrit_Zavar_View  
  
-- History:  
-- 31.03.2006 Muri; created  
-- 30.06.2006 Muri; modified to LEFT JOIN to Users  
-- 23.10.2006 Matjaz; Bug ID 26332 - added columns S.is_start, S.is_end  
-- 24.10.2006 Vilko; Bug ID 26332 - added column S.title  
-- 03.01.2007 Vilko; Maintenance ID 3722 - added columns O.id_frame and F.opis  
-- 25.01.2010 MatjazB; MID 23924 - added columns f.velja_do and f.dat_izteka  
-- 09.11.2010 JozeM; MID 26252 - added vin column  
-- 17.02.2011 Vilko; MID 27829 - added field o.id_odobrit_veza and id_doc_veza  
-- 21.03.2011 Jure; MID 28790 - Added fields for supplier and buyer: mesto, id_poste and ulica  
-- 30.10.2012 MatjazB; MID 36916 - added filed O.prevozeni_km and use gfn_GetUserDesc instead of LEFT JOIN dbo.users  
-- 26.09.2013 Jost; Task ID 7520 - add fields 'id_odobrit_tip', 'id_odobrit_kateg','id_cont', 'id_pog' and made join on 'dbo.pogodba'  
-- 02.10.2013 Jost; Task ID 7520 - add field 'id_planp_cl_content'  
-- 29.01.2014 Jelena; Task ID 7796 - added field id_p_eval  
-- 15.04.2014 Jasna; MID 45355 - added field change_data, changed is_start value  
-- 26.05.2014 Uros; Mr 45189 - added id_kupca_pl  
-- 31.07.2014 IgorS; Task ID 8182 - added join to dbo.Ponudba  
-- 04.08.2014 IgorS; Task ID 8182 - added column BOD_robresti  
-- 12.12.2014 Domen; MID 48513 - added column naziv_opr  
-- 16.05.2016 Jasna; MID 56457 -- added kategorija1 and kategorija2  
-- 30.09.2016 Blaz; MID 55653 - added field dat_1registracije  
-- 09.08.2019 MatjazB; BUG 37630 - added po.stroski_x  
-- 17.12.2019 MihaG; MID 87392 - added max_st_kloniranj  
------------------------------------------------------------------------------------------------------------  
  
CREATE FUNCTION [dbo].[gfn_Odobrit_Main_View]   
(  
@odobrit_id int  
)  
  
RETURNS TABLE  
AS  
  
RETURN (  
  
    SELECT   
        O.id_odobrit,  
        O.osnova,  
        O.id_pon,  
        O.id_doc,  
        O.nacin_leas,  
        O.id_wf_document,  
        O.id_tec,  
        O.naziv_kup_pon AS naziv_kup,  
        O.id_frame,  
        F.opis AS frame_opis,  
        O.referent AS username_vnesel,  
        WF.date_wf_started AS datum_vnosa,  
        WF.assigned_to AS username_dodeljeno,  
        WF.id_status AS status,  
        ISNULL(dbo.gfn_GetUserDesc(WF.assigned_to), WF.assigned_to) AS assigned_to_full_name,  
        ISNULL(dbo.gfn_GetUserDesc(O.referent), O.referent) AS username_referent_to_full_name,  
        O.vec_ponudb,  
        O.aktivna,  
        O.id_vrste,  
        VO.naziv as naziv_opr,  
        O.pred_naj,  
        O.id_kupca,  
        O.naziv_kup_pon,  
        K.Naz_kr_kup AS kupec_naziv,  
        K.ulica as kupec_ulica,  
        K.id_poste as kupec_id_poste,  
        K.mesto as kupec_mesto,  
        O.kupec_crna_lista,  
        O.kupec_odobritev,  
        O.kupec_zavrnitev,  
        O.id_dobavitelj,  
        D.Naz_kr_kup AS dobavitelj_naziv,  
        D.dav_stev AS dobavitelj_dav_stev,  
        D.emso AS dobavitelj_emso,  
        D.ulica as dobavitelj_ulica,  
        D.id_poste as dobavitelj_id_poste,  
        D.mesto as dobavitelj_mesto,  
        O.dobavitelj_crna_lista,  
        O.dobavitelj_pogodb,  
        O.obligoLH,  
        O.obligoLH_vred,  
        O.dat_pricak,  
        O.opis_pred,  
        O.vr_val,  
        O.vr_val_val,  
        O.vr_ocen_vred,  
        O.vr_ocen_vred_val,  
        O.vr_ocen_vred_tip,  
        O.vr_ocen_vred_datum,  
        O.MPC,  
        O.MPC_val,  
        O.letnik,  
        O.ocena_tveganja,  
        O.rizik_predmeta_financiranja,  
        O.skupina_predmeta_financiranja,  
        O.kdo_provizija,  
        O.plac_dob,  
        O.boniteta,  
        O.bilanca_datum,  
        O.evaluacija_datum,  
        O.prv_obr,  
       O.varscina,  
        O.net_nal,  
        O.ost_obr,  
        O.opcija,  
        O.obr_mera,  
        O.ostanek_dolga,  
        O.ZNPL,  
        O.BOD_debit,  
        O.BOD_glav,  
        O.obligo,  
        O.man_str,  
        O.stroski_zt,  
        O.stroski_pz,  
        O.zav_fin,  
        O.st_obrok,  
        O.traj_naj,  
        O.pokritost_zavar,  
        O.tip_DDV,  
        O.tip_DDV_traj,  
        O.porostva_dod_opis,  
        O.zavar_ostalo,  
        O.ddv AS Znesek_DDV,  
        case when S.change_data = 1 then cast(1 as bit) else S.is_start end as is_start,   
        S.is_end,  
        S.title,  
        f.velja_do AS frame_velja_do,  
        f.dat_izteka AS frame_dat_izteka,  
        O.vin,  
        O.id_odobrit_veza,  
        V.id_doc AS id_doc_veza,   
        O.prevozeni_km,  
        O.id_odobrit_tip,  
        O.id_odobrit_kateg,  
        O.id_cont,  
        P.id_pog,  
        O.id_planp_cl_content,  
        O.id_p_eval,  
        O.id_kupca_pl,  
        isnull(PO.robresti_val, 0) AS robresti_val,  
        isnull(O.BOD_robresti, 0) AS BOD_robresti,  
        O.kategorija1,  
        O.kategorija2,  
        O.dat_1registracije,   
        ISNULL(po.stroski_x, 0) as stroski_x,  
  O.max_st_kloniranj  
    FROM   
        dbo.Odobrit O  
        LEFT JOIN dbo.Partner K ON O.id_kupca = K.id_kupca  
        LEFT JOIN dbo.Partner D ON O.id_dobavitelj = D.id_kupca  
        LEFT JOIN dbo.WF_Document WF ON O.id_odobrit = WF.foreign_document AND WF.id_process = 'ODB'  
        LEFT JOIN dbo.WF_Status S ON WF.id_status = S.id_status AND S.id_process = 'ODB'  
        LEFT JOIN dbo.Frame_List F ON O.id_frame = F.id_frame  
        LEFT JOIN dbo.Odobrit V ON O.id_odobrit_veza = V.id_odobrit  
        LEFT JOIN dbo.Pogodba P on P.id_cont = O.id_cont  
        LEFT JOIN dbo.Ponudba PO ON PO.id_pon = O.id_pon  
        LEFT JOIN dbo.VRST_OPR VO on VO.id_vrste = O.id_vrste  
    WHERE O.id_odobrit = @odobrit_id  
)  