* ORIGINAL
IIF((gl_output_r.id_dav_st='EB' or gl_output_r.id_dav_st='EN' or gl_output_r.id_dav_st='ES') and RF_PRINT_PIB(gl_output_r.ddv_date), 'PDV ID broj','OIB')

*NA PIB

IIF((gl_output_r.id_dav_st='EB' or gl_output_r.id_dav_st='EN' or gl_output_r.id_dav_st='ES') and RF_PRINT_PIB(gl_output_r.ddv_date), 'PDV IB: HR', 'OIB: ')

* NOVO
Ako je partner član EU(partner.clan_eu) a nije iz HR(prema id_poste_sed), tada treba pisati naziv labele "PDV ID" + partner.dav_stev. Nema više provjere na LEN=11.
i porezna stopa OP


*Dodati u code before polje CLAN_EU u postojeći kursor _PARTNER
or (lookup(_partner.clan_eu,gl_output_r.id_kupca,_partner.id_kupca) AND left(gl_output_r.id_poste_sed,2)!='HR')


IIF((atc(gl_output_r.id_dav_st,'EB,EN,ES')>0 OR (look(_partner.clan_eu,gl_output_r.id_kupca,_partner.id_kupca) AND left(gl_output_r.id_poste_sed,2)!='HR' AND gl_output_r.id_dav_st='OP')) and RF_PRINT_PIB(gl_output_r.ddv_date), 'PDV ID broj','OIB')

*Ispis je pšojedinačni pa može bez LOOK

IIF((atc(gl_output_r.id_dav_st,'EB,EN,ES')>0 OR (_partner.clan_eu AND left(gl_output_r.id_poste_sed,2)!='HR' AND gl_output_r.id_dav_st='OP')) and RF_PRINT_PIB(gl_output_r.ddv_date), 'PDV ID broj','OIB')


*HAC na OPC_FAKA

iif(_partner.clan_eu=.T. and left(_partner.id_poste_sed,2)#'HR','PDV / VAT ID','OIB')


* HAC EORI number
'EORI BROJ (EORI number): '+iif(atc('HR',gObj_Settings.getval('p_dav_stev'))>0,'','HR')+allt(gObj_Settings.getval('p_dav_stev'))