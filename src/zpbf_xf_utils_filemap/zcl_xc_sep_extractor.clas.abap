class zcl_xc_sep_extractor definition
  public final
  create public.

  public section.

    interfaces zif_xc_value_extractor.

    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter separator | Separador de campos.
    methods constructor
      importing separator type abap_char1.

  private section.

    data mv_separator type abap_char1.

endclass.


class zcl_xc_sep_extractor implementation.

  method constructor.

    mv_separator = separator.

  endmethod.

  method zif_xc_value_extractor~extract.

    split line at mv_separator into table result.

    if lines( result ) <> lines( components ).

      raise exception new zcx_xc_file_mapper( textid = zcx_xc_file_mapper=>count_mismatch
                                              value  = |{ lines( result ) } vs { lines( components ) }| ).

    endif.

  endmethod.

endclass.
