--Parameters {X}:

-- 0 - {0} 
-- 1 - {1} 
-- 2 - {2}
-- 3 - {3}
-- 4 - {4}

--06.08.2021 g_tomislav MID 47343

select 
	'<insert_mail xmlns="urn:gmi:nova:core"><from>tomislav.krnjak@gemicro.hr</from><to>tomislav.krnjak@gemicro.hr</to><cc></cc><subject>Test INSERT_MAIL</subject><body>Aktiviranje ugovora</body><body_is_html>true</body_is_html><send_immediately>true</send_immediately></insert_mail>' as xml, 
	cast(0 as bit) as via_queue,
	300 as delay,
	cast(0 as bit) as via_esb,
	'nova.le' as esb_target