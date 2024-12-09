--Nakon promjene potrebno je promijeniti u g_system i u dbo_kategorije_entiteta

begin tran
UPDATE dbo.kategorije_entiteta SET vnesel_username = 'g_system' WHERE vnesel_username = 'g_tomislav'
UPDATE dbo.kategorije_entiteta SET poprava_username = 'g_system' WHERE poprava_username = 'g_tomislav'
--commit
--rollback

select vnesel_username, vnesel_date, * from dbo.kategorije_entiteta 
where vnesel_username = 'g_tomislav'
select poprava_username, poprava_date, *  from dbo.kategorije_entiteta 
where poprava_username= 'g_tomislav'


select vnesel_username, vnesel_date, poprava_username, poprava_date, *  from dbo.kategorije_entiteta 
where vnesel_username = 'g_tomislav' OR  poprava_username= 'g_tomislav'
--group by vnesel_username, vnesel_date, poprava_username, poprava_date -- , COUNT(*) as br_zapisa


oko importa/update kategorije entiteta na rlc, Branislav je primjetio da se G_TOMISLAV zapisalo i u dbo.kategorije entiteta pa bi i tamo (uz dbo.reprogram) trebalo napraviti update na G_SYSTEM kroz bazu. Ja mislim da bi trebalo pa da i to dodam u skripte tj. dodao bi to u zahtjev. Može?
http://gmcv03/support/maintenance.aspx?Mode=Read&Source=3&Document=39141&ID=39141