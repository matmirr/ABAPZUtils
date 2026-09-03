class zcl_xc_object_repository definition
  public final
  create public.

  public section.

    interfaces zif_xc_object_repository.

    "! <p class="shorttext synchronized">Constructor</p>
    "!
    "! @parameter serializer | Serializador a usar para convertir los objetos
    "!                         a/desde su representación binaria persistida.
    methods constructor
      importing serializer type ref to zif_xc_object_serializer.

  private section.

    data mo_serializer type ref to zif_xc_object_serializer.

    "! <p class="shorttext synchronized">Genera una nueva clave única (UUID c32)</p>
    "!
    "! @parameter result               | UUID en formato C32.
    "! @raising   zcx_xc_serialization | Falla en la generación del UUID.
    methods new_key
      returning value(result) type sysuuid_c32
      raising   zcx_xc_serialization.

    "! <p class="shorttext synchronized">Obtiene el nombre de clase de una instancia (RTTI)</p>
    "!
    "! @parameter object | Instancia a inspeccionar.
    "! @parameter result | Nombre relativo de la clase.
    methods class_name_of
      importing !object       type ref to if_serializable_object
      returning value(result) type string.

endclass.


class zcl_xc_object_repository implementation.

  method constructor.

    mo_serializer = serializer.

  endmethod.

  method zif_xc_object_repository~save.

    data ls_store type zxc_obj_store.

    object_key = new_key( ).

    get time stamp field data(lv_now).

    ls_store-repid      = repid.
    ls_store-run_id     = run_id.
    ls_store-object_key = object_key.
    ls_store-class_name = class_name_of( object ).
    ls_store-payload    = mo_serializer->serialize( object ).
    ls_store-created_at = lv_now.
    ls_store-created_by = sy-uname.

    insert zxc_obj_store from @ls_store.

  endmethod.

  method zif_xc_object_repository~load.

    select single payload from zxc_obj_store
      where repid      = @repid
        and run_id     = @run_id
        and object_key = @object_key
      into @data(lv_payload).

    if sy-subrc <> 0.
      return.   " No encontrado: referencia inicial (object IS NOT BOUND).
    endif.

    object = mo_serializer->deserialize( lv_payload ).

  endmethod.

  method zif_xc_object_repository~load_run.

    select from zxc_obj_store
      fields object_key, class_name, payload
      where repid  = @repid
        and run_id = @run_id
      order by created_at
      into table @data(lt_rows).

    loop at lt_rows into data(ls_row).
      append value #( object_key = ls_row-object_key
                      class_name = ls_row-class_name
                      object     = mo_serializer->deserialize( ls_row-payload ) )
             to result.
    endloop.

  endmethod.

  method zif_xc_object_repository~list_runs.

    select from zxc_obj_store
      fields run_id,
             min( created_at ) as created_at,
             count(*)          as object_count
      where repid = @repid
      group by run_id
      order by created_at
      into table @data(lt_runs).

    result = value #( for ls_run in lt_runs
                      ( run_id       = ls_run-run_id
                        created_at   = ls_run-created_at
                        object_count = ls_run-object_count ) ).

  endmethod.

  method zif_xc_object_repository~delete_run.

    delete from zxc_obj_store
      where repid  = @repid
        and run_id = @run_id.

  endmethod.

  method zif_xc_object_repository~delete.

    delete from zxc_obj_store
      where repid      = @repid
        and run_id     = @run_id
        and object_key = @object_key.

  endmethod.

  method new_key.

    try.

        result = cl_system_uuid=>create_uuid_c32_static( ).

      catch cx_uuid_error into data(error).

        raise exception new zcx_xc_serialization( textid   = zcx_xc_serialization=>serialization_failed
                                                  previous = error ).

    endtry.

  endmethod.

  method class_name_of.

    data(lo_descr) = cl_abap_classdescr=>describe_by_object_ref( object ).

    result = lo_descr->get_relative_name( ).

  endmethod.

endclass.
