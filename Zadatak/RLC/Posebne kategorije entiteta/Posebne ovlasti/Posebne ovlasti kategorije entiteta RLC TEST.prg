loForm = GF_GetFormObject("frmKategorije_entiteta_maska")
IF ISNULL(loForm) THEN 
 RETURN
ENDIF

LOCAL laPar[1], lcOnemogucavanje, lcPostavljanje, lcSifra

* TODO
* napraviti popunjavanje RLC_ENTITETI_OVLASTI prema kategorije.entiteta čime se može dobiti mogućnost, 
* ako ne postoji niti jedan zapis u general_register da su sva polja omogućena, 
* ili još detaljnije da je tip/šifra entiteta omogućena

TEXT TO lcSql NOSHOW
	SELECT a.* FROM (
	SELECT SUBSTRING(id_key, 0, CHARINDEX(';', id_key) ) AS sifra
	, SUBSTRING(id_key, CHARINDEX(';', id_key) + 1, LEN(id_key) ) AS rola
	, dbo.gfn_UserIsInRole(?p1, SUBSTRING(id_key, CHARINDEX(';', id_key) + 1, LEN(id_key) )) as JeURoli --neaktivne role vraća 0
	--, * 
	FROM dbo.general_register 
	WHERE id_register = 'RLC_ENTITETI_OVLASTI'
	AND neaktiven = 0
	) a 
	WHERE a.JeURoli = 1
ENDTEXT

laPar[1] = allt(GObj_Comm.getUserName())

GF_SqlExec_P(lcSql, @laPar, "_ef_RLC_ENTITETI_OVLASTI")

lcPostavljanje = ""

select kategorije
GO TOP
SCAN 
	lcOnemogucavanje = "loForm."+kategorije.obj_name+".Enabled = .F."
	&lcOnemogucavanje
	
	lcSifra = kategorije.sifra
	select TOP 1 * FROM _ef_RLC_ENTITETI_OVLASTI WHERE sifra = lcSifra ORDER BY JeURoli INTO CURSOR _ef_ima_ovlast

	IF RECCOUNT() > 0
		lcPostavljanje = "loForm."+kategorije.obj_name+".Enabled = .T."
		&lcPostavljanje
	ENDIF
	
	IF USED ("_ef_ima_ovlast") 
		USE IN _ef_ima_ovlast
	ENDIF
	
ENDSCAN


IF USED ("_ef_RLC_ENTITETI_OVLASTI") 
	USE IN _ef_RLC_ENTITETI_OVLASTI
ENDIF
	
