** EUR MIGRATION
ldMigrationDatePS = GF_SQLEXECScalarNull("select top 1 cast (val as datetime) as MigrationDate from dbo.custom_settings where code = 'Nova.EUR.Migration.MigrationDateForPrintSelection'") 
lcDom_valuta = allt(GOBJ_Settings.GetVal("dom_valuta"))

LOCAL lnOdg, lcFilter

lnOdg = rf_msgbox("Pitanje","Želite li ispis svih ili trenutnog zapisa?","Svih","Trenutnog","Poništi")

lcFilter = filter("najem_fa")
lcFilter = iif(empty(lcFilter),".t.",lcFilter)

GF_SQLEXEC("select * from dbo.ZBIRNIKI where ddv_id is not null","_zb_rac")

DO case
	CASE lnOdg = 2 && Trenutnega
		IF lcDom_valuta == "EUR" AND najem_fa.datum_dok <= ldMigrationDatePS
			POZOR("Datum dokumenta računa (" +allt(gstr(najem_fa.datum_dok)) +") je prije migracije (" +allt(gstr(ldMigrationDatePS)) +") i ne može se ispisati!")
			RETURN .F.
		ENDIF
		
		Select * from _zb_rac where ddv_id = najem_fa.ddv_id INTO CURSOR _zb_rac_tren
		IF reccount() > 0 THEN
			=POZOR("Trenutni zapis se ispisuje iz opcije zbirni računi!")
			RETURN .F.
		ENDIF
		use in _zb_rac_tren

		GF_SQLEXEC("Select ident_stevilka From dbo.partner where id_kupca = "+GF_QuotedStr(najem_fa.id_kupca),"_PID")
		IF !GF_NULLOREMPTY(_PID.ident_stevilka)
			Pozor("Kupcu se šalje eRačun i nije potrebno ispisati račun na printer!")
		ENDIF

		OBJ_ReportSelector.id_field = najem_fa.ddv_id
		
	CASE lnOdg = 1	&& Vse
		Select * From najem_fa Where &lcFilter and ddv_id not in (Select ddv_id from _zb_rac) and oznacen = .t. and (lcDom_valuta == "HRK" OR lcDom_valuta == "EUR" AND datum_dok > ldMigrationDatePS) INTO CURSOR rezultat
		
		sele rezultat
		IF reccount() = 0 THEN

			=POZOR("Nema podataka za ispis!")
			RETURN .F.
		ENDIF

		OBJ_ReportSelector.PrepareDataForMRT("rezultat", "ddv_id")
	OTHERWISE
		RETURN .F.
ENDCASE 