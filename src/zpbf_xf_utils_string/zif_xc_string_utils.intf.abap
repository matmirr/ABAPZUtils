interface zif_xc_string_utils
  public.

  "! <p class="shorttext synchronized">Convierte una estructura en una cadena de caracteres</p>
  "!
  "! Recorre recursivamente una estructura (incluyendo estructuras y tablas
  "! internas anidadas) y la serializa a un string plano, separando los
  "! componentes con el separador de línea indicado.
  "!
  "! @parameter data        | Datos a convertir (estructura).
  "! @parameter line_sep    | Separador de línea. Default CR_LF.
  "! @parameter write_empty | Si abap_true, incluye los componentes vacíos. Default abap_true.
  "! @parameter skip_fields | Lista de componentes a omitir del mapeo.
  "! @parameter result      | Cadena de caracteres resultante.
  methods struct_to_string
    importing !data         type any
              line_sep      type abap_cr_lf   default cl_abap_char_utilities=>cr_lf
              write_empty   type abap_bool    default abap_true
              skip_fields   type string_table optional
    returning value(result) type string.

  "! <p class="shorttext synchronized">Construye una tabla interna a partir de un string</p>
  "!
  "! Parsea un string delimitado y construye dinámicamente una tabla interna
  "! tipada según la estructura del diccionario indicada. Opcionalmente
  "! descarta la primera fila (encabezado).
  "!
  "! @parameter struct_name         | Nombre de la estructura del diccionario.
  "! @parameter string              | Datos a procesar.
  "! @parameter newline             | Separador de registro (fila).
  "! @parameter separator           | Separador de campo (columna). Default ';'.
  "! @parameter has_header          | Si abap_true, descarta la primera fila. Default abap_true.
  "! @parameter result              | Referencia a la tabla interna resultante.
  "! @raising   zcx_xc_string_utils | La estructura no existe, no es estructura, o el parsing falla.
  methods string_to_itab
    importing struct_name   type clike
              !string       type string
              newline       type clike
              separator     type clike     default ';'
              has_header    type abap_bool default abap_true
    returning value(result) type ref to data
    raising   zcx_xc_string_utils.

  "! <p class="shorttext synchronized">Determina el separador de registro de un texto</p>
  "!
  "! Detecta cuál de los separadores de línea (CR_LF, CR o LF) se utiliza en
  "! el texto, comprobándolos en ese orden.
  "!
  "! @parameter data   | Datos del archivo en formato string.
  "! @parameter result | Separador detectado. Vacío si no se encuentra ninguno.
  methods determine_line_sep
    importing !data         type string
    returning value(result) type string.

endinterface.
