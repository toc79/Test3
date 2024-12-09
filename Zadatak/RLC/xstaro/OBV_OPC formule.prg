'Molim Vas da nas pismenim putem obavijestite da li prihvaćate opciju kupnje objekta leasinga čija otkupna vrijednost iznosi '+rcOpcija+rcOpcTxt1+rcOpcTxt2+" ili putem maila leasing.vodjenje@rl-hr.hr"
rcOpcija
allt(trans(NVL(look(_cb_opcija.debit,odgnaopc.id_cont,_cb_opcija.id_cont),0),gccif))+' '+allt(NVL(look(_cb_opcija.id_val,odgnaopc.id_cont,_cb_opcija.id_cont),''))
rcOpcTxt1
" čime ostvarujete pravo na stjecanje vlasništva nad objektom leasinga, a nakon podmirenja otkupne vrijednosti i ispunjenja svih ugovorenih uvjeta kako je u ugovoru definirano."+chr(13)+"Opciju kupnje:"+chr(9)+"1. Prihvaćam"+chr(13)
rcOpcTxt2
chr(9)+chr(9)+chr(9)+chr(9)+"2. Ne prihvaćam"+chr(13)+chr(13)+"Datum ______________"+chr(13)+chr(13)+"Pečat i potpis primatelja leasinga."+chr(13)+chr(13)+"Ispunjeni dopis molim vratiti na fax "+allt(gobj_settings.GetVal("p_fax"))

* NOVO
Otkupna vrijednost gore navedenog objekta leasinga iznosi 15.515,17 EUR. Podmirenjem navedenog iznosa  ostvarujete pravo na stjecanje vlasništva nad objektom leasinga.

Ukoliko opciju kupnje ne prihvaćate molimo da nas obavijestite pismenim putem .U protivnom ćemo smatrati da ste opciju kupnje prihvatili.

variajble
"Otkupna vrijednost gore navedenog objekta leasinga iznosi "+rcOpcija+". Podmirenjem navedenog iznosa ostvarujete pravo na stjecanje vlasništva nad objektom leasinga."+chr(13)+chr(13)+rcOpcTxt1

rcOpcTxt1
"Ukoliko opciju kupnje ne prihvaćate molimo da nas obavijestite pismenim putem. U protivnom ćemo smatrati da ste opciju kupnje prihvatili."

rcOpcTxt2
obrisati



lctxt3
'U slučaju da ste za objekt leasinga prijavili štetni događaj, račun za popravak objekta leasinga mora biti plaćen od strane '+allt(gObj_Settings.getval('p_podjetje'))+' prema serviseru prije završetka ugovora o leasingu. Nakon isteka ugovora '

lctxt3a
'objekt leasinga moći ćete popraviti na način da račun za popravak bude OBAVEZNO naslovljen na Primatelja leasinga, za što će '+allt(gObj_Settings.getval('p_podjetje'))+' izdati Suglasnost prema osiguravajućoj kući.'

*NOVO
"U slučaju da ste za objekt leasinga prijavili štetni događaj, račun za popravak objekta leasinga mora biti plaćen od strane "+allt(gObj_Settings.getval('p_podjetje'))+" prema serviseru prije završetka ugovora o leasingu."

"Nakon isteka ugovora objekt leasinga moći ćete popraviti na način da račun za popravak bude OBAVEZNO naslovljen na Primatelja leasinga, za što će "+allt(gObj_Settings.getval('p_podjetje'))+" izdati Suglasnost prema osiguravajućoj kući."