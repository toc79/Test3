local lista
lista =  GF_CreateDelimitedList("RESULT", "id_cont", "Oznacen = .t.", ",")

gcLista = lista

OBVESTI("potrebno je pokrenuti dodatnu rutinu 4. Popravak polja U sefu za odabrane ugovore.")

loForm = GF_GetFormObject("frmPripPog2")
loForm.Release