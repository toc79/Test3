--sql
select a.inv_stev, a.datum_likvidacije, fa.dat_odpisa_datum, fa.id_fa
from dbo._za_likvidaciju a
inner join dbo.FA fa on a.inv_stev=fa.inv_stev
and fa.STATUS = 'O'
--and a.inv_stev='0026304'

*fox
select _za_likvidaciju
lnUkupno = reccount()
lnError = 0
go top 
scan
	LOCAL lcXml   &&, lnCnt, laCandidates[1]
	&&ACOPY(taId_fa, laCandidates)	
	&&IF ALEN(laCandidates) = 1 THEN
	laCandidates = _za_likvidaciju.id_fa
	tcDate = _za_likvidaciju.datum_likvidacije
	tcStorno = .F.
	
	lcXml = '<fa_liquidation xmlns="urn:gmi:nova:fa">' + gcE
	lcXml = lcXml + GF_CreateNode("id_fa", laCandidates, "I", 1) + gcE
	lcXml = lcXml + GF_CreateNode("date", tcDate, "D", 1) + gcE
	lcXml = lcXml + GF_CreateNode("storno", tcStorno , "L", 1) + gcE
	lcXml = lcXml + "</fa_liquidation>"

	IF !GF_ProcessXml(lcXml) THEN
		lnError = lnError +1
	ENDIF
endscan 

obvesti("ukupno: "+trans(lnUkupno)+gce+"greške: "+trans(lnError))



--7
--drop table dbo._za_likvidaciju
create table dbo._za_likvidaciju
(inv_stev char(7) not null, 
datum_likvidacije datetime not null)

INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0029715', '20200630')



--6
--drop table dbo._za_likvidaciju
create table dbo._za_likvidaciju
(inv_stev char(7) not null, 
datum_likvidacije datetime not null)

INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0031266', '20200630')



--4 i 5
--drop table dbo._za_likvidaciju
create table dbo._za_likvidaciju
(inv_stev char(7) not null, 
datum_likvidacije datetime not null)

INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026246', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026368', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0028900', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0029790', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0030155', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0031526', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0031646', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0028649', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0031397', '20200630')



--3

--drop table dbo._za_likvidaciju
create table dbo._za_likvidaciju
(inv_stev char(7) not null, 
datum_likvidacije datetime not null)

INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026242', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0028205', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0031506', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0033098', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0033796', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0033915', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0034962', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0035015', '20200630')


--1 i 2



--drop table dbo._za_likvidaciju
create table dbo._za_likvidaciju
(inv_stev char(7) not null, 
datum_likvidacije datetime not null)


INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0035031', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026304', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026787', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026786', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026785', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026784', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026783', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026782', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026781', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026780', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026779', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026778', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026777', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026776', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026775', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026774', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026773', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026772', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026771', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026770', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026769', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026768', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026767', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0028289', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0028312', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0028075', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0029787', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0030592', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0031516', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0031517', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0033773', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0033882', '20200630')

INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026284', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0026333', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0031819', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0032136', '20200630')
INSERT INTO dbo._za_likvidaciju (inv_stev, datum_likvidacije) VALUES ('0033155', '20200630')






29.06.2020 10:13:13:359	105	ProcessXml	Bl	[g_tomislav,192.168.23.206]	[d0714d31-293d-4a43-8ecb-14f9699866fd,FA]	<fa_liquidation xmlns="urn:gmi:nova:fa">  <id_fa>7</id_fa>  <date>2014-04-30T00:00:00.000</date>  <storno>false</storno>  </fa_liquidation>

lcTest = '<fa_liquidation xmlns="urn:gmi:nova:fa">  
<id_fa>8</id_fa>  
<date>2014-04-30T00:00:00.000</date>  
<storno>false</storno>  
</fa_liquidation>'

***************************************************************************************
* wrapper for SOAP call for residual value notifications preparation
* returns: true/false

FUNCTION GF_FA_Liquidation(taId_fa, tcDate as Datetime, tcStorno as Boolean) as Boolean

    IF PCOUNT() != 3 THEN 
        GF_NAPAKA(0,'GF_FA_Liquidation()','',LOWPARAMETERS_LOC,1)   
    ENDIF 

	LOCAL lcXml, lnCnt, laCandidates[1]
	ACOPY(taId_fa, laCandidates)	
	IF ALEN(laCandidates) = 1 THEN
	    lcXml = '<fa_liquidation xmlns="urn:gmi:nova:fa">' + gcE
	    lcXml = lcXml + GF_CreateNode("id_fa", laCandidates[1], "I", 1) + gcE
	    lcXml = lcXml + GF_CreateNode("date", tcDate, "D", 1) + gcE
	    lcXml = lcXml + GF_CreateNode("storno", tcStorno , "L", 1) + gcE
		lcXml = lcXml + "</fa_liquidation>"
	ELSE
		lcXml = '<fa_mass_liquidation xmlns="urn:gmi:nova:fa">' + gcE
		FOR lnCnt = 1 TO ALEN(laCandidates)
		    lcXml = lcXml + GF_CreateNode("id_fa", laCandidates[lnCnt], "I", 1) + gcE
		ENDFOR
		lcXml = lcXml + GF_CreateNode("date", tcDate, "D", 1) + gcE
	    lcXml = lcXml + "</fa_mass_liquidation>"
	ENDIF 
	
	IF !GF_ProcessXml(lcXml) THEN
		RETURN .F.
	ELSE
		RETURN .T.
	ENDIF
ENDFUNC
**************************************************************************************
