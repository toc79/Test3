------------------------------------------------------------------------------------------------------------  
-- Gets delimiting data in a appropriate way  
--   
-- History:  
-- 18.03.2009 Jure; TASK 5539 - created  
-- 13.07.2009 MatjazB; Task 5539 - remove % from LIKE condition  
-- 05.03.2010 Franci; Bug ID 28210 - added columns nezapadlo_le, nezapadlo_gl  
-- 05.09.2013 Ales; Task id 7512 - added parameter id_project  
-- 21.03.2018 Nejc; TID 12991 - GDPR added parameter to function  
------------------------------------------------------------------------------------------------------------  
  
CREATE PROCEDURE [dbo].[grp_Gl_Razmej_View]  
    -- activation status  
    @par_status_akt_enabled bit,  
    @par_status_akt_type int,  
    @par_status_akt_value varchar(100),  
    -- Date of the activation  
    @par_akt_obd_enabled bit,  
    @par_akt_obd_od char(8),   
    @par_akt_obd_do char(8),  
    -- account number  
    @par_konto_enabled int,  
    @par_konto_value varchar(8),   
    -- contra account  
    @par_raz_pkonto_enabled int,  
    @par_raz_pkonto_value varchar(8),   
     -- Leasee  
    @par_Id_kupca_Enabled bit,  
    @par_Id_kupca_value char(6),   
     -- Contract  
    @par_id_pog_enabled bit,  
    @par_id_pog_value char(11),   
    -- invoice number  
    @par_ddv_id_enabled bit,  
    @par_ddv_id_value varchar(100),  
    -- document id  
    @par_st_dok_enabled bit,  
    @par_st_dok_value varchar(100),  
    -- cost place  
    @par_id_strm_enabled bit,  
    @par_id_strm_value varchar(2000),  
 -- id project  
 @par_id_project_enabled int,  
 @par_id_project varchar(11),  
    -- diferences LE - GL  
 @par_diferences int  
  
AS  
BEGIN  
    DECLARE @cmd varchar(8000)  
  
 DECLARE @id_kupca char(8)  
    if @par_Id_kupca_Enabled = 1   
        set @id_kupca = '''' + @par_id_kupca_value + ''''  
 else  
  set @id_kupca = 'null'  
  
 SET @cmd = ''  
  
    SET @cmd = @cmd + '  
          SELECT   a.id_gl_razmej, a.konto, a.raz_pkonto, a.id_cont, a.ddv_id, a.id_strm, a.znesek, a.znesek_se,  
                   a.opis_dok, a.raz_datum, a.raz_st_obr, a.raz_obdobj, a.raz_tip, a.pas_akt, a.kljuc, a.dat_aktiv, a.id_kupca,  
                   a.st_dok, a.veza_l4, a.veza_ni_ok, a.obrokov_se, a.id_source, a.vrsta_dok, a.interna_veza,  
                   a.raz_tip_opis,  
                a.ddv_date,  
                a.status,  
                a.naz_kr_kup, a.id_pog, a.status_akt,  
                a.pas_akt_opis, a.dinamika, projectname, projectnumber '+  
                CASE WHEN @par_diferences = 1 THEN  
      ', CASE WHEN a.veza_l4 = 1 THEN b.st_nezap_le ELSE 0 END  as nezapadlo_le '  
       ELSE  
     ' '  
                END+  
    ' FROM dbo.gfn_Gl_Razmej_View('+@id_kupca+') a '  
    IF @par_diferences = 1  
    BEGIN  
     SET @cmd = @cmd + ' LEFT JOIN  
      (SELECT pp.id_cont,count(*) as st_nezap_le  
      FROM dbo.planp pp  
      left join dbo.vrst_ter vt on pp.id_terj=vt.id_terj  
      WHERE RTRIM(pp.evident)= '+''''+''''+' AND vt.sif_terj='+'''LOBR'''+'  
      GROUP BY pp.id_cont) b  on a.id_cont=b.id_cont         
   '  
   END  
   SET @cmd = @cmd + '  
           WHERE 1=1 '  
    IF @par_status_akt_enabled = 1  
    BEGIN  
     IF @par_status_akt_type = 1  
         SET @cmd = @cmd + 'AND (CHARINDEX(RTRIM(LTRIM(a.status)),''' + @par_status_akt_value + ''') = 0) '  
     ELSE   
            SET @cmd = @cmd + 'AND (CHARINDEX(RTRIM(LTRIM(a.status)),''' + @par_status_akt_value + ''') != 0) '  
    END      
  
    IF @par_akt_obd_enabled = 1  
        SET @cmd = @cmd + 'AND dbo.gfn_BetweenDate(a.dat_aktiv, ''' + @par_akt_obd_od + ''', ''' + @par_akt_obd_do + ''') = 1 '  
  
    IF @par_konto_enabled = 1  
        SET @cmd = @cmd + 'AND a.konto = ''' + @par_konto_value + ''' '  
  
    IF @par_raz_pkonto_enabled = 1  
        SET @cmd = @cmd + 'AND a.raz_pkonto = ''' + @par_raz_pkonto_value + ''' '  
      
    IF @par_Id_kupca_Enabled = 1  
        SET @cmd = @cmd + 'AND (a.id_kupca = ''' + @par_id_kupca_value + ''') '  
      
    IF @par_Id_pog_Enabled = 1  
        SET @cmd = @cmd + 'AND (a.id_pog = ''' + @par_id_pog_value + ''') '  
      
    IF @par_st_dok_Enabled = 1  
        SET @cmd = @cmd + 'AND (a.st_dok LIKE ''' + @par_st_dok_value + ''') '  
      
    IF @par_ddv_id_Enabled = 1  
        SET @cmd = @cmd + 'AND (a.ddv_id LIKE ''' + @par_ddv_id_value + ''') '  
  
    IF @par_id_strm_enabled = 1  
        SET @cmd = @cmd + 'AND CHARINDEX(a.id_strm, ''' + @par_id_strm_value + ''') > 0 '  
      
    IF @par_id_project_enabled = 1   
  SET @cmd = @cmd + ' AND id_project = ''' + @par_id_project + ''' '  
      
    print(@cmd)  
    exec(@cmd)  
          
END  
  