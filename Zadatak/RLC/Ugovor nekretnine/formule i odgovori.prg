- za podatke poduzeća RL sam podesio kao na standardnim ispisima ugovora.
- u čl. 4 sam podesio datum sklapanja za varijablu.
- naziv tečaja je uzet iz šifranta Tečajevi.
- razdoblje u tč. 5.3 je fiksno napisano "mjesečne". Da li ćete imati drugačija razdoblja otplate(tada bi se trebao prilagoditi tekst da odgovora nazivu razdoblja iz šifranta razdoblja) ?
- instrumenti osiguranja - prikaz je napravljen prema logici prema standardnom ugovoru za FL u wordu.
- da li ćete imati ugovore u domaćoj valuti HRK? Tada molim da provjerite i ispis s takvim ugovorom te nam povratno javite potrebne dorade.




Formule
allt(trans(round(pogodba.ost_obr * (pogodba.st_obrok - IIF(pogodba.opcija > 0 , 1, 0)), 2), "99999"))+" "+allt(pogodba.id_val)+" (slovima: "+crocif(round(pogodba.ost_obr * (pogodba.st_obrok - IIF(pogodba.opcija > 0 , 1, 0)), 2))+" "+allt(pogodba.id_val)+")"

allt(trans(pogodba.opcija, gccif))+" "+allt(pogodba.id_val)+" (slovima: "+crocif(pogodba.opcija, IIF(pogodba.id_val == "HRK", "Z", "M"))+" "+allt(pogodba.id_val)+")"

allt(trans(round(pogodba.ost_obr * (pogodba.st_obrok - IIF(pogodba.opcija > 0 , 1, 0)), 2), gccif))+" "+allt(pogodba.id_val)+" (slovima: "+crocif(round(pogodba.ost_obr * (pogodba.st_obrok - IIF(pogodba.opcija > 0 , 1, 0) ), 2), IIF(pogodba.id_val == "HRK", "Z", "M") )+" "+allt(pogodba.id_val)+")"

IIF(pogodba.opcija > 0, allt(pogodba.st_obrok)+". (slovima: "+crocif (pogodba.st_obrok, "Z",  .f.)+")", "0")