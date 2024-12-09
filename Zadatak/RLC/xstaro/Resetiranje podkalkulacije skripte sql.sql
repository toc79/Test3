select ima_robresti, * from nacini_l where nacin_leas in ('F1', 'OA','OJ','FF')

select id_dav_op_equals_id_dav_st, predp_id_dav_op, IMA_OSTSTR,* from kalk_form where nacin_leas in ('F1', 'OA','OJ','FF')

begin tran
--OL
UPDATE kalk_form SET predp_id_dav_op = '25' where nacin_leas in ('OJ') --NULL
UPDATE kalk_form SET id_dav_op_equals_id_dav_st = 0 where nacin_leas in ('OJ') --NULL
--UPDATE kalk_form SET predp_id_dav_op = NULL, id_dav_op_equals_id_dav_st = 1  where nacin_leas in ('OJ') --NULL, 1 POÈETNE POSTAVKE

--FL
--UPDATE kalk_form SET predp_id_dav_op = '25' where nacin_leas in ('FF') --NULL
--UPDATE kalk_form SET predp_id_dav_op = NULL, id_dav_op_equals_id_dav_st = 1  where nacin_leas in ('FF') --NULL, 1 POÈETNE POSTAVKE


--FF
UPDATE kalk_form SET IMA_OSTSTR = 1 where nacin_leas in ('FF') --NULL --0

UPDATE kalk_form SET IMA_OSTSTR = 0 where nacin_leas in ('FF') --NULL --0 POÈETNE POSTAVKE

--commit 