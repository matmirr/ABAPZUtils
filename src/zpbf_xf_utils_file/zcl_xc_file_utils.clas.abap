class zcl_xc_file_utils definition
  public final
  create public.

  public section.

    interfaces zif_xc_file_utils.

    "! <p class="shorttext synchronized">Vía lógica por defecto para el ámbito seguro</p>
    constants co_default_logical_path type fileintern value 'EHS_FTAPPL_2'.

    "! <p class="shorttext synchronized">Constructor</p>
    "!
    "! @parameter codepage     | Codepage ISO para conversión (ver TCP00A,
    "!                           CPATTRKIND = 'H'). Default UTF-8.
    "! @parameter line_break   | Separador de línea para append/write.
    "!                           Default CR_LF (compatible con Excel/Windows).
    "! @parameter logical_path | Logical filename del ámbito seguro.
    "!                           Default co_default_logical_path.
    methods constructor
      importing codepage     type string     default `UTF-8`
                line_break   type abap_cr_lf default cl_abap_char_utilities=>cr_lf
                logical_path type fileintern default co_default_logical_path.

  private section.

    data mv_codepage     type string.
    data mv_line_break   type abap_cr_lf.
    data mv_logical_path type fileintern.

    "! <p class="shorttext synchronized">Convierte un string a xstring según el codepage de la instancia</p>
    "!
    "! @parameter content           | Contenido de texto a convertir.
    "! @parameter result            | Representación binaria según el codepage configurado.
    "! @raising   zcx_xc_file_utils | Falla en la conversión de codepage.
    methods to_xstring
      importing content       type string
      returning value(result) type xstring
      raising   zcx_xc_file_utils.

    "! <p class="shorttext synchronized">Lee un archivo del AS completo a xstring</p>
    "!
    "! @parameter file              | Ruta completa del archivo a leer.
    "! @parameter result            | Contenido binario del archivo.
    "! @raising   zcx_xc_file_utils | Falla al abrir o leer el archivo.
    methods read_to_xstring
      importing !file         type string
      returning value(result) type xstring
      raising   zcx_xc_file_utils.

    "! <p class="shorttext synchronized">Escribe un xstring en modo append, con bloqueo opcional</p>
    "!
    "! Helper de escritura compartido por append_string y append_file. Abre el
    "! archivo en modo append binario y transfiere el contenido. Si concurrent
    "! es abap_true, serializa la escritura mediante bloqueo para soportar
    "! escritores concurrentes sobre el mismo archivo.
    "!
    "! @parameter xcontent          | Contenido binario a agregar.
    "! @parameter target            | Ruta completa del archivo destino.
    "! @parameter concurrent        | Si abap_true, protege la escritura con bloqueo.
    "! @raising   zcx_xc_file_utils | Falla al bloquear, abrir o escribir.
    methods append_with_lock
      importing xcontent   type xstring
                !target    type string
                concurrent type abap_bool
      raising   zcx_xc_file_utils.

    "! <p class="shorttext synchronized">Verifica si un archivo existe en el AS</p>
    "!
    "! Comprueba la existencia intentando abrir el archivo para lectura.
    "!
    "! @parameter file              | Ruta completa del archivo.
    "! @parameter result            | abap_true si el archivo existe y es accesible.
    "! @raising   zcx_xc_file_utils | Reservado para fallas de acceso no esperadas.
    methods file_exists
      importing !file         type string
      returning value(result) type abap_bool
      raising   zcx_xc_file_utils.

    "! <p class="shorttext synchronized">Resuelve el path del ámbito seguro</p>
    "!
    "! Determina el directorio del ámbito seguro a partir del logical filename
    "! configurado en la instancia, mediante FILE_GET_NAME.
    "!
    "! @parameter result            | Path físico del ámbito seguro.
    "! @raising   zcx_xc_file_utils | No se pudo determinar el ámbito seguro.
    methods resolve_scope
      returning value(result) type string
      raising   zcx_xc_file_utils.

    "! <p class="shorttext synchronized">Verifica que un archivo esté dentro del ámbito seguro</p>
    "!
    "! @parameter file              | Ruta completa del archivo a validar.
    "! @parameter scope             | Path del ámbito seguro permitido.
    "! @raising   zcx_xc_file_utils | El archivo está fuera del ámbito seguro.
    methods check_in_scope
      importing !file  type string
                !scope type string
      raising   zcx_xc_file_utils.

    "! <p class="shorttext synchronized">Calcula la clave de bloqueo a partir del path</p>
    "!
    "! Genera un hash MD5 (32 caracteres hex) del path para usarlo como clave
    "! de bloqueo de longitud fija. El hash NO tiene fines criptográficos; solo
    "! mapea un path de longitud variable a una clave de longitud acotada.
    "!
    "! @parameter file   | Ruta completa del archivo.
    "! @parameter result | Hash MD5 del path (32 caracteres).
    methods build_lock_key
      importing !file         type string
      returning value(result) type char32.

    "! <p class="shorttext synchronized">Setea el bloqueo de escritura sobre el archivo</p>
    "!
    "! @parameter file              | Ruta completa del archivo a bloquear.
    "! @raising   zcx_xc_file_utils | No se pudo obtener el bloqueo.
    methods enqueue_file
      importing !file type string
      raising   zcx_xc_file_utils.

    "! <p class="shorttext synchronized">Libera el bloqueo de escritura sobre el archivo</p>
    "!
    "! @parameter file | Ruta completa del archivo a desbloquear.
    methods dequeue_file
      importing !file type string.

    "! <p class="shorttext synchronized">Lista los archivos de un directorio del AS</p>
    "!
    "! Encapsula el listado del directorio del application server mediante el
    "! kernel call C_DIR_READ_*. Devuelve cada archivo con su metadata. Los no
    "! usables (directorios, devices, tamaño 0, errores) se marcan con
    "! USEABLE = space. Las entradas triviales '.' y '..' se descartan.
    "!
    "! @parameter dirname           | Directorio a listar.
    "! @parameter filename          | Filtro opcional por nombre de archivo.
    "! @parameter pattern           | Patrón opcional de coincidencia (estilo CP).
    "! @parameter result            | Lista de archivos con metadata.
    "! @raising   zcx_xc_file_utils | Falla al iniciar el listado del directorio.
    methods list_directory
      importing dirname       type string
                filename      type string
                !pattern      type string
      returning value(result) type zxc_t_file_info
      raising   zcx_xc_file_utils.

