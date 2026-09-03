interface zif_xc_object_serializer
  public.

  "! <p class="shorttext synchronized">Serializa una instancia a payload binario</p>
  "!
  "! Convierte una instancia que implementa IF_SERIALIZABLE_OBJECT en una
  "! representación binaria (xstring) apta para persistencia o transmisión.
  "! Si la instancia fue creada con compresión activa, el payload viene
  "! comprimido con GZIP.
  "!
  "! @parameter object               | Instancia a serializar. No puede ser inicial.
  "! @parameter payload              | Payload binario resultante.
  "! @raising   zcx_xc_serialization | Falla en serialización o compresión.
  methods serialize
    importing !object        type ref to if_serializable_object
    returning value(payload) type xstring
    raising   zcx_xc_serialization.

  "! <p class="shorttext synchronized">Reconstruye una instancia desde payload binario</p>
  "!
  "! Reconstruye la instancia original a partir del payload binario producido
  "! por serialize. Debe usarse el mismo modo de compresión con el que se
  "! serializó.
  "!
  "! @parameter payload              | Payload binario producido por serialize.
  "! @parameter object               | Instancia reconstruida.
  "! @raising   zcx_xc_serialization | Falla en descompresión o deserialización.
  methods deserialize
    importing payload       type xstring
    returning value(object) type ref to if_serializable_object
    raising   zcx_xc_serialization.

endinterface.
