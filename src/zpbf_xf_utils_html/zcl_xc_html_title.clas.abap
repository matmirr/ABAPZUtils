class zcl_xc_html_title definition
  public
  inheriting from zcl_xc_html_element final
  create public.

  public section.
    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter text | Texto del título de la página.
    methods constructor
      importing !text type string.

  protected section.

endclass.


class zcl_xc_html_title implementation.

  method constructor.

    super->constructor( tag   = 'title'
                        value = text ).

  endmethod.

endclass.
