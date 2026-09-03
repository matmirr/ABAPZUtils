interface zif_xc_value_extractor
  public.

  "! <p class="shorttext synchronized">Extrae los valores crudos de una línea</p>
  "!
  "! Parte una línea de texto en los valores correspondientes a cada campo de
  "! la estructura destino. La estrategia concreta determina cómo se parte
  "! (por longitud fija, por separador, etc.).
  "!
  "! @parameter line               | Línea de texto a partir.
  "! @parameter components         | Componentes de la estructura destino (RTTI).
  "! @parameter result             | Valores crudos, en el orden de los componentes.
  "! @raising   zcx_xc_file_mapper | Error al extraer (p. ej. cantidad no coincide).
  methods extract
    importing !line         type string
              !components   type abap_component_tab
    returning value(result) type string_table
    raising   zcx_xc_file_mapper.

endinterface.
