------------------------------------------------------------------------------------------------------------  
-- Procedure for getting data for GL_pregled (kartica saldakontov)  
--   
--  
-- History:  
-- 21.06.2007 Ziga; created  
-- 08.11.2007 Vik; Bug id 26924 - functions that access GL and GL_ARHIV tables are now separated  
-- 04.09.2008 PetraR; Task id 5354 - added criteria interna veza  
-- 10.10.2008 Jure; MID 17504 - added opis_dok parameter criterion  
-- 16.02.2009 Vilko; MID 19475 - added new criteria for field veza  
-- 21.10.2010 Vilko; Task ID 6082 - added new criteria for field konto - account list   
-- 08.07.2011 Jasna; BUG ID 28951 - added order by datum_dok  
-- 28.12.2011 Vilko; Bug ID 29162 - replaced * with a.* due some duplicated fields  
-- 04.07.2013 Vik; Task id 7171 - added rtrim to parameters of charindex  
-- 04.09.2013 Ales; Task id 7515 - added parameter id_project  
-- 20.06.2014 Jelena; Task ID 8153 - added support for business period, added @par_zac_stanje_enabled  
-- 20.06.2014 Jelena; Task ID 8153 - added @par_vknjizbe_zakljucka_enabled  
-- 02.07.2014 Jelena; Task ID 8153 - added @par_group_strm into call of gsp_GL_ZacetnaStanja  
-- 13.10.2014 MatjazB; Bug 30891 - change condition for account list (@par_konto_list_value)  
------------------------------------------------------------------------------------------------------------  
  
CREATE PROCEDURE [dbo].[grp_GL_Overview]  
  
 @par_partner_enabled int,  
 @par_partner_partner char(6),  
   
 @par_datum_enabled int,  
 @par_datum_datum int,  
   
 @par_konto_enabled int,  
 @par_konto_kontoOd varchar(8),   
 @par_konto_kontoDo varchar(8),   
  
 @par_konto_list_enabled int,  
 @par_konto_list_value varchar(8000),  
   
 @par_obdobje_enabled int,  
 @par_obdobje_datumod char(8),   
 @par_obdobje_datumdo char(8),  
   
 @par_strm_enabled int,  
 @par_strm_strm varchar(8000),  
   
 @par_vrstadok_enabled int,  
 @par_vrstadok_vrstadok char(3),  
   
 @par_stdok_enabled int,  
 @par_stdok_value varchar(8000),  
   
 @par_pogodba_enabled int,  
 @par_pogodba_deleted int,  
 @par_pogodba_pogodba varchar(11),   
 @par_pogodba_id_cont int,   
   
 @par_znesek_enabled int,  
 @par_znesek_znesek decimal(18,2),  
   
 @par_dnevnik_enabled int,  
 @par_dnevnik_value varchar(8000),  
  
    @par_interna_veza_enabled int,  
    @par_interna_veza_value varchar(50),  
  
 @par_opis_dok_enabled int,  
    @par_opis_dok_value varchar(50),  
  
    @par_veza_enabled int,  
    @par_veza_value varchar(21),  
      
 @par_id_project_enabled int,  
 @par_id_project varchar(11),  
  
 @par_vknjizbe_zakljucka_enabled bit,  
  
 @par_zac_stanje_enabled bit  
  
AS  
BEGIN  
  
DECLARE @cmd varchar(8000)  
  
IF @par_konto_enabled = 0   
BEGIN  
 SET @par_konto_kontoOd = null  
 SET @par_konto_kontoDo = null  
END  
  
IF @par_konto_list_enabled = 0   
 SET @par_konto_list_value = null  
  
IF @par_datum_enabled = 0  
 SET @par_datum_datum = null  
  
IF @par_partner_enabled = 0  
 SET @par_partner_partner = null  
  
IF @par_pogodba_enabled = 0  
 SET @par_pogodba_id_cont = null  
  
IF @par_stdok_enabled = 0  
 SET @par_stdok_value = null  
  
IF @par_veza_enabled = 0  
 SET @par_veza_value = null  
  
IF @par_id_project_enabled = 0  
 SET @par_id_project = null  
  
DECLARE @id_kupca char(8)  
    if @par_partner_enabled = 1   
        set @id_kupca = '''' + @par_partner_partner + ''''  
 else  
  set @id_kupca = 'null'  
  
