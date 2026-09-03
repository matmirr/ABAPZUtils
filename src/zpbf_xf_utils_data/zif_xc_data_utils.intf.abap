interface zif_xc_data_utils
  public.

  "! <p class="shorttext synchronized">Crea una estructura con el nombre de cada campo como valor</p>
  "!
  "! A partir del nombre de una estructura del diccionario, devuelve una
  "! referencia a una estructura dinámica donde cada campo es de tipo CHAR
  "! con longitud igual a la de su propio nombre. Está pensada para usarse
  "! como mapa de nombres de campo (por ejemplo, para asignación dinámica de
  "! componentes o para mapear contra claves de un JSON).
  "!
  "! @parameter struct_name       | Nombre de la estructura del diccionario.
  "! @parameter result            | Referencia a la estructura dinámica resultante.
  "! @raising   zcx_xc_data_utils | La estructura no existe o el nombre no es una estructura.
  methods struct_by_field_names
    importing struct_name   type clike
    returning value(result) type ref to data
    raising   zcx_xc_data_utils.

  "! <p class="shorttext synchronized">Crea una tabla interna con el tipo de línea de una estructura</p>
  "!
  "! A partir del nombre de una estructura del diccionario, devuelve una
  "! referencia a una tabla interna estándar cuyo tipo de línea es esa
  "! estructura, preservando los tipos reales de cada campo.
  "!
  "! @parameter struct_name       | Nombre de la estructura del diccionario.
  "! @parameter result            | Referencia a la tabla interna resultante.
  "! @raising   zcx_xc_data_utils | La estructura no existe o el nombre no es una estructura.
  methods itab_by_struct_name
    importing struct_name   type clike
    returning value(result) type ref to data
    raising   zcx_xc_data_utils.

endinterface.
