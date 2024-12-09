a.dolg - CASE WHEN a.dat_zap > GETDATE() THEN 0.00 ELSE a.debit END AS dolg_dat_zap,
CASE WHEN (a.dolg - CASE WHEN a.dat_zap > GETDATE() THEN 0.00 ELSE a.debit END) > dbo.gfn_xchange(a.id_tec, .10, '000', GETDATE()) THEN 1 ELSE 0 END AS PRINT_DOLG

datIzv.dat_izpisk as dat_izpisk,

OUTER APPLY (select max(dat_izpisk) as dat_izpisk from dbo.placila where id_app_pren is not null ) datIzv

Sva tri ispisa su ista na TEST i prod tj. nema dorada po drugim zahtjevima




Obavještavamo Vas da smo uvidom u našu poslovnu evidenciju ustanovili da nisu podmirena naša potraživanja u iznosu od {Format("{0:N2}",najem_fa.PRINT_DOLG)} {najem_fa.ID_VAL.Trim()}{IIF(najem_fa.PRINT_DOLG_RES_PRINT == 1, " (" +Format("{0:N2}",najem_fa.PRINT_DOLG_RES_AMOUNT) +" " +najem_fa.PRINT_DOLG_RES_ID_VAL +" prema tečaju " +Format("{0:N5}", najem_fa.PRINT_DOLG_RES_EXCH) +")", "")}.


Do sada se ispisivala rečenica: „Obavještavamo Vas da smo uvidom u našu poslovnu evidenciju ustanovili da nisu podmirena naša potraživanja u iznosu od xxxxx EUR. (ako je u pitanju kunski ugovor ispisuje se HRK)“

Sada želimo da se umjesto te rečenice ispisuje:
„Vaš nepodmireni dug po ovom ugovoru iznosi XXXXXX EUR ne uključujući iznos ovog računa, s knjiženim uplatama zaključno s DD.MM.YYYY te Vas molimo da isti podmirite.“

U polju datum mora se prikazivati datum zadnjeg prenesenog izvoda iz platnog prometa.

NAPOMENA:
Primjer rečenice je sa trenutne Produkcijske baze gdje još nismo podesili dvojno iskazivanje, pa molim da se i dvojno iskazivanje uzme u obzir prilikom ove izmjene.


Vaš nepodmireni dug po ovom ugovoru iznosi {Format("{0:N2}",najem_fa.PRINT_DOLG)} {najem_fa.ID_VAL.Trim()}{IIF(najem_fa.PRINT_DOLG_RES_PRINT == 1, " (" +Format("{0:N2}",najem_fa.PRINT_DOLG_RES_AMOUNT) +" " +najem_fa.PRINT_DOLG_RES_ID_VAL +" prema tečaju " +Format("{0:N5}", najem_fa.PRINT_DOLG_RES_EXCH) +") ", "")} ne uključujući iznos ovog računa, s knjiženim uplatama zaključno s {Format("{0:dd.MM.yyyy}", najem_fa.dat_izpisk)} te Vas molimo da isti podmirite.

OBV_LOBR
Obavještavamo Vas da smo uvidom u našu poslovnu evidenciju ustanovili da nisu podmirena naša potraživanja u iznosu od {Format("{0:N2}", najem_ob.PRINT_DOLG)} {najem_ob.ID_VAL.Trim()} 

NEW
Vaš nepodmireni dug po ovom ugovoru iznosi {Format("{0:N2}", najem_ob.PRINT_DOLG)} {najem_ob.ID_VAL.Trim()} ne uključujući iznos ovog računa, s knjiženim uplatama zaključno s {Format("{0:dd.MM.yyyy}", najem_ob.dat_izpisk)} te Vas molimo da isti podmirite. 


ZBR
Obavještavamo Vas da smo uvidom u našu poslovnu evidenciju ustanovili da nisu podmirena naša potraživanja u iznosu od {Format("{0:N2}", Sum(DataBand3, ZBIRNIKI.PRINT_DOLG))} {Settings.dom_valuta.Trim()}.

NEW

Vaš nepodmireni dug po ovim ugovorima iznosi {Format("{0:N2}", Sum(DataBand3, ZBIRNIKI.PRINT_DOLG))} {Settings.dom_valuta.Trim()} ne uključujući iznos ovog računa, s knjiženim uplatama zaključno s {Format("{0:dd.MM.yyyy}", ZBIRNIKI.dat_izpisk)} te Vas molimo da isti podmirite.


	CASE WHEN kon.id_kupca_k IS NOT NULL THEN 1 ELSE 0 END AS Print_Vloga,
	
	IV Ispis iznosa i u valuti na računima za rate za navedenog partnera. 
	
	LEFT JOIN (SELECT * FROM P_KONTAKT WHERE ID_VLOGA = 'IV' AND NEAKTIVEN = 0) kon on a.id_kupca = kon.id_kupca