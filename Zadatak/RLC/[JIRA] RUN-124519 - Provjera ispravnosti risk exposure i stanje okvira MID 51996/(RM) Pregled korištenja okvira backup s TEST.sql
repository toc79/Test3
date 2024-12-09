Red.br.	Ime polja	Ime stupca	Vrsta	Format	Širina	Poravnanje	Pozadina	Boja teksta	Masno	Funkcija
1,00000000	id_frame	Okvir	TextBox		75,00000000	3,00000000	255,255,255	0,0,0	.F.	
3,00000000	id_kupca	Šif.Part	TextBox		75,00000000	3,00000000	255,255,255	0,0,0	.F.	
4,00000000	naz_kr_kup	Partner	TextBox		150,00000000	3,00000000	255,255,255	0,0,0	.F.	
6,00000000	znesek_val	Odobreno VAL	TextBox	gccif	100,00000000	3,00000000	255,255,255	0,0,0	.F.	
7,00000000	plac_val	Korišteno VAL	TextBox	gccif	100,00000000	3,00000000	255,255,255	0,0,0	.F.	
8,00000000	razlika_val	Preostalo VAL	TextBox	gccif	100,00000000	3,00000000	255,255,255	0,0,0	.F.	
9,00000000	id_val	Valuta	TextBox		75,00000000	3,00000000	255,255,255	0,0,0	.F.	
10,00000000	id_tec	Tečaj	TextBox		75,00000000	3,00000000	255,255,255	0,0,0	.F.	
11,00000000	dat_odobritve	Datum odobrenja	TextBox		120,00000000	3,00000000	255,255,255	0,0,0	.F.	TTOD(@Field)
12,00000000	dat_zak	Datum zak.	TextBox		110,00000000	3,00000000	255,255,255	0,0,0	.F.	TTOD(@Field)
16,00000000	frame_type	Tip korištenja	TextBox		110,00000000	3,00000000	255,255,255	0,0,0	.F.	
14,00000000	limtraj_naj	Trajanje	TextBox		75,00000000	3,00000000	255,255,255	0,0,0	.F.	
2,00000000	status_akt	Akt.	TextBox		30,00000000	3,00000000	255,255,255	0,0,0	.F.	
5,00000000	eval_model	Model ev.	TextBox		75,00000000	3,00000000	255,255,255	0,0,0	.F.	
18,00000000	b2_eligible	B2 rel.	TextBox		40,00000000	3,00000000	255,255,255	0,0,0	.F.	
17,00000000	opis	Opis	TextBox		200,00000000	3,00000000	255,255,255	0,0,0	.F.	
15,00000000	dat_kon	Datum kon. dosp.	TextBox		75,00000000	3,00000000	255,255,255	0,0,0	.F.	TTOD(@Field)
19,00000000	kraj	Dodatni opis	TextBox		200,00000000	3,00000000	255,255,255	0,0,0	.F.	
20,00000000	user_desc	Referent	TextBox		75,00000000	3,00000000	255,255,255	0,0,0	.F.	
13,00000000	velja_do	Važi do	TextBox		75,00000000	3,00000000	255,255,255	0,0,0	.F.	TTOD(@Field)


-- 29.03.2018 GMC Branislav; MID 40182 - replace usage gv_p_eval with function gfn_PEval_LastEvaluationOnTargetDate

DECLARE @id_oc_report int
DECLARE @target_date datetime

SET @id_oc_report = {1}
set @target_date = (select date_to from dbo.gv_OcReports where id_oc_report = @id_oc_report)

select a.id_kupca, max(eval_model) as eval_model
into #gv_p_eval
from dbo.gfn_PEval_LastEvaluationOnTargetDate (@target_date, @id_oc_report, NULL) a
inner join dbo.oc_frames f on a.id_kupca = f.id_kupca and @id_oc_report = f.id_oc_report
group by a.id_kupca

