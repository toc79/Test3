Troškove registracije i trošak poreza na cestovna motorna vozila molimo fakturirati na ime korisnika vozila u prometnoj ispravi.

txt1
iif(rnSpecDodTros>0,rtxt1,rtxt2)

*NOVO
iif(rnSpecDodTros>0,rtxt1,iif(_vrsta_opr.tip_opr='P', rtxt2, rcTxt3))

rnSpecDodTros
gf_sqlexecscalar("SELECT count(*) FROM dbo.gv_DodStrPogodba WHERE id_cont="+gf_quotedstr(zap_reg.id_cont)+" and id_vrst_dod_str='05'")

rtxt1
'Troškove registracije molimo fakturirati na vlasnika '+iif(_vrsta_opr.tip_opr='P','plovila','vozila')+', tvrtka '+podjetje+', OIB: '+pdavstev+pemso+'.'

rtxt2
'Troškove registracije i eventulne dodatne troškove molimo fakturirati na ime korisnika '+txt2+' u prometnoj ispravi.'

*NOVO
rcTxt3
"Troškove registracije i trošak poreza na cestovna motorna vozila molimo fakturirati na ime korisnika vozila u prometnoj ispravi."

txt2
iif(_vrsta_opr.tip_opr='P','plovila','vozila')


'Eventulne dodatne troškove pri registraciji vozila snosi korisnik '+iif(_vrsta_opr.tip_opr='P','plovila','vozila')+' opunomoćen ovim Nalogom za registraciju.'
PW: rnSpecDodTros > 0



*ssoft

Troškove registracije i eventualne dodatne troškove molimo fakturirati na ime korisnika {IIF(za_regis.tip_opr == "P", "plovila", "vozila")} u prometnoj ispravi.

*NOVO
IIF(za_regis.tip_opr == "P", "Troškove registracije i eventualne dodatne troškove molimo fakturirati na ime korisnika "+IIF(za_regis.tip_opr == "P", "plovila", "vozila")+" u prometnoj ispravi.", "Troškove registracije i trošak poreza na cestovna motorna vozila molimo fakturirati na ime korisnika vozila u prometnoj ispravi.")


Poštovani, 
na testu na ispisima 
OVLAŠTENJE ZA REGISTRIRANJE VOZILA 
DOPIS ZA REGISTRACIJU SSOFT 
smo doradili rečenicu koja se ispisuje u slučaju da nema dodatnih troškova sukladno telefonskom razgovoru/zahtjevu.

Molim provjeru.

U prilogu vam šaljemo ponudu za utrošeno vrijeme dorade po ovom zahtjevu.

$SIGN