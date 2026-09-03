class zcl_xc_html_line_break definition
  public
  inheriting from zcl_xc_html_element final
  create public.

  public section.
    "! <p class="shorttext synchronized">Constructor</p>
    methods constructor.

    methods zif_xc_html_element~to_html redefinition.

  protected section.

endclass.


class zcl_xc_html_line_break implementation.

  method constructor.

    super->constructor( tag = 'br' ).

  endmethod.

  method zif_xc_html_element~to_html.

    result = |<{ mv_tag }>\n|.

  endmethod.

endclass.
