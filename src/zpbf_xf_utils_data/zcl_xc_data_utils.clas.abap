class zcl_xc_data_utils definition
  public final
  create public.

  public section.

    interfaces zif_xc_data_utils.

  private section.

    "! <p class="shorttext synchronized">Resuelve el descriptor de estructura desde su nombre DDIC</p>
    "! @parameter struct_name       | Nombre de la estructura.
    "! @parameter result            | Descriptor de estructura.
    "! @raising   zcx_xc_data_utils | No existe o no es una estructura.
    methods resolve_struct
      importing struct_name   type clike
      returning value(result) type ref to cl_abap_structdescr
      raising   zcx_xc_data_utils.

endclass.


class zcl_xc_data_utils implementation.

  method zif_xc_data_utils~struct_by_field_names.

    data components type cl_abap_structdescr=>component_table.

    data(lo_struct) = resolve_struct( struct_name ).

    " Por cada componente, un campo CHAR cuya longitud es la del nombre.
    " (El valor que el caller asigne será el propio nombre del campo.)
    loop at lo_struct->components reference into data(comp).

      insert value #( name = comp->name
                      type = cl_abap_elemdescr=>get_c( strlen( comp->name ) ) )
             into table components.

    endloop.

    data(lo_result) = cl_abap_structdescr=>create( components ).

    create data result type handle lo_result.

  endmethod.

  method zif_xc_data_utils~itab_by_struct_name.

    data(lo_struct) = resolve_struct( struct_name ).

    " Crear la tabla DIRECTAMENTE del descriptor de la estructura.
    " (Preserva los tipos reales de cada campo; sin reconstruir ni /2.)
    data(lo_table) = cl_abap_tabledescr=>create( p_line_type  = lo_struct
                                                 p_table_kind = cl_abap_tabledescr=>tablekind_std
                                                 p_unique     = abap_false ).

    create data result type handle lo_table.

  endmethod.

  method resolve_struct.

    data lo_type type ref to cl_abap_typedescr.

    cl_abap_typedescr=>describe_by_name( exporting  p_name         = struct_name
                                         receiving  p_descr_ref    = lo_type
                                         exceptions type_not_found = 1
                                         others                    = 2 ).

    if sy-subrc <> 0.

      raise exception new zcx_xc_data_utils( textid    = zcx_xc_data_utils=>structure_not_found
                                             structure = conv #( struct_name ) ).
    endif.

    try.

        result = cast cl_abap_structdescr( lo_type ).

      catch cx_sy_move_cast_error into data(error).

        raise exception new zcx_xc_data_utils( textid    = zcx_xc_data_utils=>not_a_structure
                                               structure = conv #( struct_name )
                                               previous  = error ).

    endtry.

  endmethod.

endclass.
