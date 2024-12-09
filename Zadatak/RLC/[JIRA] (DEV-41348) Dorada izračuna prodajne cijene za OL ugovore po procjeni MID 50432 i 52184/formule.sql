--/////////////////////////////////////////////////////
-- SKRIPTE ZA PRODUKCIJU

-- kad potvrde ponudu
--update dbo.custom_settings set val = '1' where code = 'Nova.LE.PonPredOdkup_ShowSum_CostsDifference' -- bilo 0

Igor Puček 13.7.2023 8:14:07
- Dodao sam barcode na sve ispise, kod prebacivanja ispisa na produkciju samo page header u kojem je barcode staviti enabled - false 
IP podešeno na PROD MR 50220


MK nisu prebačena 3 ispisa, 
INFORMATIVNI IZRAČUN PRODAJNE CIJENE  
PONUDA PREOSTALA VRIJEDNOST/NEDOSPJELA GLAVNICA   
PONUDA ZA PRIJEVREMENI OTKUP

prebačeni su 
Predobračun za prodaju objekta leasinga
PONUDA ZA PRIJEVREMENI OTKUP - NOVI KUPAC  

--/////////////////////////////////////////////////////
-- KOMENTARI I SKRIPTE
PON_PRED_SSOFT_RLC

zamjeniti EUR i con4prov, te varijable koje sadrže str_sod

77210
77199 i 77198

select * from dbo.custom_settings where code = 'Nova.LE.PonPredOdkup_ShowSum_CostsDifference'
--update dbo.custom_settings set val = '1' where code = 'Nova.LE.PonPredOdkup_ShowSum_CostsDifference' -- bilo 0


select top 200 dbo.gfn_Id_pog4Id_cont(id_cont) as id_pog, * from dbo.pon_pred_odkup 
where id_cont = 65971
order by id_pon_pred_odkup desc



select top 200 dbo.gfn_Id_pog4Id_cont(id_cont) as id_pog, * from dbo.pon_pred_odkup 
where id_cont = dbo.gfn_Id_cont4Id_pog('65014/21')
order by id_pon_pred_odkup desc



novi ispis Predobračun za prodaju objekta leasinga 
nisam podesio dvojno prikazivanje
{Format("{0:N2}", (pon_pred_odkup.str_vrac_kas - pon_pred_odkup.ppmv)/(1+(pon_pred_odkup.davek/100)))}

dodatne_terjatve Dodatna potraž. sam maknuo iz formula 
INFORMATIVNI IZRAČUN PRODAJNE CIJENE 
Predobračun za prodaju objekta leasinga

Stavka "Razlika dodatnih troškova" se prikazuje samo ako je različito od 0.

netreba posebno napominjati jer su tako tražili
Na ispisu 
INFORMATIVNI IZRAČUN PRODAJNE CIJENE 
Predobračun za prodaju objekta leasinga
se iznos dodatnih potraživanja sada prikazuje u zasebnoj stavci "Dodatna potraž." pa sam doradio formule da se više ne koristi taj iznos u izračunu stavke "UKUPNO ZA PLAĆANJE:" tj. "PREOSTALA VRIJEDNOST OBJEKTA LEASINGA SA PDV i
PPMV:"


Predobračun za prodaju objekta leasinga
Da li stavka Manupulativni troškovi ulaze u zbroj za Ukupno tj. za Preostala vrijednost objekta leasinga bez PDV za ispis Predobračun za prodaju objekta leasinga?
Usporedba PONUDA PREOSTALA VRIJEDNOST/NEDOSPJELA GLAVNICA i Predobračun za prodaju objekta leasinga 


PON_PRED_SSOFT_RLC
Ukupno
{IIF(cont4prov.PDV_u_rati==1,Format("{0:N2}", NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum),Format("{0:N2}", NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.pog_davek/100))-NEZAPADLO.robresti_Sum))}

-- NOVO
{IIF(cont4prov.PDV_u_rati==1,Format("{0:N2}", NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum),Format("{0:N2}", NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.pog_davek/100))-NEZAPADLO.robresti_Sum))}


