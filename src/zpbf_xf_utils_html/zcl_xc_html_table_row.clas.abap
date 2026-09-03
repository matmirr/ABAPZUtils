class zcl_xc_html_table_row definition
  public
  inheriting from zcl_xc_html_element final
  create public.

  public section.
    "! <p class="shorttext synchronized">Constructor</p>
    methods constructor.

  protected section.

endclass.


class zcl_xc_html_table_row implementation.

  method constructor.
    super->constructor( tag = 'tr' ).
  endmethod.

endclass.
