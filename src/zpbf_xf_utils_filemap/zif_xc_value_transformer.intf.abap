interface zif_xc_value_transformer
  public.

  "! <p class="shorttext synchronized">Transforma el valor de un campo</p>
  "!
  "! Recibe el valor crudo de un campo (junto con su nombre, para poder
  "! discriminar el tratamiento por campo) y devuelve el valor transformado.
  "!
  "! @parameter field              | Nombre del campo a transformar.
  "! @parameter value              | Valor crudo del campo.
  "! @parameter result             | Valor transformado.
  "! @raising   zcx_xc_file_mapper | Error en la transformación.
  methods transform
    importing !field        type string
              !value        type string
    returning value(result) type string
    raising   zcx_xc_file_mapper.

endinterface.