{cont4prov.id_dav_st} % PDV
{IIF(cont4prov.PDV_u_rati==1,Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)), Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)))}

-- NOVO
{IIF(cont4prov.PDV_u_rati==1,Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)), Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)))}


( od osnove {IIF(cont4prov.PDV_u_rati!=1,NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum,NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.pog_davek/100))-NEZAPADLO.robresti_Sum)} {cont4prov.id_val.Trim()} )

-- NOVO
( od osnove {IIF(cont4prov.PDV_u_rati!=1,NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum,NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.pog_davek/100))-NEZAPADLO.robresti_Sum)} {cont4prov.id_val.Trim()} )

UKUPNO SA PDV
{IIF(cont4prov.PDV_u_rati!=1,Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)+(NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)),Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)+ (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)))}

-- NOVO
{IIF(cont4prov.PDV_u_rati!=1,Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)+(NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)),Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)+ (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)))}

UKUPNO ZA PLAĆANJE
{IIF(cont4prov.PDV_u_rati!=1,Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)+(NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)+NEZAPADLO.robresti_Sum),Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)+ (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)+NEZAPADLO.robresti_Sum))}

-- NOVO
{IIF(cont4prov.PDV_u_rati!=1,Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)+(NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)+NEZAPADLO.robresti_Sum),Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)+ (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)+NEZAPADLO.robresti_Sum))}


{IIF(cont4prov.PDV_u_rati==1,"Za plaćanje UKUPNO", "UKUPNO DOSPJELI DUG PRIMATELJA LEASINGA")}
{IIF(cont4prov.PDV_u_rati!=1,Format("{0:N2}", OfferResultSum.zam_obr_Sum+ZE_ZAPADLO.net_val_Sum),Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)+ (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)+OfferResultSum.zam_obr_Sum+ZE_ZAPADLO.net_val_Sum))}
--NOVO
{IIF(cont4prov.PDV_u_rati!=1,Format("{0:N2}", OfferResultSum.zam_obr_Sum+ZE_ZAPADLO.net_val_Sum+cont4prov.dodatne_ter),Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)+ (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)+OfferResultSum.zam_obr_Sum+ZE_ZAPADLO.net_val_Sum))}

--NOVO 06.09.2023
{IIF(cont4prov.PDV_u_rati!=1,Format("{0:N2}", OfferResultSum.zam_obr_Sum+ZE_ZAPADLO.net_val_Sum+cont4prov.dodatne_ter_bruto), Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter_bruto+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)+ (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter_bruto+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)+OfferResultSum.zam_obr_Sum+ZE_ZAPADLO.net_val_Sum))}


FL
{IIF(cont4prov.PDV_u_rati==1,"Za plaćanje UKUPNO", "UKUPNO DOSPJELI DUG PRIMATELJA LEASINGA")}
{IIF(cont4prov.PDV_u_rati!=1,Format("{0:N2}", OfferResultSum.zam_obr_Sum+ZE_ZAPADLO.net_val_Sum),Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter_bruto+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100)))+ (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter_bruto+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100)))*(cont4prov.id_dav_st/100)+OfferResultSum.zam_obr_Sum+ZE_ZAPADLO.net_val_Sum))}



{IIF(cont4prov.PDV_u_rati!=1,Format("{0:N2}",EUR.DOSPJELI_DUG_NE_U_RATI_RES_AMOUNT)+ " " + EUR.DOSPJELI_DUG_NE_U_RATI_ID_VAL,Format("{0:N2}",EUR.DOSPJELI_DUG_U_RATI_RES_AMOUNT)+ " " + EUR.DOSPJELI_DUG_U_RATI_ID_VAL)} prema tečaju konverzije {IIF(cont4prov.PDV_u_rati!=1,Format("{0:N5}",EUR.DOSPJELI_DUG_NE_U_RATI_RES_EXCH),Format("{0:N5}",EUR.DOSPJELI_DUG_U_RATI_RES_EXCH))}


