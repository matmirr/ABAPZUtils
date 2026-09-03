interface zif_xc_field_validator
  public.

  "! <p class="shorttext synchronized">Valida el valor de un campo</p>
  "!
  "! Devuelve abap_true si el valor es válido. Si la validación falla de forma
  "! recuperable, devuelve abap_false (la línea se descarta). Si la falla es
  "! terminal (impide continuar el proceso), lanza la excepción.
  "!
  "! @parameter field              | Nombre del campo a validar.
  "! @parameter value              | Valor del campo (crudo).
  "! @parameter messages           | Mensajes de resultado de la validación (acumulativo).
  "! @parameter result             | abap_true = válido; abap_false = descartar línea.
  "! @raising   zcx_xc_file_mapper | Validación terminal: el proceso no debe continuar.
  methods validate
    importing !field        type string
              !value        type string
    changing  !messages     type bapirettab optional
    returning value(result) type abap_bool
    raising   zcx_xc_file_mapper.

endinterface.
