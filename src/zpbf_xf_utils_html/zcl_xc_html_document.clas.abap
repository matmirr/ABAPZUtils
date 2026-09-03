class zcl_xc_html_document definition
  public
  inheriting from zcl_xc_html_element final
  create public.

  public section.
    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter page_title | Título de la página (va dentro de un nodo title en el head).
    methods constructor
      importing page_title type string.

    "! <p class="shorttext synchronized">Devuelve el nodo head del documento</p>
    "! @parameter result | Nodo head.
    methods get_head
      returning value(result) type ref to zif_xc_html_element.

    "! <p class="shorttext synchronized">Devuelve el nodo body del documento</p>
    "! @parameter result | Nodo body.
    methods get_body
      returning value(result) type ref to zif_xc_html_element.

    "! <p class="shorttext synchronized">Agrega un salto de línea al body</p>
    "! @parameter result | El propio documento (para encadenar).
    methods line_break
      returning value(result) type ref to zcl_xc_html_document.

  private section.
    data mo_head type ref to zif_xc_html_element.
    data mo_body type ref to zif_xc_html_element.

endclass.


class zcl_xc_html_document implementation.

  method constructor.
    super->constructor( tag = 'html' ).

    mo_head = new zcl_xc_html_element( tag = 'head' ).
    mo_body = new zcl_xc_html_element( tag = 'body' ).

    " El título va DENTRO de un nodo <title>, no como texto suelto del head.
    " (Corrige el bug del legacy, que generaba <head>texto</head>.)
    mo_head->add_child( new zcl_xc_html_title( page_title ) ).

    zif_xc_html_element~add_child( mo_head ).
    zif_xc_html_element~add_child( mo_body ).
  endmethod.

  method get_head.
    result = mo_head.
  endmethod.

  method get_body.
    result = mo_body.
  endmethod.

  method line_break.
    mo_body->add_child( new zcl_xc_html_line_break( ) ).
    result = me.
  endmethod.

endclass.
