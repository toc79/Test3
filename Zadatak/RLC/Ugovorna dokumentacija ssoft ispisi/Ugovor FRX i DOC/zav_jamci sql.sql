DECLARE @id varchar(100)
SET @id = 56106


Declare @dav_stev as varchar(25), @naz_kr_kup as varchar(80), @ulica_sed as varchar(70), @vr_osebe as char(2)
Declare @id_poste_sed as varchar(70), @mesto_sed as varchar(25), @direktor as varchar(100), @stev_reg as varchar(100), @dat_sklen as datetime
Declare @svi_jamci varchar(max), @broj_jamaca as int

Set @svi_jamci = ''
Set @broj_jamaca = 0

declare tmp_j cursor For
Select p.dav_stev, p.naz_kr_kup, p.ulica_sed, p.vr_osebe, p.id_poste_sed, 
	p.mesto_sed, p.direktor, p.stev_reg, o.dat_sklen 
	From dbo.pogodba o 
INNER JOIN dbo.pog_poro g ON o.id_cont=g.id_cont
INNER JOIN dbo.partner p ON g.id_poroka=p.id_kupca 
Where o.id_cont= @id
ORDER BY g.oznaka ASC

open tmp_j
Fetch next from tmp_j into @dav_stev, @naz_kr_kup, @ulica_sed, @vr_osebe, @id_poste_sed, @mesto_sed, @direktor, @stev_reg, @dat_sklen
while @@fetch_status = 0 
begin
print @@fetch_status
set @svi_jamci = @svi_jamci + LTRIM(RTRIM(@naz_kr_kup))+', '+LTRIM(RTRIM(@ulica_sed))+', '+LTRIM(RTRIM(@id_poste_sed))+' '+LTRIM(RTRIM(@mesto_sed)) 
	+ CASE WHEN LEN(@dav_stev) = 11 THEN ', OIB: '+LTRIM(RTRIM(@dav_stev)) ELSE '' END 
	+ CASE WHEN @vr_osebe = 'SP' THEN ', MBO: '+LTRIM(RTRIM(@stev_reg)) ELSE '' END
	+ CASE WHEN LEN(LTRIM(RTRIM(@direktor))) <> 0 THEN ', zastupan po ' +LTRIM(RTRIM(@direktor)) ELSE '' END --'FD' vrsta osobe ne postoji na RLC
	--+ CHAR(10)+CHAR(13) Dodano ispod
Fetch next from tmp_j into @dav_stev, @naz_kr_kup, @ulica_sed, @vr_osebe, @id_poste_sed, @mesto_sed, @direktor, @stev_reg, @dat_sklen
IF @@fetch_status = 0 
BEGIN
	SET @svi_jamci = @svi_jamci +CHAR(10)+CHAR(13) 
END

Set @broj_jamaca = @broj_jamaca + 1

end
close tmp_j
deallocate tmp_j

Select @svi_jamci as svi_jamci, @broj_jamaca as broj_jamaca 


