class zcl_xc_file_mapper_demo definition
  public final create public.

  public section.

    interfaces if_oo_adt_classrun.

  private section.

    types: begin of ts_header,
             title type c length 30,
             date  type c length 8,
           end of ts_header.

    types: begin of ts_consultant,
             first_name type c length 15,
             last_name  type c length 15,
             age        type c length 3,
           end of ts_consultant.

    types tt_consultant type standard table of ts_consultant with empty key.

    methods run_separator importing !out type ref to if_oo_adt_classrun_out.
    methods run_fixed     importing !out type ref to if_oo_adt_classrun_out.

endclass.


class zcl_xc_file_mapper_demo implementation.

  method if_oo_adt_classrun~main.

    out->write( |=== Mapeo por SEPARADOR ===| ).
    run_separator( out ).
    out->write( |=== Mapeo por POSICION FIJA ===| ).
    run_fixed( out ).

  endmethod.

  method run_separator.

    " Contenido en memoria: cabecera + 2 registros, separados por ';'
    data(lt_content) = value string_table( ( |CONSULTORES;{ sy-datum }| )
                                           ( |Ana;Garcia;30| )
                                           ( |Luis;Perez;45| )
                                           ( |Mal;Registro;ABC| ) ).      " edad inválida -> debe descartarse

    data(lo_mapper) = new zcl_xc_line_mapper( extractor   = new zcl_xc_sep_extractor( separator = ';' )
                                              validator   = new lcl_age_validator( )
                                              transformer = new lcl_upper_transformer( ) ).
    data(lo_reader) = new zcl_xc_file_content_reader( content         = lt_content
                                                      mapper          = lo_mapper
                                                      has_header_line = abap_true ).

    data ls_header  type ts_header.
    data lt_records type tt_consultant.

    try.

        lo_reader->process( changing cs_header  = ls_header
                                     ct_records = lt_records ).

        out->write( |Cabecera: { ls_header-title } / { ls_header-date }| ).

        loop at lt_records into data(ls_rec).

          out->write( |Registro: { ls_rec-first_name } { ls_rec-last_name } ({ ls_rec-age })| ).

        endloop.

        out->write( lo_reader->get_messages( ) ).

      catch zcx_xc_file_mapper into data(lo_err).

        out->write( |Error: { lo_err->get_text( ) }| ).

    endtry.

  endmethod.

  method run_fixed.

    " Contenido en memoria: cabecera + 2 registros, ancho fijo.
    " Header: title(30) + date(8). Registro: first_name(15) + last_name(15) + age(3).
    data(lt_content) = value string_table( ( |CONSULTORES                   { sy-datum }| )
                                           ( |Ana            Garcia         030| )
                                           ( |Luis           Perez          045| )
                                           ( |Mal            Registro       ABC| ) ).   " edad inválida -> descarta

    data(lo_mapper) = new zcl_xc_line_mapper( extractor   = new zcl_xc_fixed_extractor( )
                                              validator   = new lcl_age_validator( )
                                              transformer = new lcl_upper_transformer( ) ).

    data(lo_reader) = new zcl_xc_file_content_reader( content         = lt_content
                                                      mapper          = lo_mapper
                                                      has_header_line = abap_true ).

    data ls_header  type ts_header.

    data lt_records type tt_consultant.

    try.
        lo_reader->process( changing cs_header  = ls_header
                                     ct_records = lt_records ).

        out->write( |Cabecera: { ls_header-title } / { ls_header-date }| ).

        loop at lt_records into data(ls_rec).

          out->write( |Registro: { ls_rec-first_name } { ls_rec-last_name } ({ ls_rec-age })| ).

        endloop.

        out->write( lo_reader->get_messages( ) ).

      catch zcx_xc_file_mapper into data(lo_err).

        out->write( |Error: { lo_err->get_text( ) }| ).
    endtry.

  endmethod.

endclass.
