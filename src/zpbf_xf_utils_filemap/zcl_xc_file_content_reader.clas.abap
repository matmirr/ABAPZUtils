class zcl_xc_file_content_reader definition
  public final
  create public.

  public section.

    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter content         | Contenido del archivo (líneas ya leídas).
    "! @parameter mapper          | Estrategia de mapeo de línea.
    "! @parameter has_header_line | La primera línea es cabecera.
    "! @parameter log_detail      | Acumular mensajes de detalle por línea.
    methods constructor
      importing content         type string_table
                mapper          type ref to zif_xc_line_mapper
                has_header_line type abap_bool default abap_false
                log_detail      type abap_bool default abap_true.

    "! <p class="shorttext synchronized">Procesa el contenido</p>
    "!
    "! Mapea cada línea del contenido a la estructura destino. La primera línea
    "! se trata como cabecera si así se indicó. Las líneas inválidas se descartan.
    "!
    "! @parameter cs_header          | Estructura de cabecera (si aplica).
    "! @parameter ct_records         | Tabla de registros mapeados.
    "! @raising   zcx_xc_file_mapper | Error terminal de mapeo o validación.
    methods process
      changing cs_header  type any optional
               ct_records type standard table
      raising  zcx_xc_file_mapper.

    "! <p class="shorttext synchronized">Mensajes de resultado del proceso</p>
    "! @parameter result | Mensajes acumulados (BAPIRETTAB).
    methods get_messages
      returning value(result) type bapirettab.

  private section.

    data mt_content    type string_table.
    data mo_mapper     type ref to zif_xc_line_mapper.
    data mv_has_header type abap_bool.
    data mv_log_detail type abap_bool.
    data mt_messages   type bapirettab.

    "! Agrega un mensaje de detalle (si el log de detalle está activo).
    "!
    "! @parameter msgno | Número de mensaje
    "! @parameter reg   | Número de registro
    "! @parameter type  | Tipo de mensaje
    methods log
      importing msgno type symsgno
                reg   type i
                !type type bapi_mtype default 'I'.

endclass.


class zcl_xc_file_content_reader implementation.

  method constructor.

    mt_content    = content.
    mo_mapper     = mapper.
    mv_has_header = has_header_line.
    mv_log_detail = log_detail.

  endmethod.

  method process.

    data lv_reg type i.

    loop at mt_content into data(lv_line).

      lv_reg = sy-tabix.

      log( msgno = '001'
           reg   = lv_reg ).   " Comienza el mapeo del registro &1

      " ¿Cabecera o registro?
      data(lv_is_header) = xsdbool(     mv_has_header  = abap_true
                                    and cs_header     is supplied
                                    and lv_reg         = 1 ).

      " Mapear sobre la estructura que corresponda
      data lv_ok type abap_bool.

      if lv_is_header = abap_true.

        lv_ok = mo_mapper->map( exporting line      = lv_line
                                          is_header = abap_true
                                changing  data      = cs_header
                                          messages  = mt_messages ).

      else.

        " Nuevo registro vacío al final de la tabla
        append initial line to ct_records assigning field-symbol(<record>).

        lv_ok = mo_mapper->map( exporting line      = lv_line
                                          is_header = abap_false
                                changing  data      = <record>
                                          messages  = mt_messages ).

      endif.

      " Resultado del mapeo de la línea
      if lv_ok = abap_true.

        log( msgno = '002'
             reg   = lv_reg
             type  = 'S' ).  " Procesado correctamente

      else.

        log( msgno = '003'
             reg   = lv_reg
             type  = 'E' ).  " Descartado por errores

        " Descartar: cabecera se limpia; registro se borra

        if lv_is_header = abap_true.

          clear cs_header.

        else.

          delete ct_records index lines( ct_records ).

        endif.

      endif.

    endloop.

  endmethod.

  method log.

    check mv_log_detail = abap_true.

    mt_messages = value #( base mt_messages
                           ( type       = type
                             id         = 'ZXC_FILE_MAPPER'
                             number     = msgno
                             message_v1 = |{ reg }| ) ).

  endmethod.

  method get_messages.

    result = mt_messages.

  endmethod.

endclass.
