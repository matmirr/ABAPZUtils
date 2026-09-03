" =======================================================================
" BEHAVIOR POOL: GESTIÓN DE VARIABLES (ITEMS)
" =======================================================================
CLASS lhc_Item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    " Determina automáticamente la secuencia numérica (0000 o correlativo)
    METHODS calculatenumb FOR DETERMINE ON MODIFY IMPORTING keys FOR item~calculatenumb.

    " Valida que no existan variables duplicadas o incompatibles antes de guardar
    METHODS validateduplicates FOR VALIDATE ON SAVE IMPORTING keys FOR item~validateduplicates.

    " Controla dinámicamente si los campos se bloquean (gris) o se habilitan en pantalla
    METHODS get_instance_features FOR INSTANCE FEATURES IMPORTING keys REQUEST requested_features FOR Item RESULT result.

    " Limpia los valores de Signo, Opción y Valor Superior si el tipo es P (Parámetro)
    METHODS clearfieldsontypep FOR DETERMINE ON MODIFY IMPORTING keys FOR item~clearfieldsontypep.

    " Convierte el Nombre de la variable a MAYÚSCULAS y le quita los espacios
    METHODS formatname FOR DETERMINE ON MODIFY IMPORTING keys FOR item~formatname.

    " Valida que el usuario no haya escrito solo espacios en blanco en el nombre
    METHODS validateempty FOR VALIDATE ON SAVE IMPORTING keys FOR item~validateempty.

    " Si es tipo S (Select Option), asigna por defecto Signo = I y Opción = EQ
    METHODS defaultvaluesontypes FOR DETERMINE ON MODIFY IMPORTING keys FOR item~defaultvaluesontypes.

    " Si el usuario escribe un nombre que ya existe, auto-selecciona el tipo 'S'
    METHODS determinetypefromname FOR DETERMINE ON MODIFY IMPORTING keys FOR item~determinetypefromname.
ENDCLASS.