endclass.


class zcl_xc_file_utils implementation.

  method constructor.

    mv_codepage     = codepage.
    mv_line_break   = line_break.
    mv_logical_path = logical_path.

  endmethod.

  method zif_xc_file_utils~write_file.

    data(xcontent) = to_xstring( content ).

    open dataset target_file for output
                             in binary mode
                             message data(lv_msg).
    if sy-subrc <> 0.

      raise exception new zcx_xc_file_utils( textid   = zcx_xc_file_utils=>open_for_write_failed
                                             filename = |{ target_file } ({ lv_msg })| ).

    endif.

    try.
        transfer xcontent to target_file.

      catch cx_sy_file_io into data(error).

        close dataset target_file.

        raise exception new zcx_xc_file_utils( textid   = zcx_xc_file_utils=>write_failed
                                               filename = target_file
                                               previous = error ).
    endtry.

    close dataset target_file.

  endmethod.

  method zif_xc_file_utils~append_string.

    data(xcontent) = to_xstring( content ).

    append_with_lock( xcontent   = xcontent
                      target     = target_file
                      concurrent = concurrent ).

  endmethod.

  method zif_xc_file_utils~append_file.

    " Validaciones: si fallan, lanzan excepción (no hay retorno silencioso).
    zif_xc_file_utils~defensive_check( input_file  = input_file
                                       output_file = output_file ).

    if file_exists( input_file ) = abap_false.

      raise exception new zcx_xc_file_utils( textid   = zcx_xc_file_utils=>file_not_found
                                             filename = input_file ).

    endif.

    data(xcontent) = read_to_xstring( input_file ).

    append_with_lock( xcontent   = xcontent
                      target     = output_file
                      concurrent = concurrent ).

    if delete_source = abap_true.

      delete dataset input_file.

    endif.

  endmethod.

  method zif_xc_file_utils~defensive_check.

    data(scope) = resolve_scope( ).

    check_in_scope( file  = input_file
                    scope = scope ).

    if output_file is supplied and output_file is not initial.

      check_in_scope( file  = output_file
                      scope = scope ).

    endif.

  endmethod.

  method zif_xc_file_utils~list.

    result = list_directory( dirname  = dirname
                             filename = filename
                             pattern  = pattern ).

  endmethod.

  method to_xstring.

    try.
        result = cl_abap_conv_codepage=>create_out( codepage = mv_codepage )->convert( source = content ).

      catch cx_sy_conversion_codepage into data(error).

        raise exception new zcx_xc_file_utils( textid   = zcx_xc_file_utils=>write_failed
                                               previous = error ).

    endtry.

  endmethod.

  method read_to_xstring.

    open dataset file for input
                      in binary mode
                      message data(lv_msg).

    if sy-subrc <> 0.

      raise exception new zcx_xc_file_utils( textid   = zcx_xc_file_utils=>open_for_read_failed
                                             filename = |{ file } ({ lv_msg })| ).

    endif.

    try.

        read dataset file into result.

      catch cx_sy_file_io into data(error).

        close dataset file.

        raise exception new zcx_xc_file_utils( textid   = zcx_xc_file_utils=>open_for_read_failed
                                               filename = |{ file } ({ lv_msg })|
                                               previous = error ).
    endtry.

    close dataset file.

  endmethod.

  method append_with_lock.

    if concurrent = abap_true.
      enqueue_file( target ).
    endif.

    open dataset target for appending
         in binary mode
         message data(lv_msg).

    if sy-subrc <> 0.

      if concurrent = abap_true.

        dequeue_file( target ).

      endif.

      raise exception new zcx_xc_file_utils( textid   = zcx_xc_file_utils=>open_for_write_failed
                                             filename = |{ target } ({ lv_msg })| ).
    endif.

    try.

        transfer xcontent to target.

      catch cx_sy_file_io into data(error).

        close dataset target.
        if concurrent = abap_true.
          dequeue_file( target ).
        endif.

        raise exception new zcx_xc_file_utils( textid   = zcx_xc_file_utils=>write_failed
                                               filename = target
                                               previous = error ).
    endtry.

    close dataset target.

    if concurrent = abap_true.
      dequeue_file( target ).
    endif.

  endmethod.

  method file_exists.

    open dataset file for input
         in binary mode
         message data(lv_msg) ##needed.

    if sy-subrc = 0.
      close dataset file.
      result = abap_true.
    else.
      result = abap_false.
    endif.

  endmethod.

  method resolve_scope.

    call function 'FILE_GET_NAME'
      exporting  logical_filename = mv_logical_path
                 including_dir    = abap_true
      importing  file_name        = result
      exceptions file_not_found   = 1
                 others           = 2.

    if sy-subrc <> 0 or result is initial.

      raise exception new zcx_xc_file_utils( textid       = zcx_xc_file_utils=>scope_undetermined
                                             logical_path = conv string( mv_logical_path ) ).

    endif.

  endmethod.

  method check_in_scope.

    if substring_to( val = file
                     sub = scope ) <> scope.

      raise exception new zcx_xc_file_utils( textid   = zcx_xc_file_utils=>out_of_scope
                                             filename = file
                                             scope    = scope ).

    endif.

  endmethod.

  method build_lock_key.

    " Hash NO criptográfico: solo para obtener una clave de longitud fija
    " a partir del path. MD5 hex = 32 caracteres.
    try.
        cl_abap_message_digest=>calculate_hash_for_char( exporting if_algorithm  = 'MD5'
                                                                   if_data       = file
                                                         importing ef_hashstring = data(lv_hash) ).

        result = lv_hash.

      catch cx_abap_message_digest.
        " Fallback improbable: si el hash fallara, usamos el path truncado.
        result = file.

    endtry.

  endmethod.

  method enqueue_file.

    data(lv_key) = build_lock_key( file ).

    call function 'ENQUEUE_EZXC_FILE_LOCK'
      exporting  lock_key       = lv_key
      exceptions foreign_lock   = 1
                 system_failure = 2
                 others         = 3.

    if sy-subrc <> 0.

      raise exception new zcx_xc_file_utils( textid   = zcx_xc_file_utils=>lock_failed
                                             filename = file ).

    endif.

  endmethod.

  method dequeue_file.

    data(lv_key) = build_lock_key( file ).

    call function 'DEQUEUE_EZXC_FILE_LOCK'
      exporting lock_key = lv_key.

  endmethod.

  method list_directory.

    types: begin of ts_file,
             type    type c length 10,
             name    type c length 75,
             len     type n length 16,
             owner   type c length 8,
             mtime   type n length 16,
             fmode   type c length 9,
             errno   type c length 3,
             errmsg  type c length 40,
             useable type abap_bool,
           end of ts_file.

    data(ls_file) = value ts_file( ).

    data(lv_errcnt) = value i( ).

    " Conversión epoch Unix (segundos desde 1970-01-01 UTC) -> TIMESTAMP.
    data lv_date     type d.
    data lv_time     type t.
    data lv_seconds  type i.
    data lv_mtime_ts type timestamp.

    constants lc_no      type c length 1 value ' '.
    constants lc_max_err type i          value 10.

    " Cierre defensivo de cualquier lectura previa interrumpida.
    call 'C_DIR_READ_FINISH'
         id 'ERRNO'  field ls_file-errno
         id 'ERRMSG' field ls_file-errmsg.

    call 'C_DIR_READ_START'
         id 'DIR'    field dirname
         id 'FILE'   field filename
         id 'ERRNO'  field ls_file-errno
         id 'ERRMSG' field ls_file-errmsg.

    if sy-subrc <> 0.

      raise exception new zcx_xc_file_utils( textid  = zcx_xc_file_utils=>list_failed
                                             dirname = dirname ).

    endif.

    do.
      clear ls_file.

      call 'C_DIR_READ_NEXT'
           id 'TYPE'   field ls_file-type
           id 'NAME'   field ls_file-name
           id 'LEN'    field ls_file-len
           id 'OWNER'  field ls_file-owner
           id 'MTIME'  field ls_file-mtime
           id 'MODE'   field ls_file-fmode
           id 'ERRNO'  field ls_file-errno
           id 'ERRMSG' field ls_file-errmsg.

      case sy-subrc.

        when 0.

          clear: ls_file-errno,
                 ls_file-errmsg.

          " Solo archivos normales son usables; directorios/devices/vacíos no.
          ls_file-useable = abap_true.

          if to_upper( ls_file-type(1) ) <> 'F'.
            ls_file-useable = lc_no.
          endif.
          if ls_file-len = 0.
            ls_file-useable = lc_no.
          endif.

        when 1.
          exit.

        when others.
          lv_errcnt += 1.
          if lv_errcnt > lc_max_err.
            exit.
          endif.
          ls_file-useable = lc_no.
      endcase.

      if pattern is initial or ls_file-name cp pattern.

        lv_seconds = ls_file-mtime.
        lv_date = '19700101'.
        lv_date += ( lv_seconds div 86400 ).   " días completos desde epoch
        lv_time = lv_seconds mod 86400.                  " segundos restantes del día
        convert date lv_date time lv_time
                into time stamp lv_mtime_ts time zone 'UTC'.

        append value #( dirname = dirname
                        name    = ls_file-name
                        type    = ls_file-type
                        length  = ls_file-len
                        owner   = ls_file-owner
                        mtime   = lv_mtime_ts
                        fmode   = ls_file-fmode
                        useable = ls_file-useable )
               to result.
      endif.

    enddo.

    call 'C_DIR_READ_FINISH'
         id 'ERRNO'  field ls_file-errno
         id 'ERRMSG' field ls_file-errmsg.

    " Ignorar entradas triviales de directorio.
    delete result where name = '.'.
    delete result where name = '..'.

  endmethod.

  method zif_xc_file_utils~calculate_hash.

    try.
        cl_abap_message_digest=>calculate_hash_for_raw( exporting if_algorithm  = algorithm
                                                                  if_data       = content
                                                        importing ef_hashstring = result ).

      catch cx_abap_message_digest into data(lo_err).

        raise exception new zcx_xc_file_utils( textid   = zcx_xc_file_utils=>hash_error
                                               previous = lo_err ).
    endtry.

  endmethod.

  method zif_xc_file_utils~verify_hash.

    data(lv_actual) = zif_xc_file_utils~calculate_hash( content   = content
                                                        algorithm = algorithm ).

    result = xsdbool( to_upper( lv_actual ) = to_upper( expected_hash ) ).

  endmethod.

endclass.
