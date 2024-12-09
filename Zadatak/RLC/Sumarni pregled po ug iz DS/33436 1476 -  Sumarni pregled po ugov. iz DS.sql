1. Kolona NEFAKTURIRANI PPMV postoji na pregledu kao BUD. PPMV
SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.bod_robresti_LPOD, PP.ID_tec, @par_tecajnica_datumtec)) AS Se_Robresti,
Ukoliko su mislili na Fakturiranu nedospjeli PPMV to je u g) poknj_nezap_robresti_lpod – Iznos rev. kamata za proknjižena nedospjela potraživanja tipa LOBR, POLO, OPC, DDV. 

Formula za UKUPNO  u gfn_Report_SumContractFromDailySnapshot je sada 
Skupaj = Saldo + Se_neto + Se_fin_davek,

SALDO
Saldo =  CASE WHEN @par_zaprteterj_enabled = 0 THEN T.Saldo ELSE T.saldo_vklj_zaprto END,

SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_saldo_brut_LPOD + PP.znp_saldo_OST, PP.ID_tec, @par_tecajnica_datumtec) ) AS Saldo,
znp_saldo_brut_LPOD - Saldo in due not payed claims (only 'LOBR','OPC','POLO','DDV')
znp_saldo_OST - Saldo in due not payed other claims (only those which ARE NOT in 'LOBR','OPC','POLO','DDV')

-> da li bi bilo bolje da se uzme ZNP_SALDO_BRUT_ALL  (Dued not paid amount from all claims- This field presents total debt for this contract and should be equal to znp_saldo_ost+znp_saldo_lpod) ? Saldo je koliko toliko dobar.... 
Ovaj znp_saldo_lpod NE POSTOJI , valjda se misli na znp_saldo_brut_LPOD  


SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.saldo_total - PP.bod_debit_brut_ALL, PP.ID_tec, @par_tecajnica_datumtec) ) AS saldo_vklj_zaprto,

SE_NETO
SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.bod_neto_LPOD, PP.ID_tec, @par_tecajnica_datumtec)) AS Se_Neto,
bod_neto_LPOD
Sum of field planp.neto in all claims (only those which are in 'LOBR','OPC','POLO','DDV') and are not dued

-> tu bi trebalo dodati BOD_ROBRESTI_LPOD Sum of field planp.robresti in all claims (only those which are in 'LOBR','OPC','POLO','DDV') and are not dued

SE_FIN_DAVEK
SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.bod_findavek, PP.ID_tec, @par_tecajnica_datumtec)) AS Se_fin_davek,
bod_findavek
Sum of financed tax in all claims (only those which are in 'LOBR','OPC','POLO','DDV') and are not dued

-> da li je potrebno tu uključiti i BOD_DAVEK	Sum of field planp.davek for all future claims except those which are included in bod_findavek
s obzirom da bi po njima trebalo uključiti i "3. Fakturirani nedospjeli Porez". Zapravo NE jer je već kao proknjiženo pa se gleda kao dug, dok ostalo (SE_NETO i SE_FIN_DAVEK) se gleda kao buduća glavnica 

2. Fakturiranu nedospjelu Kamatu 
d) poknj_nezap_obresti_lpod - Iznos kamata za proknjižena nedospjela potraživanja tipa LOBR, POLO, OPC, DDV. 

3. Fakturirani nedospjeli Porez 
i) poknj_nezap_davek - Iznos poreza za proknjižena nedospjela potraživanja (gdje pdv nije u ratama). 
h) poknj_nezap_findavek - Iznos financiranog poreza za proknjižena nedospjela potraživanja (gdje je pdv u ratama). 

Također iznose tih triju kolona uključiti u ukupan iznos prikazan u koloni "Ukupno EUR" 
Već smo ranijim mailom naveli da u tu kolonu (Ukupno EUR) treba biti uključen iznos iz kolone "Bud.PPMV EUR" 
-> Trebalo bi dodati još iznos
a) poknj_nezap_debit_brut_lpod - Bruto iznos debit za proknjižena nedospjela potraživanja tipa LOBR, POLO, OPC, DDV. 
ili ukupni 
k) poknj_nezap_debit_brut_all - Bruto iznos za sva proknjižena nedospjela potraživanja.
zbog npr. g) poknj_nezap_robresti_lpod – Iznos rev. kamata za proknjižena nedospjela potraživanja tipa LOBR, POLO, OPC, DDV. 
Također nisu definirali za neto koji bi se nalazio u 
c) poknj_nezap_neto_lpod - Neto iznos za proknjižena nedospjela potraživanja tipa LOBR, POLO, OPC, DDV. 

 

