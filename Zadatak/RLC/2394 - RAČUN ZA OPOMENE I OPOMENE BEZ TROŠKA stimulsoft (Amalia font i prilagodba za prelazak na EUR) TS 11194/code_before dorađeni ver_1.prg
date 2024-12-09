LOCAL lnOdg, lcText, llIzpisan, lnid_opom, lcFilter

lnOdg = rf_msgbox("Pitanje","Želite li ispis svih ili trenutnog zapisa?","Svih","Trenutnog","Poništi")

ldMigrationDatePS = GF_SQLEXECScalarNull("select top 1 cast(val as datetime) as MigrationDate from dbo.custom_settings where code = 'Nova.EUR.Migration.MigrationDateForPrintSelection'") 
lcDom_valuta = allt(GOBJ_Settings.GetVal("dom_valuta"))						

lcFilter = filter("za_opom")
lcFilter = iif(empty(lcFilter),".t.",lcFilter)

llIzpisan = GF_PCDDesc("_pcdparameter", "parcont", "parname", "IZPISAN", "ENABLED", "parvalue", "L")

DO case
	CASE lnOdg = 2	&& Trenutnega
		IF lcDom_valuta == "EUR" AND za_opom.datum_dok <= ldMigrationDatePS	
			POZOR("Datum dokumenta računa (" +allt(gstr(za_opom.datum_dok)) +") je prije migracije (" +allt(gstr(ldMigrationDatePS)) +") i ne može se ispisati!")
			RETURN .F.
    	ENDIF	

	
		lnid_opom = za_opom.id_opom
		Select * From za_opom where id_opom = lnid_opom and !GF_NULLOREMPTY(dok_opom) and !(INLIST(id_za_opom_type, 6, 8)) INTO cursor rezultat && u slučaju trenutnog sam izbacio kod and oznacen = .t. zbog poteškoća kod uvažavanja zadnje označenog zapisa
	CASE lnOdg = 1	&& Vse
		** zadnji označen zapis ne uvažava pa su potrebne sljedeće 3 linije
		SELECT za_opom
		SCAN FOR oznacen = .t.
		ENDSCAN
		Select * From za_opom Where &lcFilter and !GF_NULLOREMPTY(dok_opom) and oznacen = .t. and !(INLIST(id_za_opom_type, 6, 8)) and (lcDom_valuta == "HRK" OR lcDom_valuta == "EUR" AND datum_dok > ldMigrationDatePS) INTO CURSOR rezultat
	OTHERWISE
		RETURN .F.
ENDCASE

sele rezultat   
IF reccount() = 0 THEN
	=POZOR("Nema podataka za ispis!")
	RETURN .F.
endif

OBJ_ReportSelector.PrepareDataForMRT("rezultat", "id_opom")