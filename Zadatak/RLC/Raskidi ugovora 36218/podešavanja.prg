select * from statusi --RA odp

UPDATE STATUSI SET sif_status = 'ODP' where STATUS='RA'

select * from status_sys --id_status = 2 ODP

UPDATE status_sys set sif_status_sys = 'ODP' where id_status = 2 --ODP

<?xml version='1.0' encoding='utf-8' ?>
<claims_clone xmlns='urn:gmi:nova:leasing'>
<id_cont>8078</id_cont>
<dat_posn>2016-08-30T16:27:50.000</dat_posn>
<vnesel>g_tomislav</vnesel>
<komentar>test</komentar>
</claims_clone>


#INCLUDE locs.h

local lcXML, lcXmlDiff, lnErrorCount
lcXmlDiff = ""
lnErrorCount=0

	lcXML = "<?xml version='1.0' encoding='utf-8' ?>"
	lcXML = lcXML + '<claims_clone xmlns="urn:gmi:nova:leasing">' + gcE
	lcXML = lcXML + GF_CreateNode("id_cont", pogodba.id_cont, "I", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("dat_posn", DATETIME(), "T", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("vnesel", allt(GObj_Comm.getUserName()), "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("komentar", "test aut. snimka", "C", 1)+ gcE
	lcXML = lcXML + "</claims_clone>"
	
IF !GF_ProcessXml(lcXML) THEN
   lnErrorCount=lnErrorCount+1
ENDIF
obvesti ("plan otplate je spremljen!")
	

SELECT *  FROM [dbo].[PLANP_CLONE_CONTENT]
select * from planp_clone
	
select odp_opom_dni,* from loc_nast

UPDATE loc_nast set odp_opom_dni = 7

modify form "U:\Source\Fox_2.22\Fox\leasing\forms\odpoved_maska.SCX"
modify file  "U:\Source\Fox_2.22\Fox\leasing\forms\odpoved_maska.SC2"
	
sp_helptext gsp_LogContractExceptionsUpdate	
gsp_UpdateContractExceptions
sql=[dbo.gsp_updatecontractexceptions] values=[@par_id_cont=1146][@par_sif_status_sys=ODP][@par_username=g_tomislav]
31.8.2016. 11:12:13:772	143	DBHelper	Db	[g_tomislav,192.168.23.208]	[40d9d154-5cb2-4918-99e7-701b1771cd94,LE]	Finished executing command : sql=[dbo.gsp_updatecontractexceptions] values=[@par_id_cont=1146][@par_sif_status_sys=ODP][@par_username=g_tomislav]


Pozdrav, 
tijekom testiranja raskida ugovora u opciji Raskida ugovora (odpoved_pregled.scx) u 2.21.13 i 2.22.3 smo primjetili da se u pregled reprograma ugovora zapisuje tekst 
"Prijenos u sudski postupak (tužbu)"
što nije ispravno (u prilogu su slike) pa bi to trebalo ispraviti. 
Dodatno, oko definiranja ID_REP_CATEGORY u gsp_LogContractExceptionsUpdate, on se preuzima s predloška status_sys = TOZ, iako se ovdje radi o ODP predlošku. S obzirom da se ID_REP_CATEGORY odabire na koraku izdavanja raskida na masci changedate_rpg.scx, možda je ispavno da se u pregled reprograma zapiše ta odabrana kategorija (a ne iz status_sys)?
Također na masci Prijenos ugovora u sudske postupke (tpogodba_pogoji.scx), ID_REP_CATEGORY se odabere/prikazuje na masci, ali je po našem prijedlogu (na temelju kojeg je napravljena dorada u GMI MID 53726) naravljeno da se preuzima s predloška status_sys = TOZ, pa se može i to provjeriti što bi bilo ispravnije (promaklo nam je da se ista procedura koristi i kod raskida ugovora).

Ako se zapisivanje napravi koristeći processxml rpg_contract_update s odgovarajućem tekstom komentara u common_parameters npr.
"Izdan je raskid ugovora"
, koji se inače koristi kod ručnog dodavanja posebnosti ugovora (maska pos_pog_maska.scx), da li bi takvo rješenje za dodavanje posebnosti i rpg ugovora bilo bolje?  Nedostatak ovog rješenja je u tome što za zapisivanje posebnosti ugovora korisnik treba imati pravo POSPOGEDIT i za promjenu podataka ugovora korisnik treba imati pravo ACTIVECONTRACTUPDATE.
