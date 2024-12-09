INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG3','RBA_RatResp','RBA Rating responsibility','',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG3','RL_RatResp','RL Rating responsibility','',0,0)
INSERT INTO general_register (id_register,id_key,value, val_char, val_bit,neaktiven) VALUES ('P_EVAL_KATEG3','RZB_RatResp','RZB Rating responsibility','',0,0)

begin tran
update p_eval set kategorija3='RBA_RatResp' where oall_ratin = 'RBA_RatRes'
update p_eval set kategorija3='RL_RatResp' where oall_ratin = 'RL_RatResp'
update p_eval set kategorija3='RZB_RatResp' where oall_ratin = 'RZB_RatResp'
update p_eval set oall_ratin='' where oall_ratin = 'RBA_RatRes'
update p_eval set oall_ratin='' where oall_ratin = 'RL_RatResp'
update p_eval set oall_ratin='' where oall_ratin = 'RZB_RatResp'

--BACKUP
select oall_ratin,kategorija3,* from p_eval where oall_ratin in ('RBA_RatRes','RL_RatResp','RZB_RatResp')
-------
select oall_ratin,kategorija3,* from p_eval where kategorija3 = 'RBA_RatResp'
select oall_ratin,kategorija3,* from p_eval where kategorija3 = 'RL_RatResp'
select oall_ratin,kategorija3,* from p_eval where kategorija3 = 'RZB_RatResp'
--rollback
--commit