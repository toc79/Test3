select * from rezultat1 where id_frame = rezultat.id_frame into cursor _frame_ugovori
GF_DataPreview("_frame_ugovori", "", "FrmRLCFrameUgovoriDok", "Pregled ugovora i dokumentacije okvira")

use in _frame_ugovori