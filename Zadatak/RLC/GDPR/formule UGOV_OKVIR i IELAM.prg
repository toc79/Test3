*STARO
lcIdDok = GF_SQLExecScalarNull("Select a.id_dokum From dbo.dokument a Where a.id_obl_zav = 'IE' AND a.id_pon = "+GF_QuotedStr(ponudba.id_pon))

TEXT TO lcSQL NOSHOW
	Select a.ZACETEK, a.ID_HIPOT, b.opis as thipot_opis, a.vrednost, tec.id_val, 
		IsNull(r3.value, '') as kategorija2_naziv, 
		IsNull(r4.value, '') as kategorija3_naziv,
		IsNull(r5.value, '') as kategorija4_naziv,
		IsNull(r7.value, '') as kategorija6_naziv,
		a.opis1, a.opombe, 
		IsNull(r1.value, '') as tip_cen
	From dbo.dokument a
	Left join dbo.thipot b on a.id_hipot = b.id_hipot
	LEFT JOIN dbo.gfn_g_register('OCEN_VRED_TIP') AS r1 on r1.id_key = a.tip_cen
	LEFT JOIN dbo.gfn_g_register('DOK_KATEGORIJA2') AS r3 on r3.id_key = a.kategorija2
	LEFT JOIN dbo.gfn_g_register('DOK_KATEGORIJA3') AS r4 on r4.id_key = a.kategorija3
	LEFT JOIN dbo.gfn_g_register('DOK_KATEGORIJA4') AS r5 on r5.id_key = a.kategorija4
	LEFT JOIN dbo.gfn_g_register('DOK_KATEGORIJA6') AS r7 on r7.id_key = a.kategorija6
	LEFT JOIN dbo.tecajnic tec on tec.id_tec = a.id_tec
	Where a.id_dokum =
ENDTEXT

GF_SQLExec(lcSQL + IIF(GF_NULLOREMPTY(lcIdDok),GF_QuotedStr(""),TRANS(lcIdDok)), "_IEDOK")

TEXT TO lcSQL NOSHOW
	Declare @id as char(5), @id_fgroup int

	SET @id = (Select a.id_hipot From dbo.dokument a Where a.id_pon = {0})
	SET @id_fgroup = (select dbo.gfn_GetValueTablePeriodActive(dbo.gfn_GetValueTableGroup({1})))

	Select IDENTITY(INT, 1,1) as ID, a.value_at_end_p
	INTO #DSA
	From dbo.factors_values a
	Inner join dbo.FACTORS_GROUPS_PERIOD b ON a.id_fgroup_p = b.id_fgroup_p
	Where a.id_fgroup_p = @id_fgroup
		AND (b.period_type <> 3 OR id_period IN (12,24,36,48,60,72,84))
	 ORDER BY a.id_period


	Select * from #DSA
	PIVOT (MAX(value_at_end_p) for id IN ([1],[2],[3],[4],[5],[6],[7])) as PivotTable

	DROP TABLE #DSA
ENDTEXT

lcSQL = STRTRAN(lcSQL, "{0}", GF_QuotedStr(ponudba.id_pon))
lcSQL = STRTRAN(lcSQL, "{1}", IIF(GF_NULLOREMPTY(lcIdDok), GF_QuotedStr(ponudba.id_vrste)+", NULL","NULL, @id"))
GF_SQLExec(lcSQL, "_KOEF")

GF_SQLExec("Select id_vrste, naziv as Oprema_naziv From dbo.vrst_opr Where id_vrste = " + GF_QuotedStr(ponudba.id_vrste), "_OPR")



*STARO
lcIdDok = GF_SQLExecScalarNull("Select a.id_dokum From gv_KrovnaDokumentacija a Where a.id_obl_zav = 'IE' AND a.id_pon = "+GF_QuotedStr(ponudba.id_pon))

TEXT TO lcSQL NOSHOW
	Select a.ZACETEK, a.ID_HIPOT, /*a.thipot_opis,*/b.opis as thipot_opis, a.vrednost, a.id_val, a.kategorija2_naziv
			, a.kategorija3_naziv, a.kategorija4_naziv, a.kategorija6_naziv, a.opis1
			, a.opombe, a.tip_cen
	From gv_KrovnaDokumentacija a
	Left join dbo.thipot b on a.id_hipot = b.id_hipot
	Where a.id_dokum =
ENDTEXT

GF_SQLExec(lcSQL + IIF(GF_NULLOREMPTY(lcIdDok),GF_QuotedStr(""),TRANS(lcIdDok)), "_IEDOK")

