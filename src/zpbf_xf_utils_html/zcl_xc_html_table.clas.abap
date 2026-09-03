class zcl_xc_html_table definition
  public
  inheriting from zcl_xc_html_element final
  create public.

  public section.

    types: begin of ts_label,
             field type string,
             label type string,
           end of ts_label.
    types tt_label type sorted table of ts_label with unique key field.

    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter id    | Atributo id. Opcional.
    "! @parameter class | Atributo class. Opcional.
    methods constructor
      importing !id    type string optional
                !class type string optional.

    "! <p class="shorttext synchronized">Llena la tabla a partir de una tabla interna</p>
    "!
    "! Genera una fila de encabezado y una fila por cada registro de la tabla.
    "! Los campos que sean tablas internas anidadas se aplanan a CSV.
    "!
    "! @parameter data           | Tabla interna de datos.
    "! @parameter visible_fields | Lista de campos visibles separados por coma. Si se omite, todos.
    "! @parameter labels         | Etiquetas de columna por campo. Opcional (fallback: nombre técnico).
    "! @raising   zcx_xc_html    | El dato proporcionado no es una tabla interna.
    methods set_table_data
      importing !data          type any table
                visible_fields type clike    optional
                labels         type tt_label optional
      raising   zcx_xc_html.

    "! <p class="shorttext synchronized">Llena la tabla a partir de una estructura</p>
    "!
    "! Genera, por cada campo visible, una fila con su etiqueta y su valor.
    "! Los campos que sean tablas internas anidadas se aplanan a CSV.
    "!
    "! @parameter data           | Estructura de datos.
    "! @parameter visible_fields | Lista de campos visibles separados por coma. Si se omite, todos.
    "! @parameter labels         | Etiquetas de columna por campo. Opcional (fallback: nombre técnico).
    "! @raising   zcx_xc_html    | El dato proporcionado no es una estructura.
    methods set_struct_data
      importing !data          type any
                visible_fields type clike    optional
                labels         type tt_label optional
      raising   zcx_xc_html.

  protected section.

  private section.

    data mt_visible type string_table.
    data mt_labels  type tt_label.

    "! Prepara el estado interno (campos visibles + labels) común a ambos métodos.
    "!
    "! @parameter visible_fields | Campos visibles
    "! @parameter labels         | Etiquetas
    methods prepare
      importing visible_fields type clike
                labels         type tt_label.

    "! Indica si un campo debe mostrarse (según la lista de visibles).
    "!
    "! @parameter field  | Campo
    "! @parameter result | ¿Es visible?
    methods is_visible
      importing !field        type clike
      returning value(result) type abap_bool.

    "! Resuelve la etiqueta de una columna: label configurado o nombre técnico (fallback).
    "! Punto único de extensión futura para resolución vía XCO.
    "!
    "! @parameter field  | Campo
    "! @parameter result | Etiqueta
    methods resolve_label
      importing !field        type clike
      returning value(result) type string.

    "! Devuelve los componentes de un descriptor de estructura vía RTTI.
    "!
    "! @parameter descr  | Descriptor
    "! @parameter result | Componentes
    methods components_of_descr
      importing descr         type ref to cl_abap_typedescr
      returning value(result) type abap_component_tab.

    "! Convierte un valor de campo a string; aplana tablas internas anidadas a CSV.
    "!
    "! @parameter value  | Valor de campo
    "! @parameter result | String
    methods value_to_string
      importing !value        type any
      returning value(result) type string.

endclass.


