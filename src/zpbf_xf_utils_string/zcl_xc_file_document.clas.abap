class zcl_xc_file_document definition
  public final
  create public.

  public section.
    "! <p class="shorttext synchronized">Agrega una sección al documento</p>
    "!
    "! Las secciones se renderizan en el orden en que se agregan.
    "!
    "! @parameter section | Sección a agregar (header, body, footer, etc.).
    "! @parameter result  | El propio documento (para encadenar llamadas).
    methods add_section
      importing !section      type ref to zif_xc_file_section
      returning value(result) type ref to zcl_xc_file_document.

    "! <p class="shorttext synchronized">Renderiza el documento completo</p>
    "!
    "! Concatena el render de todas las secciones, en orden.
    "!
    "! @parameter result               | Contenido completo del documento.
    "! @raising   zcx_xc_struct_mapper | Error al renderizar alguna sección.
    methods render
      returning value(result) type string
      raising   zcx_xc_struct_mapper.

  private section.

    data mt_sections type standard table of ref to zif_xc_file_section with empty key.

endclass.


class zcl_xc_file_document implementation.

  method add_section.

    append section to mt_sections.
    result = me.

  endmethod.

  method render.

    loop at mt_sections into data(lo_section).

      result = result && lo_section->render( ).

    endloop.

  endmethod.

endclass.
