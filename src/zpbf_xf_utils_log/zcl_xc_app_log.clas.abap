class ZCL_XC_APP_LOG definition
  public
  final
  create public .

public section.

  interfaces ZIF_XC_APP_LOG .
  interfaces IF_RAP_QUERY_PROVIDER .

    "! <p class="shorttext synchronized">Constructor</p>
    "!
    "! Crea un nuevo log de aplicación con su cabecera. El objeto y subobjeto
    "! deben existir previamente (definidos en SLG0 o vía ADT).
    "!
    "! @parameter object         | Objeto de log (SLG0).
    "! @parameter subobject      | Subobjeto de log (SLG0).
    "! @parameter external_id    | Identificador externo del log. Opcional.
    "! @raising   zcx_xc_app_log | Falla al crear el log (cabecera inconsistente).
  methods CONSTRUCTOR
    importing
      !OBJECT type CLIKE
      !SUBOBJECT type CLIKE
      !EXTERNAL_ID type CLIKE optional
    raising
      ZCX_XC_APP_LOG .
  private section.

    data mo_log type ref to if_bali_log.

    "! <p class="shorttext synchronized">Agrega un mensaje al log con la severidad indicada</p>
    "!
    "! Helper compartido por add_message y los métodos de conveniencia
    "! (add_error, add_warning, add_info, add_success). Construye el mensaje
    "! por clase y número, y lo agrega como item al log.
    "!
    "! @parameter severity       | Severidad (IF_BALI_CONSTANTS=>C_SEVERITY_*).
    "! @parameter id             | Clase de mensajes.
    "! @parameter number         | Número de mensaje.
    "! @parameter v1             | Variable de mensaje 1.
    "! @parameter v2             | Variable de mensaje 2.
    "! @parameter v3             | Variable de mensaje 3.
    "! @parameter v4             | Variable de mensaje 4.
    "! @raising   zcx_xc_app_log | Falla al construir o agregar el mensaje.
    methods add_with_severity
      importing severity type if_bali_constants=>ty_severity
                !id      type symsgid
                !number  type symsgno
                v1       type clike
                v2       type clike
                v3       type clike
                v4       type clike
      raising   zcx_xc_app_log.

ENDCLASS.



CLASS ZCL_XC_APP_LOG IMPLEMENTATION.


  method constructor.

    try.

        mo_log = cl_bali_log=>create_with_header( cl_bali_header_setter=>create(
                                                      object      = conv #( object )
                                                      subobject   = conv #( subobject )
                                                      external_id = conv #( external_id ) ) ).

      catch cx_bali_runtime into data(error).

        raise exception new zcx_xc_app_log( textid   = zcx_xc_app_log=>header_inconsistent
                                            msgv1    = conv #( object )
                                            msgv2    = conv #( subobject )
                                            msgv3    = conv #( external_id )
                                            previous = error ).
    endtry.

  endmethod.


  method zif_xc_app_log~add_message.

    add_with_severity( severity = severity
                       id       = id
                       number   = number
                       v1       = v1
                       v2       = v2
                       v3       = v3
                       v4       = v4 ).

  endmethod.


  method zif_xc_app_log~add_error.

    add_with_severity( severity = if_bali_constants=>c_severity_error
                       id       = id
                       number   = number
                       v1       = v1
                       v2       = v2
                       v3       = v3
                       v4       = v4 ).
  endmethod.


  method zif_xc_app_log~add_warning.

    add_with_severity( severity = if_bali_constants=>c_severity_warning
                       id       = id
                       number   = number
                       v1       = v1
                       v2       = v2
                       v3       = v3
                       v4       = v4 ).

  endmethod.


  method zif_xc_app_log~add_info.

    add_with_severity( severity = if_bali_constants=>c_severity_information
                       id       = id
                       number   = number
                       v1       = v1
                       v2       = v2
                       v3       = v3
                       v4       = v4 ).
  endmethod.


  method zif_xc_app_log~add_success.

    add_with_severity( severity = if_bali_constants=>c_severity_status
                       id       = id
                       number   = number
                       v1       = v1
                       v2       = v2
                       v3       = v3
                       v4       = v4 ).
  endmethod.


  method zif_xc_app_log~add_from_sy.

    try.
        mo_log->add_item( cl_bali_message_setter=>create_from_sy( ) ).

      catch cx_bali_runtime into data(error).

        raise exception new zcx_xc_app_log( textid   = zcx_xc_app_log=>msg_inconsistent
                                            previous = error ).

    endtry.

  endmethod.


  method zif_xc_app_log~add_free_text.

    try.

        mo_log->add_item( cl_bali_free_text_setter=>create( severity = severity
                                                            text     = conv #( text ) ) ).

      catch cx_bali_runtime into data(error).

        raise exception new zcx_xc_app_log( textid   = zcx_xc_app_log=>msg_inconsistent
                                            previous = error ).

    endtry.

  endmethod.


  method zif_xc_app_log~add_exception.

    try.

        mo_log->add_item( cl_bali_exception_setter=>create( severity  = severity
                                                            exception = exception ) ).

      catch cx_bali_runtime into data(error).

        raise exception new zcx_xc_app_log( textid   = zcx_xc_app_log=>msg_inconsistent
                                            previous = error ).

    endtry.

  endmethod.


  method zif_xc_app_log~add_from_bapiret.

    try.

        loop at messages into data(ls_ret).

          mo_log->add_item( cl_bali_message_setter=>create_from_bapiret2( ls_ret ) ).

        endloop.

      catch cx_bali_runtime into data(error).

        raise exception new zcx_xc_app_log( textid   = zcx_xc_app_log=>msg_inconsistent
                                            previous = error ).

    endtry.

  endmethod.


  method zif_xc_app_log~save.

    try.
        cl_bali_log_db=>get_instance( )->save_log( log = mo_log ).

      catch cx_bali_runtime into data(error).

        raise exception new zcx_xc_app_log( textid   = zcx_xc_app_log=>save_failed
                                            previous = error ).

    endtry.

  endmethod.


  method zif_xc_app_log~get_handle.

    result = mo_log->get_handle( ).

  endmethod.


  method zif_xc_app_log~get_messages.

    try.

        result = mo_log->get_all_items( ).

      catch cx_bali_runtime into data(error).

        raise exception new zcx_xc_app_log( textid   = zcx_xc_app_log=>log_not_found
                                            previous = error ).

    endtry.

  endmethod.


  method add_with_severity.

    try.

        mo_log->add_item( cl_bali_message_setter=>create( severity   = severity
                                                          id         = id
                                                          number     = number
                                                          variable_1 = conv #( v1 )
                                                          variable_2 = conv #( v2 )
                                                          variable_3 = conv #( v3 )
                                                          variable_4 = conv #( v4 ) ) ).

      catch cx_bali_runtime into data(error).

        raise exception new zcx_xc_app_log( textid   = zcx_xc_app_log=>msg_inconsistent
                                            previous = error ).

    endtry.

  endmethod.


  method IF_RAP_QUERY_PROVIDER~SELECT.

*** test - Esto lo tengo que sacar de acá y poner en la clase final que implementa la interfaz...

*    me->mo_log...

*  DATA(lv_object)    = io_request->get_filter( )->get_as_ranges( )-object.
*  DATA(lv_subobject) = io_request->get_filter( )->get_as_ranges( )-subobject.

*** test

  endmethod.
ENDCLASS.
