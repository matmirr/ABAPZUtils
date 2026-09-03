class zcl_xc_html_image definition
  public
  inheriting from zcl_xc_html_element final
  create public.

  public section.
    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter id    | Atributo id. Opcional.
    "! @parameter src   | URL de la imagen. Opcional.
    "! @parameter alt   | Texto alternativo. Opcional.
    "! @parameter class | Atributo class. Opcional.
    methods constructor
      importing !id    type string optional
                src    type string optional
                alt    type string optional
                !class type string optional.

    "! <p class="shorttext synchronized">Fija el ancho de la imagen</p>
    "! @parameter value  | Ancho (p. ej. '150').
    "! @parameter result | El propio nodo (para encadenar).
    methods set_width
      importing !value        type string
      returning value(result) type ref to zif_xc_html_element.

    "! <p class="shorttext synchronized">Fija el alto de la imagen</p>
    "! @parameter value  | Alto (p. ej. '150').
    "! @parameter result | El propio nodo (para encadenar).
    methods set_height
      importing !value        type string
      returning value(result) type ref to zif_xc_html_element.

    "! <p class="shorttext synchronized">Embebe una imagen binaria como data-URI base64</p>
    "!
    "! Codifica el contenido binario en base64 y lo fija como atributo src en
    "! formato data-URI. El binario debe obtenerse fuera de esta clase (p. ej.
    "! de un servicio, OData o el MIME repository en código Standard).
    "!
    "! @parameter content   | Contenido binario de la imagen.
    "! @parameter mime_type | Tipo MIME (p. ej. 'image/png'). Default 'image/png'.
    methods embed_base64
      importing content   type xstring
                mime_type type string default 'image/png'.

    methods zif_xc_html_element~to_html redefinition.

  private section.
    "! Fija (o reemplaza) el atributo src.
    "!
    "! @parameter value | Contenido del atributo "src"
    methods set_src
      importing !value type string.

endclass.


CLASS zcl_xc_html_image IMPLEMENTATION.

  method constructor.
    super->constructor( tag   = 'img'
                        id    = id
                        class = class ).

    if src is not initial.
      zif_xc_html_element~add_attribute( name  = 'src'
                                         value = src ).
    endif.

    if alt is not initial.
      zif_xc_html_element~add_attribute( name  = 'alt'
                                         value = alt ).
    endif.
  endmethod.

  method set_width.
    result = zif_xc_html_element~add_attribute( name  = 'width'
                                                value = value ).
  endmethod.

  method set_height.
    result = zif_xc_html_element~add_attribute( name  = 'height'
                                                value = value ).
  endmethod.

  method embed_base64.
    data(lv_base64) = cl_web_http_utility=>encode_x_base64( content ).
    set_src( |data:{ mime_type };base64,{ lv_base64 }| ).
  endmethod.

  method set_src.
    " Reemplaza el src si ya existe; si no, lo agrega.
    assign mt_attributes[ name = 'src' ] to field-symbol(<src>).
    if sy-subrc = 0.
      <src>-value = value.
    else.
      zif_xc_html_element~add_attribute( name  = 'src'
                                         value = value ).
    endif.
  endmethod.

  method zif_xc_html_element~to_html.
    " <img/> es un elemento void: sin contenido ni cierre, solo atributos.
    result = |<{ mv_tag }{ render_attributes( ) }/>\n|.
  endmethod.

endclass.
