
select '<update_fa xmlns=''urn:gmi:nova:fa''> <id_strm>1000</id_strm> <id_sobe>00001</id_sobe> <neam_vred>0</neam_vred> <id_amor_sk>001</id_amor_sk> <id_nomen>100</id_nomen> <id_kupca>000001</id_kupca> <id_gl_sifkljuc>1</id_gl_sifkljuc> <id_knjizbe>0001</id_knjizbe> <id_fa>784</id_fa> <zac_reval>2014/06</zac_reval> <id_grupe>0000</id_grupe> <id_cont>2005</id_cont> <naziv1>test unosa OS</naziv1> <naziv2></naziv2> <stopnja_am>4</stopnja_am> <sys_ts>1332971</sys_ts> <zac_amort>2014/06</zac_amort> <st_amint>0</st_amint> <st_amek>0</st_amek> <ne_knjizim>false</ne_knjizim> <opombe></opombe> <zac_amort_datum>2014-06-01T00:00:00.000</zac_amort_datum> </update_fa>' as xml,
	cast(0 as bit) as via_queue,    
	300 as delay,    
	cast(0 as bit) as via_esb,    
	'nova.le' as esb_target