class zcl_xc_html_table implementation.

  method constructor.

    super->constructor( tag   = 'table'
                        id    = id
                        class = class ).

  endmethod.

  method prepare.

    clear: mt_visible,
           mt_labels.

    mt_labels = labels.

    if visible_fields is not initial.

      data(lv_upper) = to_upper( visible_fields ).
      split lv_upper at ',' into table mt_visible.

    endif.

  endmethod.

  method is_visible.

    " Sin lista de visibles => todos visibles.
    result = cond #( when mt_visible is initial
                     then abap_true
                     else xsdbool( line_exists( mt_visible[ table_line = to_upper( field ) ] ) ) ).
  endmethod.

  method resolve_label.

    " Prioridad 1: label configurado por el caller.
    if line_exists( mt_labels[ field = to_upper( field ) ] ).
      result = mt_labels[ field = to_upper( field ) ]-label.
      return.
    endif.

    " Prioridad 2 (fallback): nombre técnico del campo.
    " (Punto único donde, a futuro, podría resolverse el texto vía XCO.)
    result = field.

  endmethod.

  method components_of_descr.

    result = cast cl_abap_structdescr( descr )->get_components( ).

  endmethod.

  method value_to_string.

    data(lo_type) = cl_abap_typedescr=>describe_by_data( value ).

    " Si el campo es una tabla interna anidada, se aplana a CSV.
    if lo_type->type_kind = cl_abap_typedescr=>typekind_table.

      assign value to field-symbol(<tab>).

      data(lv_csv) = ``.

      loop at <tab> assigning field-symbol(<row>).

        lv_csv = cond #( when lv_csv is initial
                         then |{ <row> }|
                         else |{ lv_csv },{ <row> }| ).

      endloop.

      result = lv_csv.

    else.

      result = |{ value }|.

    endif.

  endmethod.

  method set_table_data.

    prepare( visible_fields = visible_fields
             labels         = labels ).

    data(lo_table) = cl_abap_typedescr=>describe_by_data( data ).

    try.

        data(lo_line) = cast cl_abap_tabledescr( lo_table )->get_table_line_type( ).
        data(components) = components_of_descr( lo_line ).

      catch cx_sy_move_cast_error into data(error).

        raise exception new zcx_xc_html( textid   = zcx_xc_html=>not_a_table
                                         previous = error ).

    endtry.

    " --- Fila de encabezado ---
    data(header_row) = new zcl_xc_html_table_row( ).

    zif_xc_html_element~add_child( header_row ).

    loop at components into data(comp).

      if is_visible( comp-name ) = abap_false.
        continue.
      endif.

      header_row->zif_xc_html_element~add_child( new zcl_xc_html_table_header_cell( resolve_label( comp-name ) ) ).

    endloop.

    " --- Filas de datos ---
    loop at data assigning field-symbol(<line>).

      data(data_row) = new zcl_xc_html_table_row( ).

      zif_xc_html_element~add_child( data_row ).

      loop at components into comp.

        if is_visible( comp-name ) = abap_false.
          continue.
        endif.

        assign component comp-name of structure <line> to field-symbol(<value>).

        data_row->zif_xc_html_element~add_child( new zcl_xc_html_table_cell( value_to_string( <value> ) ) ).

      endloop.

    endloop.

  endmethod.

  method set_struct_data.

    prepare( visible_fields = visible_fields
             labels         = labels ).

    data(lo_descr) = cl_abap_typedescr=>describe_by_data( data ).

    try.

        data(components) = components_of_descr( lo_descr ).

      catch cx_sy_move_cast_error into data(error).

        raise exception new zcx_xc_html( textid   = zcx_xc_html=>not_a_structure
                                         previous = error ).

    endtry.

    " Una fila por campo: [ etiqueta | valor ]
    loop at components into data(comp).

      if is_visible( comp-name ) = abap_false.
        continue.
      endif.

      data(row) = new zcl_xc_html_table_row( ).
      zif_xc_html_element~add_child( row ).

      row->zif_xc_html_element~add_child( new zcl_xc_html_table_header_cell( resolve_label( comp-name ) ) ).

      assign component comp-name of structure data to field-symbol(<value>).

      row->zif_xc_html_element~add_child( new zcl_xc_html_table_cell( value_to_string( <value> ) ) ).

    endloop.

  endmethod.

endclass.
