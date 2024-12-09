"Efektivna kamatna stopa:"+allt(trans(_eks.sa_pdv,gccif))+"% sa PDV-om, "+allt(trans(_eks.bez_pdv, gccif))+"% bez PDV-a"

TRANS(LOOKUP(pon_terj_stros.znesek,"TK",pon_terj_stros.id_stroska),GCCIF)


PONUDA EKS - Fizička lica 

* ovo je potrebno ako se na ponudi žele ispisati neto iznosi npr. pologa
* pošto to nije spremljeno u ponudi, 
* treba napraviti novu kalkulaciju, učitati ju iz ponude, i pokrenuti izračun

Public loUserData
loUserData=gobj_comm.getUserData()

kalk_l.gen_am_plan(2)

**Select planp
**Delete All
**Append From Dbf("_tmpplanp2")
**Replace anuiteta With neto+obresti All
**LOCAL lnGlavnica
**SUM planp.neto FOR !DELETED() TO lnGlavnica 
**SCAN 
**	REPLACE nsaldo WITH lnGlavnica - neto IN planp
**	lnGlavnica = lnGlavnica - neto
**ENDSCAN 
**Go Top

GF_SQLExec("select * from dbo.partner where id_kupca="+gf_quotedstr(allt(transf(ponudba.id_kupca))),"_partner")

GF_SQLExec("select * from dbo.ponudba where id_pon="+gf_quotedstr(allt(transf(ponudba.id_pon))),"_ponudba")

select (neto+obresti) as anuiteta from _tmpplanp2 where sif_terj="LOBR" and zap_obr=1 into cursor prva_rata

GF_SQLExec("select * from dbo.dav_stop where id_dav_st="+gf_quotedstr(allt(transf(ponudba.id_dav_st))),"_dav_stop")

GF_SQLExec("select user_desc from dbo.users where username="+gf_quotedstr(allt(transf(ponudba.vnesel))),"_vnesel")

GF_SQLExec("select * from dbo.tecaj where id_tec="+gf_quotedstr(ponudba.id_tec)+" and datum="+gf_quotedstr(dtoc(ttod(ponudba.dat_pon))),"_tecaj")

select (neto+obresti) as anuiteta, davek from _tmpplanp2 where sif_terj="MFIN" and zap_obr=1 into cursor _morat

select (neto+obresti) as anuiteta, davek from _tmpplanp2 where sif_terj="SFIN" into cursor _inter_kam

select neto, davek, debit from _tmpplanp2 where sif_terj="ADMN" into cursor _tros_admn

* 26.3.2019 g_tomislav MR 41986
select SUM(debit) sum_debit from _tmpplanp2 where sif_terj = "ORYX" into cursor _tros_oryx

**kalk_l.gen_am_plan(2)
RF_CALC_PONUDBA_EOM_FBA()