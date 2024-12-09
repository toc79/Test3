test qwwqdf wqf

<?xml version='1.0' encoding='utf-8'?><rpg_res type='immediate'><rpg_calc xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'><automatic_rpg><rpg_calc_type>automatic_rpg</rpg_calc_type><id_cont>8747</id_cont><new_index_rate xsi:nil='true' /><new_index_date xsi:nil='true' /><je_nk>false</je_nk></automatic_rpg></rpg_calc></rpg_res>


local lcXMLresult
lcXMLresult = "<?xml version='1.0' encoding='utf-8'?><rpg_res type='i'><rpg_calc xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www'><automatic_rpg><id_cont>8747</id_cont><new_index_rate></new_index_rate></automatic_rpg></rpg_calc></rpg_res>"

lcXMLresult = strtran(lcXMLresult, "<new_index_rate></new_index_rate>", "")

lcrootNode = "//rpg_res/rpg_calc/automatic_rpg"

	DIMENSION CursorDescription(2,17)

	CursorDescription(1,1) = "id_cont"
	CursorDescription(1,2) = "I"
	CursorDescription(1,3) = 4
	CursorDescription(1,4) = 0
	CursorDescription(1,5) = .F.
	CursorDescription(1,6) = .F.
	CursorDescription(1,7) = "id_cont"

	 CursorDescription(2,1) = "new_index_rate"
	 CursorDescription(2,2) = "N"
	 CursorDescription(2,3) = 9
	 CursorDescription(2,4) = 4
	 CursorDescription(2,5) = .T.
	 CursorDescription(2,6) = .F.
	 CursorDescription(2,7) = "new_index_rate"
	
	GF_XML2Cursor(@CursorDescription, "_ef_automatic_rpg", lcXMLresult, lcrootNode)

select * from _ef_automatic_rpg



* 2 primjer
local lcXMLresult
lcXMLresult = "<?xml version='1.0' encoding='utf-8'?><rpg_res type='i'><rpg_calc xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www'><automatic_rpg><id_cont>8747</id_cont><new_index_rate xsi:nil='true' /></automatic_rpg></rpg_calc></rpg_res>"

lcrootNode = "//rpg_res/rpg_calc/automatic_rpg"

	DIMENSION CursorDescription(1,17)

	CursorDescription(1,1) = "id_cont"
	CursorDescription(1,2) = "I"
	CursorDescription(1,3) = 4
	CursorDescription(1,4) = 0
	CursorDescription(1,5) = .F.
	CursorDescription(1,6) = .F.
	CursorDescription(1,7) = "id_cont"

	 CursorDescription(3,1) = "new_index_rate"
	 CursorDescription(3,2) = "N"
	 CursorDescription(3,3) = 9
	 CursorDescription(3,4) = 4
	 CursorDescription(3,5) = .F.
	 CursorDescription(3,6) = .F.
	 CursorDescription(3,7) = "new_index_rate"
	
	GF_XML2Cursor(@CursorDescription, "_ef_automatic_rpg", lcXMLresult, lcrootNode)

select * from _ef_automatic_rpg



	*_ef_automatic_rpg.new_index_rate != _ef_pogodba.rind_zadnji OR _ef_automatic_rpg.new_index_date != _ef_pogodba.rind_datum
&&MARŽA NIJE ZAPISANA I KOMPLEKSNO JU JE ZA DOBITI S OBZIROM NA SADRŽAJ PODATAKA U KURSORIMA