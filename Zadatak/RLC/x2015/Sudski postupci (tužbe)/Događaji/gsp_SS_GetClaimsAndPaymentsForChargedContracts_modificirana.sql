-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
-- Procedure: Gets claims and payments for charged contract  
-- Parameters:  
--   @par_Id_Cont        - contract id  
--   @par_Vnesel         - username  
--   @par_UpdatePlanP    - flag for updating exisitng events for new claims and deleting events for countermanding claims   
--   @par_UpdateLsk      - flag for updating exisitng events for new payments and deleting events for countermanding payments   
--   @par_UpdateGl       - flag for updating exisitng events for new corrections and deleting events for countermanding corrections  
--   @par_Id_Ss_Postopek - legal proceedings id  
-- History:  
-- 29.11.2004 Vilko; Created  
-- 09.08.2007 Vilko; set cursor as FAST_FORWARD due faster execution  
-- 26.02.2008 Vilko; MID 13608 - added ability to get data for all charged contracts at once  
-- 19.05.2011 Vilko; Task ID 6094 - added parameter @par_Id_Ss_Postopek  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
ALTER   PROCEDURE [dbo].[gsp_SS_GetClaimsAndPaymentsForChargedContracts]   
@par_Id_Cont int,  
@par_Vnesel varchar(10),  
@par_UpdatePlanP bit,  
@par_UpdateLsk bit,  
@par_UpdateGl bit,  
@par_Id_Ss_Postopek int  
AS  
BEGIN  
  DECLARE @Dat_V_Toz datetime, @Id_fakt char(9), @Opis varchar(120),   
          @Skupaj decimal(18,2), @OpisTmp varchar(1000), @Konto_Popr char(8),  
          @Tip_Dogod char(4), @Vrs_Plac char(3), @Status char(10)  
  DECLARE @TDogodki TABLE (  
    id_cont int,  
    datum datetime,  
    vnesel char(10),  
    avtom bit,  
    debit decimal(18,2),  
    kredit decimal(18,2),  
    opis varchar(1000),  
    st_dok char(21),  
    id_plac int,  
    tip_dogod char(4),  
    vrs_plac char(3),  
    status char(10),  
    id_ss_postopek int  
  )  
  
  /* Gets correction account from settings */  
  SELECT @Konto_Popr = konto_popr  
    FROM dbo.ss_nastavit  
  
  DECLARE TPogodba CURSOR FAST_FORWARD FOR  
   SELECT id_cont, dat_v_toz, id_ss_postopek   
     FROM dbo.ss_tpogodba   
    WHERE (@par_Id_Cont IS NULL OR id_cont = @par_Id_Cont)  
      AND (@par_Id_Ss_Postopek IS NULL OR id_ss_postopek = @par_Id_Ss_Postopek)  
  
  OPEN TPogodba  
  FETCH NEXT FROM TPogodba INTO @par_Id_Cont, @Dat_V_Toz, @par_Id_Ss_Postopek  
  WHILE @@FETCH_STATUS = 0  
    BEGIN  
  
      /* Resets field obdelal */  
      UPDATE dbo.ss_tdogodki  
         SET obdelal = 0  
       WHERE id_cont = @par_Id_Cont  
         AND id_ss_postopek = @par_Id_Ss_postopek  
  
      /* PLANP */  
      SET @Tip_Dogod = 'TERJ'  
      SET @Vrs_Plac = ISNULL((SELECT MIN(vrs_plac) FROM dbo.ss_vrs_plac WHERE tip_dogod = @Tip_Dogod), '')  
      SET @Status = ISNULL((SELECT MIN(id_key) FROM dbo.general_register WHERE id_register = 'SS_TDOGODKI_STASTUS' AND val_char = @Vrs_Plac), '')  
      /* Selects all new claims from planp for charged contract */  
      INSERT INTO @TDogodki (id_cont, datum, vnesel, avtom, debit, kredit, opis, st_dok, tip_dogod, vrs_plac, status, id_ss_postopek)  
        SELECT P.id_cont,   
               P.dat_zap AS datum,   
               @par_Vnesel AS vnesel,   
               CAST(1 AS BIT) AS avtom,  
               dbo.gfn_XChange('000', P.debit, P.id_tec, GETDATE()) AS debit,  
               0 AS kredit,  
               T.naziv AS opis,  
               P.st_dok,  
               @Tip_Dogod AS tip_dogod,  
               @Vrs_Plac AS vrs_plac,  
               @Status AS status,  
               @par_Id_Ss_Postopek AS id_ss_postopek  
          FROM dbo.planp P  
         INNER JOIN dbo.vrst_ter T  
            ON P.id_terj = T.id_terj  
         WHERE P.id_cont = @par_Id_Cont  
           AND P.dat_zap > @Dat_V_Toz  
           AND T.sif_terj NOT IN ('DDV','LOBR','OPC','ZOBR','POLO')  
      /* Selects all items from general invoices for new claims */  
      DECLARE FakPos CURSOR FAST_FORWARD FOR  
       SELECT F.id_fakt, F.opis, F.skupaj  
         FROM dbo.fak_pos F  
        INNER JOIN @TDogodki D  
           ON F.id_fakt = D.st_dok  
      SET @OpisTmp = ''  
      OPEN FakPos  
      FETCH NEXT FROM FakPos  
        INTO @Id_fakt, @Opis, @Skupaj  
      WHILE @@FETCH_STATUS = 0  
        BEGIN  
          SET @OpisTmp = @OpisTmp + CHAR(13) + CHAR(10) + STR(@Skupaj,18,2) + SPACE(3) + RTRIM(@Opis)  
          FETCH NEXT FROM FakPos  
            INTO @id_fakt, @opis, @skupaj  
        END  
      CLOSE FakPos  
      DEALLOCATE FakPos  
      /* Update events for existing claims */  
      UPDATE dbo.ss_tdogodki  
         SET datum = (CASE WHEN @par_UpdatePlanP = 1 THEN D.datum ELSE T.datum END),  
             debit = (CASE WHEN @par_UpdatePlanP = 1 THEN D.debit ELSE T.debit END),  
             avtom = (CASE WHEN @par_UpdatePlanP = 1 THEN D.avtom ELSE 0 END),  
             vnesel = (CASE WHEN @par_UpdatePlanP = 1 THEN D.vnesel ELSE T.vnesel END),  
             obdelal = 1  
        FROM dbo.ss_tdogodki T  
       INNER JOIN @TDogodki D  
          ON T.id_cont = D.id_cont AND T.st_dok = D.st_dok AND T.tip_dogod = D.tip_dogod AND T.id_ss_postopek = D.id_ss_postopek  
       WHERE T.datum <> D.datum  
          OR T.debit <> D.debit  
      UPDATE dbo.ss_tdogodki  
         SET obdelal = 1  
        FROM dbo.ss_tdogodki T  
       INNER JOIN @TDogodki D  
          ON T.id_cont = D.id_cont AND T.st_dok = D.st_dok AND T.tip_dogod = D.tip_dogod AND T.id_ss_postopek = D.id_ss_postopek  
       WHERE T.datum = D.datum  
          OR T.debit = D.debit  
       
      /* Insert new events for new claims */  
      INSERT INTO dbo.ss_tdogodki (id_cont, datum, vnesel, avtom, debit, kredit,  
                                   opis, st_dok, tip_dogod, id_plac, vrs_plac,   
                                   id_opis, opravil_st, obdelal, status, id_ss_postopek)  
        SELECT D.id_cont, D.datum, D.vnesel, D.avtom, D.debit, D.kredit,  
               D.opis, D.st_dok, D.tip_dogod, -1, D.vrs_plac,   
               '', '', 1, D.status, D.id_ss_postopek  
          FROM @TDogodki D  
         WHERE NOT EXISTS (SELECT id_cont, st_dok, id_ss_postopek  
                             FROM dbo.ss_tdogodki  
                            WHERE id_cont = D.id_cont  
                              AND st_dok = D.st_dok  
                              AND tip_dogod = D.tip_dogod  
                              AND id_ss_postopek = D.id_ss_postopek)  
      IF @par_UpdatePlanP = 1  
        /* Delete events for countermanding claims */  
        DELETE dbo.ss_tdogodki  
          FROM dbo.ss_tdogodki T  
         WHERE T.id_cont = @par_Id_Cont  
           AND T.st_dok <> ''  
           AND T.avtom = 1  
           AND T.tip_dogod = @Tip_Dogod  
           AND T.id_ss_postopek = @par_Id_Ss_Postopek  
           AND NOT EXISTS (SELECT id_cont, st_dok, id_ss_postopek  
                             FROM @TDogodki  
                            WHERE id_cont = T.id_cont  
                              AND st_dok = T.st_dok  
                              AND tip_dogod = T.tip_dogod  
                              AND id_ss_postopek = T.id_ss_postopek)  
      ELSE  
        /* Update events for countermanding claims */  
        UPDATE dbo.ss_tdogodki  
           SET vnesel = @par_Vnesel,  
               avtom = 0,  
               obdelal = 1  
         FROM dbo.ss_tdogodki T  
        WHERE T.id_cont = @par_Id_Cont  
          AND T.st_dok <> ''  
          AND T.avtom = 1  
          AND T.tip_dogod = @Tip_Dogod  
          AND T.id_ss_postopek = @par_Id_Ss_Postopek  
          AND NOT EXISTS (SELECT id_cont, st_dok, id_ss_postopek  
                            FROM @TDogodki  
                           WHERE id_cont = T.id_cont  
                             AND st_dok = T.st_dok  
                             AND tip_dogod = T.tip_dogod  
                             AND id_ss_postopek = T.id_ss_postopek)  
      /* Deletes all records in temporary table */  
      DELETE @TDogodki  
  
      /* LSK */  
      SET @Tip_Dogod = 'PLAC'  
      SET @Vrs_Plac = ISNULL((SELECT MIN(vrs_plac) FROM dbo.ss_vrs_plac WHERE tip_dogod = @Tip_Dogod), '')  
      SET @Status = ISNULL((SELECT MIN(id_key) FROM dbo.general_register WHERE id_register = 'SS_TDOGODKI_STASTUS' AND val_char = @Vrs_Plac), '')  
      /* Selects all new payments from lsk for charged contract */  
      INSERT INTO @TDogodki (id_cont, datum, vnesel, avtom, debit, kredit, opis, st_dok, id_plac, tip_dogod, vrs_plac, status, id_ss_postopek)  
        SELECT L.id_cont,   
               MAX(L.valuta) AS datum,   
               @par_Vnesel AS vnesel,   
               CAST(1 AS BIT) AS avtom,  
               0 AS debit,  
               SUM(L.kredit_dom) AS kredit,  
               T.naziv AS opis,  
               LTRIM(STR(L.id_plac)) AS st_dok,  
               L.id_plac,  
               @Tip_Dogod AS tip_dogod,  
               @Vrs_Plac AS vrs_plac,  
               @Status AS status,  
               @par_Id_Ss_Postopek AS id_ss_postopek  
          FROM dbo.lsk L  
         INNER JOIN dbo.vrst_ter T  
            ON L.id_terj = T.id_terj  
         WHERE L.id_cont = @par_Id_Cont  
           AND L.id_plac <> -1  
           AND L.kredit_dom <> 0  
           AND L.valuta >= @Dat_V_Toz  
         GROUP BY L.id_cont, L.id_plac, T.naziv  
        HAVING SUM(L.kredit_dom) <> 0  
      /* Update events for existing payments */  
      UPDATE dbo.ss_tdogodki  
         SET datum = (CASE WHEN @par_UpdateLsk = 1 THEN D.datum ELSE T.datum END),  
             kredit = (CASE WHEN @par_UpdateLsk = 1 THEN D.kredit ELSE T.kredit END),  
             avtom = (CASE WHEN @par_UpdateLsk = 1 THEN D.avtom ELSE 0 END),  
             vnesel = (CASE WHEN @par_UpdateLsk = 1 THEN D.vnesel ELSE T.vnesel END),  
             obdelal = 1  
        FROM dbo.ss_tdogodki T  
       INNER JOIN @TDogodki D  
          ON T.id_cont = D.id_cont AND T.id_plac = D.id_plac AND T.tip_dogod = D.tip_dogod AND T.id_ss_postopek = D.id_ss_postopek  
       WHERE T.datum <> D.datum  
          OR T.kredit <> D.kredit  
      UPDATE dbo.ss_tdogodki  
         SET obdelal = 1  
        FROM dbo.ss_tdogodki T  
       INNER JOIN @TDogodki D  
          ON T.id_cont = D.id_cont AND T.id_plac = D.id_plac AND T.tip_dogod = D.tip_dogod AND T.id_ss_postopek = D.id_ss_postopek  
       WHERE T.datum = D.datum  
          OR T.kredit = D.kredit  
      /* Insert new events for new payments */  
      INSERT INTO dbo.ss_tdogodki (id_cont, datum, vnesel, avtom, debit, kredit,  
                                   opis, st_dok, tip_dogod, id_plac, vrs_plac,   
                                   id_opis, opravil_st, obdelal, status, id_ss_postopek)  
        SELECT D.id_cont, D.datum, D.vnesel, D.avtom, D.debit, D.kredit,  
               D.opis, D.st_dok, D.tip_dogod, D.id_plac, D.vrs_plac,  
               '', '', 1, D.status, D.id_ss_postopek  
          FROM @TDogodki D  
         WHERE NOT EXISTS (SELECT id_cont, id_plac, id_ss_postopek  
                             FROM dbo.ss_tdogodki  
                            WHERE id_cont = D.id_cont  
                              AND id_plac = D.id_plac  
                              AND tip_dogod = D.tip_dogod  
                              /*AND id_ss_postopek = D.id_ss_postopek*/)  
      IF @par_UpdateLsk = 1  
        /* Delete events for countermanding payments */  
        DELETE dbo.ss_tdogodki  
          FROM dbo.ss_tdogodki T  
         WHERE T.id_cont = @par_Id_Cont  
           AND T.id_plac <> -1  
           AND T.avtom = 1  
           AND T.tip_dogod = @Tip_Dogod  
           AND T.id_ss_postopek = @par_Id_Ss_Postopek  
           AND NOT EXISTS (SELECT id_cont, id_plac, id_ss_postopek  
                              FROM @TDogodki  
                             WHERE id_cont = T.id_cont  
                               AND id_plac = T.id_plac  
                               AND tip_dogod = T.tip_dogod  
                               /*AND id_ss_postopek = T.id_ss_postopek*/ )  
      ELSE  
        /* Update events for countermanding payments */  
        UPDATE dbo.ss_tdogodki  
           SET vnesel = @par_Vnesel,  
               avtom = 0,  
               obdelal = 1  
         FROM dbo.ss_tdogodki T  
        WHERE T.id_cont = @par_Id_Cont  
          AND T.id_plac <> -1  
          AND T.avtom = 1  
          AND T.tip_dogod = @Tip_Dogod  
          AND T.id_ss_postopek = @par_Id_Ss_Postopek  
          AND NOT EXISTS (SELECT id_cont, id_plac, id_ss_postopek  
                            FROM @TDogodki  
                           WHERE id_cont = T.id_cont  
                             AND id_plac = T.id_plac  
                             AND tip_dogod = T.tip_dogod  
                             AND id_ss_postopek = T.id_ss_postopek)  
      /* Deletes all records in temporary table */  
      DELETE @TDogodki  
  
      /* GL */  
      SET @Tip_Dogod = 'POPR'  
      SET @Vrs_Plac = ISNULL((SELECT MIN(vrs_plac) FROM dbo.ss_vrs_plac WHERE tip_dogod = @Tip_Dogod), '')  
      SET @Status = ISNULL((SELECT MIN(id_key) FROM dbo.general_register WHERE id_register = 'SS_TDOGODKI_STASTUS' AND val_char = @Vrs_Plac), '')  
      /* Selects all new corrections from gl for charged contract */  
      INSERT INTO @TDogodki (id_cont, datum, vnesel, avtom, debit, kredit, opis, st_dok, tip_dogod, vrs_plac, status, id_ss_postopek)  
        SELECT id_cont,   
               datum_dok AS datum,   
               @par_Vnesel AS vnesel,   
               CAST(1 AS BIT) AS avtom,  
               SUM(debit_dom) AS debit,  
               SUM(kredit_dom) AS kredit,  
               opisdok AS opis,  
               'POPRAVEK '+CONVERT(char(10), datum_dok, 104) AS st_dok,  
               @Tip_Dogod AS tip_dogod,  
               @Vrs_Plac AS vrs_plac,  
               @Status AS status,  
               @par_Id_Ss_Postopek AS id_ss_postopek  
          FROM dbo.gl  
         WHERE id_cont = @par_Id_Cont  
           AND datum_dok >= @Dat_V_Toz  
           AND konto = @Konto_Popr  
         GROUP BY id_cont, datum_dok, opisdok  
        HAVING SUM(kredit_dom) <> 0 OR SUM(debit_dom) <> 0  
      /* Update events for existing corrections */  
      UPDATE dbo.ss_tdogodki  
         SET datum = (CASE WHEN @par_UpdateGl = 1 THEN D.datum ELSE T.datum END),  
             kredit = (CASE WHEN @par_UpdateGl = 1 THEN D.kredit ELSE T.kredit END),  
             avtom = (CASE WHEN @par_UpdateGl = 1 THEN D.avtom ELSE 0 END),  
             vnesel = (CASE WHEN @par_UpdateGl = 1 THEN D.vnesel ELSE T.vnesel END),  
             obdelal = 1  
        FROM dbo.ss_tdogodki T  
       INNER JOIN @TDogodki D  
          ON T.id_cont = D.id_cont AND T.st_dok = D.st_dok AND T.tip_dogod = D.tip_dogod AND T.id_ss_postopek = D.id_ss_postopek  
       WHERE T.debit <> D.debit  
          OR T.kredit <> D.kredit  
      UPDATE dbo.ss_tdogodki  
         SET obdelal = 1  
        FROM dbo.ss_tdogodki T  
       INNER JOIN @TDogodki D  
          ON T.id_cont = D.id_cont AND T.st_dok = D.st_dok AND T.tip_dogod = D.tip_dogod AND T.id_ss_postopek = D.id_ss_postopek  
       WHERE T.debit = D.debit  
          OR T.kredit = D.kredit  
      /* Insert new events for new corrections */  
      INSERT INTO dbo.ss_tdogodki (id_cont, datum, vnesel, avtom, debit, kredit,  
                                   opis, st_dok, tip_dogod, id_plac, vrs_plac,   
                                   id_opis, opravil_st, obdelal, status, id_ss_postopek)  
        SELECT D.id_cont, D.datum, D.vnesel, D.avtom, D.debit, D.kredit,  
               D.opis, D.st_dok, D.tip_dogod, -1, D.vrs_plac,  
               '', '', 1, D.status, D.id_ss_postopek  
          FROM @TDogodki D  
         WHERE NOT EXISTS (SELECT id_cont, id_plac, id_ss_postopek  
                             FROM dbo.ss_tdogodki  
                            WHERE id_cont = D.id_cont  
                              AND st_dok = D.st_dok  
                              AND tip_dogod = D.tip_dogod  
                              AND id_ss_postopek = D.id_ss_postopek)  
      IF @par_UpdateGl = 1  
        /* Delete events for countermanding corrections */  
        DELETE dbo.ss_tdogodki  
          FROM dbo.ss_tdogodki T  
         WHERE T.id_cont = @par_Id_Cont  
           AND T.id_plac <> -1  
           AND T.avtom = 1  
           AND T.tip_dogod = @Tip_Dogod  
           AND T.id_ss_postopek = @par_Id_Ss_Postopek  
           AND NOT EXISTS (SELECT id_cont, id_plac, id_ss_postopek  
                              FROM @TDogodki  
                             WHERE id_cont = T.id_cont  
                               AND st_dok = T.st_dok  
                               AND tip_dogod = T.tip_dogod  
                               AND id_ss_postopek = T.id_ss_postopek)  
      ELSE  
        /* Update events for countermanding corrections */  
        UPDATE dbo.ss_tdogodki  
           SET vnesel = @par_Vnesel,  
               avtom = 0,  
               obdelal = 1  
         FROM dbo.ss_tdogodki T  
        WHERE T.id_cont = @par_Id_Cont  
          AND T.st_dok <> ''  
          AND T.avtom = 1  
          AND T.tip_dogod = @Tip_Dogod  
          AND T.id_ss_postopek = @par_Id_Ss_Postopek  
          AND NOT EXISTS (SELECT id_cont, id_plac, id_ss_postopek  
                            FROM @TDogodki  
                           WHERE id_cont = T.id_cont  
                             AND st_dok = T.st_dok  
                             AND tip_dogod = T.tip_dogod  
                             AND id_ss_postopek = T.id_ss_postopek)  
      /* Calculate debt and some other values for charged contract */  
      EXEC dbo.gsp_SS_RefreshDebtInChargedContracts @par_Id_Cont, @Dat_V_Toz, @par_Id_Ss_Postopek  
  
      /* Deletes all records in temporary table */  
      DELETE @TDogodki  
  
      FETCH NEXT FROM TPogodba INTO @par_Id_Cont, @Dat_V_Toz, @par_Id_Ss_Postopek  
    END  
  
  CLOSE TPogodba  
  DEALLOCATE TPogodba  
END  