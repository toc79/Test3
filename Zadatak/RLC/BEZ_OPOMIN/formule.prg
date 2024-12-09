Poštovani, 
1) oko ispisa
 a) datum dospijeća na ispisu ne treba podešavati nego je za dospijeće to potrebno podesiti u pripremi opomena u odlomku Valuta dana, pa će se tako i prikazati na ispisu (tek s novom pripremom opomena, za dosad izdane ne).
 b) oko promjene u dijelu teksta 'OPOMENA ZA NEPLAĆENA POTRAŽIVANJA PO', logika priprema ispisa je da u dijelu ispisa gdje se prikazuju sva neplaćena potraživanja može biti prikazano više potraživanja(čak i za TP ugovore) dok prikazivanje broja računa u naslovu se može odnositi samo na jedan račun. U slučaju da će se opomena kreirati na temelju 2 ili više potraživanja, mi bi onda za broj računa prikazali samo jedan (prvi) broj računa.
 c) s obzirom da se 2. i 3. opomena praktički neće kreirati (a niti ćete ispisivati) i s obzirom da je razlika između postojećeg ispisa samo u jednom dijelu rečenice, mislim da bi bilo najbolje da se radi dorada postojećeg ispisa TEKST OPOMENE BEZ TROŠKOVA OPOMENE, pogotovo ako ćete sve opomene odjednom ispisivati (sve tipove leasinga). 
 Ako želite za TP ipak odvojeni ispis (odvojen od ostalih opomena bez troška), onda je potrebno raditi doradu postojećeg potonjeg ispisa (da se ne ispisuju TP ugovori) te napraviti novi ispis s novom opcijom ispisivanja koji će ispisivati samo opomene za TP.

2) oko dobivanja obavijesti mailom, nova priprema opomena te izdavanje novih opomena će biti obuhvaćeno u obavijesti mailom. Na produkciji ćete i taj dio trebati svakako provjeriti.

3) oko problem s ispisom opomena za NF ugovore, u odgovoru od kolege Omara je vidljivo da je problem povezan s 2. opomenom (za koji u zadnjem odgovor ste javili "Sada nakon mjesec dana, kod kreiranja 2. i 3.opomena - obavijest smo dobili ispravno.") dok u slučaju TP ugovora neće biti 2. opomene. Dok za 1. opomene za TP su isti parametri u pripremi opomena pa bi obavijest trebala biti u redu. Funkcionalnost procedure za kreiranje obavijesti ćete svakako morati provjeriti u radu s novim TP ugovorima (na testu ili produkciji). Tek tada možemo vidjeti da li će biti potrebno doraditi proceduru za kreiranje obavijesti i na koji način.






iif(lc_tipleas='OZ','OBAVIJEST','OPOMENA')+' ZA NEPLAĆENA POTRAŽIVANJA PO UGOVORU'
lc_tipleas
lookup(_nacinil2.tip_leas,za_opom.nacin_leas,_nacinil2.nacin_leas)

Datum dospijeća
': '+dtoc(ttod(za_opom.datum_dok)+za_opom.zap_op)

* NOVO
IIF(lc_tipleas="OZ","OBAVIJEST","OPOMENA")+" ZA NEPLAĆENA POTRAŽIVANJA PO "+IIF(lc_tipleas="TP", "RAČUNU "+rcTextTP," UGOVORU")

* NOVO Ver. 2
IIF(lc_tipleas="OZ","OBAVIJEST","OPOMENA")+" ZA NEPLAĆENA POTRAŽIVANJA PO "+IIF(lc_tipleas != "TP", "UGOVORU", "RAČUNU "+rcTextTP)

PW: na rečenici ispod
lc_tipleas != "TP"

* lookup(_nacinil2.tip_leas,za_opom.nacin_leas,_nacinil2.nacin_leas)


rcTextTP
allt(lookup(_temp.ddv_id, opom_tmp.st_dok, _temp.st_dok))

*BCK Branislav

iif(lc_tipleas='OZ','OBAVIJEST','OPOMENA')+' ZA NEPLAĆENA POTRAŽIVANJA PO UGOVORU'


* 2. OPOMENA
OPOMENA ZA NEPLAĆENA POTRAŽIVANJA PO UGOVORU

*NOVO
"OPOMENA ZA NEPLAĆENA POTRAŽIVANJA PO "+IIF(lc_tipleas != "TP", "UGOVORU", "RAČUNU "+rcTextTP)


*3. OPOMENA
OPOMENA ZA  NEPLAĆENA POTRAŽIVANJA PRED RASKID UGOVORA

*NOVO
"OPOMENA ZA NEPLAĆENA POTRAŽIVANJA"+IIF(lc_tipleas != "TP", "PRED RASKID UGOVORA", "PO RAČUNU "+rcTextTP)





