OL
"36004/11-19-000AVT"

OL
"36004/11-20-000AVT"

F1
"36048/11-20-000AVT"

{IIF(String.IsNullOrEmpty(planplacil.ddv_id.Trim()),IIF(planplacil.sif_terj=="VARS","Poziv za plaćanje br.: "+planplacil.st_dok.Trim(),""),"R-1")}