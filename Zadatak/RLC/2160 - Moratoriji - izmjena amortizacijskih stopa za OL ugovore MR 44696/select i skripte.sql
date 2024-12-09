--select INV_STEV, STOPNJA_AM, ST_AMINT, status, DAT_LIKV, odpis_prod, DAT_ODPISA, DAT_ODPISA_DATUM, * from dbo.FA
--select distinct status from dbo.FA

select *
	, datalength(inv_stev) as data
	, right('0000000' +rtrim(inv_stev), COL_LENGTH( '_tmp_fa' , 'inv_stev' )) as r_exsample  
	--, FORMAT(inv_stev, 'd10') as padWithZeros
	, COL_LENGTH ( '_tmp_fa' , 'inv_stev' ) 
	, REPLICATE('0', 7 - DATALENGTH(inv_stev)) + inv_stev as replicae_exsample
from dbo._tmp_fa


--UPDATE dbo._tmp_fa SET ex_inv_stev = right('0000000' +rtrim(inv_stev), COL_LENGTH( '_tmp_fa' , 'inv_stev' ))




select a.*, b.INV_STEV, b.STOPNJA_AM, b.ST_AMINT, b.status, b.DAT_LIKV, b.odpis_prod, b.DAT_ODPISA, b.DAT_ODPISA_DATUM
, * 
from dbo._tmp_fa a
join dbo.fa b on a.ex_inv_stev = b.INV_STEV and a.stopnja_am = b.STOPNJA_AM and a.st_amint = b.ST_AMINT --niti jedan zapis nije isti => OK
where status = 'A'

begin tran
UPDATE dbo.fa SET STOPNJA_AM = b.STOPNJA_AM, ST_AMINT = b.ST_AMINT
from dbo.fa a 
join dbo._tmp_fa b on a.INV_STEV = b.ex_inv_stev
where status = 'A'
--commit


--Za ubuduće nićda bi se moglo tako mijenjati
<update_fa xmlns='urn:gmi:nova:fa'>
<id_strm>0010</id_strm>
<id_sobe>00003</id_sobe>
<neam_vred>0</neam_vred>
<id_amor_sk>001</id_amor_sk>
<id_nomen>003</id_nomen>
<id_kupca>000047</id_kupca>
<id_knjizbe>0024</id_knjizbe>
<id_fa>13</id_fa>
<zac_reval>2000/01</zac_reval>
<id_grupe>0000</id_grupe>
<naziv1>SWING PROCESOR MENAGER SERVER LICENCA</naziv1>
<naziv2></naziv2>
<stopnja_am>19</stopnja_am>
<sys_ts>444060024</sys_ts>
<zac_amort>2000/01</zac_amort>
<st_amint>18</st_amint>
<st_amek>0</st_amek>
<ne_knjizim>false</ne_knjizim>
<opombe></opombe>
<zac_amort_datum>2000-01-01T00:00:00.000</zac_amort_datum>
</update_fa>