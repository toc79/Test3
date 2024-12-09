
GF_SQLEXEC(" SELECT CAST(d.sys_ts as bigint) as cast_sys_ts, cast('20200611' as datetime) as vrnjen_new, 'g_tomislav' as lcPopravil, d.* from dbo.dokument d WHERE id_dokum in (51303,51304,52625) order by id_dokum", "_stari_okvir_dokument")
*--d.id_cont = 8765
*fox
create cursor _dokumenti_za_promjenu ;
	( ;
    id_cont number(10,0) NOT NULL, cast_sys_ts character(19) NOT NULL, id_dokum number(10,0) NOT NULL, vrnjen_new datetime NOT NULL, popravil character(10) NOT NULL ;
	)
	
sele _stari_okvir_dokument 
go top
scan				
	insert into _dokumenti_za_promjenu (id_cont, cast_sys_ts, id_dokum, vrnjen_new, popravil) ;
	VALUES (_stari_okvir_dokument.id_cont, _stari_okvir_dokument.cast_sys_ts, _stari_okvir_dokument.id_dokum, _stari_okvir_dokument.vrnjen_new, _stari_okvir_dokument.lcPopravil)

endscan
use in _stari_okvir_dokument
* insert into _dokumenti_za_promjenu (id_cont, cast_sys_ts, id_dokum, vrnjen_new, popravil) values (8765,	'4679153',	51303,	date()-1,	'g_tomislav')
* insert into _dokumenti_za_promjenu (id_cont, cast_sys_ts, id_dokum, vrnjen_new, popravil) values (8765, '4679154', 	51304,	date()-1, 	'g_tomislav')
* insert into _dokumenti_za_promjenu (id_cont, cast_sys_ts, id_dokum, vrnjen_new, popravil) values (8765,	'4679113',	52625,	date()-1,	'g_tomislav')

insert into _dokumenti_za_promjenu (id_cont, cast_sys_ts, id_dokum, vrnjen_new, popravil) values (8765,	'3671572',	51305,	date()-3,	'g_tomislav')
insert into _dokumenti_za_promjenu (id_cont, cast_sys_ts, id_dokum, vrnjen_new, popravil) values (8765,	'3671577',	51306,	date()-3,	'g_tomislav')

select * from _dokumenti_za_promjenu order by id_dokum into cursor _dokumenti_za_promjenu2
use in _dokumenti_za_promjenu

select * from _dokumenti_za_promjenu2 order by id_dokum into cursor _dokumenti_za_promjenu
sele _dokumenti_za_promjenu
			
lnUkupno=RECCOUNT()
lnErrorCount=0
lnUspjesno=0
lcUgovoriUGresci=""
lcPoruka=""

go top
scan
	LOCAL lcXML

	lcXML = ""
	lcXML = lcXML + "<?xml version='1.0' encoding='utf-8' ?>" + gcE
	lcXML = lcXML + '<rpg_documentation_update_delete xmlns="urn:gmi:nova:leasing">' + gcE
	lcXML = lcXML + '<common_parameters>'+ gcE
	lcXML = lcXML + GF_CreateNode("id_cont", _dokumenti_za_promjenu.id_cont, "N", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("comment", "Automatsko popunjavanje datuma vraćanja na dokumetima okvira", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("sys_ts", _dokumenti_za_promjenu.cast_sys_ts, "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("id_dokum", _dokumenti_za_promjenu.id_dokum, "N", 1)+ gcE
	lcXML = lcXML + '</common_parameters>'+ gcE
	lcXML = lcXML + GF_CreateNode("is_update", .T., "L", 1)+ gcE	
	lcXML = lcXML + '<updated_values>'+ gcE
	lcXML = lcXML + GF_CreateNode("table_name", "DOKUMENT", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("name", "VRNJEN", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("updated_value", _dokumenti_za_promjenu.vrnjen_new, "D", 1)+ gcE
	lcXML = lcXML + '</updated_values>'+ gcE
	lcXML = lcXML + '<updated_values>'+ gcE
	lcXML = lcXML + GF_CreateNode("table_name", "DOKUMENT", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("name", "POPRAVIL", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("updated_value", _dokumenti_za_promjenu.popravil, "C", 1)+ gcE
	lcXML = lcXML + '</updated_values>'+ gcE
	lcXML = lcXML + '<updated_values>'+ gcE
	lcXML = lcXML + GF_CreateNode("table_name", "DOKUMENT", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("name", "dat_poprave", "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("updated_value", datetime(), "D", 1)+ gcE
	lcXML = lcXML + '</updated_values>'+ gcE
	lcXML = lcXML + '</rpg_documentation_update_delete>'

	WAIT WIND 'Pripremam podatke' NOWAIT
	IF !GF_ProcessXml(lcXml) THEN
		obvesti("Poruka poslije greške!")
		*17.06.2020 g_tomislav MID 44927 - u slučaju greške se promjena napravila na krovnom dok po dokumentima ugovora ZO nije. Dodana obavijest korisniku oko broja promjena i zaustavljen nastavak spremanja
		*pozor("Greška u izvođenju promjene dokumenata ugovora ZO za ugovor "+allt(GF_LOOKUP("pogodba.id_pog", _dokumenti_za_promjenu.id_cont, "pogodba.id_cont"))+" br. dok.: "+allt(trans(_dokumenti_za_promjenu.id_dokum))+"!")
		lnErrorCount = lnErrorCount + 1
		lcUgovoriUGresci = lcUgovoriUGresci + allt(GF_LOOKUP("pogodba.id_pog", _dokumenti_za_promjenu.id_cont, "pogodba.id_cont"))+" br. dok.: "+allt(trans(_dokumenti_za_promjenu.id_dokum)) +gce
		*RETURN .F.
		*RETURN
	ELSE 
		lnUspjesno = lnUspjesno + 1
	ENDIF
endscan

lcPoruka = "Rezultat promjena na dokumentima ugovora ZO"+gce ;
		+"ukupno za promjenu: "+allt(trans(lnUkupno))+gce ;
		+"uspješno promijenjeno: "+allt(trans(lnUspjesno))+gce ;
		+"greške: "+allt(trans(lnErrorCount)) ;

IF lnErrorCount > 0
	IF POTRJENO(lcPoruka+gce +"Greška u izvođenju je bila kod ugovora "+gce +lcUgovoriUGresci+gce+"Da li želite ponoviti promjenu datuma vraćanja za te ugovore/dokumente?")
		obvesti("Molimo da ponovno kliknete na gumb za spremanje kako bi se izvođenje ponovilo za ugovore u grešci!")
		RETURN .F.
	ENDIF
ELSE
	obvesti(lcPoruka)
ENDIF
obvesti ("Kraj, promjena na krovnom dokumentu se napravila!") 