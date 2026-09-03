class zcl_xc_html_element definition
  public
  create public.

  public section.
    interfaces zif_xc_html_element.

    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter tag   | Etiqueta HTML (p. ej. 'div', 'p', 'table').
    "! @parameter id    | Atributo id. Opcional.
    "! @parameter value | Contenido textual del nodo. Opcional.
    "! @parameter class | Atributo class. Opcional.
    methods constructor
      importing tag    type string
                !id    type string optional
                !value type string optional
                !class type string optional.

  protected section.

    data mv_tag        type string.
    data mv_value      type string.
    data mt_attributes type zif_xc_html_element=>tt_attribute.
    data mt_children   type zif_xc_html_element=>tt_element.

    "! <p class="shorttext synchronized">Renderiza los atributos como cadena HTML</p>
    "! @parameter result | Atributos en formato ' name="value"...'.
    methods render_attributes
      returning value(result) type string.

    "! <p class="shorttext synchronized">Renderiza los hijos concatenando su HTML</p>
    "! @parameter result | HTML de todos los nodos hijos.
    methods render_children
      returning value(result) type string.

  private section.

endclass.


class zcl_xc_html_element implementation.

  method constructor.

    mv_tag   = tag.
    mv_value = value.

    if id is not initial.

      zif_xc_html_element~add_attribute( name  = 'id'
                                         value = id ).

    endif.

    if class is not initial.

      zif_xc_html_element~add_attribute( name  = 'class'
                                         value = class ).

    endif.

  endmethod.

  method zif_xc_html_element~add_attribute.

    append value #( name  = name
                    value = value ) to mt_attributes.

    result = me.

  endmethod.

  method zif_xc_html_element~add_child.

    append child to mt_children.
    result = me.

  endmethod.

  method zif_xc_html_element~has_child.

    result = xsdbool( mt_children is not initial ).

  endmethod.

  method zif_xc_html_element~set_value.

    mv_value = value.

  endmethod.

  method zif_xc_html_element~get_value.

    result = mv_value.

  endmethod.

  method zif_xc_html_element~to_html.

    result = |<{ mv_tag }{ render_attributes( ) }>|
          && mv_value
          && render_children( )
          && |</{ mv_tag }>\n|.

  endmethod.

  method render_attributes.

    result = reduce string(
               init att type string
               for <a> in mt_attributes
               next att = |{ att } { <a>-name }="{ <a>-value }"| ).

  endmethod.

  method render_children.

    result = reduce string(
               init html type string
               for <c> in mt_children
               next html = html && <c>->to_html( ) ).

  endmethod.

endclass.
