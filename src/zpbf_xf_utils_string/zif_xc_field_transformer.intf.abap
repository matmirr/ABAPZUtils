interface zif_xc_field_transformer
  public.

  "! <p class="shorttext synchronized">Transforma el valor de un campo</p>
  "!
  "! Recibe el valor crudo de un campo y devuelve el valor transformado.
  "! Se aplica antes de dar formato (alineación / ancho fijo).
  "!
  "! @parameter value                | Valor crudo del campo.
  "! @parameter result               | Valor transformado.
  "! @raising   zcx_xc_struct_mapper | Error durante la transformación (p. ej. valor sin mapeo).
  methods transform
    importing !value        type string
    returning value(result) type string
    raising   zcx_xc_struct_mapper.

endinterface.
