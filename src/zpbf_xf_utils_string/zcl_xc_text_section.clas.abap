class zcl_xc_text_section definition
  public final
  create public.

  public section.

    interfaces zif_xc_file_section.

    "! <p class="shorttext synchronized">Constructor</p>
    "! @parameter lines     | Líneas de texto de la sección.
    "! @parameter separator | Separador de línea. Por defecto, salto de línea.
    methods constructor
      importing !lines    type string_table
                separator type string optional.

  private section.

    data mt_lines     type string_table.
    data mv_separator type string.

endclass.


class zcl_xc_text_section implementation.

  method constructor.

    mt_lines     = lines.
    mv_separator = cond #( when separator is supplied
                           then separator
                           else cl_abap_char_utilities=>cr_lf ).

  endmethod.

  method zif_xc_file_section~render.

    result = concat_lines_of( table = mt_lines
                              sep   = mv_separator ) && mv_separator.

  endmethod.

endclass.
