class zcl_xc_line_mapper definition
  public final
  create public.

  public section.
    interfaces zif_xc_line_mapper.

    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter extractor   | Estrategia de extracción de valores (fixed/sep).
    "! @parameter validator   | Validador de campos (opcional).
    "! @parameter transformer | Transformador de valores (opcional).
    methods constructor
      importing extractor   type ref to zif_xc_value_extractor
                validator   type ref to zif_xc_field_validator   optional
                transformer type ref to zif_xc_value_transformer optional.

  private section.

    data mo_extractor   type ref to zif_xc_value_extractor.
    data mo_validator   type ref to zif_xc_field_validator.
    data mo_transformer type ref to zif_xc_value_transformer.

endclass.


class zcl_xc_line_mapper implementation.

  method constructor.

    mo_extractor   = extractor.
    mo_validator   = validator.
    mo_transformer = transformer.

  endmethod.

  method zif_xc_line_mapper~map.

    " 1) Componentes de la estructura destino
    data(lo_type) = cl_abap_typedescr=>describe_by_data( data ).

    if lo_type->kind <> cl_abap_typedescr=>kind_struct.

      raise exception new zcx_xc_file_mapper( textid = zcx_xc_file_mapper=>not_a_structure ).

    endif.

    data(lt_components) = cast cl_abap_structdescr( lo_type )->get_components( ).

    " 2) Extraer valores crudos (la estrategia define cómo)
    data(lt_values) = mo_extractor->extract( line       = line
                                             components = lt_components ).

    " 3) Recorrer campos: validar, transformar, asignar
    loop at lt_components into data(ls_component).

      data(lv_idx)   = sy-tabix.
      data(lv_value) = lt_values[ lv_idx ].

      assign component lv_idx of structure data to field-symbol(<field>).

      " Validación (solo registros, si hay validador)
      if is_header = abap_false and mo_validator is bound.

        if mo_validator->validate( exporting field    = ls_component-name
                                             value    = lv_value
                                   changing  messages = messages ) = abap_false.
          " Validación fallida (recuperable): descartar línea
          result = abap_false.

          return.

        endif.

      endif.

      " Transformación (solo registros, si hay transformador)
      if is_header = abap_false and mo_transformer is bound.

        <field> = mo_transformer->transform( field = ls_component-name
                                             value = lv_value ).
      else.

        <field> = lv_value.

      endif.

    endloop.

    result = abap_true.

  endmethod.

endclass.
