*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

"--- Transformador de SOCIEDAD (cabecera): SAP -> externo ---
class lcl_sociedad_transformer definition create public.

  public section.
    interfaces zif_xc_field_transformer.

endclass.


class lcl_sociedad_transformer implementation.

  method zif_xc_field_transformer~transform.

    case value.
      when '1000'. result = 'AR01'.
      when '2000'. result = 'AR02'.
      when '3000'. result = 'UY01'.
      when others.
        raise exception new zcx_xc_struct_mapper( textid = zcx_xc_struct_mapper=>transform_error
                                                  value  = |Sociedad { value } sin mapeo externo| ).
    endcase.

  endmethod.

endclass.


"--- Transformador de CONCEPTO de factura (líneas): interno -> externo ---
class lcl_concepto_transformer definition create public.

  public section.

    interfaces zif_xc_field_transformer.

endclass.


class lcl_concepto_transformer implementation.

  method zif_xc_field_transformer~transform.

    case value.
      when 'HON'. result = 'H001'.   " Honorarios
      when 'GAS'. result = 'G001'.   " Gastos
      when 'IVA'. result = 'I001'.   " IVA
      when others.
        raise exception new zcx_xc_struct_mapper( textid = zcx_xc_struct_mapper=>transform_error
                                                  value  = |Concepto { value } sin mapeo externo| ).
    endcase.

  endmethod.

endclass.