TEXT TO lcSQL NOSHOW
	Declare @id as char(5), @id_fgroup int

	SET @id = (Select a.id_hipot From gv_KrovnaDokumentacija a Where a.id_pon = {0})
	SET @id_fgroup = (select dbo.gfn_GetValueTablePeriodActive(dbo.gfn_GetValueTableGroup({1})))

	Select IDENTITY(INT, 1,1) as ID, a.value_at_end_p
	INTO #DSA
	From dbo.factors_values a
	Inner join dbo.FACTORS_GROUPS_PERIOD b ON a.id_fgroup_p = b.id_fgroup_p
	Where a.id_fgroup_p = @id_fgroup
		AND (b.period_type <> 3 OR id_period IN (12,24,36,48,60,72,84))
	 ORDER BY a.id_period


	Select * from #DSA
	PIVOT (MAX(value_at_end_p) for id IN ([1],[2],[3],[4],[5],[6],[7])) as PivotTable

	DROP TABLE #DSA
ENDTEXT

lcSQL = STRTRAN(lcSQL, "{0}", GF_QuotedStr(ponudba.id_pon))
lcSQL = STRTRAN(lcSQL, "{1}", IIF(GF_NULLOREMPTY(lcIdDok), GF_QuotedStr(ponudba.id_vrste)+", NULL","NULL, @id"))
GF_SQLExec(lcSQL, "_KOEF")

GF_SQLExec("Select id_vrste, naziv as Oprema_naziv From dbo.vrst_opr Where id_vrste = " + GF_QuotedStr(ponudba.id_vrste), "_OPR")




*UGOV_OKVIR





local lnId_frame 
&&lnId_frame = frame_list.id_frame
&&select * from frame_list where id_frame = lnId_frame into cursor frame_list 

LOCAL lcId_kupca, lcId_strm

lcId_kupca = frame_list.id_kupca
lcId_strm = frame_list.id_strm

GF_SQLEXEC("select * from partner where id_kupca="+GF_QuotedStr(lcId_kupca),"_partner")
GF_SQLEXEC("select * from strm1 where id_strm="+GF_QuotedStr(lcId_strm),"_strm1")
GF_SQLEXEC("select part.naz_kr_kup as naz_kr_kup   from dbo.partner par left join dbo.partner part on par.skrbnik_1=part.id_kupca where par.id_kupca="+GF_QuotedStr(lcId_kupca),"_skrbnik")

TEXT TO lcSQl NOSHOW
	SELECT case when d.id_krov_dok is not null
				then rtrim(ltrim(d.opis)) + ' (' + cast(d.id_krov_dok as varchar(20)) + ')'
				else d.opis
		end as opis
	, d.kolicina, d.velja_do, ' ' as velj_opis, p.naz_kr_kup as naz_kr_kup
	FROM dbo.dokument d
	INNER JOIN dbo.dok dk ON dk.id_obl_zav = d.id_obl_zav
	LEFT JOIN dbo.partner p on p.id_kupca = d.id_kupca
	WHERE dk.ali_na_pog = 1 and d.id_frame = {0}
ENDTEXT

lcSQL = STRTRAN(lcSQL, "{0}", TRANS(frame_list.id_frame))
GF_SQLEXEC(lcSQL, 'krov_dokum')

GF_SQLEXEC("select * from users where username='"+allt(GObj_Comm.getUserName())+"'","_user")




* staro
local lnId_frame 
&&lnId_frame = frame_list.id_frame
&&select * from frame_list where id_frame = lnId_frame into cursor frame_list 

LOCAL lcId_kupca, lcId_strm

lcId_kupca = frame_list.id_kupca
lcId_strm = frame_list.id_strm

GF_SQLEXEC("select * from partner where id_kupca="+GF_QuotedStr(lcId_kupca),"_partner")
GF_SQLEXEC("select * from strm1 where id_strm="+GF_QuotedStr(lcId_strm),"_strm1")
GF_SQLEXEC("select part.naz_kr_kup as naz_kr_kup   from dbo.partner par left join dbo.partner part on par.skrbnik_1=part.id_kupca where par.id_kupca="+GF_QuotedStr(lcId_kupca),"_skrbnik")

TEXT TO lcSQl NOSHOW
	SELECT opis, kolicina, velja_do, ' ' as velj_opis, naz_kr_kup_dok as naz_kr_kup
	FROM dbo.gv_KrovnaDokumentacija 
	WHERE ali_na_pog = 1 and id_frame = {0}
ENDTEXT

lcSQL = STRTRAN(lcSQL, "{0}", TRANS(frame_list.id_frame))
GF_SQLEXEC(lcSQL, 'krov_dokum')

GF_SQLEXEC("select * from users where username='"+allt(GObj_Comm.getUserName())+"'","_user")