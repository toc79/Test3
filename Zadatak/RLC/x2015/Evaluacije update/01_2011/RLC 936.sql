﻿begin tran
UPDATE general_register SET neaktiven=1 where id_register='p_eval_kateg1'
select * from general_register where id_register='p_eval_kateg1'
UPDATE general_register SET neaktiven=1 where id_register='P_EVAL_KATEG1-NADGRUPA'
select * from general_register where id_register='P_EVAL_KATEG1-NADGRUPA'
--commit

INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','10101010','Oil & Gas Drilling','OGD',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','10101020','Oil & Gas Equipment & Services','OGE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','10102010','Integrated Oil & Gas','OIL',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','10102020','Oil & Gas Exploration & Production','OEP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','10102030','Oil & Gas Refining & Marketing','ORM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','10102040','Oil & Gas Storage & Transportation','OST',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','10102050','Coal & Consumable Fuels','CCF',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','10109010','Crude Oil Trader','COT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','10109030','Refined Products Trader','RPT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','10109040','Coal Trader','TCT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','10109050','Diversified Energy Trader','DET',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15101010','Commodity Chemicals','CYC',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15101020','Diversified Chemicals','DCH',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15101030','Fertilizers & Agricultural Chemicals','FAC',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15101040','Industrial Gases','ING',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15101050','Specialty Chemicals','SCH',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15102010','Construction Materials','CMA',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15103010','Metal & Glas Containers','MGC',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15103020','Paper Packaging','PPG',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15104010','Aluminium','ALU',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15104020','Diversifed Metals & Mining','DMM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15104030','Gold','GLD',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15104040','Precious Metals & Minerals','PME',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15104050','Steel Production & Iron Ore Mining','STL',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15104090','Steel & Ferrous Metals Trader','STT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15104092','Non-Ferrous Metals Trader','NFT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15104094','Precious Metals Trader','PMT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15105010','Forest Products','FWP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15105020','Paper Products','PAP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15105090','Pulp & Paper Trader','PAT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','15109010','Chemicals & Petrochemicals Distributors','CHT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20101010','Aerospace & Defense','AER',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20102010','Building Products','BUM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20103010','Construction & Engineering','CVE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20104010','Electrical Components & Equipment','ELE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20104020','Heavy Electrical Equipment','HEE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20105010','Industrial Conglomerates','ICS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20106010','Construction & Farm Machinery & Heavy Trucks','CFM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20106020','Industrial Machinery','IMY',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20107010','Industrial products wholesalers','IPD',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20201010','Commercial Printing','COP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20201050','Environmental & Facilities Services','EFS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20201060','Office Services & Supplies','OSS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20201070','Diversified Support Services','DSS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20201080','Security & Alarm Services','SAS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20202010','Human Resource & Employment Services','HES',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20202020','Research & Consulting Services','RCS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20202090','Financial & Legal Services','FSV',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20301010','Air Freight & Logistics','AFL',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20302010','Airlines','AIR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20303010','Marine','MAR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20304010','Railroads','RRO',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20304020','Trucking','TRU',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20305010','Airport Services','AIS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20305020','Highways & Railtracks','HRT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','20305030','Marine Ports & Services','MPS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25101010','Auto Parts & Equipment','APE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25101020','Tire & Rubber','TIR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25102010','Automobile Manufacturers','AUM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25102020','Motorcycle Manufacturers','MOT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25201010','Consumer Electronics','CES',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25201020','Home Furnishings','HOF',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25201030','Homebuilding','HOB',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25201040','Household Appliances','HAP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25201050','Housewares & Specialties','HWS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25202010','Leisure Products','LEQ',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25202020','Photographic Products','PHO',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25203010','Apparel, Accessories & Luxury Goods','AAL',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25203020','Footwear','FWR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25203030','Textiles','TEX',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25203090','Cotton & Fiber Traders','CFT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25301010','Casinos & Gaming','GAM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25301020','Hotels, Ressorts & Cruise Lines','HOT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25301030','Leisure Facilities','LEF',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25301040','Restaurants','RES',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25302010','Education Services','EDU',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25302020','Specialized Consumer Services','SCS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25401010','Advertising','ADV',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25401020','Broadcasting','BRC',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25401025','Cable & Satellite','SAT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25401030','Movies & Entertainment','MOV',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25401040','Publishing','PUB',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25501010','Distributors','DIS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25502010','Catalog Retail','CTR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25502020','Internet Retail','ITR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25503010','Department Stores','DEP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25503020','General Merchandise Stores','GMS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25504010','Apparel Retail','APR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25504020','Computer & Electronics Retail','CER',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25504030','Home Improvement Retail','HIR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25504040','Specialty Stores','SPS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25504050','Automotive Retail','ATR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25504060','Home Furnishing Retail','HFR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','25509010','Diversified Cyclical','DCY',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30101010','Drug Retail','DRR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30101020','Food Distributors','FOD',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30101030','Food Retail','FOR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30101040','Hypermarkets & Supercenters','HMS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30201010','Brewers','BER',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30201020','Distillers & Vinters','VIN',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30201030','Soft Drinks','SOD',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30202010','Agricultural Products','AGP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30202020','Agro-Commodity Traders','ACT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30202030','Packaged Foods & Meats','PFM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30203010','Tobacco','TOB',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30301010','Household Products','HOP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30302010','Personal Products','PEP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','30309010','Diversified Non-Cyclical','DNC',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','35101010','Health Care Equipment','HEQ',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','35101020','Health Care Supplies','HCM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','35102010','Health Care Distributors','HCD',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','35102015','Health Care Services','HCS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','35102020','Health Care Facilities','HCF',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','35102030','Managed Health Care','MHC',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','35103010','Health Care Technology','HCT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','35201010','Biotechnology','BIO',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','35202010','Pharmaceuticals','PHA',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','35203010','Life Scs. Tools & Services','LST',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40101010','Diversified Banks','DBK',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4010101010','Commercial Banks','BCM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4010101020','Global Bank/Banks','BGL',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40101015','Regional Banks','RBK',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4010101510','Savings Bank','BSA',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4010101520','Government owned (no data)','BGO',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4010101530','Islamic Banks','BIS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4010101540','Development Bank','BDE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40102010','Thirfts & Mortgage Finance','TMF',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4010201010','Mortgage Finance Vehicles','FMV',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4010201020','Building Societies','BBS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40201020','Other Diversified Fin. Serv.','OFS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40201030','Multi-Sector Holdings','MSH',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020103010','Holding','FHO',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40201040','Specialized Finance','SPF',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020104010','ECAs','FEK',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020104015','Stock Exchange','FSE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020104020','Commodity Exchange','FCE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020104025','Exchange Houses','FEH',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020104030','Loan Warehouse','FWH',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020104035','Clearing House','FCL',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020104040','Factoring','FFA',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020104045','Financing Vehicle for parents','FFV',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020104050','Commercial Finance Company','FCO',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020104055','Special Finance Company','FSS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40202010','Consumer Finance','CSF',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020201010','Consumer Fin., Credit Cards','FCF',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020201020','Leasing','FLS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020201030','Microfinance','FMF',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40203010','Asset Management & Custody Banks','AMC',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020301010','Asset Management','FAM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020301020','KAG','FKA',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40203020','Investment Banking & Brokerage','IBB',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020302010','Brokerage Companies','FBR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020302020','Private & Investment Bank','BPI',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020302030','Investment Bank (large)','BIN',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020302040','Hedge Fund','CHD',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020302050','Weekly Regulated Fund','CWR',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020302060','UCIT (EU-regulated Fund)','CCT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40203030','Diversified Capital Markets','DCM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4020303010','Global Bank/Cap. Markets','BGC',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40301010','Insurance Brokers','IBK',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40301020','Life & Health Insurance','LHI',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4030102010','Life Insurance','ILF',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4030102020','Social Security','ISO',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40301030','Multi-line Insurance','MII',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40301040','Property & Casuality Insurance','PCI',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','4030104010','Non-Life Insurance','INL',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40301050','Re-Insurance','IRI',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40402010','Diversified Real Estate','DRE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40402020','Industrial Real Estate','IRE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40402030','Mortgage Real Estate','MRE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40402040','Office Real Estate','ORE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40402050','Residential Real Estate','RRE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40402060','Retail Real Estate','RET',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40402070','Specialized Real Estate','SRE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40403010','Diversified Real Estate Serv.','DRS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40403020','Real Estate Operating Comp.','ROC',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40403030','Real Estate Development','RED',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','40403040','Real Estate Services','REV',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45101010','Internet Software & Services','ISS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45102010','IT Consulting & Other Serv.','ITC',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45102020','Data Processing. & Outs. Serv.','DPS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45103010','Application Software','APS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45103020','Systems Software','SYS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45103030','Home Entertainment Software','ESW',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45201020','Communications Equipment','COE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45202010','Computer Hardware','COM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45202020','Comp. Storage & Peripherals','CSP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45203010','Electronic Equipment & Instr.','EEI',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45203015','Electronic Components','ECP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45203020','Electronic Manufact. Services','EMS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45203030','Technology Distributors','TED',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45204010','Office Electronics','OFE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45301010','Semiconductor Equipment ','SEE',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','45301020','Semiconductors','SEM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','50101010','Alternative Carriers','ALC',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','50101020','Integrated Telco Services','ITS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','50102010','Wireless Telecom Services','WTS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','55101010','Electric Utilities','EUT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','55102010','Gas Utilities','GUT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','55103010','Multi Utilities','MUT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','55104010','Water Utilities','WUT',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','55105010','Independent Power Producers','IPP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','55105090','Gas & Power Merchants','GPM',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','90101010','Political Parties','POP',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','90101020','Other Private Services','OPS',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','90102010','Religious Organisations','REO',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','90102020','Environmental Organisations','EVO',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','90102030','Labor Organisations','LBO',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','90102040','Charity Organisations','CHO',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','90102050','Research & Development','RSD',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','90102060','Other Organisations','OTO',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','90105010','Private Households','PRV',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG1','90109010','Not Classified','NCL',0,0)
