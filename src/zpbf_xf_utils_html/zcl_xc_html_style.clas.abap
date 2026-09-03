class zcl_xc_html_style definition
  public
  inheriting from zcl_xc_html_element final
  create public.

  public section.
    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter css | Contenido CSS del bloque de estilos.
    methods constructor
      importing css type string.

  protected section.

endclass.


class zcl_xc_html_style implementation.

  method constructor.

    super->constructor( tag   = 'style'
                        value = css ).

  endmethod.

endclass.