KREDIT
Kredit = CASE WHEN @par_zaprteterj_enabled = 0 THEN T.Kredit ELSE t.kredit_vklj_zaprto END, 
SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_kredit_LPOD + PP.znp_kredit_OST, PP.ID_tec, @par_tecajnica_datumtec) ) AS Kredit,
znp_kredit_LPOD
Kredit-already payed in due not payed claims (only 'LOBR','OPC','POLO','DDV')
znp_kredit_OST
Kredit-already payed in due not payed other claims (only those which ARE NOT in 'LOBR','OPC','POLO','DDV')


DEBIT
Debit =  CASE WHEN @par_zaprteterj_enabled = 0 THEN T.Debit ELSE t.debit_vklj_zaprto END ,
SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_debit_LPOD + PP.znp_debit_OST, PP.ID_tec, @par_tecajnica_datumtec) ) AS Debit,
znp_debit_LPOD
Debit- obliged to pay in due not payed claims (only 'LOBR','OPC','POLO','DDV')
znp_debit_OST
Debit- obliged to pay in due not payed other claims (only those which ARE NOT in 'LOBR','OPC','POLO','DDV')

DRUGI MAIL
1.  Fakturirani nedospjeli PPMV = planp_ds.poknj_nezap_robresti_lpod -> nema u funkciji gfn_Report_SumContractFromDailySnapshot (trebalo bi ga onda dodati)
2. Fakturiranu nedospjelu Kamatu = poknj_nezap_obresti_lpod -> nema u funkciji 
3. Fakturirani nedospjeli Porez = poknj_nezap_davek -> nema u funkciji 
4. UKUPNO 
Se_Robresti = BOD_ROBRESTI_LPOD (sadrži i poknj_nezap_robresti_lpod)
Nova formula za Skupaj:
Skupaj = Saldo + Se_neto + Se_fin_davek + Se_Robresti + poknj_nezap_obresti_lpod + poknj_nezap_davek 

select ZNP_SALDO_BRUT_ALL, ZNP_SALDO_BRUT_ALL+bod_neto_LPOD+bod_findavek as Skupaj,BOD_ROBRESTI_LPOD, poknj_nezap_robresti_lpod,* from planp_ds where BOD_ROBRESTI_LPOD != 0 and poknj_nezap_robresti_lpod !=0--poknj_nezap_neto_lpod != 0 --and id_cont=155

--select planp_ds_tec,* from LOC_NAST
--UPDATE loc_nast set planp_ds_tec = '000'

Za cijelu sliku bi možda trebalo dodati i kolone 
h) poknj_nezap_findavek - Iznos financiranog poreza za proknjižena nedospjela potraživanja (gdje je pdv u ratama). 
i) poknj_nezap_davek - Iznos poreza za proknjižena nedospjela potraživanja (gdje pdv nije u ratama). 
j) poknj_nezap_ost – Iznos (bez poreza) za proknjižena nedospjela potraživanja (kratkoročna) koja nisu tipa LOBR, POLO, OPC, DDV. 

fyi, iz release notes: 
- Dnevni snimak stanja smo proširili s novim poljima koja predstavljaju proknjiženo nedospijelo: 
a) poknj_nezap_debit_brut_lpod - Bruto iznos debit za proknjižena nedospjela potraživanja tipa LOBR, POLO, OPC, DDV. 
b) poknj_nezap_debit_net_lpod - Neto iznos debit za proknjižena nedospjela potraživanja tipa LOBR, POLO, OPC, DDV. 
c) poknj_nezap_neto_lpod - Neto iznos za proknjižena nedospjela potraživanja tipa LOBR, POLO, OPC, DDV. 
d) poknj_nezap_obresti_lpod - Iznos kamata za proknjižena nedospjela potraživanja tipa LOBR, POLO, OPC, DDV. 
e) poknj_nezap_marza_lpod - Iznos marže za proknjižena nedospjela potraživanja tipa LOBR, POLO, OPC, DDV. 
f) poknj_nezap_regist_lpod - Iznos registracije za proknjižena nedospjela potraživanja tipa LOBR, POLO, OPC, DDV. 
g) poknj_nezap_robresti_lpod – Iznos rev. kamata za proknjižena nedospjela potraživanja tipa LOBR, POLO, OPC, DDV. 
h) poknj_nezap_findavek - Iznos financiranog poreza za proknjižena nedospjela potraživanja (gdje je pdv u ratama). 
i) poknj_nezap_davek - Iznos poreza za proknjižena nedospjela potraživanja (gdje pdv nije u ratama). 
j) poknj_nezap_ost – Iznos (bez poreza) za proknjižena nedospjela potraživanja (kratkoročna) koja nisu tipa LOBR, POLO, OPC, DDV. 
k) poknj_nezap_debit_brut_all - Bruto iznos za sva proknjižena nedospjela potraživanja. 
l) poknj_nezap_debit_net_all - Neto iznos za sva proknjižena nedospjela potraživanja. 
m) poknj_nezap_davek_lpod – Iznos poreza za proknjižena nedospjela potraživanja tipa LOB, POLO, OPC, DDV. 
- Sva gore navedena polja su već uključena u istoimena polja koja predstavljaju budući dio (bod_...). 
- Promjena je uključena u hotfix 2.9.7 (za verziju 2.9).
Progress
Tomislav Krnjak
17.12.2015 10:31:08
 Interno Self made Hide comment from customer: True Toggle
