select * from pogodba where id_cont in (SELECT id_cont FROM dbo.krov_pog_pogodba) AND ID_CONT in (select id_cont from dbo.frame_pogodba)

SELECT * FROM dbo.krov_pog_pogodba where id_cont in (
select id_cont from pogodba where id_cont in (SELECT id_cont FROM dbo.krov_pog_pogodba) AND ID_CONT in (select id_cont from dbo.frame_pogodba)
)


SELECT distinct id_frame  FROM dbo.frame_pogodba where id_cont in (
select id_cont from pogodba where id_cont in (SELECT id_cont FROM dbo.krov_pog_pogodba) AND ID_CONT in (select id_cont from dbo.frame_pogodba)
)