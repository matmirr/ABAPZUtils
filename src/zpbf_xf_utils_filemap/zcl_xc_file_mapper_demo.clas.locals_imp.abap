*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

"--- Validador de ejemplo: AGE debe ser numérica y mayor que 0 ---
class lcl_age_validator definition create public.

  public section.
    interfaces zif_xc_field_validator.

endclass.


class lcl_age_validator implementation.

  method zif_xc_field_validator~validate.

    result = abap_true.

    " Solo controla AGE; el resto pasa.
    if field <> 'AGE'.
      return.
    endif.

    data(lv_age) = condense( value ).

    if lv_age co '0123456789' and lv_age > 0.
      " válido
    else.
      " Validación recuperable: descarta la línea
      result = abap_false.

      messages = value #( base messages
                          ( type       = 'E'
                            id         = 'ZXC_FILE_MAPPER'
                            number     = '006'
                            message_v1 = field ) ).
    endif.

  endmethod.

endclass.

"--- Transformador de ejemplo: apellido a mayúsculas ---
class lcl_upper_transformer definition create public.

  public section.
    interfaces zif_xc_value_transformer.

endclass.


class lcl_upper_transformer implementation.

  method zif_xc_value_transformer~transform.

    " Solo transforma LAST_NAME; el resto queda igual.
    result = cond #( when field = 'LAST_NAME'
                     then to_upper( value )
                     else value ).

  endmethod.

endclass.
