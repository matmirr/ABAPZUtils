interface zif_xc_app_log
  public.

  "! <p class="shorttext synchronized">Agrega un mensaje al log por clase y número</p>
  "!
  "! @parameter severity       | Severidad (ver IF_BALI_CONSTANTS=>C_SEVERITY_*).
  "! @parameter id             | Clase de mensajes.
  "! @parameter number         | Número de mensaje.
  "! @parameter v1             | Variable de mensaje 1.
  "! @parameter v2             | Variable de mensaje 2.
  "! @parameter v3             | Variable de mensaje 3.
  "! @parameter v4             | Variable de mensaje 4.
  "! @raising   zcx_xc_app_log | Falla al agregar el mensaje.
  methods add_message
    importing severity type if_bali_constants=>ty_severity
              !id      type symsgid
              !number  type symsgno
              v1       type clike optional
              v2       type clike optional
              v3       type clike optional
              v4       type clike optional
    raising   zcx_xc_app_log.

  "! <p class="shorttext synchronized">Agrega un mensaje de error (E) al log</p>
  "! @parameter id             | Clase de mensajes.
  "! @parameter number         | Número de mensaje.
  "! @parameter v1             | Variable de mensaje 1.
  "! @parameter v2             | Variable de mensaje 2.
  "! @parameter v3             | Variable de mensaje 3.
  "! @parameter v4             | Variable de mensaje 4.
  "! @raising   zcx_xc_app_log | Falla al agregar el mensaje.
  methods add_error
    importing !id     type symsgid
              !number type symsgno
              v1      type clike optional
              v2      type clike optional
              v3      type clike optional
              v4      type clike optional
    raising   zcx_xc_app_log.

  "! <p class="shorttext synchronized">Agrega un mensaje de advertencia (W) al log</p>
  "! @parameter id             | Clase de mensajes.
  "! @parameter number         | Número de mensaje.
  "! @parameter v1             | Variable de mensaje 1.
  "! @parameter v2             | Variable de mensaje 2.
  "! @parameter v3             | Variable de mensaje 3.
  "! @parameter v4             | Variable de mensaje 4.
  "! @raising   zcx_xc_app_log | Falla al agregar el mensaje.
  methods add_warning
    importing !id     type symsgid
              !number type symsgno
              v1      type clike optional
              v2      type clike optional
              v3      type clike optional
              v4      type clike optional
    raising   zcx_xc_app_log.

  "! <p class="shorttext synchronized">Agrega un mensaje informativo (I) al log</p>
  "! @parameter id             | Clase de mensajes.
  "! @parameter number         | Número de mensaje.
  "! @parameter v1             | Variable de mensaje 1.
  "! @parameter v2             | Variable de mensaje 2.
  "! @parameter v3             | Variable de mensaje 3.
  "! @parameter v4             | Variable de mensaje 4.
  "! @raising   zcx_xc_app_log | Falla al agregar el mensaje.
  methods add_info
    importing !id     type symsgid
              !number type symsgno
              v1      type clike optional
              v2      type clike optional
              v3      type clike optional
              v4      type clike optional
    raising   zcx_xc_app_log.

  "! <p class="shorttext synchronized">Agrega un mensaje de éxito (S) al log</p>
  "! @parameter id             | Clase de mensajes.
  "! @parameter number         | Número de mensaje.
  "! @parameter v1             | Variable de mensaje 1.
  "! @parameter v2             | Variable de mensaje 2.
  "! @parameter v3             | Variable de mensaje 3.
  "! @parameter v4             | Variable de mensaje 4.
  "! @raising   zcx_xc_app_log | Falla al agregar el mensaje.
  methods add_success
    importing !id     type symsgid
              !number type symsgno
              v1      type clike optional
              v2      type clike optional
              v3      type clike optional
              v4      type clike optional
    raising   zcx_xc_app_log.

  "! <p class="shorttext synchronized">Agrega un mensaje desde las variables de sistema (SY-MSG*)</p>
  "!
  "! Toma SY-MSGID, SY-MSGNO, SY-MSGTY y SY-MSGV1..4 del contexto actual.
  "!
  "! @raising zcx_xc_app_log | Falla al agregar el mensaje.
  methods add_from_sy
    raising zcx_xc_app_log.

  "! <p class="shorttext synchronized">Agrega un texto libre al log</p>
  "!
  "! @parameter severity       | Severidad (ver IF_BALI_CONSTANTS=>C_SEVERITY_*).
  "! @parameter text           | Texto libre a registrar.
  "! @raising   zcx_xc_app_log | Falla al agregar el texto.
  methods add_free_text
    importing severity type if_bali_constants=>ty_severity
              !text    type clike
    raising   zcx_xc_app_log.

  "! <p class="shorttext synchronized">Agrega una excepción al log</p>
  "!
  "! Registra una excepción en el log, incluyendo su cadena de causas.
  "!
  "! @parameter severity       | Severidad (ver IF_BALI_CONSTANTS=>C_SEVERITY_*).
  "! @parameter exception      | Excepción a registrar.
  "! @raising   zcx_xc_app_log | Falla al agregar la excepción.
  methods add_exception
    importing severity   type if_bali_constants=>ty_severity
              !exception type ref to cx_root
    raising   zcx_xc_app_log.

  "! <p class="shorttext synchronized">Agrega mensajes desde una tabla BAPIRET2</p>
  "!
  "! @parameter messages       | Tabla de mensajes BAPIRET2.
  "! @raising   zcx_xc_app_log | Falla al agregar los mensajes.
  methods add_from_bapiret
    importing !messages type bapirettab
    raising   zcx_xc_app_log.

  "! <p class="shorttext synchronized">Persiste el log en base de datos</p>
  "!
  "! Guarda el log para que sea visible en SLG1. No ejecuta COMMIT WORK:
  "! la transacción la controla el llamador.
  "!
  "! @raising zcx_xc_app_log | Falla al guardar el log.
  methods save
    raising zcx_xc_app_log.

  "! <p class="shorttext synchronized">Devuelve el handle del log</p>
  "! @parameter result | Handle del log en memoria.
  methods get_handle
    returning value(result) type balloghndl.

  "! <p class="shorttext synchronized">Devuelve todos los items del log en memoria</p>
  "!
  "! Devuelve los items tal como los entrega la API de Application Log
  "! (referencias a IF_BALI_ITEM). Cada item permite obtener su texto,
  "! severidad, etc. mediante sus métodos (p. ej. item->get_message_text( )).
  "!
  "! @parameter result | Tabla de items del log.
  methods get_messages
    returning value(result) type if_bali_log=>ty_item_table
    raising   zcx_xc_app_log.

endinterface.