iif(lc_tipleas!='OZ','Ukoliko ne postupite u skladu s ovom opomenom bit ćemo prisiljeni naplatu izvršiti putem sredstava osiguranja plaćanja.'+chr(10),'')+txt1

txt1
'Opomena je pravovaljana bez pečata i potpisa jer je izrađena upotrebom informacijske tehnologije kao elektronička isprava, sukladno Zakonu o elektroničkoj ispravi.'

9.5.2017
Poštovani, 

podesili smo ispis "TEKST OPOMENE BEZ TROŠKOVA OPOMENE" za slučaj 1. opomene na Test bazi. 
Rečenica "Ukoliko ne postupite u skladu s ovom obavijesti..." se ispisuje samo jednom boldanim fontom. 
Rečenica "O istome obaviješteni jamci po Ugovoru o leasingu." je podešena da se ne ispisuje za slučaj TP tipa ugovora, kao što se ne ispisuje niti za slučaj tipa ugovora zakup/najam. 
Pozdrav, 

Branislav Knežević 

"Ukoliko ne postupite u skladu s ovom obavijesti..."
PW:
za_opom.vr_osebe!='FO' and ATC(lc_tipleas,'OZ')=0





Public gcPotpis
gcPotpis = IIF(GF_NULLOREMPTY(RF_POTPIS('OPOMIN')),GOBJ_Comm.GetUserDesc(),RF_POTPIS(gcRep))
GF_SQLEXEC("select id_kupca,stev_reg from partner ","cur_partner")
gf_sqlexec("select * from dbo.nacini_l","_nacinil")

select rf_tip_pog(za_opom.nacin_leas) as tip_leas, za_opom.nacin_leas from za_opom group by za_opom.nacin_leas into cursor _nacinil2

PUBLIC rlplbrez_stroskov
rlplbrez_stroskov=.T.
	
LOCAL lnOdg, lcText, llIzpisan

lnOdg=rf_msgbox("Pitanje","Želite li ispis svih označenih ili trenutnog zapisa?","Svih","Trenutnog","Poništi")
DO case
	CASE lnOdg = 2	&& 7 Trenutnega

		SELECT za_opom	
		IF oznacen = .f. or GF_NULLOREMPTY(dok_opom) or !GF_NULLOREMPTY(ddv_id) or id_za_opom_type = 6
			OBVESTI("Niste odabrali nijednu izdanu opomenu za fizičku osobu!")
			return .f.
		ENDIF
		GF_SQLEXEC("select a.id_pog, isnull(b.id_tec_new,b.id_tec) as id_tec,isnull(c.id_val,a.id_val) as id_val from pogodba a left join tecajnic b on a.id_tec=b.id_tec left join tecajnic c on b.id_tec_new=c.id_tec where id_cont="+allt(transf(za_opom.id_cont)),"_pogodba")	
		obj_ReportSelector.obj_reportPrinter.rep_scope = "FOR id_opom="+transform(za_opom.id_opom)
		* "next 1"
	CASE lnOdg = 1	&& 6 Vse
		obj_ReportSelector.obj_reportPrinter.rep_scope = "FOR oznacen = .T. and !GF_NULLOREMPTY(dok_opom) AND GF_NULLOREMPTY(ddv_id) and id_za_opom_type != 6"

		**GF_SQLEXEC("SELECT id_kupca from p_kontakt where id_vloga='O1' and neaktiven=0","cur_za_opom")
		**list = GF_CreateDelimitedList("cur_za_opom","id_kupca", "", ",",.t.)
			
		SELECT za_opom
		LOCATE FOR oznacen = .T. AND !GF_NULLOREMPTY(dok_opom) AND GF_NULLOREMPTY(ddv_id) AND id_za_opom_type != 6
		** AND !(INLIST(allt(id_kupca),&list))
		
		IF !FOUND()
			OBVESTI("Niste odabrali nijednu izdanu opomenu za fizičku osobu!")
			return .f.
		ENDIF
	
		GF_SQLEXEC("select a.id_pog, isnull(b.id_tec_new,b.id_tec) as id_tec,isnull(c.id_val,a.id_val) as id_val from pogodba a left join tecajnic b on a.id_tec=b.id_tec left join tecajnic c on b.id_tec_new=c.id_tec","_pogodba")		
	OTHERWISE
		RETURN .F.
ENDCASE

*public gcDatum_upisa,gdDatum_upisa
*gdDatum_upisa=date()-1
*gdDatum_upisa=GF_GET_DATE("Datum upisa",gdDatum_upisa)

public loUserData
loUserData=gobj_comm.getUserData()

SELECT za_opom
SET FILTER TO oznacen = .T. AND !EMPTY(dok_opom)
** AND !(INLIST(allt(id_kupca),&list))
SET SKIP TO opom_tmp

GF_SQLEXEC("select a.*, b.ddv_id from opom_tmp a left join planp b on a.id_cont=b.id_cont AND a.st_dok=b.st_dok","_temp")