* bck podešavanja
INSERT INTO dbo.general_register(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('ID_REGISTER','RLC_ENTITETI_OVLASTI','Posebne ovlasti za posebne kategorije entiteta',0,NULL,NULL,0,NULL)

INSERT INTO dbo.general_register(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('RLC_ENTITETI_OVLASTI','2;contractvi','7, POGODBA, 2, ORCA ID-Datum Frod',0,NULL,NULL,0,NULL)
INSERT INTO dbo.general_register(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('RLC_ENTITETI_OVLASTI','HOL_FLG;contractvi','Holistic flag, 2, PARTNER',0,NULL,NULL,0,NULL)
INSERT INTO dbo.general_register(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('RLC_ENTITETI_OVLASTI','U1;contractvi','3, POGODBA, U1, Broj Inicijane ponude',0,NULL,NULL,0,NULL)
INSERT INTO dbo.general_register(ID_REGISTER,ID_KEY,VALUE,VAL_BIT,VAL_NUM,VAL_CHAR,neaktiven,val_datetime) VALUES('RLC_ENTITETI_OVLASTI','U2;contractvi','4, POGODBA, U2, Ugov. razl. nak. (% ili Iznos)',0,NULL,NULL,0,NULL)



--select dbo.gfn_UserIsInRole('g_tomislav', 'contractad')
--SELECT dbo.gfn_UserIsInRole('g_tomislav', 'contractad'), * FROM dbo.kategorije_tip

SELECT a.* FROM (
SELECT CHARINDEX(';', val_char) AS charindex
, SUBSTRING(val_char, 0, CHARINDEX(';', val_char) ) AS tip
, SUBSTRING(val_char, CHARINDEX(';', val_char) + 1, LEN(val_char) ) AS rola
--, dbo.gfn_UserIsInRole('g_tomislav', SUBSTRING(val_char, CHARINDEX(';', val_char) + 1, LEN(val_char) )) as JeURoli
, dbo.gfn_UserIsInRole('anad', SUBSTRING(val_char, CHARINDEX(';', val_char) + 1, LEN(val_char) )) as JeURoli
, * 
FROM dbo.general_register 
WHERE id_register = 'RLC_ENTITETI_OVLASTI'
AND neaktiven = 0
) a 
WHERE a.JeURoli = 1
	
	

begin tran
UPDATE kategorije_tip set tip_polja = 'DATETIME' WHERE id_kategorije_tip = 2 --bilo TEXT
--commit
--rollback

select * from kategorije_entiteta
select * from kategorije_sifrant
select * from kategorije_tip



ext_func

loForm = GF_GetFormObject("frmKategorije_entiteta_maska")
IF ISNULL(loForm) THEN 
 RETURN
ENDIF

*select * from kategorije

*loForm.Combobox1.Enabled = .f.
*loForm.Textbox2.Enabled = .f.

lcTest = "loForm.Combobox1.Enabled"

&lcTest = .f.



          KategorijeTipSifrant (1083)	All activities related to categories	Sve aktivnosti vezane uz kategorije_tip in kategorije_sifrant
               KategorijeSifrantInsert (1087)	All activities related to entering new kategorije_sifrant	Unos šifrant kategorije
               KategorijeSifrantUpdate (1088)	All activities related to updating existing kategorije_sifrant	Popravak šifrant kategorije
               KategorijeTipInsert (1085)	All activities related to entering new kategorije_tip	Unos tipa kategorije
               KategorijeTipSifrantView (1084)	All activites related to viewing kategorije_tip and kategorije_sifrant	Pregled za kategorije_tip i kategorije_sifrant
               KategorijeTipUpdate (1086)	All activities related to updating existing kategorije_tip	Popravak tipa kategorije


sp_helptext grp_Kategorije_entitete_view

(1,kategorija_entiteta)EXEC  dbo.grp_Kategorije_entitete_view 1,'DOKUMENT,P_EVAL,PARTNER,POGODBA',0,'',0,'',1 
___________________________________________________
(1,_tmpcur)	declare @pravice table (val int, entiteta char(10));
	insert into @pravice (val, entiteta)
	select MAX(a.val) as val, a.entiteta
	from (
	    select dbo.gfn_UserCanDoByName('g_tomislav', 'ContractDashboard') as val, 'POGODBA' as entiteta
	    union
	    select dbo.gfn_UserCanDoByName('g_tomislav', 'partnerView') as val, 'PARTNER' as entiteta
	    union
	    select dbo.gfn_UserCanDoByName('g_tomislav', 'ContractDocumentationView') as val, 'DOKUMENT' as entiteta
	    union
	    select dbo.gfn_UserCanDoByName('g_tomislav', 'CollectionDocumentationView') as val, 'DOKUMENT' as entiteta
	    union
	    select dbo.gfn_UserCanDoByName('g_tomislav', 'PartnerEvalView_E') as val, 'P_EVAL' as entiteta
	    union
	    select dbo.gfn_UserCanDoByName('g_tomislav', 'PartnerEvalView_Other') as val, 'P_EVAL' as entiteta
	) a
	group by a.entiteta

	select
	    a.entiteta
	from
	    dbo.gfn_kategorije_entitete() a
	    inner join @pravice b on a.entiteta = b.entiteta
	where b.val = 2
	order by a.entiteta




