Poštovani,
na testu smo podesili ispis 'Odobrenje Financiranja Stimulsoft' te ga dodali u opciju ispisivanja 'Masovni ispis ugovorne dokumentacije stimulsoft'.
Komentari uz ispis:
a) podatak 'Dat. isteka:' samo podesio u istoj liniji kao i 'Vrijedi do:'. Da li je to u redu (koliko se sjećam stavka je stavljena ispod jer nije stala u taj redak)?
b) iznos za stavku 'Ostatak duga' se nikada ne ispisuje. Da ju maknemo s ispisa (radi dobivanja prostora)?
c) iznos za stavku 'Stari ugovori (još nije dospelo):' se nikada ne ispisuje. Da ju maknemo s ispisa (radi dobivanja prostora)?
d) iznos za stavku 'UKUPAN DUG:' se nikada ne ispisuje. Da ju maknemo s ispisa (radi dobivanja prostora)?
e) odlomak 'Dodatne informacije o partneru:' za vrstu osobe FO, podesio sam da je prikazano na vrhu odlomka te da svaka lijeija ide najviše u dva reda (time neće prelaziti okvir koji je time fiksan).
f) margine i razmaci između teksta međusobno i okvira, da li su u redu?

Molim provjeru ispisa.

$SIGN

"UKUPAN DUG:"

DECLARE @id int
SET @id =          21448--2486 --3729 ---2486


je_oper
iif(allt(gf_lookup('nacini_l.tip_knjizenja',_ponuda.nacin_leas,'nacini_l.nacin_leas'))=='1',.t.,.f.)

, CASE WHEN nacini_l.tip_knjizenja = 1 THEN 1 ELSE 0 END AS je_oper

akondep
iif(!je_oper,_ponuda.prv_obr,_ponuda.varscina) za FL i prv_obr, za OL je varscina

iif(je_oper,0,akondep)
+_ponuda.ost_obr*_ponuda.st_obrok
+ iif(je_oper,0,_ponuda.opcija)

*NOVO
	, CASE WHEN nacini_l.tip_knjizenja == 1 THEN 0 ELSE pon.prv_obr + pon.opcija END 
	+ ROUND(pon.ost_obr * pon.st_obrok, 2)  
	AS vrijednost_ugovora



 CASE WHEN nacini_l.tip_knjizenja != 1 THEN pon.prv_obr ELSE pon.varscina END AS akondep
	--iif(je_oper,0,akondep/iif(_ponuda.dobrocno=.t.,(1+rpt_davek),1)) +_ponuda.ost_obr/iif(_ponuda.dobrocno=.t.,(1+rpt_davek),1)*_ponuda.st_obrok+iif(je_oper,0,_ponuda.opcija/iif(_ponuda.dobrocno=.t.,(1+rpt_davek),1)
	--za OL je 0, za ostale je znači FL; dobrocno se može izbaciti iz izračuna
	, CASE WHEN nacini_l.tip_knjizenja != 1 THEN pon.prv_obr ELSE pon.varscina END 
		+  ROUND(pon.ost_obr * pon.st_obrok, 2)  
	AS vrijednost_ugovora







"Plaćanje na početku ("+iif(_ponuda.varscina>0,"jamčevina, ","")
+iif(_ponuda.prv_obr>0,"akontacija",iif(_ponuda.ddv>0,", ",""))
+iif(_ponuda.ddv>0,"PDV","")
+" i trošak obrade):"


iif(_odobrit.id_frame#0, gstr(cur_frame_list.velja_do)
, iif(empty(_odobrit.dat_pricak) or isnull(_odobrit.dat_pricak), '90 DANA', '90 dana ili do '+dtoc(_odobrit.dat_pricak))


ZANIMANJE KLIJENTA: {odobrit.partner_poklic.Trim()})
POSLODAVAC: {odobrit.partner_delodajale.Trim()}
IMOVINA U VLASNIŠTVU: {Format("{0:N2}", odobrit.bilans_kapital)} {odobrit.bilans_id_val_bil} ({odobrit.bilans_opis_kapital.Trim()})
UKUPNI PRIHODI: {Format("{0:N2}", odobrit.bilans_prihodki)} {odobrit.bilans_id_val_bil}
JOŠ DOZVOLJENO TEREĆENJE: {Format("{0:N2}, odobrit.bilans_ap_max - odobrit.bilans_odhodki)} {odobrit.bilans_id_val_bil}

LEFT JOIN (SELECT a.*, b.id_val AS id_val_bil FROM 
			(SELECT ROW_NUMBER() OVER (PARTITION BY id_kupca order by datum_bil DESC) br_retka
			, id_kupca, datum_bil, prihodki, kapital, opis_kapital, id_tec_bil, fprihodki, ap_max, odhodki 
			FROM dbo.gv_PBilanc_LastBilanc) a
			LEFT JOIN dbo.tecajnic b ON a.id_tec_bil = b.id_tec
			WHERE a.br_retka = 1
			
			dbo.gv_PBilanc_LastBilanc
			
			) bilans ON a.id_kupca = bilans.id_kupca
			
			
			select * from nacini_l

select dat_pricak,* from odobrit where dat_pricak is not null

select * from dbo.gv_PBilanc_LastBilanc

sp_helptext gv_PBilanc_LastBilanc

<font size="3">&nbsp;</font>



