class zcl_xc_html_table_header_cell definition
  public
  inheriting from zcl_xc_html_element final
  create public.

  public section.
    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter value | Contenido de la celda de encabezado. Opcional.
    methods constructor
      importing !value type string optional.

  protected section.

endclass.


class zcl_xc_html_table_header_cell implementation.

  method constructor.
    super->constructor( tag   = 'th'
                        value = value ).
  endmethod.

endclass.
