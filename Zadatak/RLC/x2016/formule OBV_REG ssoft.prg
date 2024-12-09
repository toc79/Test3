*--1. rečenica FRX
iif(rnSpecDodTros>0,rtxt1,rtxt2)

rnSpecDodTros
gf_sqlexecscalar("SELECT count(*) FROM dbo.gv_DodStrPogodba WHERE id_cont="+gf_quotedstr(zap_reg.id_cont)+" and id_vrst_dod_str='05'")

rtxt1
'Troškove registracije molimo fakturirati na vlasnika '+iif(_vrsta_opr.tip_opr='P','plovila','vozila')+', tvrtka '+podjetje+', OIB: '+pdavstev+pemso+'.'

rtxt2
'Troškove registracije i eventulne dodatne troškove molimo fakturirati na ime korisnika '+txt2+' u prometnoj ispravi.'

txt2
iif(_vrsta_opr.tip_opr='P','plovila','vozila')

*-- 2 rečenica FRX
'Eventulne dodatne troškove pri registraciji vozila snosi korisnik '+iif(_vrsta_opr.tip_opr='P','plovila','vozila')+' opunomoćen ovim Nalogom za registraciju.'



*-- ssoft
Troškove registracije molim fakturirati na vlasnika {IIF(za_regis.tip_opr == "P", "plovila", "vozila")}, tvrtka {Settings.p_podjetje.Trim()}, OIB {Settings.p_dav_stev.Trim()}.

Troškove registracije i eventualne dodatne troškove molimo fakturirati na ime korisnika {IIF(za_regis.tip_opr == "P", "plovila", "vozila")} u prometnoj ispravi.

Eventulne dodatne troškove pri registraciji  {IIF(za_regis.tip_opr == "P", "plovila", "vozila")} snosi korisnik  {IIF(za_regis.tip_opr == "P", "plovila", "vozila")} opunomoćen ovim Nalogom za registraciju.




Ukoliko je knjižica {IIF(za_regis.tip_opr == "P", "plovila", "vozila")} važeća na dan produljenja registracije {IIF(za_regis.tip_opr == "P", "plovila", "vozila")}, ista je deponirana kod {Settings.p_podjetje.Trim()} 