Ukupno FL
{IIF(cont4prov.PDV_u_rati==1,Format("{0:N2}", NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))),Format("{0:N2}", NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.pog_davek/100))))}
-- NOVO
{IIF(cont4prov.PDV_u_rati==1,Format("{0:N2}", NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))),Format("{0:N2}", NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.pog_davek/100))))}

PDV
{IIF(cont4prov.PDV_u_rati==1,Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)), Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)))}

-- NOVO
{IIF(cont4prov.PDV_u_rati==1,Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)), Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)))}


( od osnove {IIF(cont4prov.PDV_u_rati==1,Format("{0:N2}",NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))),Format("{0:N2}",NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.pog_davek/100))))} {cont4prov.id_val.Trim()} )
-- NOVO
( od osnove {IIF(cont4prov.PDV_u_rati==1,Format("{0:N2}",NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))),Format("{0:N2}",NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.pog_davek/100))))} {cont4prov.id_val.Trim()} )

UKUPNO SA PDV
{IIF(cont4prov.PDV_u_rati==1,Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)))+(NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)),Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100)))+ (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100)))*(cont4prov.id_dav_st/100)))}
-- NOVO
{IIF(cont4prov.PDV_u_rati==1,Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)))+(NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)),Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100)))+ (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100)))*(cont4prov.id_dav_st/100)))}

UKUPNO ZA PL- PRODAJNA CIJENA ZA NOVOG KUPCA
{IIF(cont4prov.PDV_u_rati!=1,Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)+(NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)+NEZAPADLO.robresti_Sum),Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)+ (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+cont4prov.dodatne_ter+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)+NEZAPADLO.robresti_Sum))}
--NOVO
{IIF(cont4prov.PDV_u_rati!=1,Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)+(NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)+NEZAPADLO.robresti_Sum),Format("{0:N2}", (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)+ (NEZAPADLO.VOPC_disk_vred_Sum+OfferResultSum.varscina2_Sum+cont4prov.str_odv_s_pdv+cont4prov.str_sod+cont4prov.str_man_s_pdv+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100))+((OfferResultSum.varscina2_Sum + NEZAPADLO.VOPC_disk_vred_Sum) * (cont4prov.str_proc/100)*(cont4prov.id_dav_st/100))-NEZAPADLO.robresti_Sum)*(cont4prov.id_dav_st/100)+NEZAPADLO.robresti_Sum))}



(CA-VO) Pregled ponuda za prijevremeni otkup s PPMV-om                                              

Rb	Type	ToCheck	IdForm	RepName	RepKey	RepType
1	MRT reports	str_vrac_kas		PON_DOPIS_SSOFT_RLC           	PON_DOPIS_SSOFT_RLC           	MRT
2	MRT reports	str_vrac_kas		PON_PRE_VRIJED_SSOFT_RLC      	PON_PRE_VRIJED_SSOFT_RLC      	MRT
3	MRT reports	str_vrac_kas		PON_PRED_OBR_SSOFT_RLC        	PON_PRED_OBR_SSOFT_RLC        	MRT
4	MRT reports	str_vrac_kas		PON_PRED_ODK_SSOFT_RLC        	PON_PRED_ODK_SSOFT_RLC        	MRT
5	MRT reports	str_vrac_kas		PON_PRED_SSOFT_NK_RLC         	PON_PRED_SSOFT_NK_RLC         	MRT
6	MRT reports	str_vrac_kas		PON_PRED_SSOFT_RLC            	PON_PRED_SSOFT_RLC            	MRT
7	MRT reports	str_vrac_kas		SED_IZJAVA_ODJ_SSOFT          	SED_IZJAVA_ODJ_SSOFT          	MRT
8	MRT reports	str_vrac_kas		ZAP_PPROD_SSOFT_RLC           	ZAP_PPROD_SSOFT_RLC           	MRT
9	Special reports / Select	str_vrac_kas		(CA-VO) Pregled ponuda za prijevremeni otkup s PPMV-om                                              	(CA-VO) Pregled ponuda za prijevremeni otkup s PPMV-om                                              	FOX
10	SQL Server objects	SQL_STORED_PROCEDURE	SQL Server	grp_offer_prior_redemption	grp_offer_prior_redemption	SQL_STORED_PROCEDURE

