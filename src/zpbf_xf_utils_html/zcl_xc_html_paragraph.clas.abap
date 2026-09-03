class zcl_xc_html_paragraph definition
  public
  inheriting from zcl_xc_html_element final
  create public.

  public section.
    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter id    | Atributo id. Opcional.
    "! @parameter text  | Contenido textual del párrafo. Opcional.
    "! @parameter class | Atributo class. Opcional.
    methods constructor
      importing !id    type string optional
                !text  type string optional
                !class type string optional.

  protected section.

endclass.


class zcl_xc_html_paragraph implementation.

  method constructor.

    super->constructor( tag   = 'p'
                        id    = id
                        value = text
                        class = class ).

  endmethod.

endclass.
