class zcl_xc_struct_table_mapper definition
  public final
  create public.

  public section.

    interfaces zif_xc_file_section.

    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter data   | Tabla interna de datos a mapear (una fila = un grupo de líneas).
    "! @parameter config | Filas de configuración (ZXC_STRUCT_MAP) del proceso.
    methods constructor
      importing !data  type any table
                config type zxc_t_struct_map.

    "! <p class="shorttext synchronized">Registra un transformador de campo</p>
    "!
    "! El transformador se aplicará a cada fila de la tabla.
    "!
    "! @parameter key         | Clave del transformador (columna ACCIÓN).
    "! @parameter transformer | Implementación del transformador.
    "! @parameter result      | El propio mapper de tabla (para encadenar).
    methods add_transformer
      importing !key          type zxc_accion
                transformer   type ref to zif_xc_field_transformer
      returning value(result) type ref to zcl_xc_struct_table_mapper.

  private section.

    types: begin of ts_transformer,
             key         type zxc_accion,
             transformer type ref to zif_xc_field_transformer,
           end of ts_transformer.
    types tt_transformer type sorted table of ts_transformer with unique key key.

    data mr_table        type ref to data.
    data mt_config       type zxc_t_struct_map.
    data mt_transformers type tt_transformer.

endclass.


class zcl_xc_struct_table_mapper implementation.

  method constructor.

    get reference of data into mr_table.
    mt_config = config.

  endmethod.

  method add_transformer.

    insert value #( key         = key
                    transformer = transformer ) into table mt_transformers.
    result = me.

  endmethod.

  method zif_xc_file_section~render.

    field-symbols <table> type any table.

    assign mr_table->* to <table>.

    " Por cada fila de la tabla, se delega a un mapper de estructura,
    " reutilizando la misma config y los mismos transformadores.
    loop at <table> assigning field-symbol(<row>).

      data(lo_row_mapper) = new zcl_xc_struct_mapper( data   = <row>
                                                      config = mt_config ).

      " Propagar los transformadores registrados a cada fila.
      loop at mt_transformers into data(ls_t).

        lo_row_mapper->add_transformer( key         = ls_t-key
                                        transformer = ls_t-transformer ).

      endloop.

      result = result && lo_row_mapper->zif_xc_file_section~render( ).

    endloop.

  endmethod.

endclass.
