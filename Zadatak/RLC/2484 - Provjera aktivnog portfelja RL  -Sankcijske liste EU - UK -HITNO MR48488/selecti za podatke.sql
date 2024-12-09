dosadašnja provjera u NOVA radi tako da ako i IME se nalazi u nazivu osobe, javiti će se pogodak.
U BPMu radi samo po unesenom nazivu tako da ako su unijeli drugačiji redoslijed onda neće biti pogotka. Da li ostaviti takvu provjeru u BPMu?

SELECT  par.id_kupca, par.naz_kr_kup
	, b.*
	, par.drzavljan, par.drzavljanstvo, par.id_poste_sed, par.id_poste, par.*
from dbo.partner par
outer apply dbo.gfn_CheckInternationalBlackListSummary(par.id_kupca) b
where par.vr_osebe in ('F1','FO','FR','JS','OT','PD','R1','SP','SR')
and par.neaktiven = 0
and b.ZPPDFT_confirmation = 1
--order by par.id_kupca


<black_list_check xmlns='urn:gmi:nova:integration'><id_kupca>000147</id_kupca></black_list_check>

039576
************
<check_partner_blacklist xmlns='urn:gmi:nova:leasing'>
<id_kupca>000012</id_kupca>
</check_partner_blacklist>

 <!--provjera na aml_un_list gdje se nalazi lista terorista -->
  <shared_evaluators>
    <evaluator name="check_desc_aml_un_list" evaluator="nova_sql">
      <statement><![CDATA[
            if exists(select * from dbo.aml_un_list where ${global_customer_desc} != '' And name like +'%'+${global_customer_desc}+'%')
                      Select 'Da' as global_customer_desc_doubtful, 'Da' as global_mark_xc
            else
                      Select 'Ne' as global_customer_desc_doubtful
        ]]></statement>
    </evaluator>
    <!--provjera na aml_un_listi i ODS da li je adresa ili država na popisu sumnjivih država ili adresa check_adress_aml_un_list-->
    <evaluator name="check_adress_aml_un_list" evaluator="nova_sql">
      <statement><![CDATA[
           if exists(SELECT address as drzava FROM dbo.aml_un_list WHERE ${global_address} != '' And REPLACE(REPLACE(REPLACE(REPLACE(address,'č','c'),'ć','c'),'ž','z'),'š','s') LIKE +'%'+REPLACE(REPLACE(REPLACE(REPLACE(${global_address}, 'č', 'c'), 'ć', 'c'), 'ž', 'z'), 'š', 's')+'%')
              Select 'Da' as global_address_doubtful, 'Da' as global_mark_xc
            else
                      Select 'Ne' as global_address_doubtful
            
        ]]></statement>
    </evaluator>

-- IDEALNO BI BILO DA SE RADI PERMUTACIJA IMENA I PREZIMENA I OBJE KOMBINACIJE USPOREĐUJU S name . U SLUČAJU TRI IMENA I TRI PERMUTACIJE, A AKO JE name SAMO 2, ONDA BI SE PERMUTACIJA MORALA NAPRAVITI U PAROVIMA (VALJDA 3 PARA). POGODAK SAMO NA IME NIJE DOBRO


SELECT top 100 par.id_kupca, par.naz_kr_kup
	, b.*
from dbo.partner par
outer apply dbo.gfn_CheckInternationalBlackListSummary(par.id_kupca) b
order by par.id_kupca




select * 
into #aml_confirmed
from (
select top 100 dbo.gfn_CheckInternationalBlackList(par.id_kupca) as ZPPDFT_confirmation, par.id_kupca 
from dbo.partner par
) a
where ZPPDFT_confirmation = 1

select * 
from #aml_confirmed a
join dbo.partner par on a.id_kupca = par.id_kupca

sp_helptext grp_InternationalBlackLSearch 
sp_helptext gfn_IsOnBlackList
sp_helptext gfn_CheckInternationalBlackList
sp_helptext gfn_CheckInternationalBlackListSummary
 SET @res = (SELECT ZPPDFT_confirmation FROM [dbo].[gfn_CheckInternationalBlackListSummary](@id_kupca))  
go
select * from dbo.aml_un_list

select * from dbo.custom_settings where code = 'ZPPDFT_History'

select dbo.gfn_CheckInternationalBlackList(par.id_kupca), par.* 
from dbo.partner par

select * from dbo.partner where drzavljan = 'RU' or id_poste_sed like 'RU-' -- 11 partnera

select * from dbo.VRST_OSE where sifra != 'PO'

select * from dbo.aml_un_list order by cast(data_id as int) desc

***************************************************************************************
* Function: Check partner in ZPPDFT
* returns: true/false
* tcId_kupca: partner id
* tcNaziv1_kup: partner name
* tcUlica: partner address

FUNCTION GF_Partner_Check_ZPPDFT(tcId_kupca, tcNaziv1_kup, tcUlica)
	LOCAL lcXml, lcResult, lnSuccess
	IF VAL(GF_CustomSettings("ZPPDFT_CHECK")) = 1 THEN 	 
		WAIT WINDOW "Preverjam partnerja na mednarodnih listah...(ZPPDFT)! Prosim počakaj ..." + gcE + ALLTRIM(tcNaziv1_kup) NOWAIT
		lcXml = "<black_list_check xmlns='urn:gmi:nova:integration'>"
		lcXml = lcXml + GF_CreateNode("id_kupca", tcId_kupca, "C", 1) + gcE
		lcXml = lcXml + "</black_list_check>"
		IF !GF_ProcessXml(lcXml) THEN 
			obvesti("Neuspešno preverjanje mednarodnih list teroristov.")
		ELSE 
			lcResult = GOBJ_Comm.GetResult() 
			lnSuccess = XMLDataType(GF_GetSingleNodeXml(lcResult, "result"), "L", 2)
			
			IF (lnSuccess = .T.) THEN 
				IF potrjeno("Pri preverjanju je prišlo do zadetkov. Želite več informacij?") THEN 
					LOCAL laParams [2, 3]
					laParams [1, 1] = "N"
					laParams [1, 2] = "name"
					laParams [1, 3] = ALLTRIM(tcNaziv1_kup)
					laParams [2, 1] = "N"
					laparams [2, 2] = "address"
					laParams [2, 3] = ALLTRIM(tcUlica)
					DO international_blacklists WITH .T., .F., .T., laParams IN frmparams_pregledi_share
				ENDIF 
			ELSE 
				IF VAL(GF_CustomSettings("ZPPDFT_Notify")) = 1 THEN 
					obvesti("Ni zadetkov pri preverjanju.")
				ENDIF 
			ENDIF 
		ENDIF
	ENDIF 
ENDFUNC 