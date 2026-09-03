interface zif_xc_file_section
  public.

  "! <p class="shorttext synchronized">Renderiza la sección como texto</p>
  "!
  "! Devuelve el contenido de la sección ya formateado, listo para
  "! concatenar en el documento final.
  "!
  "! @parameter result               | Contenido de la sección.
  "! @raising   zcx_xc_struct_mapper | Error durante el render de la sección.
  methods render
    returning value(result) type string
    raising   zcx_xc_struct_mapper.

endinterface.
