Poštovana/i, 

na NOVA_TEST sam podesio funkcionalnost povlačenja podataka iz odobrenja prema zahtjevu.

Povlaćenje podataka iz odobrenja se sada radi na sljedeći način: 
- kod unosa ID odobrenja se prvo prikaže sistemska poruka "Želite li povući podatke iz odabranog odobrenja?" kao i do sada i riječ je o sistemskoj poruci koja odgovorom na DA podesi sljedeće vrijednosti: 
"Kam. stopa (%)"
"Partner" 					
"Tečaj" (šifra, i iznos)
i "Iznos_val".

- nakon toga se pokreće novo podešena funkcionalnost te će se prikazati pitanje "Da li želite povući podatke za polja 'Iznos VAL', 'Dat. odobrenja' te podatke na stranici/tab-u 'Dodatni uvjeti za korištenje'?"
u ojima se povuku i postave podaci u navedenim poljima.
				
- u slučaju da se obriše broj odobrenja nakon postavljanja vrijednosti u poljima, iznosi će ostati nepromijenjeni (neće se obrisati).

Molim provjeru i povratnu informaciju.

This.Parent.txtObr_mera.Value = odobrit.obr_mera
This.Parent.txtID_Kupca.Value = odobrit.id_kupca
This.Parent.txtNaz_kr_kup.Value = odobrit.naz_kr_kup
This.Parent.cboTecajnica.Value = odobrit.id_tec
This.Parent.txtZnesek_val.Value = odobrit.vr_val 
ENDIF



‑ Datum odobrenja‑ Datum statusa odobreno na Modulu odobrenja (zadnji datum)‑ može se povući iz NOVA
treba dakle popuniti sva polja na drugom listu/tabu "Dodatni uvjeti korištenja" osim polja "Opis osiguranja"?


ext_func se pokreće više puta na više mjesta tako da je potrebno podesiti da ukoliko je razlika da se onda setira i prikaže poruka. Prikaz poruke je po meni poželjan zato što postoji slučaj
"nedostatak ovog rješenja je što kod popravka zapisa okvira ako promijenite šifru odobrenja i onda ne promijenite status aktivnosti, tada se eksterna funkcija neće pokretati pa time niti setiranje. "

obvesti("frame_list_maska_set_controls_after")
obvesti(trans(lnZnesek_val, gccif) + gce + trans(lnId_odobrit ))


loForm.pgfFrames.pagFrame.txtZnesek_val.Value = 100


loForm = GF_GetFormObject("frame_list_maska")
IF ISNULL(loForm) 
	RETURN
ENDIF

**----------------------------------------
** 10.06.2021 g_tomislav MID 47032

lnSif_odobrit = loForm.pgfFrames.pagFrame.txtSifOdobr.Value 

IF !GF_NULLOREMPTY(lnSif_odobrit) OR
	
	lnZnesek_val = loForm.pgfFrames.pagFrame.txtZnesek_val.Value
	lnNet_nal = NVL(GF_LOOKUP("odobrit.net_nal", lnSif_odobrit, "odobrit.id_odobrit"), 0)
	
	IF lnZnesek_val != lnNet_nal 
		loForm.pgfFrames.pagFrame.txtZnesek_val.Value = lnNet_nal
		obvesti("Promijenjen je podatak u polju '" + allt(loForm.pgfFrames.pagFrame.lblZnesek_val.Caption) +"' iz " +allt(trans(lnZnesek_val, gccif)) +" u " +allt(trans(lnNet_nal, gccif)) +" (neto iznos financiranja)!")
	ENDIF

ENDIF
** KRAJ MID 47032---------------------------
