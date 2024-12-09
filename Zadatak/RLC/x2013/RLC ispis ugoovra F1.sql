iif(allt(pogodba.id_rtip)#"0" and ATC(pogodba.vr_osebe,'F1FO')>0,chr(13)+"Kamatna stopa iznosi "+allt(trans(pogodba.obr_mera))+"%, odnosno jednaka je zbroju stope "+ALLT(pogodba.rtip_naziv)+"-a i nepromjenjive marže u iznosu od "+ALLT(TRANS(pogodba.FIX_DEL,GCCIF))+"%. Kamatna stopa je promjenjiva i vezana uz stopu "+ALLT(pogodba.rtip_naziv)+"-a, te se u skladu s povećanjem ili smanjenjem stope "+ALLT(pogodba.rtip_naziv)+"-a mijenja svaka ","")



iif(allt(pogodba.id_rtip)#"0",left(allt(pogodba.rtip_naziv),1)+" mjeseca počevši od datuma ponude."+gcE,"")


iif(allt(pogodba.id_rtip)#"0" and ATC(partner.vr_osebe,'F1FO')>0,chr(13)+"Kamatna stopa iznosi "+allt(trans(pogodba.obr_mera))+"%, odnosno jednaka je zbroju stope "+ALLT(pogodba.rtip_naziv)+"-a i nepromjenjive marže u iznosu od "+ALLT(TRANS(pogodba.FIX_DEL,GCCIF))+"%. Kamatna stopa je promjenjiva i vezana uz stopu "+ALLT(pogodba.rtip_naziv)+"-a, te se u skladu s povećanjem ili smanjenjem stope ","")



iif(allt(pogodba.id_rtip)#"0" and ATC(partner.vr_osebe,'F1FO')>0,ALLT(pogodba.rtip_naziv)+"-a mijenja svaka "+left(allt(pogodba.rtip_naziv),1)+" mjeseca počevši od datuma ponude."+gcE,"")