Pregledi| Sadašnja vrijednost ugovora|Ponuda za prijevremni zaključak s mogućnošću spremanja
Pregledi | Sadašnja vrijednost ugovora | Ponuda za prijevremeni otkup s mogućnošću spremanja
Pregledi | Sadašnja vrijednost ugovora | Ponuda za prijevremeni otkup s mogućnošću spremanja
Pregledi| Sadašnja vrijednost ugovora|Ponuda za prijevremni zaključak s mogućnošću spremanja
Pregledi| Sadašnja vrijednost ugovora|Ponuda za prijevremni zaključak s mogućnošću spremanja
Pregledi | Sadašnja vrijednost ugovora | Ponuda za prijevremeni otkup s mogućnošću spremanja
Pregledi | Sadašnja vrijednost ugovora | Ponuda za prijevremeni otkup s mogućnošću spremanja
Pregledi| Sadašnja vrijednost ugovora|Ponuda za prijevremni zaključak s mogućnošću spremanja
Pregledi | Sadašnja vrijednost ugovora | Ponuda za prijevremeni otkup s mogućnošću spremanja
Pregledi | Sadašnja vrijednost ugovora | Ponuda za prijevremeni otkup s mogućnošću spremanja
Pregledi| Sadašnja vrijednost ugovora|Ponuda za prijevremni zaključak s mogućnošću spremanja


ZAPISNIK O PRIMOPREDAJI PRILIKOM PROD. -Stimulsoft	ZAP_PPROD_SSOFT_RLC           
PONUDA ZA PRIJEVREMENI OTKUP - Stimulsoft- RLC    	PON_PRED_SSOFT_RLC            
PONUDA PREOSTALA VRIJEDNOST/NEDOSPJELA GLAVNICA   	PON_PRE_VRIJED_SSOFT_RLC      
IZJAVA O OBVEZI ODJAVE VOZILA Stimulsoft          	SED_IZJAVA_ODJ_SSOFT          
INFORMATIVNI IZRAČUN PRODAJNE CIJENE - SSOFT      	PON_PRED_ODK_SSOFT_RLC        
PONUDA ZA PRIJEVREMENI OTKUP - NOVI KUPAC - Stimul	PON_PRED_SSOFT_NK_RLC         
PONUDA ZA PRIJEVREMENI OTKUP                      	PON_PRED_SSOFT_RLC            
INFORMATIVNI IZRAČUN PRODAJNE CIJENE              	PON_PRED_ODK_SSOFT_RLC        
PONUDA ZA PRIJEVREMENI OTKUP - NOVI KUPAC         	PON_PRED_SSOFT_NK_RLC         
Pojašnjenja klijentima kod prekida OL ugovora     	PON_DOPIS_SSOFT_RLC           
Predobračun za prodaju objekta leasinga           	PON_PRED_OBR_SSOFT_RLC        


ZAPISNIK O PRIMOPREDAJI PRILIKOM PROD. -Stimulsoft	ZAP_PPROD_SSOFT_RLC           
PONUDA PREOSTALA VRIJEDNOST/NEDOSPJELA GLAVNICA   	PON_PRE_VRIJED_SSOFT_RLC      
IZJAVA O OBVEZI ODJAVE VOZILA Stimulsoft          	SED_IZJAVA_ODJ_SSOFT          
PONUDA ZA PRIJEVREMENI OTKUP                      	PON_PRED_SSOFT_RLC            
INFORMATIVNI IZRAČUN PRODAJNE CIJENE              	PON_PRED_ODK_SSOFT_RLC        
PONUDA ZA PRIJEVREMENI OTKUP - NOVI KUPAC         	PON_PRED_SSOFT_NK_RLC         
Pojašnjenja klijentima kod prekida OL ugovora     	PON_DOPIS_SSOFT_RLC           
Predobračun za prodaju objekta leasinga           	PON_PRED_OBR_SSOFT_RLC        