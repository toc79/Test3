iif(INLIST(ALLTRIM(partner.vr_osebe),"F1","FO") AND ALLTRIM(pogodba.id_rtip) !="0","Slučajevi eventualne potrebe zamjene referentne kamatne stope kao i način utvrđivanja zamjenske referentne kamatne stope te očuvanje ekonomske vrijednosti transakcije "+"financirane temeljem ovog Ugovora detaljno su opisani u točki 6. i 7. Općih uvjeta ugovora o financijskom leasingu.","")


clan80c
"Slučajevi eventualne potrebe zamjene referentne kamatne stope kao i način utvrđivanja zamjenske referentne kamatne stope te očuvanje ekonomske vrijednosti transakcije financirane temeljem ovog "

clan80d
"Ugovora detaljno su opisani u točki 6. i 7. Općih uvjeta ugovora o financijskom leasingu."

PW
INLIST(partner.vr_osebe,"F1","FO") AND TRIM(lookup(_rtip.id_rtip, pogodba.id_rtip, _rtip.id_rtip)) != "0"



clan84a
"Slučajevi eventualne potrebe zamjene Referentne kamatne stope kao i način utvrđivanja zamjenske referentne kamatne stope te očuvanje ekonomske vrijednosti transakcije financirane temeljem ovog Ugovora"

clan84b
"detaljno su opisani u točki 7. Općih uvjeta ugovora o financijskom leasingu."

rtip_base
lookup(_rtip.id_rtip_base, pogodba.id_rtip, _rtip.id_rtip)

!INLIST(partner.vr_osebe,"F1","FO")


kovacevic
iif(!INLIST(partner.vr_osebe,"F1","FO"),chr(13)+"Slučajevi eventualne potrebe zamjene Referentne kamatne stope kao i način utvrđivanja zamjenske referentne kamatne stope te očuvanje ekonomske vrijednosti transakcije"+"financirane temeljem ovog Ugovora detaljno su opisani u točki 7. Općih uvjeta ugovora o financijskom leasingu."+chr(13),"")

*NOVO
clanakPO3
iif(INLIST(ALLTRIM(partner.vr_osebe),"F1","FO") AND ALLTRIM(pogodba.id_rtip) !="0","Slučajevi eventualne potrebe zamjene referentne kamatne stope kao i način utvrđivanja zamjenske referentne kamatne stope te očuvanje ekonomske vrijednosti transakcije "+"financirane temeljem ovog Ugovora detaljno su opisani u točki 6. i 7. Općih uvjeta ugovora o financijskom leasingu.","") + iif(!INLIST(partner.vr_osebe,"F1","FO"),"Slučajevi eventualne potrebe zamjene Referentne kamatne stope kao i način utvrđivanja zamjenske referentne kamatne stope te očuvanje ekonomske vrijednosti transakcije"+"financirane temeljem ovog Ugovora detaljno su opisani u točki 7. Općih uvjeta ugovora o financijskom leasingu.","")