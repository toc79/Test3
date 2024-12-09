--backup
exec dbo.tsp_generate_inserts 'dej_grp', 'dbo', 'FALSE', '##inserts', 'where dej_grupa!=""'
select * from ##inserts

declare @s varchar(8000)
declare tmp cursor for select ins_stmt from ##inserts
open tmp
fetch next from tmp into @s
while @@fetch_status=0
begin
 print @s
 fetch next from tmp into @s
end
close tmp
deallocate tmp

drop table ##inserts
--za brisati
select Dej_grupa from dej_grp

begin tran
--dodavanje novih grupa
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('AER','Aerospace & Defense','1')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('AFC','Freight & Logistics','2')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('AGR','Agricultural Products','3')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('AIR','Airlines','4')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('ATR','Auto Trade','5')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('AUC','Auto Components','6')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('AUT','Automobiles','7')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('BEV','Beverages','8')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('BKS','Banks','9')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('BUM','Building Products','10')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('CHE','Basic Chemicals','11')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('CMA','Construction Materials','12')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('COE','Communications Equipment','13')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('COM','Computer Hardware','14')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('COS','Construction Companies','15')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('CVE','Civil Engineering','16')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('DCH','Diversified Chemicals','17')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('DIV','Diversified Financials','18')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('DMM','Diversified Metals & Mining','19')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('DTS','Diversified Telecom Services,Wireless Telecom Serv','20')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('EDU','Educational Services','21')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('EEI','Electronic Equipment & Instruments','22')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('ELE','Electrical Equipment','23')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('ENT','Entertainment','24')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('EUT','Electric Utilities','25')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('FOB','Food Products','26')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('FOR','Food & Drug Retailing','27')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('FSV','Financial Services','28')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('FWP','Forest & Wood Products','29')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('GIS','General Industrial Services','30')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('GUT','Gas Utilities','31')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('HCE','HC Equipment & Supplies','32')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('HCI','HC Insurance','33')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('HCP','HC Providers & Services','34')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('HDM','Heavy Duty Machinery','35')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('HOD','Household Durables','36')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('HOP','Household Products','37')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('INS','Insurance','38')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('ITC','IT Consulting & Services','39')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('LEA','Leasing','40')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('LEP','Leisure Equipment & Products','41')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('MAC','Industrial Machinery','42')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('MED','Media','43')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('MLR','Multiline Retail','44')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('NFM','Non Ferrous Metals & Mining','45')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('OFE','Office Electronics','46')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('OIL','Oil & Gas & Energy','47')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('PAC','Containers & Packaging','48')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('PAP','Pulp & Paper','49')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('PEP','Personal Products','50')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('PHA','Pharmaceuticals & Biotech','51')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('PME','Precious Metals','52')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('PRV','Private Households','53')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('PUB','Public Administration','54')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('RED','Associations','55')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('REM','Real Estate Management','56')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('ROR','Road & Rail','57')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('SCH','Specialty Chemicals','58')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('SOG','Specialized Oil & Gas','59')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('SPF','Specialty Finance','60')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('SPR','Specialty Retail','61')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('STL','Steel & Ferrous Metals','62')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('SWR','Computer Software','63')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('TEX','Textiles, Apparels & Luxury Goods','64')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('TOB','Tobacco','65')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('VAR','Various','66')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('WAD','Waste Disposal','67')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('WUT','Water Utilities','68')
INSERT INTO dej_grp (Dej_grupa,opis,vrstni_red) VALUES ('XXX','Not applicable','69')
--select * from dej_grp
--commit
--rollback