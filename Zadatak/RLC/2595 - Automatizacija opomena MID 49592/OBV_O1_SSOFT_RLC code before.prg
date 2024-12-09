LOCAL lnOdg, lnid_cont, lnId, lcSql

lnOdg = rf_msgbox("Pitanje","Želite li ispis svih ili trenutnog zapisa?","Svih","Trenutnog","Poništi")

Select '000000000000000000000000000' as kljuc From result where id_cont = -1  into cursor _ispis READWRITE

DO case
 CASE lnOdg = 2 && Trenutnega
  lnId_cont = result.id_cont
  select id_kupca, id_tec_s, dat_tec_s from result where oznacen = .t. and id_cont = lnId_cont INTO cursor rezultat
  select id_cont from result where oznacen = .t. and id_cont = lnId_cont INTO cursor rezultat2
  
  lcIdkupca = rezultat.id_kupca
  lcIdTec = rezultat.id_tec_s
  lcDatTec = rezultat.dat_tec_s
  lnId = GF_InsertSsoftReportXML("rezultat2", "frmppizbords5_group")
  
  lcKljuc = allt(lcIdkupca) + "$"+ allt(lcIdTec) + "$" + allt(lcDatTec) + "$" + allt(trans(lnId)) + "$"
  
  insert into _ispis(kljuc) values (allt(lcKljuc))
  
 CASE lnOdg = 1 && Vse
  select id_kupca, id_tec_s, dat_tec_s from result where oznacen = .t. group by id_kupca, dat_tec_s, id_tec_s INTO cursor rezultat
  
  sele rezultat
  go top 
  
  scan
    lcIdkupca = rezultat.id_kupca
  	lcIdTec = rezultat.id_tec_s
  	lcDatTec = rezultat.dat_tec_s
  	
  	select id_cont as id_cont from result where oznacen = .t. and id_kupca = allt(lcIdkupca) group by id_cont INTO cursor rezultat2
  	
  	lnId = GF_InsertSsoftReportXML("rezultat2", "frmppizbords5_group")
  
	lcKljuc = allt(lcIdkupca) + "$"+ allt(lcIdTec) + "$" + allt(lcDatTec) + "$" + allt(trans(lnId)) + "$"
  
	insert into _ispis(kljuc) values (allt(lcKljuc))
  endscan
  
  
 OTHERWISE
  RETURN .F.
ENDCASE

sele _ispis
IF reccount() = 0 THEN
	=POZOR("Nema podataka za ispis!")
	RETURN .F.
endif

**OBJ_ReportSelector.id_field = lnId
OBJ_ReportSelector.PrepareDataForMRT("_ispis", "kljuc")