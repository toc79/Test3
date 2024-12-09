------------------------------------------------------------------------------------------------------------  
-- Gets delimiting data in a appropriate way  
--   
-- History:  
-- 15.04.2009 Jure; TASK 5539 - created  
-- 15.04.2009 Jure; TASK 5539 - changed caption when raz_tip = 1(turned around)  
-- 13.07.2009 MatjazB; Task 5539 - CAST field raz_tip_opis  
-- 05.09.2013 Ales; Task id 7512 - added parameter id_project  
-- 21.03.2018 Nejc; TID 12991 - GDPR added parameter to function  
------------------------------------------------------------------------------------------------------------  
  
CREATE FUNCTION [dbo].[gfn_Gl_Razmej_View](  
@id_kupca varchar(6)  
) returns table   
AS  
return (  
SELECT         A.id_gl_razmej, A.konto, A.raz_pkonto, A.id_cont, A.ddv_id, A.id_strm, A.znesek, A.znesek_se,  
                   A.opis_dok, A.raz_datum, A.raz_st_obr, A.raz_obdobj, A.raz_tip, A.pas_akt, A.kljuc, A.dat_aktiv, A.id_kupca,  
                   A.st_dok, A.veza_l4, A.veza_ni_ok, A.obrokov_se, A.id_source, A.vrsta_dok, A.interna_veza,  
                   raz_tip_opis = CAST(CASE WHEN raz_tip=1   
                                        THEN UPPER(dbo.gfn_GetAppMessageByLang(NULL, 'CAccrualsTypeL'))   
                                        ELSE UPPER(dbo.gfn_GetAppMessageByLang(NULL, 'CAccrualsTypeLD'))  
                                    END AS varchar(239)),  
                ddv_date = (CASE WHEN a.vrsta_dok = 'IFA' THEN ro.ddv_date   
                                 WHEN a.vrsta_dok = 'PFA' THEN ri.ddv_date  
                     ELSE NULL  
                       END),  
                status = (CASE WHEN a.dat_aktiv is null THEN 'N'  
                      WHEN a.dat_aktiv is not null and znesek_se=0 THEN 'Z'  
                      ELSE 'A'  
                    END),   
                B.naz_kr_kup, ISNULL(C.id_pog, pd.id_pog) AS id_pog, C.status_akt,  
                pas_akt_opis = (CASE WHEN A.pas_akt=1 THEN 'Pas.' ELSE 'Akt.' END),  
                   OBD.naziv as dinamika,   
                   A.id_project, p.projectname, p.projectnumber  
         FROM dbo.gl_razmej AS A   
         LEFT JOIN dbo.gfn_Partner_Pseudo('grp_Gl_Razmej_View',@id_kupca) AS B   
              ON A.id_kupca = B.id_kupca   
         LEFT JOIN dbo.pogodba AS C   
              ON A.id_cont = C.id_cont  
         LEFT JOIN dbo.rac_out ro   
              ON ro.ddv_id = a.ddv_id AND a.vrsta_dok = 'IFA'  
         LEFT JOIN (SELECT ddv_id, MAX(ddv_date) AS ddv_date   
                         FROM dbo.rac_in   
                        GROUP BY ddv_id) ri   
              ON ri.ddv_id = a.ddv_id AND a.vrsta_dok = 'PFA'  
         LEFT JOIN dbo.pogodba_deleted pd   
              ON A.id_cont = pd.id_cont  
            LEFT JOIN dbo.obdobja AS OBD  
              ON A.raz_obdobj = OBD.id_obd  
            LEFT JOIN dbo.projects p ON p.id_project = a.id_project  
)  
  