DECLARE @vrsta_dok_zac char(3), @opis_dok_zac varchar(50), @par_group_strm bit  
SELECT @vrsta_dok_zac = vrsta_dok, @opis_dok_zac = opis_dok FROM dbo.vrstedok WHERE sif_dok = 'ZAC'  
SET @par_group_strm = (SELECT NEW_YEAR_GROUP_BY_COST_PLACE FROM dbo.gl_nastavit)  
  
--arhiv  
IF @par_datum_enabled = 1  
BEGIN  
 IF @par_zac_stanje_enabled = 1 BEGIN   
  DECLARE @guid varchar(40)  
  SET @guid = cast(newid() as varchar(40))  
  EXEC [dbo].[gsp_GL_ZacetnaStanja] @guid, @par_obdobje_datumod, @par_group_strm, @par_datum_datum, @par_konto_kontoOd, @par_konto_kontoDo, @par_konto_list_value, @par_partner_partner, @par_pogodba_id_cont, @par_stdok_value, @par_veza_value, @par_id_proje
ct  
  
  SET @cmd = '  
   SELECT * FROM (  
   SELECT   
    '''' as id_gl,  
    g.konto,  
    g.id_kupca,  
    ''' + @vrsta_dok_zac + ''' as vrsta_dok,  
    g.debit_dom,  
    g.kredit_dom,  
    '''' as protikonto,  
    g.st_dok,  
    ''' + @par_obdobje_datumod  + ''' as datum_dok,  
    str(month(''' + @par_obdobje_datumod  + '''),2,0)+''.''+str(year(''' + @par_obdobje_datumod  + '''),4,0) as obdobje,  
    g.debit_val,  
    g.kredit_val,  
    t.id_val,  
    g.veza,  
    g.id_strm,  
    g.opisdok,  
    g.dur,  
    '''' as kljuc,  
    g.valuta,  
    1 as tecaj,  
    g.id_tec,  
    '''' as st_tem,  
    '''' as njihova_st,  
    g.interna_veza,  
    '''' as id_dnevnik,  
    g.debit_dom-g.debit_dom as komulativa,   
    g.debit_dom-g.kredit_dom as saldo_dom,  
    g.id_cont,  
    g.dat_vnosa,  
    isnull(p1.id_pog, p2.id_pog) as id_pog,  
    c.vr_osebe,  
    c.sif_dej,  
    c.naz_kr_kup,  
    '''' as vnesel,  
    '''' as users_vnesel,  
    '''' as vrstadokopis,  
    isnull(p1.id_tec, '''') as pid_tec,  
    isnull(p1.id_val, '''') as pid_val,  
    a.naziv as konto_naziv,  
    c.id_skis,  
    h.opis as skis_opis,  
    '''' as id_parent,  
    ''GL_ZacetnaStanja'' as source_tbl,  
    '''' as id_source,  
    '''' as protikonto_naziv,  
    cast(0 as bit) as changed,  
    g.id_project, p.projectnumber, p.projectname     
   FROM   
   dbo.GL_ZacetnaStanja G   
   LEFT JOIN dbo.gfn_Partner_Pseudo(''grp_GL_Overview'',null) C ON G.id_kupca = C.id_kupca   
   LEFT JOIN dbo.akonplan A ON G.konto = A.konto  
   LEFT JOIN dbo.sif_skis H ON C.id_skis = H.id_skis  
   LEFT JOIN dbo.pogodba p1 ON G.id_cont = P1.id_cont  
   LEFT JOIN dbo.pogodba_deleted p2 ON G.id_cont = P2.id_cont  
   LEFT JOIN dbo.projects P on P.id_project = G.id_project  
   INNER JOIN dbo.tecajnic T ON T.id_tec = G.id_tec  
   WHERE g.session_id = ''' + @guid + '''  
  
   UNION  
  
   SELECT g.*  
   FROM dbo.gfn_GL_Overview2_Archive(' + cast(@par_datum_datum as varchar(5)) + ','+@id_kupca+',''grp_GL_Overview'') g   
   WHERE g.vrsta_dok <> ''ZAC'' ) a'  
  
  END  
  ELSE   
  BEGIN  
   SET @cmd = '  
    SELECT a.*  
    FROM dbo.gfn_GL_Overview2_Archive(' + cast(@par_datum_datum as varchar(5)) + ','+@id_kupca+',''grp_GL_Overview'') a '  
  END  
END  
--aktivno leto  
ELSE  
BEGIN  
 IF @par_zac_stanje_enabled = 1 BEGIN   
  
  DECLARE @guid1 varchar(40)  
  SET @guid1 = cast(newid() as varchar(40))  
  EXEC [dbo].[gsp_GL_ZacetnaStanja] @guid1, @par_obdobje_datumod, @par_group_strm, null, @par_konto_kontoOd, @par_konto_kontoDo, @par_konto_list_value, @par_partner_partner, @par_pogodba_id_cont, @par_stdok_value, @par_veza_value, @par_id_project  
  
  SET @cmd = '  
   SELECT * FROM (  
   SELECT   
    '''' as id_gl,  
    g.konto,  
    g.id_kupca,  
    ''' + @vrsta_dok_zac + ''' as vrsta_dok,  
    g.debit_dom,  
    g.kredit_dom,  
    '''' as protikonto,  
    g.st_dok,  
    ''' + @par_obdobje_datumod  + ''' as datum_dok,  
    str(month(''' + @par_obdobje_datumod  + '''),2,0)+''.''+str(year(''' + @par_obdobje_datumod  + '''),4,0) as obdobje,  
    g.debit_val,  
    g.kredit_val,  
    t.id_val,  
    g.veza,  
    g.id_strm,  
    g.opisdok,  
    g.dur,  
    '''' as kljuc,  
    g.valuta,  
    1 as tecaj,  
    g.id_tec,  
    '''' as st_tem,  
    '''' as njihova_st,  
    g.interna_veza,  
    '''' as id_dnevnik,  
    g.debit_dom-g.debit_dom as komulativa,   
    g.debit_dom-g.kredit_dom as saldo_dom,  
    g.id_cont,  
    g.dat_vnosa,  
    isnull(p1.id_pog, p2.id_pog) as id_pog,  
    c.vr_osebe,  
    c.sif_dej,  
    c.naz_kr_kup,  
    '''' as vnesel,  
    '''' as users_vnesel,  
    '''' as vrstadokopis,  
    isnull(p1.id_tec, '''') as pid_tec,  
    isnull(p1.id_val, '''') as pid_val,  
    a.naziv as konto_naziv,  
    c.id_skis,  
    h.opis as skis_opis,  
    '''' as id_parent,  
    ''GL_ZacetnaStanja'' as source_tbl,  
    '''' as id_source,  
    '''' as protikonto_naziv,  
    cast(0 as bit) as changed,  
    g.id_project, p.projectnumber, p.projectname     
   FROM   
   dbo.GL_ZacetnaStanja G   
   LEFT JOIN dbo.gfn_Partner_Pseudo(''grp_GL_Overview'',null) C ON G.id_kupca = C.id_kupca   
   LEFT JOIN dbo.akonplan A ON G.konto = A.konto  
   LEFT JOIN dbo.sif_skis H ON C.id_skis = H.id_skis  
   LEFT JOIN dbo.pogodba p1 ON G.id_cont = P1.id_cont  
   LEFT JOIN dbo.pogodba_deleted p2 ON G.id_cont = P2.id_cont  
   LEFT JOIN dbo.projects P on P.id_project = G.id_project  
   INNER JOIN dbo.tecajnic T ON T.id_tec = G.id_tec  
   WHERE g.session_id = ''' + @guid1 + '''  
  
   UNION  
  
   SELECT g.*  
    FROM dbo.gfn_GL_Overview2_Current('+@id_kupca+',''grp_GL_Overview'') g  
    WHERE g.vrsta_dok <> ''ZAC'')  a'  
  END  
  ELSE   
  BEGIN  
   SET @cmd = 'SELECT a.*  
      FROM dbo.gfn_GL_Overview2_Current('+@id_kupca+',''grp_GL_Overview'') a'  
  END  
  
    
END  
  
  
IF @par_pogodba_enabled = 1  
BEGIN  
    IF @par_pogodba_deleted = 1   
        SET @cmd = @cmd +   
        ' LEFT JOIN (SELECT id_cont, id_pog, id_tec, id_val  
                       FROM dbo.pogodba  
                      WHERE id_pog LIKE ''' + @par_pogodba_pogodba + ''') p ON a.id_cont = p.id_cont '  
  
    IF @par_pogodba_deleted = 2   
    BEGIN  
        SET @cmd = @cmd +   
        ' LEFT JOIN (SELECT id_cont, id_pog, '''' AS id_tec, '''' AS id_val  
                       FROM dbo.pogodba_deleted  
                      WHERE '  
     IF @par_pogodba_id_cont = -1  
       SET @cmd = @cmd + ' id_pog LIKE ''' + @par_pogodba_pogodba + ''') p ON a.id_cont = p.id_cont '  
     ELSE  
       SET @cmd = @cmd + ' id_cont = ' + str(@par_pogodba_id_cont, 10, 0) + ') p ON a.id_cont = p.id_cont '  
        END  
    END  
ELSE  
BEGIN  
    SET @cmd = @cmd +   
    ' LEFT JOIN (SELECT id_cont, id_pog, id_tec, id_val  
                   FROM dbo.pogodba  
                  UNION  
                 SELECT id_cont, id_pog, '''' AS id_tec, '''' AS id_val  
                   FROM dbo.pogodba_deleted) p ON p.id_cont = a.id_cont '  
END  
  
SET @cmd = @cmd + ' WHERE 1 = 1 '  
  
IF @par_pogodba_enabled = 1  
BEGIN  
    IF @par_pogodba_id_cont = -1  
     SET @cmd = @cmd + ' AND p.id_pog LIKE ''' + @par_pogodba_pogodba + ''' '   
    ELSE  
     SET @cmd = @cmd + ' AND a.id_cont = ' + str(@par_pogodba_id_cont, 10, 0) + ' '  
END  
  
IF @par_partner_enabled = 1  
    SET @cmd = @cmd + ' AND a.id_kupca = ''' + @par_partner_partner + '''  '  
  
IF @par_konto_enabled = 1  
    SET @cmd = @cmd + ' AND a.konto >= ''' + @par_konto_kontoOd + '''AND a.konto <= ''' + @par_konto_kontoDo + '''  '  
  
IF @par_konto_list_enabled = 1   
begin  
    -- added temp table  
    set @cmd = 'select id as ids into #konti from dbo.gfn_GetTableFromList(''' + @par_konto_list_value + ''');' + char(13) + char(10) + @cmd  
    SET @cmd = @cmd + ' AND a.konto in (select ids from #konti)  '  
end  
  
IF @par_obdobje_enabled = 1  
   SET @cmd = @cmd + ' AND a.datum_dok BETWEEN ''' + @par_obdobje_datumod + ''' AND ''' + @par_obdobje_datumdo + '''  '  
  
IF @par_strm_enabled = 1  
    SET @cmd = @cmd + ' AND CHARINDEX(rtrim(a.id_strm), ''' + @par_strm_strm + ''') > 0  '  
  
IF @par_vrstadok_enabled = 1  
    SET @cmd = @cmd + ' AND a.vrsta_dok = ''' + @par_vrstadok_vrstadok + '''  '  
  
IF @par_stdok_enabled = 1  
    SET @cmd = @cmd + ' AND a.st_dok LIKE ''' + @par_stdok_value + '''  '  
  
IF @par_znesek_enabled = 1  
     SET @cmd = @cmd + ' AND (a.debit_DOM = ' + cast(@par_znesek_znesek as varchar(100)) + ' OR a.kredit_DOM = ' + cast(@par_znesek_znesek as varchar(100)) + ')  '  
  
IF @par_dnevnik_enabled = 1  
    SET @cmd = @cmd + ' AND a.id_dnevnik = ''' + @par_dnevnik_value + '''  '  
      
IF @par_interna_veza_enabled = 1  
    SET @cmd = @cmd + ' AND a.interna_veza LIKE ''' + rtrim(@par_interna_veza_value) + '''  '  
  
IF @par_opis_dok_enabled = 1  
    SET @cmd = @cmd + ' AND a.opisdok LIKE ''' + rtrim(@par_opis_dok_value) + '''  '  
  
IF @par_veza_enabled = 1  
    SET @cmd = @cmd + ' AND a.veza LIKE ''' + rtrim(@par_veza_value) + '''  '  
      
IF @par_id_project_enabled = 1   
    SET @cmd = @cmd + ' AND id_project = ''' + @par_id_project + ''' '  
  
IF @par_vknjizbe_zakljucka_enabled = 0   
    SET @cmd = @cmd + ' AND vrsta_dok NOT IN (''PZL'', ''ZPL'') '  
  
SET @cmd = @cmd + 'ORDER BY a.datum_dok OPTION (MAXDOP 1)'  
  
-- drop table #konti  
IF @par_konto_list_enabled = 1   
    set @cmd = @cmd + '; ' + char(13) + char(10) + 'DROP TABLE #konti'  
  
PRINT (@cmd)  
EXECUTE(@cmd)  
  
END  
  