interface zif_xc_object_repository
  public.

  "! <p class="shorttext synchronized">Objeto persistido recuperado</p>
  "! Fila devuelta por load_run: identidad del objeto, su clase y la
  "! instancia ya deserializada.
  types: begin of ts_pers_obj,
           object_key type sysuuid_c32,
           class_name type string,
           object     type ref to if_serializable_object,
         end of ts_pers_obj.

  "! <p class="shorttext synchronized">Tabla de objetos persistidos recuperados</p>
  types tt_pers_obj type standard table of ts_pers_obj with empty key.

  "! <p class="shorttext synchronized">Información de una corrida</p>
  "! Fila devuelta por list_runs: identidad de la corrida, su momento y
  "! la cantidad de objetos que guardó.
  types: begin of ts_run_info,
           run_id       type sysuuid_c32,
           created_at   type timestampl,
           object_count type i,
         end of ts_run_info.
  "! <p class="shorttext synchronized">Tabla de información de corridas</p>
  types tt_run_info type standard table of ts_run_info with empty key.

  "! <p class="shorttext synchronized">Persiste un objeto bajo una corrida</p>
  "!
  "! Serializa el objeto y lo guarda asociado al proceso (repid) y la corrida
  "! (run_id). Genera y devuelve la clave única del objeto (object_key). NO
  "! ejecuta COMMIT WORK: la transacción la controla el llamador.
  "!
  "! @parameter repid                | Identificador del proceso.
  "! @parameter run_id               | Identificador de la corrida (generado por el
  "!                         llamador, estable durante toda la ejecución).
  "! @parameter object               | Instancia a persistir (implementa IF_SERIALIZABLE_OBJECT).
  "! @parameter object_key           | Clave única generada para el objeto.
  "! @raising   zcx_xc_serialization | Falla en la serialización del objeto.
  methods save
    importing repid             type clike
              run_id            type sysuuid_c32
              !object           type ref to if_serializable_object
    returning value(object_key) type sysuuid_c32
    raising   zcx_xc_serialization.

  "! <p class="shorttext synchronized">Recupera un objeto puntual de una corrida</p>
  "!
  "! Lee y deserializa un objeto identificado por proceso, corrida y clave.
  "!
  "! @parameter repid                | Identificador del proceso.
  "! @parameter run_id               | Identificador de la corrida.
  "! @parameter object_key           | Clave única del objeto.
  "! @parameter object               | Instancia deserializada.
  "! @raising   zcx_xc_serialization | Falla en la deserialización o no se halló el objeto.
  methods load
    importing repid         type clike
              run_id        type sysuuid_c32
              object_key    type sysuuid_c32
    returning value(object) type ref to if_serializable_object
    raising   zcx_xc_serialization.

  "! <p class="shorttext synchronized">Recupera todos los objetos de una corrida</p>
  "!
  "! Lee y deserializa la familia completa de objetos guardados en una corrida.
  "! Cada fila incluye la clave, el nombre de clase y la instancia deserializada.
  "!
  "! @parameter repid                | Identificador del proceso.
  "! @parameter run_id               | Identificador de la corrida.
  "! @parameter result               | Objetos de la corrida, deserializados.
  "! @raising   zcx_xc_serialization | Falla en la deserialización de algún objeto.
  methods load_run
    importing repid         type clike
              run_id        type sysuuid_c32
    returning value(result) type tt_pers_obj
    raising   zcx_xc_serialization.

  "! <p class="shorttext synchronized">Lista las corridas de un proceso</p>
  "!
  "! Devuelve las corridas registradas para un proceso, con su momento de
  "! creación y la cantidad de objetos que guardó cada una. No deserializa.
  "!
  "! @parameter repid  | Identificador del proceso.
  "! @parameter result | Corridas del proceso con su metadata.
  methods list_runs
    importing repid         type clike
    returning value(result) type tt_run_info.

  "! <p class="shorttext synchronized">Borra todos los objetos de una corrida</p>
  "!
  "! Elimina la corrida completa. NO ejecuta COMMIT WORK: la transacción la
  "! controla el llamador.
  "!
  "! @parameter repid  | Identificador del proceso.
  "! @parameter run_id | Identificador de la corrida.
  methods delete_run
    importing repid  type clike
              run_id type sysuuid_c32.

  "! <p class="shorttext synchronized">Borra un objeto puntual de una corrida</p>
  "!
  "! NO ejecuta COMMIT WORK: la transacción la controla el llamador.
  "!
  "! @parameter repid      | Identificador del proceso.
  "! @parameter run_id     | Identificador de la corrida.
  "! @parameter object_key | Clave única del objeto.
  methods delete
    importing repid      type clike
              run_id     type sysuuid_c32
              object_key type sysuuid_c32.

endinterface.
