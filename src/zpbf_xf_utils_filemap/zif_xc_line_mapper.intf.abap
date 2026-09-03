interface zif_xc_line_mapper
  public.

  "! <p class="shorttext synchronized">Mapea una línea de texto a una estructura</p>
  "!
  "! Convierte una línea del archivo en los campos de la estructura destino,
  "! aplicando validación y transformación por campo si están configuradas.
  "!
  "! @parameter line               | Línea de texto a mapear.
  "! @parameter is_header          | Indica si la línea corresponde a la cabecera.
  "! @parameter data               | Estructura destino donde se vuelcan los campos.
  "! @parameter messages           | Mensajes de resultado del mapeo (acumulativo).
  "! @parameter result             | Resultado del mapeo (abap_true = línea válida).
  "! @raising   zcx_xc_file_mapper | Error terminal de mapeo o validación.
  methods map
    importing !line         type string
              is_header     type abap_bool
    changing  !data         type any
              !messages     type bapirettab optional
    returning value(result) type abap_bool
    raising   zcx_xc_file_mapper.

endinterface.