Select f.id_frame,
f.id_kupca, op.naz_kr_kup, f.znesek_val, f.znesek_dom,
f.plac_val, f.plac_dom, f.znesek_val - f.plac_val as razlika_val, f.znesek_dom - f.plac_dom as razlika_dom,
t.id_val, f.id_tec, f.dat_odobritve, f.dat_zak, f.frame_type, f.limtraj_naj, f.b2_eligible,
e.eval_model, 
case when f.dat_zak > @target_date then 'A' else f.status_akt end as status_akt,
n.velja_do, dateadd(m, isnull(f.limtraj_naj, 0), n.velja_do) as dat_kon, n.opis, n.kraj, s.user_desc
from dbo.oc_frames f
inner join dbo.oc_customers op on f.id_kupca = op.id_kupca and op.id_oc_report = @id_oc_report
inner join dbo.tecajnic t on f.id_tec = t.id_tec and t.id_oc_report = @id_oc_report
left outer join #gv_p_eval e on f.id_kupca = e.id_kupca
left outer join {3}.dbo.frame_list n on f.id_frame = n.id_frame
left outer join {3}.dbo.users s on n.username = s.username
where f.id_oc_report = @id_oc_report

drop table #gv_p_eval

Poštovana/i, 

razlika u izvještajima je što se u izvještaju "(RM) Pregled korištenja okvira" za REV tip okvira (Obnavljajući okvir - ugovor) za podatak "Korišteno VAL", koji se dobiva kao zbroj buduće glavnice i obliga, u obligo ulazi bruto iznos nedospjele rate, konkretno iznos 83,35 za potraživanje 73545/23-21-003AVT koje dakle nije proknjižen/evidentiran zbog posebnosti (datum dokumenta je 1.11.2023) pa je riječ o dospjelo neproknjiženom iznosu.  
U izvještaju "(AC) EBA Present Value - sumarni pregled potraživanja po ugovorima IFRS9 (DW) ver 19.4.2021" u koloni "Risk exposure" za takva dospjela neproknjižena potraživanja (između ostalog) ide neto iznos (glavnice), konkretno iznos 51,47 za isto potraživanje 73545/23-21-003AVT.
Bili ste naveli da podatak "Risk exposure" u EBA izvještaju točan i da bi trebalo doraditi izvještaju "(RM) Pregled korištenja okvira". 
S obzirom da se taj podatak ide iz snimke stanja te se radi o sistemskom podatku, jednostavnije rješenje je da se radi dorada izvještaja "(RM) Pregled korištenja okvira" na način da se napravi custom prikaz podataka "Korišteno VAL" kada se radi o REV tipu okvira tj. obnavljajućem tipu okvira.
Drugo riješenje je da se pošalje zahjtev kolegama u Sloveniju da se sistemski podatak korištenosti okvira ("Korišteno VAL") doradi za REV tip okvira oko izračuna obliga. Koliko sam vidio, obligo se računa samo za tipove okvira 
REV Obnavljajući okvir - ugovor
RNE Obnavljajući okvir - iznos financiranja
RFO Obnavljajući okvir - Ford
pa da li treba za sve te tipve okvira?

Molim provjeru i povratnu informaciju.

$SIGN


gleda se datum dokumenta, pa ako bi se snimka radila na datum između datuma dokumenta i datuma dospijeća, bio bi isti izračun

('REV', 'RFO', 'RNE') 
da pošaljemo u zahjtev GMi ili da se 
=A Mada kada testiram select dobije se obligo 83,35 !!!!

U Pregledu korištenja okvira za REV tip okvira u koloni "Korišteno VAL" je prikazana suma Buduća glavnica + Obligo te u sumu Obligo ulazu cijeli iznos rate koja je neproknjižena/ne evidentiran zbog posebnosti ugovora, konkretno u tom izvještaju se ne nalazi iznos 83,35 za potraživanje 73545/23-21-003AVT koje nije proknjiženo/evidentirano zbog posebnosti (datum dokumenta je 1.11.2023). 



U izvještaju "(AC) EBA Present Value - sumarni pregled potraživanja po ugovorima IFRS9 (DW) ver 19.4.2021" u koloni Risk exposure se prikazuje i dospjelo neproknjiženo 