CLASS lhc_Item IMPLEMENTATION.

  " -------------------------------------------------------------------
  " MÉTODO: formatname
  " Propósito: Limpieza de datos (Data Cleansing). Asegura que el nombre
  " de la constante no tenga espacios y esté en mayúsculas.
  " -------------------------------------------------------------------
  METHOD formatname.
    " EML (Entity Manipulation Language): Lee los registros que dispararon esta determinación usando su llave (keys)
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE
         ENTITY Item FIELDS ( Name ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_items).

    " Tabla interna para acumular las modificaciones a realizar en la BD Transaccional
    DATA lt_update TYPE TABLE FOR UPDATE zi_xc_ricefi.

    LOOP AT lt_items INTO DATA(ls_item).
      DATA(lv_formatted) = ls_item-Name.
      " Reemplaza los espacios en blanco por nada (junta las palabras)
      REPLACE ALL OCCURRENCES OF ` ` IN lv_formatted WITH ''.
      " Pasa todo a mayúsculas
      lv_formatted = to_upper( lv_formatted ).

      " Solo agregamos a la tabla de actualización si realmente hubo un cambio (previene bucles infinitos)
      IF lv_formatted <> ls_item-Name.
        APPEND VALUE #( %tky = ls_item-%tky Name = lv_formatted ) TO lt_update.
      ENDIF.
    ENDLOOP.

    " EML: Ejecuta la actualización de los registros modificados en la memoria transaccional
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_xc_ricefh IN LOCAL MODE
             ENTITY Item UPDATE FIELDS ( Name ) WITH lt_update.
    ENDIF.
  ENDMETHOD.


  " -------------------------------------------------------------------
  " MÉTODO: determinetypefromname
  " Propósito: 'Smart Default' (Valor por defecto inteligente). Si el
  " usuario tipea el nombre de una variable que ya existe en otro registro,
  " asume que es una continuación de un Select-Option y le asigna el tipo 'S'.
  " -------------------------------------------------------------------
  METHOD determinetypefromname.
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE
         ENTITY Item FIELDS ( Name Type Ricefid ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_items).

    " Truco RAP: Obtenemos las llaves de la cabecera (Ricefid) de los items actuales
    " para poder buscar a todos sus 'hermanos' (los demás items del mismo desarrollo).
    TYPES: tt_header_keys TYPE TABLE FOR READ IMPORT zi_xc_ricefh.
    DATA lt_header_keys TYPE tt_header_keys.
    lt_header_keys = VALUE #( FOR ls_req IN lt_items ( %tky-Ricefid = ls_req-Ricefid %tky-%is_draft = ls_req-%is_draft ) ).

    " Silenciamos las advertencias de ABAP ATC sobre llaves vacías usando #EC CI_SORTSEQ
    SORT lt_header_keys. "#EC CI_SORTSEQ
    DELETE ADJACENT DUPLICATES FROM lt_header_keys. "#EC CI_SORTSEQ

    " EML: Leemos TODOS los items asociados a las cabeceras obtenidas arriba
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE
         ENTITY Header BY \_Item FIELDS ( Name Type ) WITH CORRESPONDING #( lt_header_keys )
         RESULT DATA(lt_all_items). "#EC CI_SORTSEQ

    DATA lt_update TYPE TABLE FOR UPDATE zi_xc_ricefi.

    LOOP AT lt_items INTO DATA(ls_item).
      " Normalizamos el nombre (sin espacios y mayúsculas) para compararlo de forma segura
      DATA(lv_safe_name) = ls_item-Name.
      REPLACE ALL OCCURRENCES OF ` ` IN lv_safe_name WITH ''.
      lv_safe_name = to_upper( lv_safe_name ).
      CHECK lv_safe_name IS NOT INITIAL.

      " Recorremos a todos los hermanos para ver si alguno se llama igual
      LOOP AT lt_all_items INTO DATA(ls_sibling) WHERE Ricefid = ls_item-Ricefid AND ItemUuid <> ls_item-ItemUuid.
        DATA(lv_sib_name) = ls_sibling-Name.
        REPLACE ALL OCCURRENCES OF ` ` IN lv_sib_name WITH ''.
        lv_sib_name = to_upper( lv_sib_name ).

        " Si encontramos un hermano con el mismo nombre, forzamos el tipo a 'S'
        IF lv_sib_name = lv_safe_name AND ls_item-Type <> 'S'.
          APPEND VALUE #( %tky = ls_item-%tky Type = 'S' ) TO lt_update.
          EXIT. " Con encontrar uno es suficiente, salimos del bucle interno
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Item UPDATE FIELDS ( Type ) WITH lt_update.
    ENDIF.
  ENDMETHOD.


  " -------------------------------------------------------------------
  " MÉTODO: validateempty
  " Propósito: Validación. Bloquea el guardado si el usuario dejó el
  " nombre en blanco o escribió únicamente espacios.
  " -------------------------------------------------------------------
  METHOD validateempty.
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Item FIELDS ( Name ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).
      DATA(lv_check) = ls_item-Name.
      REPLACE ALL OCCURRENCES OF ` ` IN lv_check WITH ''.

      IF lv_check IS INITIAL.
        " EML 'failed': Agrega el registro a la tabla de fallos para abortar el guardado de la transacción
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-item.

        " EML 'reported': Envía el mensaje de error a la pantalla (Fiori UI)
        " %element-name = mk-on: Hace que la cajita del campo 'Name' se pinte de rojo
        APPEND VALUE #( %tky = ls_item-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'El Nombre no puede estar vacío.' )
                        %element-name = if_abap_behv=>mk-on ) TO reported-item.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  " -------------------------------------------------------------------
  " MÉTODO: calculatenumb
  " Propósito: Calcula el 'Nro Secuencia'. Si es un parámetro (P), siempre es 0000.
  " Si es un Select Option (S), busca el número máximo de sus hermanos con
  " el mismo nombre y le suma 1 al nuevo registro.
  " -------------------------------------------------------------------
  METHOD calculatenumb.
    DATA lv_max TYPE n LENGTH 4.
    DATA lv_numb_final TYPE tvarv_numb.

    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Item FIELDS ( Type Name Ricefid Numb ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_items).

    TYPES: tt_header_keys TYPE TABLE FOR READ IMPORT zi_xc_ricefh.
    DATA lt_header_keys TYPE tt_header_keys.
    lt_header_keys = VALUE #( FOR ls_req IN lt_items ( %tky-Ricefid = ls_req-Ricefid %tky-%is_draft = ls_req-%is_draft ) ).

    " Silenciamos advertencias de llaves vacías
    SORT lt_header_keys. "#EC CI_SORTSEQ
    DELETE ADJACENT DUPLICATES FROM lt_header_keys. "#EC CI_SORTSEQ

    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Header BY \_Item FIELDS ( Type Name Numb ) WITH CORRESPONDING #( lt_header_keys )
         RESULT DATA(lt_all_items). "#EC CI_SORTSEQ

    DATA lt_update TYPE TABLE FOR UPDATE zi_xc_ricefi.

    LOOP AT lt_items INTO DATA(ls_new_item).
      DATA(lv_safe_name) = ls_new_item-Name.
      REPLACE ALL OCCURRENCES OF ` ` IN lv_safe_name WITH ''.
      lv_safe_name = to_upper( lv_safe_name ).

      CHECK lv_safe_name IS NOT INITIAL AND ls_new_item-Type IS NOT INITIAL.

      " Lógica para Parámetro (P): Siempre secuencia 0000
      IF ls_new_item-Type = 'P' AND ls_new_item-Numb <> '0000'.
        APPEND VALUE #( %tky = ls_new_item-%tky Numb = '0000' ) TO lt_update.

      " Lógica para Select Option (S): Buscar correlativo
      ELSEIF ls_new_item-Type = 'S'.
        lv_max = '0000'.
        CLEAR lv_numb_final.

        " Buscamos el Nro de Secuencia mayor entre los hermanos que se llamen igual
        LOOP AT lt_all_items INTO DATA(ls_sibling) WHERE Ricefid = ls_new_item-Ricefid AND Type = 'S' AND ItemUuid <> ls_new_item-ItemUuid.
          DATA(lv_sib_name) = ls_sibling-Name.
          REPLACE ALL OCCURRENCES OF ` ` IN lv_sib_name WITH ''.
          lv_sib_name = to_upper( lv_sib_name ).

          IF lv_sib_name = lv_safe_name AND ls_sibling-Numb > lv_max.
            lv_max = ls_sibling-Numb.
          ENDIF.
        ENDLOOP.

        " Sumamos 1 al mayor encontrado
        lv_max = lv_max + 1.
        lv_numb_final = lv_max. " La asignación a CHAR4 añade los ceros a la izquierda automáticamente (ej. 0003)

        IF ls_new_item-Numb <> lv_numb_final.
          APPEND VALUE #( %tky = ls_new_item-%tky Numb = lv_numb_final ) TO lt_update.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Item UPDATE FIELDS ( Numb ) WITH lt_update.
    ENDIF.
  ENDMETHOD.


  " -------------------------------------------------------------------
  " MÉTODO: get_instance_features
  " Propósito: 'Dynamic UI Control' (Control de Características de Instancia).
  " Le dice al frontend de Fiori qué campos deben estar bloqueados (grisados)
  " y cuáles habilitados, dependiendo del valor de otro campo (Type).
  " -------------------------------------------------------------------
  METHOD get_instance_features.
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Item FIELDS ( Type ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_items).

    " La tabla 'result' le indica a Fiori el estado (feature control) de cada campo por fila
    result = VALUE #( FOR ls_item IN lt_items (
      %tky = ls_item-%tky
      " Si es P (Parámetro), devuelve el estado read_only (solo lectura) para bloquearlo en pantalla.
      " Si no es P, devuelve unrestricted (editable).
      %field-Sign = COND #( WHEN ls_item-Type = 'P' THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
      %field-Opti = COND #( WHEN ls_item-Type = 'P' THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
      %field-High = COND #( WHEN ls_item-Type = 'P' THEN if_abap_behv=>fc-f-read_only ELSE if_abap_behv=>fc-f-unrestricted )
    ) ).
  ENDMETHOD.


  " -------------------------------------------------------------------
  " MÉTODO: clearfieldsontypep
  " Propósito: Limpieza lógica. Si el usuario selecciona 'P', los campos
  " Sign, Opti y High no tienen sentido en el negocio. Este método los vacía.
  " -------------------------------------------------------------------
  METHOD clearfieldsontypep.
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Item FIELDS ( Type ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_items).
    DATA lt_update TYPE TABLE FOR UPDATE zi_xc_ricefi.

    LOOP AT lt_items INTO DATA(ls_item) WHERE Type = 'P'.
      APPEND VALUE #( %tky = ls_item-%tky Sign = '' Opti = '' High = '' ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Item UPDATE FIELDS ( Sign Opti High ) WITH lt_update.
    ENDIF.
  ENDMETHOD.


  " -------------------------------------------------------------------
  " MÉTODO: defaultvaluesontypes
  " Propósito: 'Smart Default'. Si el usuario selecciona 'S', rellena
  " automáticamente el Signo con 'I' y la Opción con 'EQ' para ahorrarle clics.
  " -------------------------------------------------------------------
  METHOD defaultvaluesontypes.
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Item FIELDS ( Type Sign Opti ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_items).
    DATA lt_update TYPE TABLE FOR UPDATE zi_xc_ricefi.

    LOOP AT lt_items INTO DATA(ls_item).
      IF ls_item-Type = 'S'.
        DATA(lv_changed) = abap_false.
        DATA ls_update TYPE STRUCTURE FOR UPDATE zi_xc_ricefi.
        CLEAR ls_update. ls_update-%tky = ls_item-%tky.

        IF ls_item-Sign IS INITIAL.
          ls_update-Sign = 'I'. lv_changed = abap_true.
        ENDIF.
        IF ls_item-Opti IS INITIAL.
          ls_update-Opti = 'EQ'. lv_changed = abap_true.
        ENDIF.

        IF lv_changed = abap_true.
          APPEND ls_update TO lt_update.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Item UPDATE FIELDS ( Sign Opti ) WITH lt_update.
    ENDIF.
  ENDMETHOD.


  " -------------------------------------------------------------------
  " MÉTODO: validateduplicates
  " Propósito: Asegura la integridad lógica de la base de datos (Validación).
  " Regla 1: Un tipo 'P' no puede tener hermanos con el mismo nombre.
  " Regla 2: Un tipo 'S' no puede tener hermanos de tipo 'P' con el mismo nombre.
  " -------------------------------------------------------------------
  METHOD validateduplicates.
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Item FIELDS ( Ricefid Name Type ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_items).

    TYPES: tt_header_keys TYPE TABLE FOR READ IMPORT zi_xc_ricefh.
    DATA lt_header_keys TYPE tt_header_keys.
    lt_header_keys = VALUE #( FOR ls_req IN lt_items ( %tky-Ricefid = ls_req-Ricefid %tky-%is_draft = ls_req-%is_draft ) ).

    " Silenciamos advertencias de llaves vacías
    SORT lt_header_keys. "#EC CI_SORTSEQ
    DELETE ADJACENT DUPLICATES FROM lt_header_keys. "#EC CI_SORTSEQ

    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE
        ENTITY Header BY \_Item
        FIELDS ( Name Type ) WITH CORRESPONDING #( lt_header_keys )
        RESULT DATA(lt_all_items). "#EC CI_SORTSEQ

    LOOP AT lt_items INTO DATA(ls_item).
      DATA(lv_safe_name) = ls_item-Name.
      REPLACE ALL OCCURRENCES OF ` ` IN lv_safe_name WITH ''.
      lv_safe_name = to_upper( lv_safe_name ).
      CHECK lv_safe_name IS NOT INITIAL.

      LOOP AT lt_all_items INTO DATA(ls_sibling) WHERE Ricefid = ls_item-Ricefid AND ItemUuid <> ls_item-ItemUuid.
        DATA(lv_sib_name) = ls_sibling-Name.
        REPLACE ALL OCCURRENCES OF ` ` IN lv_sib_name WITH ''.
        lv_sib_name = to_upper( lv_sib_name ).
        CHECK lv_sib_name = lv_safe_name. " Solo analizamos hermanos que se llamen igual

        DATA(lv_error) = abap_false.
        " Reglas de incompatibilidad
        IF ls_item-Type = 'P' OR ( ls_item-Type = 'S' AND ls_sibling-Type = 'P' ).
          lv_error = abap_true.
        ENDIF.

        IF lv_error = abap_true.
          APPEND VALUE #( %tky = ls_item-%tky ) TO failed-item.
          APPEND VALUE #( %tky = ls_item-%tky
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = |Conflicto: La variable '{ lv_safe_name }' ya existe o su tipo es incompatible.| )
                          %element-name = if_abap_behv=>mk-on ) TO reported-item.
          EXIT. " Bloquea y sale del bucle al encontrar el primer error
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


