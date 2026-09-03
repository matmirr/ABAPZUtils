class zcl_xc_html_table_cell definition
  public
  inheriting from zcl_xc_html_element final
  create public.

  public section.
    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter value | Contenido de la celda. Opcional.
    methods constructor
      importing !value type string optional.


  protected section.

endclass.


class zcl_xc_html_table_cell implementation.

  method constructor.
    super->constructor( tag   = 'td'
                        value = value ).
  endmethod.

endclass.
