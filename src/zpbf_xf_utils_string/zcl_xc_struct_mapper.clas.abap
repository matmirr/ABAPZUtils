class zcl_xc_struct_mapper definition
  public final
  create public.

  public section.

    interfaces zif_xc_file_section.

    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter data   | Estructura de datos a mapear.
    "! @parameter config | Filas de configuración (ZXC_STRUCT_MAP) del proceso.
    methods constructor
      importing !data  type any
                config type zxc_t_struct_map.

    "! <p class="shorttext synchronized">Registra un transformador de campo</p>
    "! @parameter key         | Clave del transformador (columna ACCION).
    "! @parameter transformer | Implementación del transformador.
    "! @parameter result      | El propio mapper (para encadenar).
    methods add_transformer
      importing !key          type zxc_accion
                transformer   type ref to zif_xc_field_transformer
      returning value(result) type ref to zcl_xc_struct_mapper.

  private section.

    types: begin of ts_transformer,
             key         type zxc_accion,
             transformer type ref to zif_xc_field_transformer,
           end of ts_transformer.
    types tt_transformer type sorted table of ts_transformer with unique key key.

    data mr_data         type ref to data.
    data mt_config       type zxc_t_struct_map.
    data mt_transformers type tt_transformer.

    "! Resuelve el valor crudo de un campo de la estructura.
    "!
    "! @parameter field                | Nombre del campo a mapear (acepta 'ESTRUCT-CAMPO' o 'CAMPO').
    "! @parameter result               | Valor crudo del campo, convertido a texto.
    "! @raising   zcx_xc_struct_mapper | El campo no existe en la estructura.
    methods map_field
      importing !field        type zxc_campo
      returning value(result) type string
      raising   zcx_xc_struct_mapper.

    "! Aplica el transformador indicado (si la clave no es inicial).
    "!
    "! @parameter key                  | Clave del transformador (columna ACCIÓN). Si es inicial, no transforma.
    "! @parameter value                | Valor crudo a transformar.
    "! @parameter result               | Valor transformado, o el original si no hay transformador.
    "! @raising   zcx_xc_struct_mapper | La clave indicada no corresponde a ningún transformador registrado.
    methods apply_transformer
      importing !key          type zxc_accion
                !value        type string
      returning value(result) type string
      raising   zcx_xc_struct_mapper.

    "! Da formato de ancho fijo con alineación a un valor.
    "!
    "! @parameter value     | Valor a formatear.
    "! @parameter length    | Ancho fijo de salida. Si el valor excede, se trunca.
    "! @parameter alignment | Alineación dentro del ancho: 'DER' derecha; 'IZQ' o vacío, izquierda.
    "! @parameter result    | Valor ajustado al ancho fijo con la alineación indicada.
    methods format_value
      importing !value        type string
                !length       type zxc_longitud
                alignment     type zxc_alineacion
      returning value(result) type string.

endclass.


class zcl_xc_struct_mapper implementation.

  method constructor.

    get reference of data into mr_data.
    mt_config = config.

  endmethod.

  method add_transformer.

    insert value #( key         = key
                    transformer = transformer ) into table mt_transformers.
    result = me.

  endmethod.

  method zif_xc_file_section~render.

    " 1) Sin configuración => error explícito.
    if mt_config is initial.
      raise exception new zcx_xc_struct_mapper( textid = zcx_xc_struct_mapper=>config_not_found ).
    endif.

    " 2) Ordenar por registro (línea) y campo (orden dentro de la línea).
    data(lt_config) = mt_config.
    sort lt_config by nro_registro
                      nro_campo.

    " 3) Recorrer con detección manual de cambio de grupo sobre NRO_REGISTRO.
    data lv_line     type string.
    data lv_first    type abap_bool value abap_true.
    data lv_prev_reg type zxc_nro_registro.

    loop at lt_config into data(ls_cfg).
      " ¿Cambió el número de registro? => cerrar la línea anterior.
      if lv_first = abap_false and ls_cfg-nro_registro <> lv_prev_reg.
        result = result && lv_line && cl_abap_char_utilities=>cr_lf.
        clear lv_line.
      endif.

      " Solo filas activas.
      if ls_cfg-activo = abap_true.
        data(lv_raw)    = map_field( ls_cfg-campo ).
        data(lv_transf) = apply_transformer( key   = ls_cfg-accion
                                             value = lv_raw ).
        lv_line = lv_line && format_value( value     = lv_transf
                                           length    = ls_cfg-longitud
                                           alignment = ls_cfg-alineacion ).
      endif.

      lv_prev_reg = ls_cfg-nro_registro.
      lv_first    = abap_false.
    endloop.

    " 4) Cerrar la última línea.
    if lv_first = abap_false.
      result = result && lv_line && cl_abap_char_utilities=>cr_lf.
    endif.
  endmethod.

  method map_field.

    " Campo de un solo nivel. Tolerante a 'ESTRUCT-CAMPO' o 'CAMPO'.
    data(lv_name) = field.
    if lv_name cs '-'.
      split lv_name at '-' into table data(lt_parts).
      lv_name = lt_parts[ lines( lt_parts ) ].   " la última parte = nombre del campo
    endif.

    assign mr_data->* to field-symbol(<data>).
    assign component lv_name of structure <data> to field-symbol(<field>).
    if sy-subrc <> 0.
      raise exception new zcx_xc_struct_mapper( textid = zcx_xc_struct_mapper=>field_not_found
                                                value  = conv #( field ) ).
    endif.

    result = |{ <field> }|.

  endmethod.

  method apply_transformer.

    " Sin acción => valor sin transformar.
    if key is initial.
      result = value.
      return.
    endif.

    " Buscar el transformador registrado.
    try.

        data lo_transf type ref to zif_xc_field_transformer.

        lo_transf = mt_transformers[ key = key ]-transformer.

      catch cx_sy_itab_line_not_found.

        raise exception new zcx_xc_struct_mapper( textid = zcx_xc_struct_mapper=>transformer_not_found
                                                  value  = conv #( key ) ).

    endtry.

    result = lo_transf->transform( value ).

  endmethod.

  method format_value.

    data(lv_val) = value.

    " Truncar si excede la longitud.
    if strlen( lv_val ) > length.
      lv_val = lv_val(length).
      result = lv_val.
      return.
    endif.

    " Rellenar a la longitud según alineación.
    case alignment.
      when 'DER'.
        result = |{ lv_val align = right width = length }|.
      when others.   " 'IZQ' o vacío => izquierda
        result = |{ lv_val align = left width = length }|.
    endcase.
  endmethod.

endclass.