Pozdrav, 

RLHR bi na pregledu Pregledi | Pregledi plaćenosti potraživanja | Sumarni pregled po ugovorima iz dnevne snimke stanja (gfn_Report_SumContractFromDailySnapshot) dodao slijedeće kolone: 
1. Fakturirana nedospjela glavnica = planp_ds.poknj_nezap_neto_lpod -> nema u funkciji gfn_Report_SumContractFromDailySnapshot (trebalo bi ga onda dodati) 
2. Fakturirana nedospjela kamata = planp_ds.poknj_nezap_obresti_lpod -> nema u funkciji 
3. Fakturirana nedospjela marža = planp_ds.poknj_nezap_marza_lpod -> nema u funkciji 
4. Fakturirane nedospjele dod. usluge = planp_ds.poknj_nezap_regist_lpod -> nema u funkciji 
5. Fakturirani nedospjeli porez = planp_ds.poknj_nezap_davek_lpod -> nema u funkciji 
6. Fakturirani nedospjeli PPMV = planp_ds.planp_ds.poknj_nezap_robresti_lpod -> nema u funkciji 
7. Još bi htjeli da se podatak budućeg PPMV doda u izračun kolone UKUPNO (SKUPAJ). Trenutna formula je 
Skupaj = Saldo + Se_neto + Se_fin_davek 
pa bi trebali dodati podatak Se_Robresti pa bi formula izgledala: 
Skupaj = Saldo + Se_neto + Se_fin_davek + Se_Robresti 


Pozdrav, 
Daniel Vrpoljac 
Voditelj održavanja / Head o

lcPar_tecajnica_datumtec = GF_PCDDESC('_PCDPARAMETER','PARNAME','PARCONT','DATUMTEC','TECAJ','PARVALUE','C')
lcPar_tecajnica_tecajnica = GF_PCDDESC('_PCDPARAMETER','PARNAME','PARCONT','TECAJNICA','TECAJ','PARVALUE','C')

*budući neto i PPMV se već nalazi u SKUPAJ 
GF_SQLEXEC("select id_cont, SUM(dbo.gfn_Xchange("+GF_Quotedstr(lcPar_tecajnica_tecajnica)+", poknj_nezap_debit_brut_LPOD - poknj_nezap_neto_LPOD - poknj_nezap_robresti_LPOD, ID_tec, "+GF_Quotedstr(lcPar_tecajnica_datumtec)+")) as OSTALO from planp_ds group by id_cont","_dr_planp_ds_staro")

GF_AddColumnsToGrid("frmPP_IZBOR_DS", "BGridResult", "Risk izloženost staro", "PPIzbor.SKUPAJ + LOOKUP(_dr_planp_ds_staro.OSTALO,PPIzbor.ID_CONT,_dr_planp_ds_staro.ID_CONT)" , 150, "999,999,999,999.99")

TEXT TO lcSQL NOSHOW
	Select id_cont, SUM(dbo.gfn_Xchange({0}, znp_saldo_brut_LPOD + znp_saldo_OST + bod_neto_LPOD +  bod_findavek + bod_robresti_LPOD + BOD_OST, ID_tec, {1})) as Risk_exp 
	From dbo.planp_ds 
	Group by id_cont
ENDTEXT

lcSQL = STRTRAN(lcSQL, "{0}", GF_QUOTEDSTR(lcPar_tecajnica_tecajnica))
lcSQL = STRTRAN(lcSQL, "{1}", GF_QUOTEDSTR(lcPar_tecajnica_datumtec ))

GF_SQLEXEC(lcSQL,"_dr_planp_ds")
GF_AddColumnsToGrid("frmPP_IZBOR_DS", "BGridResult", "Risk izloženost", "LOOKUP(_dr_planp_ds.Risk_exp, PPIzbor.ID_CONT, _dr_planp_ds.ID_CONT)" , 150, "999,999,999,999.99")


sum(pp.znp_saldo_brut_all + pp.poknj_nezap_debit_brut_ALL + pp.bod_neto_lpod - pp.poknj_nezap_neto_lpod + pp.bod_robresti_lpod - pp.poknj_nezap_robresti_lpod
			+ case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' then pp.bod_davek_LPOD - pp.poknj_nezap_davek_LPOD else 0 end) as risk_exposure,
			
			select * from planp_ds where id_cont=52448
			
			
TREBA ZAMIJENITI poknj_nezap_debit_brut_LPOD sa poknj_nezap_debit_brut_all
			
			
			
			
			

