*//////////////////////////////////////////////
* 16.12.2019 g_tomislav MR 43505 - created;

GF_SQLEXEC("SELECT id_rtip FROM dbo.rtip WHERE id_rtip_base IS NOT NULL", "_ef_izvedeni")

SELECT a.id_pog, a.id_rtip, a.rind_zadnji, a.indeks, a.sprememba, a.obrok_bruto, a.nov_obrok_bruto FROM rep_pog a ;
INNER JOIN _ef_izvedeni b ON a.id_rtip = b.id_rtip ;
WHERE (!GF_NULLOREMPTY(a.sprememba) AND a.sprememba != 0) OR (!GF_NULLOREMPTY(a.nov_obrok_bruto) AND a.obrok_bruto != a.nov_obrok_bruto);
INTO CURSOR _ef_izv_ugovori

IF RECCOUNT("_ef_izv_ugovori") > 0
	IF POTRJENO("Na ugovorima s izvedenim ugovorima je došlo da promjene vrijednosti indeksa ili iznosa nove rate. Da li želite vidjeti listu tih ugovora?")
		SELECT id_pog AS Ugovori, id_rtip AS Rev_indeks, rind_zadnji AS Stari_indeks, indeks AS Novi_indeks, sprememba AS Promjena, obrok_bruto AS Trenutna_rata, nov_obrok_bruto AS Nova_rata, obrok_bruto - nov_obrok_bruto AS Razlika_rata FROM _ef_izv_ugovori 
	ENDIF
ENDIF
* END MR 43505//////////////////////////////////////////////