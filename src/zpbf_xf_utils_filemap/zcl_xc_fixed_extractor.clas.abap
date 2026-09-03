class zcl_xc_fixed_extractor definition
  public final
  create public.

  public section.
    interfaces zif_xc_value_extractor.

endclass.


class zcl_xc_fixed_extractor implementation.

  method zif_xc_value_extractor~extract.

    data lv_offset type i.
    data lv_length type i.

    " Por cada componente, extraer un substring de la línea según su longitud
    loop at components into data(ls_component).

      " Longitud de salida del campo (RTTI)
      lv_length = cast cl_abap_elemdescr( ls_component-type )->output_length.

      " Extraer el valor en la posición actual
      append line+lv_offset(lv_length) to result.

      " Avanzar el offset
      lv_offset += lv_length.

    endloop.

  endmethod.

endclass.
