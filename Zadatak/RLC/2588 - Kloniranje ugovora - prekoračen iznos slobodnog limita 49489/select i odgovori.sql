Poštovana/i, 

kontrolu bi napravili kod promjene statusa na Odobreno, da se provjerava iznos okvira po istoj logici kako je kod unosa broja okvira na dobrenju. Iznos za limit bi se onda izračunavao pomnožen s brojem maksimalnih kloniranja unesenm u polje "Maks. br. kloniranja" npr. ako je "Maks. br. kloniranja" = 5, onda bi iznos za provjeru bio 5 puta veći od iznosa za to odobrenje/ponudu. 
Odobrenje bi moralo imati unesen broj okvira da bi se kontrola pokretala. Takvom odobrenju bi bilo onemogućeno napraviti promjenu statusa na Odobreno.

U privitku vam šaljemo ponudu izradu navedene kontrole.
Zadnja stavka ponude "Pomoć korisnicima kod testiranja i nepredviđene situacije" će se naplatiti prema stvarnom utrošenom vremenu ako do njih dođe.

$SIGN

rlc, pripremio ponudu. Malo mi se odužila analiza jer sam se fokusirao na logiku kako je na kod unosa ugovora, i kad sam skužio da može, išao još nekaj testirati na odobrenju i vidim da je i tamo ta kontrola  tako da to sigurno može. 
http://gmcv03/support/Maintenance.aspx?ID=49489&Tab=Progress




PROCEDURE tabMain.Page6.txtId_frame.Valid
		LOCAL llVrni, lcTabela, lcFields, laHeader[6], lcId_dav_st, lcListIdPoroka
		
		WITH This
			llVrni = .T.
			IF !(EMPTY(.Value) OR ISNULL(.Value)) THEN
			
				* del kode dodan zaradi novega polja na maski za okvirje "Okvir se lahko črpa s pogodbami, kjer je nosilec okvira porok" 
				* poroke vzamemo iz kurzorja _porok - zaradi tega ni potrebe za pošiljanjem parametra {3} - id_cont
				SELECT _porok
				LOCATE 
				IF RECCOUNT("_porok") > 0
					lcListIdPoroka = GF_CreateDelimitedList("_porok", "id_poroka", "", ",")
				ELSE 
				 	lcListIdPoroka = ""
				ENDIF	
		
				lcTabela = "gfn_FrameSelect('{0}', {1}, {2}, null, '{4}')"
					
				lcTabela = STRTRAN(lcTabela, "{0}", _odobrit.id_kupca)
				lcTabela = STRTRAN(lcTabela, "{1}", TRANSFORM(Thisform.tip_vnosne_maske))
				lcTabela = STRTRAN(lcTabela , "{2}", TRANSFORM(thisform.id_frame_original))
				lcTabela = STRTRAN(lcTabela , "{4}", lcListIdPoroka)
				
				lcFields = "id_frame,opis,id_kupca,dat_odobritve,status_akt,sif_frame_type"
				laHeader[1] = "Okvir" && Caption
				laHeader[2] = "Opis" && Caption
				laHeader[3] = "Partner" && Caption
				laHeader[4] = "Dat. odobritve" && Caption
				laHeader[5] = "Status akt." && Caption
				laHeader[6] = "Tip črpanja" && Caption
				
				llVrni = GF_OBSTOJA(lcTabela , "id_frame", .Value, lcFields, @laHeader, "frame_list", "") 
		
				IF llVrni = .T. THEN
					.Parent.txtId_frame.Value = frame_list.id_frame
					.Parent.txtOpis_frame.Value = frame_list.opis
					.Parent.txtVelja_do.Value = frame_list.velja_do
					.Parent.txtDat_izteka.Value = frame_list.dat_izteka
		
					* Prepare data for frame availability check
					SELECT _odobrit
					lcId_dav_st = GF_LOOKUP("ponudba.id_dav_st", _odobrit.id_pon, "ponudba.id_pon")
					LOCATE
					SELECT id_kupca, DATE() AS dat_sklen, id_tec, vr_val, net_nal, vr_val as vr_val_zac, net_nal as net_nal_zac, vr_val_val AS id_val, lcId_dav_st as id_dav_st, nacin_leas, man_str, stroski_x, stroski_pz, stroski_zt, zav_fin, 0 as str_financ, robresti_val, Znesek_DDV as ddv, MPC;
					  FROM _odobrit INTO CURSOR _contract NOFILTER
		
					SELECT _contract
					SCATTER MEMO NAME loContract
					USE IN _contract
					
					SELECT frame_list
					SCATTER MEMO NAME loFrameList
					USE IN frame_list
		
					* Check frame availability for contract
					llVrni = GF_CheckFrameAvailabilityForContract(loContract, loFrameList)
		
				ENDIF
			ELSE
				.Parent.txtOpis_frame.Value = "Ni opredeljen"  && Caption
				.Parent.txtVelja_do.Value = CTOD("  .  .    ")
				.Parent.txtDat_izteka.Value = CTOD("  .  .    ")
			ENDIF 
		ENDWITH
		RETURN llVrni