" =======================================================================
" BEHAVIOR POOL: GESTIÓN DE CABECERA Y TRANSPORTES (HEADER)
" =======================================================================
CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    " Controla los permisos (autorizaciones) estándar del registro
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.

    " Impide que el ID principal (RICEFID) se guarde con espacios
    METHODS validatericefid FOR VALIDATE ON SAVE IMPORTING keys FOR header~validatericefid.

    " Acción para recolectar el desarrollo y sus variables, e insertarlos en una Orden de Transporte
    METHODS transportdevelopment FOR MODIFY IMPORTING keys FOR ACTION header~transportdevelopment RESULT result.

    " Acción para mantener el texto descriptivo del desarrollo en el idioma de la sesión (sin necesidad de ir a la pestaña de Textos)
    METHODS maintaintext FOR MODIFY IMPORTING keys FOR ACTION header~maintaintext RESULT result.
ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

  METHOD get_instance_authorizations.
    " Método vacío requerido por el modo Strict (2) si no se usa DCL (Control de acceso por base de datos).
  ENDMETHOD.


  " -------------------------------------------------------------------
  " MÉTODO: validateRicefid
  " Propósito: Al ser la Llave Primaria, no podemos limpiarla en vivo
  " (daría Dump). Si el usuario pone un espacio al crearla, detenemos el guardado.
  " -------------------------------------------------------------------
  METHOD validateRicefid.
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Header FIELDS ( Ricefid ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_header).
      " 1. Recortamos los espacios invisibles que ABAP le pone a los campos CHAR(20)
      DATA(lv_ricefid_trim) = shift_right( val = ls_header-Ricefid ).

      " 2. Ahora sí, verificamos si quedaron espacios reales en el medio de la palabra
      IF lv_ricefid_trim CS ` `.
        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-header.
        APPEND VALUE #( %tky = ls_header-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'El RICEFID no puede contener espacios.' )
                        %element-ricefid = if_abap_behv=>mk-on ) TO reported-header.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  " -------------------------------------------------------------------
  " MÉTODO: maintaintext
  " PROPÓSITO: Recibe el texto escrito por el usuario en el frontend (FPM)
  " y hace un "Upsert" (Actualiza si existe, Crea si no existe) en la tabla
  " de textos multi-idioma (ZXC_TBL_RICEFT) respetando el idioma actual de la sesión.
  " -------------------------------------------------------------------
  METHOD maintaintext.

    " 1. LECTURA INICIAL: Leemos los datos actuales de la Cabecera.
    " Nota para Juniors: Usamos 'IN LOCAL MODE' para saltarnos las verificaciones de autorización
    " del BDEF, ya que el usuario ya pasó la seguridad al entrar a la pantalla.
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE
         ENTITY Header ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_headers).

    " 2. LECTURA ASOCIADA: Leemos las traducciones que ya existen para esta cabecera.
    " Usamos 'BY \_Text' para navegar por la composición y traer todos los idiomas guardados.
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE
         ENTITY Header BY \_Text ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_texts).

    " 3. PROCESAMIENTO: Recorremos las llaves de entrada.
    " 'keys' contiene la información de la fila seleccionada y los parámetros enviados desde Fiori.
    LOOP AT keys INTO DATA(ls_key).

      " Extraemos el texto que el frontend JavaScript nos envió usando la Entidad Abstracta.
      " El componente '%param' contiene los campos definidos en ZD_XC_RICEF_TEXTP.
      DATA(lv_description) = ls_key-%param-Description.
      DATA(lv_exists)      = abap_false.

      " Buscamos si ya existe un texto guardado para el idioma actual del usuario (sy-langu).
      " Usamos 'WITH KEY entity COMPONENTS' para evitar advertencias de sintaxis (Warnings) en ABAP moderno.
      READ TABLE lt_texts INTO DATA(ls_text)
           WITH KEY entity COMPONENTS Ricefid = ls_key-Ricefid
                                      Spras   = sy-langu. "#EC *

      IF sy-subrc = 0.
        " =====================================================================
        " ESCENARIO A: ACTUALIZACIÓN (UPDATE)
        " El idioma ya existía, así que modificamos su descripción.
        " Usamos '%tky' (Transactional Key), que es una llave inteligente de RAP que sabe
        " si estamos trabajando sobre un Borrador (Draft) o sobre la tabla Activa automáticamente.
        " =====================================================================
        MODIFY ENTITIES OF zi_xc_ricefh IN LOCAL MODE
               ENTITY Text UPDATE FIELDS ( Description )
               WITH VALUE #( ( %tky = ls_text-%tky Description = lv_description ) ).
      ELSE.
        " =====================================================================
        " ESCENARIO B: CREACIÓN (CREATE)
        " El idioma no existía. Lo creamos a través de la cabecera (CREATE BY \_Text).
        " Conceptos RAP Clave aquí:
        " 1. '%cid' (Content ID): Es obligatorio inventar un ID temporal para que la memoria
        "    RAM de RAP pueda identificar el registro nuevo antes de guardarlo en base de datos.
        " 2. '%is_draft': Debemos heredar el estado del padre (si el padre es un borrador,
        "    el hijo también debe ser un borrador) para evitar Dumps (Errores 500).
        " =====================================================================
        MODIFY ENTITIES OF zi_xc_ricefh IN LOCAL MODE
               ENTITY Header CREATE BY \_Text FIELDS ( Spras Description )
               WITH VALUE #( ( %tky    = ls_key-%tky
                               %target = VALUE #( ( %cid        = |CID_{ sy-langu }|
                                                    %is_draft   = ls_key-%is_draft
                                                    Spras       = sy-langu
                                                    Description = lv_description ) ) ) ).
      ENDIF.
    ENDLOOP.

    " 4. RETORNO DE DATOS:
    " En nuestro BDEF dijimos que esta acción devuelve '$self' (la misma cabecera).
    " Volvemos a leer la cabecera para atrapar los datos más frescos.
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE
         ENTITY Header ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT lt_headers.

    " Al mapear el resultado de vuelta a Fiori, la Vista de Proyección aplicará la
    " asociación de lectura y actualizará la pantalla automáticamente con el nuevo texto.
    result = VALUE #( FOR ls_header IN lt_headers ( %tky   = ls_header-%tky
                                                    %param = ls_header ) ).
  ENDMETHOD.

  " -------------------------------------------------------------------
  " MÉTODO: transportdevelopment
  " Propósito: Integra la aplicación Fiori con el Sistema de Transportes
  " de SAP (CTS). Busca la Tarea (Task) del usuario bajo la Orden ingresada
  " y empaqueta las llaves genéricas (RICEFID + '*') en la tabla E071K para
  " forzar a SAP a hacer un 'Reemplazo Total' en el ambiente destino (Borrados automáticos).
  " -------------------------------------------------------------------
  METHOD transportdevelopment.
    " 1. Obtener la Orden (Cabecera) ingresada por el usuario en el Popup
    DATA(lv_trkorr_input) = keys[ 1 ]-%param-TransportRequest.
    DATA lv_task TYPE trkorr.

    " No permitimos transportar borradores (El draft no existe como tabla oficial en los transportes)
    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.
      APPEND VALUE #( %tky = keys[ 1 ]-%tky %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Guarde los cambios antes de transportar.' ) ) TO reported-header. RETURN.
    ENDIF.

    " 2. RESOLUCIÓN DE TAREAS (Busca la Tarea hija si se ingresó la Cabecera)
    SELECT SINGLE trfunction, strkorr, as4user FROM e070 WHERE trkorr = @lv_trkorr_input INTO @DATA(ls_order).
    IF sy-subrc <> 0.
      reported-header = VALUE #( ( %tky = keys[ 1 ]-%tky %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |La Orden { lv_trkorr_input } no existe.| ) ) ). RETURN.
    ENDIF.

    IF ls_order-trfunction = 'W'. " W = Orden de Customizing
      " Buscar Tarea (Q) en estado Modificable (D) perteneciente al usuario conectado
      SELECT SINGLE trkorr FROM e070 WHERE strkorr = @lv_trkorr_input AND trfunction = 'Q' AND trstatus = 'D' AND as4user = @sy-uname INTO @lv_task.
      IF sy-subrc <> 0.
        reported-header = VALUE #( ( %tky = keys[ 1 ]-%tky %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |No tienes una Tarea abierta en { lv_trkorr_input }.| ) ) ). RETURN.
      ENDIF.
    ELSEIF ls_order-trfunction = 'Q'. " Q = Si el usuario ingresó directamente la Tarea
      lv_task = lv_trkorr_input.
    ELSE.
      reported-header = VALUE #( ( %tky = keys[ 1 ]-%tky %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |Debe ser Orden de Customizing.| ) ) ). RETURN.
    ENDIF.

    " 3. CONSTRUCCIÓN DE LAS TABLAS DE TRANSPORTE
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Header FIELDS ( Ricefid ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_headers).

    " lt_objects: Le dice al CTS qué tablas se van a transportar (E071)
    " objfunc = 'K': Indica que le vamos a enviar llaves específicas en la tabla E071K
    DATA: lt_objects TYPE TABLE OF e071, lt_keys TYPE TABLE OF e071k.
    APPEND VALUE #( pgmid = 'R3TR' object = 'TABU' obj_name = 'ZXC_TBL_RICEFH' objfunc = 'K' ) TO lt_objects.
    APPEND VALUE #( pgmid = 'R3TR' object = 'TABU' obj_name = 'ZXC_TBL_RICEFI' objfunc = 'K' ) TO lt_objects.
    APPEND VALUE #( pgmid = 'R3TR' object = 'TABU' obj_name = 'ZXC_TBL_RICEFT' objfunc = 'K' ) TO lt_objects.

    LOOP AT lt_headers INTO DATA(ls_header).
      DATA lv_tabkey TYPE e071k-tabkey.
      " Padding: El campo RICEFID en BD ocupa 20 caracteres exactos.
      " El sistema de transportes exige que los espacios en blanco a la derecha estén presentes.
      DATA(lv_ricefid_pad) = ls_header-Ricefid.

      " Llave para la tabla Cabecera (Longitud 23: MANDT (3) + RICEFID (20))
      lv_tabkey = sy-mandt && lv_ricefid_pad.
      APPEND VALUE #( pgmid = 'R3TR' object = 'TABU' objname = 'ZXC_TBL_RICEFH' mastertype = 'TABU' mastername = 'ZXC_TBL_RICEFH' tabkey = lv_tabkey ) TO lt_keys.

      " Llave Genérica para Items (*): SAP borrará todo en destino y pondrá lo nuevo
      lv_tabkey = sy-mandt && lv_ricefid_pad && '*'.
      APPEND VALUE #( pgmid = 'R3TR' object = 'TABU' objname = 'ZXC_TBL_RICEFI' mastertype = 'TABU' mastername = 'ZXC_TBL_RICEFI' tabkey = lv_tabkey ) TO lt_keys.

      " Llave Genérica para Textos (*)
      lv_tabkey = sy-mandt && lv_ricefid_pad && '*'.
      APPEND VALUE #( pgmid = 'R3TR' object = 'TABU' objname = 'ZXC_TBL_RICEFT' mastertype = 'TABU' mastername = 'ZXC_TBL_RICEFT' tabkey = lv_tabkey ) TO lt_keys.
    ENDLOOP.

    " 4. EJECUTAR TRANSPORTE VÍA API ESTÁNDAR (CTS)
    CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
      EXPORTING wi_trkorr = lv_task
      TABLES wt_e071 = lt_objects wt_e071k = lt_keys
      EXCEPTIONS OTHERS = 1.

    " 5. DEVOLVER RESULTADOS AL UI
    IF sy-subrc = 0.
      reported-header = VALUE #( ( %tky = keys[ 1 ]-%tky %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success text = |Transportado a la Tarea { lv_task }| ) ) ).
    ELSE.
      reported-header = VALUE #( ( %tky = keys[ 1 ]-%tky %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |Error técnico al agregar a { lv_task }| ) ) ).
    ENDIF.

    " Lectura obligatoria de retorno de entidad para el framework Fiori
    READ ENTITIES OF zi_xc_ricefh IN LOCAL MODE ENTITY Header ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_read_results).
    result = VALUE #( FOR ls_read IN lt_read_results ( %tky = ls_read-%tky %param = ls_read ) ).
  ENDMETHOD.
ENDCLASS.