***********************************************
*25.05.2006 Nenad Milevoj ispisuje sve jamce za jedan ugovor
*27.11.2009 Tomislav Krnjak: dodan je OIB
*03.02.2010 Tomislav Krnjak: dodano da za vr_osebe=SP ispisuje 'MBO:' i stev_reg
FUNCTION RF_JAMCI(lcid_cont)
	IF ISNULL(lcid_cont) OR EMPTY(lcid_cont) THEN
		RETURN "GREŠKA"
	ENDIF
	LOCAL lcResult, lcOldAlias
	lcOldAlias = nvl(alias(),'')
	LOCAL x
	lcResult=""
	
	GF_SQLEXEC("Select CASE WHEN vr_osebe<>"+GF_QuotedStr("FO")+" THEN "+GF_QuotedStr("MB: ")+"+ p.emso ELSE "+GF_QuotedStr("JMBG: ")+"+ p.emso END as emso,p.dav_stev,p.naz_kr_kup,p.ulica_sed,p.vr_osebe,p.id_poste_sed,p.mesto_sed,p.direktor,p.stev_reg, o.dat_sklen From pogodba o INNER JOIN POG_PORO g ON o.id_cont=g.id_cont INNER JOIN PARTNER p ON g.id_poroka=p.id_kupca Where o.id_cont="+str(lcid_cont)+" ORDER BY g.oznaka ASC","_cur1")
	select _cur1
	go top
	x=1
	scan
	
	lcResult=lcResult+allt(_cur1.naz_kr_kup)+", "+allt(_cur1.ulica_sed)+", "+allt(_cur1.id_poste_sed)+" "+allt(_cur1.mesto_sed)+iif(LEN(allt(_cur1.dav_stev))=11,", OIB: "+alltr(_cur1.dav_stev),"")+iif(_cur1.vr_osebe='SP',', MBO: '+allt(_cur1.stev_reg),iif(RF_PRINT_MB()>_cur1.dat_sklen,+', '+allt(_cur1.emso),""));
	+iif(!empty(_cur1.direktor),iif(_cur1.vr_osebe="FD",", vlasnik ",", zastupan po ")+allt(_cur1.direktor),"")+chr(13)
	x=x+1
	endscan
	if !empty(lcOldAlias) 
	select (lcOldAlias) 
	endif
	RETURN lcResult
ENDFUNC


Declare @dav_stev as varchar(25), @naz_kr_kup as varchar(80), @ulica_sed as varchar(70), @vr_osebe as char(2)
Declare @id_poste_sed as varchar(70), @mesto_sed as varchar(25), @direktor as varchar(100), @stev_reg as varchar(100), @dat_sklen as datetime
Declare @svi_jamci varchar(max), @broj_jamaca as int

Set @svi_jamci = ''
Set @broj_jamaca = 0

declare tmp_j cursor For
Select p.dav_stev, p.naz_kr_kup, p.ulica_sed, p.vr_osebe, p.id_poste_sed, 
	p.mesto_sed, p.direktor, p.stev_reg, o.dat_sklen 
	From dbo.pogodba o 
INNER JOIN dbo.pog_poro g ON o.id_cont=g.id_cont
INNER JOIN dbo.partner p ON g.id_poroka=p.id_kupca 
Where o.id_cont= @id
ORDER BY g.oznaka ASC

open tmp_j
Fetch next from tmp_j into @dav_stev, @naz_kr_kup, @ulica_sed, @vr_osebe, @id_poste_sed, @mesto_sed, @direktor, @stev_reg, @dat_sklen
while @@fetch_status = 0 
begin
set @svi_jamci = @svi_jamci + LTRIM(RTRIM(@naz_kr_kup))+', '+LTRIM(RTRIM(@ulica_sed))+', '+LTRIM(RTRIM(@id_poste_sed))+' '+LTRIM(RTRIM(@mesto_sed)) + 
CASE WHEN LEN(@dav_stev)=11 THEN ', OIB: '+LTRIM(RTRIM(@dav_stev)) ELSE '' END + 
CASE WHEN (LEN(LTRIM(RTRIM(@direktor))) <> 0 AND @vr_osebe = 'FD') THEN ', vlasnik ' + LTRIM(RTRIM(@direktor))
	 WHEN (LEN(LTRIM(RTRIM(@direktor))) <> 0 AND @vr_osebe <> 'FD') THEN ', zastupan po ' + LTRIM(RTRIM(@direktor))
ELSE '' END + CHAR(10)+CHAR(13)
 Fetch next from tmp_j into @dav_stev, @naz_kr_kup, @ulica_sed, @vr_osebe, @id_poste_sed, @mesto_sed, @direktor, @stev_reg, @dat_sklen
Set @broj_jamaca = @broj_jamaca + 1
end
close tmp_j
deallocate tmp_j


Select @svi_jamci as svi_jamci, @broj_jamaca as broj_jamaca 