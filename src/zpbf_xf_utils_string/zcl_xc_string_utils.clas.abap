class zcl_xc_string_utils definition
  public final
  create public.

  public section.
    interfaces zif_xc_string_utils.

  private section.
    "! <p class="shorttext synchronized">Mapea un componente al string según su tipo (recursivo)</p>
    "! @parameter component | Componente a mapear (valor, estructura o tabla).
    "! @parameter line_sep  | Separador de línea.
    "! @parameter string    | Cadena en construcción.
    "! @parameter last_kind | Tipo del último componente mapeado.
    methods map_component
      importing !component type any
                line_sep   type abap_cr_lf
      changing  !string    type string
                last_kind  type abap_typekind.

    "! <p class="shorttext synchronized">Recorre los componentes de una estructura (recursivo)</p>
    methods read_struct
      importing struct    type any
                line_sep  type abap_cr_lf
      changing  !string   type string
                last_kind type abap_typekind.

    "! <p class="shorttext synchronized">Recorre las filas de una tabla interna (recursivo)</p>
    methods read_table
      importing !table    type index table
                line_sep  type abap_cr_lf
      changing  !string   type string
                last_kind type abap_typekind.

    "! <p class="shorttext synchronized">Determina si un componente puede omitirse del mapeo</p>
    methods is_skipable
      importing !component    type any
                write_empty   type abap_bool
      returning value(result) type abap_bool.

    "! <p class="shorttext synchronized">Resuelve el descriptor de estructura desde su nombre DDIC</p>
    "! @parameter struct_name         | Nombre de la estructura.
    "! @parameter result              | Descriptor de estructura.
    "! @raising   zcx_xc_string_utils | No existe o no es una estructura.
    methods resolve_struct
      importing struct_name   type clike
      returning value(result) type ref to cl_abap_structdescr
      raising   zcx_xc_string_utils.

endclass.


class zcl_xc_string_utils implementation.

  method zif_xc_string_utils~struct_to_string.

    data last_kind type abap_typekind.

    data(components) = cast cl_abap_structdescr(
                         cl_abap_typedescr=>describe_by_data( data ) )->get_components( ).

    loop at components into data(comp).
      " Filtrado: omitir los componentes de la lista skip_fields.
      if line_exists( skip_fields[ table_line = comp-name ] ).
        continue.
      endif.

      assign component comp-name of structure data to field-symbol(<comp>).

      if is_skipable( component   = <comp>
                      write_empty = write_empty ).
        continue.
      endif.

      map_component( exporting component = <comp>
                               line_sep  = line_sep
                     changing  string    = result
                               last_kind = last_kind ).

      " Si el último componente fue una tabla interna, las filas ya vienen
      " separadas por el separador definido; no se agrega otro.
      if last_kind <> cl_abap_typedescr=>typekind_table.
        result = result && line_sep.
      endif.

    endloop.

  endmethod.

  method zif_xc_string_utils~string_to_itab.

    " Resolver la estructura del DDIC (lanza si no existe / no es estructura).
    data(lo_struct) = resolve_struct( struct_name ).

    " Crear el tipo de tabla DIRECTAMENTE del descriptor de la estructura.
    " (Evita reconstruir campo por campo y el problema de longitudes en Unicode.)
    data(lo_table) = cl_abap_tabledescr=>create( p_line_type  = lo_struct
                                                 p_table_kind = cl_abap_tabledescr=>tablekind_std
                                                 p_unique     = abap_false ).

    create data result type handle lo_table.

    assign result->* to field-symbol(<table>).

    " Separar en filas y quitar las vacías.
    split string at newline into table data(rows).

    delete rows where table_line is initial.

    data(from_index)      = cond i( when has_header = abap_true then 2 else 1 ).
    data(component_count) = lines( lo_struct->components ).

    data lr_line type ref to data.

    loop at rows into data(row) from from_index.

      split row at separator into table data(cols).

      " Validar que la cantidad de columnas coincida con la estructura.
      if lines( cols ) <> component_count.
        raise exception new zcx_xc_string_utils( textid    = zcx_xc_string_utils=>column_mismatch
                                                 structure = conv #( struct_name ) ).
      endif.

      " Construir la fila.
      create data lr_line type handle lo_struct.
      assign lr_line->* to field-symbol(<line>).

      loop at cols into data(col).

        assign component sy-tabix of structure <line> to field-symbol(<field>).

        if sy-subrc <> 0.

          raise exception new zcx_xc_string_utils( textid    = zcx_xc_string_utils=>parse_failed
                                                   structure = conv #( struct_name ) ).

        endif.

        <field> = col.
      endloop.

      insert <line> into table <table>.

    endloop.

  endmethod.

  method zif_xc_string_utils~determine_line_sep.

    " Comprobar en orden: CR_LF (2 chars), luego CR, luego LF.
    data(cr_lf) = cl_abap_char_utilities=>cr_lf.
    data(cr)    = cl_abap_char_utilities=>cr_lf(1).      " primer char = CR
    data(lf)    = cl_abap_char_utilities=>newline.       " LF

    if contains( val = data
                 sub = cr_lf ).
      result = cr_lf.
    elseif contains( val = data
                     sub = cr ).
      result = cr.
    elseif contains( val = data
                     sub = lf ).
      result = lf.
    endif.

  endmethod.

  method map_component.

    data(lo_descr) = cl_abap_typedescr=>describe_by_data( component ).

    case lo_descr->type_kind.

      when cl_abap_typedescr=>typekind_struct1
        or cl_abap_typedescr=>typekind_struct2.

        read_struct( exporting struct    = component
                               line_sep  = line_sep
                     changing  string    = string
                               last_kind = last_kind ).

        last_kind = lo_descr->type_kind.

      when cl_abap_typedescr=>typekind_table.

        read_table( exporting table     = component
                              line_sep  = line_sep
                    changing  string    = string
                              last_kind = last_kind ).

        last_kind = cl_abap_typedescr=>typekind_table.

      when others.

        string = |{ string }{ component }|.
        last_kind = lo_descr->type_kind.

    endcase.

  endmethod.

  method read_struct.

    data(components) = cast cl_abap_structdescr(
                         cl_abap_typedescr=>describe_by_data( struct ) )->get_components( ).

    loop at components into data(comp).
      assign component comp-name of structure struct to field-symbol(<field>).
      map_component( exporting component = <field>
                               line_sep  = line_sep
                     changing  string    = string
                               last_kind = last_kind ).
    endloop.

  endmethod.

  method read_table.

    loop at table assigning field-symbol(<row>).

      map_component( exporting component = <row>
                               line_sep  = line_sep
                     changing  string    = string
                               last_kind = last_kind ).

      string = string && line_sep.

    endloop.

  endmethod.

  method is_skipable.

    result = xsdbool( component is initial and write_empty = abap_false ).

  endmethod.

  method resolve_struct.

    data lo_type type ref to cl_abap_typedescr.

    cl_abap_typedescr=>describe_by_name( exporting  p_name         = struct_name
                                         receiving  p_descr_ref    = lo_type
                                         exceptions type_not_found = 1
                                                    others         = 2 ).

    if sy-subrc <> 0.

      raise exception new zcx_xc_string_utils( textid    = zcx_xc_string_utils=>structure_not_found
                                               structure = conv #( struct_name ) ).

    endif.

    try.

        result = cast cl_abap_structdescr( lo_type ).

      catch cx_sy_move_cast_error into data(error).

        raise exception new zcx_xc_string_utils( textid    = zcx_xc_string_utils=>not_a_structure
                                                 structure = conv #( struct_name )
                                                 previous  = error ).

    endtry.

  endmethod.

endclass.
