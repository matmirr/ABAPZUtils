interface zif_xc_file_utils
   public.

  "! <p class="shorttext synchronized">Lista archivos de un directorio del application server</p>
  "!
  "! Devuelve la lista de archivos de un directorio del AS, con su metadata
  "! (tamaño, fecha de modificación, propietario, etc.). Los archivos no
  "! usables (directorios, devices, tamaño 0, errores de lectura) se incluyen
  "! marcados con USEABLE = space para que el consumidor decida si filtrarlos.
  "!
  "! @parameter dirname           | Directorio a listar.
  "! @parameter filename          | Filtro opcional por nombre de archivo.
  "! @parameter pattern           | Patrón opcional de coincidencia (estilo CP).
  "! @parameter result            | Lista de archivos con metadata.
  "! @raising   zcx_xc_file_utils | Falla al listar el directorio.
  methods list
    importing dirname       type string
              filename      type string optional
              !pattern      type string optional
    returning value(result) type zxc_t_file_info
    raising   zcx_xc_file_utils.

  "! <p class="shorttext synchronized">Escribe un string en un archivo (sobrescribe)</p>
  "!
  "! Escribe el contenido en el archivo destino, sobrescribiendo su contenido
  "! previo. El codepage y el salto de línea se toman de la configuración de
  "! la instancia.
  "!
  "! @parameter content           | Contenido a escribir.
  "! @parameter target_file       | Ruta completa del archivo destino.
  "! @raising   zcx_xc_file_utils | Falla al abrir o escribir el archivo.
  methods write_file
    importing content     type string
              target_file type string
    raising   zcx_xc_file_utils.

  "! <p class="shorttext synchronized">Agrega un string al final de un archivo</p>
  "!
  "! Agrega el contenido al final del archivo destino (append). Si concurrent
  "! es abap_true, la escritura se serializa mediante bloqueo para soportar
  "! escritores concurrentes sobre el mismo archivo.
  "!
  "! @parameter content           | Contenido a agregar.
  "! @parameter target_file       | Ruta completa del archivo destino.
  "! @parameter concurrent        | Si abap_true, protege con bloqueo. Default false.
  "! @raising   zcx_xc_file_utils | Falla al abrir, bloquear o escribir.
  methods append_string
    importing content     type string
              target_file type string
              concurrent  type abap_bool default abap_false
    raising   zcx_xc_file_utils.

  "! <p class="shorttext synchronized">Agrega el contenido de un archivo al final de otro</p>
  "!
  "! Lee el archivo de entrada y agrega su contenido al final del archivo de
  "! salida. Opcionalmente borra el archivo de entrada al finalizar. Si
  "! concurrent es abap_true, la escritura se serializa mediante bloqueo.
  "!
  "! @parameter input_file        | Archivo de entrada (origen).
  "! @parameter output_file       | Archivo de salida (destino).
  "! @parameter delete_source     | Si abap_true, borra el origen al terminar. Default false.
  "! @parameter concurrent        | Si abap_true, protege con bloqueo. Default false.
  "! @raising   zcx_xc_file_utils | Falla al leer, abrir, bloquear o escribir.
  methods append_file
    importing input_file    type string
              output_file   type string
              delete_source type abap_bool default abap_false
              concurrent    type abap_bool default abap_false
    raising   zcx_xc_file_utils.

  "! <p class="shorttext synchronized">Verifica que las rutas estén dentro del ámbito seguro</p>
  "!
  "! Valida que los archivos indicados se encuentren dentro del ámbito seguro
  "! configurado (vía logical filename en la instancia). Lanza excepción si
  "! alguno está fuera del ámbito o si no se puede determinar el ámbito.
  "!
  "! @parameter input_file        | Archivo de entrada a validar.
  "! @parameter output_file       | Archivo de salida a validar (opcional).
  "! @raising   zcx_xc_file_utils | Algún archivo está fuera del ámbito seguro,
  "!                              o no se pudo determinar el ámbito.
  methods defensive_check
    importing input_file  type string
              output_file type string optional
    raising   zcx_xc_file_utils.

  "! <p class="shorttext synchronized">Calcula el hash de un contenido binario</p>
  "! @parameter content           | Contenido sobre el que calcular el hash.
  "! @parameter algorithm         | Algoritmo de hash (por defecto SHA256).
  "! @parameter result            | Hash en formato hexadecimal.
  "! @raising   zcx_xc_file_utils | Error al calcular el hash.
  methods calculate_hash
    importing content       type xstring
              algorithm     type string default 'SHA256'
    returning value(result) type string
    raising   zcx_xc_file_utils.

  "! <p class="shorttext synchronized">Verifica el hash de un contenido</p>
  "!
  "! Calcula el hash del contenido y lo compara contra el esperado.
  "! La comparación no distingue mayúsculas/minúsculas.
  "!
  "! @parameter content           | Contenido a verificar.
  "! @parameter expected_hash     | Hash esperado (hexadecimal).
  "! @parameter algorithm         | Algoritmo de hash (por defecto SHA256).
  "! @parameter result            | abap_true si el hash coincide.
  "! @raising   zcx_xc_file_utils | Error al calcular el hash.
  methods verify_hash
    importing content       type xstring
              expected_hash type string
              algorithm     type string default 'SHA256'
    returning value(result) type abap_bool
    raising   zcx_xc_file_utils.

endinterface.
