local lcDatumTec

lcDatumtec = allt(look(_PCDPARAMETER.Parvalue,'DATUMTEC',_PCDPARAMETER.Parname))

GF_SQLEXEC("SELECT distinct(id_kupca) as id_kupca, id_vloga from p_kontakt where id_vloga='O1'","_parO1")

select id_kupca, sum(saldo) as sum_duguje ;
from PPIZBOR ;
group by id_kupca ;
into cursor _ppizbor_sum

	SELECT .F. as oznacen, A.*, B.id_vloga, C.sum_duguje, lcDatumtec as dat_tec_s ;
	FROM PPIZBOR A ;
	INNER JOIN _parO1 B ON A.ID_KUPCA = B.ID_KUPCA ;
	INNER JOIN _ppizbor_sum C ON A.ID_KUPCA = C.ID_KUPCA and C.sum_duguje>50 ;
	ORDER BY A.id_kupca, A.id_pog ;
	INTO CURSOR REZ
	
	USE IN _parO1
	USE IN _ppizbor_sum

GF_DataPreview("REZ", "", "frmppizbords5_group", "Partneri O1")