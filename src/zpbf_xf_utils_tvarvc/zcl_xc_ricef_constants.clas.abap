CLASS zcl_xc_ricef_constants DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    " =========================================================================
    " TIPOS PÚBLICOS (Para uso de los desarrolladores que llamen a la clase)
    " =========================================================================

    " Estructura idéntica a un 'RANGO' estándar de ABAP.
    " Nota para Juniors: Las tablas de rangos que se usan en los 'IN' de un SELECT
    " siempre exigen que los campos se llamen exactamente: SIGN, OPTION, LOW y HIGH.
    " Como en nuestra base de datos lo llamamos 'OPTI', aquí lo mapeamos a 'OPTION'.
    TYPES: BEGIN OF ty_range,
             sign   TYPE bapisign,         " Valores: I (Incluir) / E (Excluir)
             option TYPE bapioption,       " Valores: EQ, BT, CP, etc.
             low    TYPE rvari_val_255,    " Límite inferior del valor
             high   TYPE rvari_val_255,    " Límite superior del valor
           END OF ty_range.

    TYPES tt_range TYPE STANDARD TABLE OF ty_range WITH EMPTY KEY.

    " =========================================================================
    " MÉTODOS PÚBLICOS DE CONSUMO
    " =========================================================================

    " 1. GET_PARAM: Recupera un Parámetro (Devuelve un único valor de texto)
    CLASS-METHODS get_param
      IMPORTING
        iv_ricefid      TYPE char20
        iv_name         TYPE rvari_vnam
      RETURNING
        VALUE(rv_value) TYPE rvari_val_255.

    " 2. GET_RANGE: Recupera un Rango (Devuelve una tabla interna tipo Rango)
    CLASS-METHODS get_range
      IMPORTING
        iv_ricefid      TYPE char20
        iv_name         TYPE rvari_vnam
      RETURNING
        VALUE(rt_range) TYPE tt_range.

    " 3. PRELOAD_RICEF: Precarga todos los valores de un RICEF en la memoria RAM
    " (Se puede llamar explícitamente para optimizar procesos masivos)
    CLASS-METHODS preload_ricef
      IMPORTING
        iv_ricefid TYPE char20.

  PROTECTED SECTION.
  PRIVATE SECTION.

    " =========================================================================
    " ATRIBUTOS PRIVADOS (MEMORIA CACHÉ / BUFFER)
    " =========================================================================

    " 'gt_buffer_items' guardará TODOS los registros traídos de la base de datos.
    " Al ser CLASS-DATA (Estático), esta memoria se mantiene viva y no se borra
    " mientras el programa del usuario siga ejecutándose.
    " Tiene una 'Sorted Key' (llave ordenada) para que las lecturas en RAM sean ultra rápidas.
    CLASS-DATA:
      gt_buffer_items TYPE STANDARD TABLE OF zxc_tbl_ricefi
                           WITH NON-UNIQUE SORTED KEY k_ricef COMPONENTS ricefid name,

      " 'gt_loaded_ricef' es nuestra lista de control para saber qué RICEFIDs
      " ya fuimos a buscar a la base de datos y no repetir el SELECT.
      gt_loaded_ricef TYPE STANDARD TABLE OF char20 WITH EMPTY KEY.

ENDCLASS.

CLASS zcl_xc_ricef_constants IMPLEMENTATION.

  METHOD preload_ricef.
" -------------------------------------------------------------------------
  " MÉTODO: PRELOAD_RICEF (Patrón Lazy Loading / Carga perezosa)
  " Propósito: Garantiza que solo vayamos a la Base de Datos UNA VEZ por RICEFID.
  " Beneficio: Evita matar el rendimiento del sistema si un Junior pone el
  " método get_param() dentro de un bucle LOOP de miles de registros.
  " -------------------------------------------------------------------------

    " 1. Verificamos si este RICEFID ya está en nuestra lista de 'Cargados'.
    " Si line_exists da verdadero, significa que ya lo leímos antes, así que
    " salimos del método inmediatamente (Coste de rendimiento = 0).
    IF line_exists( gt_loaded_ricef[ table_line = iv_ricefid ] ).
      RETURN.
    ENDIF.

    " 2. Si no estaba cargado, hacemos el SELECT a la BD para traer TODA la familia.
    DATA lt_db_items TYPE STANDARD TABLE OF zxc_tbl_ricefi.

    SELECT * FROM zxc_tbl_ricefi
      WHERE ricefid = @iv_ricefid
      INTO TABLE @lt_db_items.

    " 3. Insertamos los registros encontrados en nuestra memoria global (Buffer).
    IF lt_db_items IS NOT INITIAL.
      INSERT LINES OF lt_db_items INTO TABLE gt_buffer_items.
    ENDIF.

    " 4. Dejamos anotado que este RICEFID ya fue procesado.
    " (Incluso si el SELECT no trajo nada, lo anotamos para no volver a
    " ejecutar un SELECT inútil la próxima vez).
    APPEND iv_ricefid TO gt_loaded_ricef.
  ENDMETHOD.


  METHOD get_param.
  " -------------------------------------------------------------------------
  " MÉTODO: GET_PARAM
  " Propósito: Buscar en el buffer la variable solicitada y devolver su campo LOW.
  " -------------------------------------------------------------------------
    " 1. Aseguramos que los datos de este RICEFID estén en memoria.
    preload_ricef( iv_ricefid ).

    " 2. Buscamos el registro exacto en la RAM usando la llave secundaria (k_ricef)
    READ TABLE gt_buffer_items INTO DATA(ls_item)
         WITH KEY k_ricef COMPONENTS ricefid = iv_ricefid
                                     name    = iv_name.

    " 3. Si lo encontramos y verificamos que fue configurado como Parámetro ('P')
    IF sy-subrc = 0 AND ls_item-type = 'P'.
      rv_value = ls_item-low.
    ENDIF.

    " Nota: Si el registro no existe o no es tipo 'P', rv_value se devolverá
    " vacío automáticamente, evitando que el programa del usuario falle.
  ENDMETHOD.


  METHOD get_range.
  " -------------------------------------------------------------------------
  " MÉTODO: GET_RANGE
  " Propósito: Buscar en el buffer todas las líneas de un Select Option ('S')
  " y formatearlas como una tabla de rangos clásica de ABAP.
  " -------------------------------------------------------------------------
    " 1. Aseguramos que los datos de este RICEFID estén en memoria.
    preload_ricef( iv_ricefid ).

    " 2. Extraemos todos los registros del buffer que coincidan.
    " Usamos LOOP en lugar de READ TABLE porque un Select Option puede
    " tener configuradas múltiples filas (ej. Secuencia 1, 2, 3...).
    LOOP AT gt_buffer_items INTO DATA(ls_item)
         USING KEY k_ricef
         WHERE ricefid = iv_ricefid
           AND name    = iv_name
           AND type    = 'S'.

      " 3. Convertimos nuestra estructura a la estructura de Rango estándar
      APPEND VALUE #( sign   = ls_item-sign
                      option = ls_item-opti
                      low    = ls_item-low
                      high   = ls_item-high ) TO rt_range.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
