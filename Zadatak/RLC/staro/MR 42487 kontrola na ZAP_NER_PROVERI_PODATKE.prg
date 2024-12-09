LOCAL loForm
loForm = GF_GetFormObject('frmZap_ner_maska')

*/////////////////////////////////////////////////////////////////
* 26.04.2019 g_tomislav MR 42487 - zapisi u kojima nije popunjena kolona NAZIV se ne spremaju tako da je možda potrebno napraviti selekciju 
* - kod popravka postojećeg zapisa ako se obriše NAZIV, kod spremanja ne dođe do promjene naziva nego se ostane dosadašnji. Brisanje zapisa se dakle radi na gumb briši.

* Osvježavanje podataka u tabeli opreme (u suprotnom je ponekad kursor prazan)
SELECT oprema
GO TOP
loForm.Bpageframe1.Page2.grdOprema.Refresh

select * from oprema where EMPTY(naziv) into cursor _ef_oprema_naziv
select * from oprema where EMPTY(znamka) into cursor _ef_oprema_znamka    

* Ako je unesen zapis bez naziva (koji neće biti spremljen) ili ako na jednom od zapisa nije unesena marka
IF RECCOUNT("_ef_oprema_naziv") > 0 OR RECCOUNT("_ef_oprema_znamka") > 0  
	OBVESTI("Unijeti polje MARKA ako se radi o o Hyundai i Mitsubishi opremi!")
ENDIF

USE IN _ef_oprema_naziv
USE IN _ef_oprema_znamka
* KRAJ MR 42487 ////////////////////////////////////////////////////


Poštovana/i, 

u privitku vam šaljemo ponudu za izradu kontrolne poruke/obavijesti prilikom spremanja podataka zapisnika za opremu, u slučaju da nije unesen podatak Marka na jednom od zapisa, da se javi poruka "Unijeti polje MARKA ako se radi o o Hyundai i Mitsubishi opremi".

$SIGN