kod odabira okvira na ugovoru kontrolu radi GF_CheckFrameAvailabilityForContract
kod kloniranja ugovora postoji kontrola na broj kloniranih ugovora
select * from dbo.custom_settings where code = 'Nova.Le.ContractCloner.CheckOdobritMax'
select top 100 max_st_kloniranj, * from dbo.odobrit order by id_odobrit  desc
Praktički bi se to moglo zaobići ako se klonira dva puta, ako je moguće dva puta klonirati jedan ugovor
Bolje da možda su kreirali ext_func u kojemu da se naprave sve custom kontrole...

kontrolu je moguće podesiti u dvij ext_func LE_ODOBRIT_PUSH_PREVERI_PODATKE_CUSTOM i LE_ODOBRIT_PUSH_PREVERI_MULTIPLE_PODATKE_CUSTOM

treba još s RLC definirati kako će to biti za flote, možda max_st_kloniranj * iznos iskorištenosti?

da li samo kontrola ili da i na pregledu korištenosti okvira se ta iskoristivost prikazuje (npr. ako odobrenje ima ugovor, gledaju se samo podaci s ugovora a ako odobrenje nema ugovor onda samo s odobrenja) => NE TREBA

Testirao u FOXu i moće se dobiti. Objekt loContract se popuni s podacima s ponude umjesto s ugovora. Primjer ispod
NOVA_TEST na RLC
** FOX skripta za testiranje
GF_SQLEXEC("select *, dat_pon as dat_sklen from dbo.ponudba where id_pon = '0267269'", "pogodba")
select * from pogodba
SELECT pogodba
SCATTER MEMO NAME loContract
* SCATTER FIELDS EXCEPT id_cont NAME loPonudba

TEXT TO lcSQL NOSHOW
SELECT l.id_frame, l.opis, l.id_kupca, l.dat_odobritve, l.status_akt, t.sif_frame_type, l.velja_do, l.dat_izteka  
FROM dbo.frame_list l  
INNER JOIN frame_type t ON l.frame_type = t.id_frame_type   
WHERE t.sif_frame_type IN ('POG', 'REV', 'NET', 'RFO', 'RNE', 'MPC')
and id_frame = 2379
ENDTEXT
GF_SQLEXEC(lcSQL , "frame_list")
select * from frame_list
SELECT frame_list
SCATTER MEMO NAME loFrameList
USE IN frame_list
llVrni = GF_CheckFrameAvailabilityForContract(loContract, loFrameList)
obvesti(trans(llVrni ))

U slučaju više odobrenja, trebalo bi iznose pomnožiti 

id_cont, id_tec, id_val, dat_sklen, vr_val, nacin_leas, id_dav_st, robresti_val, man_str, stroski_x, stroski_pz + stroski_zt + zav_fin + str_financ, net_nal_zac, vr_val_zac, ddv, mpc


** FOX skripta za testiranje 2
TEXT TO lcSQL NOSHOW
	select id_kupca, id_cont as id_cont_pon
	, dat_pon as dat_sklen
	, 0 as id_cont
	, id_tec, id_val, vr_val, nacin_leas, id_dav_st, robresti_val, man_str, stroski_x, stroski_pz + stroski_zt + zav_fin + str_financ
	, net_nal as net_nal_zac, vr_val as vr_val_zac, ddv
	, vr_bruto * dbo.gfn_VrednostTecaja(id_tec, dat_pon) as mpc
	, vr_bruto 
from dbo.ponudba where id_pon = '0267269'
ENDTEXT
GF_SQLEXEC(lcSQL, "_ef_ponudba")
? TYPE("_ef_ponudba.id_cont")
select * from _ef_ponudba
SELECT _ef_ponudba
SCATTER MEMO NAME loContract
?obvesti(TYPE("toContract.id_cont") )
* SCATTER FIELDS EXCEPT id_cont NAME loPonudba

TEXT TO lcSQL NOSHOW
SELECT l.id_frame, l.opis, l.id_kupca, l.dat_odobritve, l.status_akt, t.sif_frame_type, l.velja_do, l.dat_izteka  
FROM dbo.frame_list l  
INNER JOIN frame_type t ON l.frame_type = t.id_frame_type   
WHERE t.sif_frame_type IN ('POG', 'REV', 'NET', 'RFO', 'RNE', 'MPC')
and id_frame = 2379
ENDTEXT
GF_SQLEXEC(lcSQL , "frame_list")
select * from frame_list
SELECT frame_list
SCATTER MEMO NAME loFrameList
USE IN frame_list
llVrni = GF_CheckFrameAvailabilityForContract(loContract, loFrameList)
obvesti(trans(llVrni ))

KONTROLA DA SADRŽAVA DA LI JE NA TEMELJU PONUDE NAPRAVLJEN UGOVOR

Ranije komentari:
lcFrameType = "REV" OR lcFrameType = "RFO" OR lcFrameType = "RNE"
ide obligo (DNP i buduća glavnica) iz planp_ds pa iznos neće biti ok NOT OK
ali to je za popravak postojećeg ugovora jer gleda id_cont koji u trenutku unosa ugovora nije poznat, ali kod provjere samog odobrenja bi trebalo biti u redu

gfn_GetFrameResidual gleda podatke s ugovora, znači već odobrena odobrenja neće gledati i neće biti ok NOT OK
samo za par tipova okvira bi bilo ok jer koriste podatke s objekta loContract


