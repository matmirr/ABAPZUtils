class zcx_xc_file_mapper definition
  public
  inheriting from cx_static_check final
  create public.

  public section.
    interfaces if_t100_dyn_msg.
    interfaces if_t100_message.

    constants: begin of count_mismatch,
                 msgid type symsgid      value 'ZXC_FILE_MAPPER',
                 msgno type symsgno      value '004',
                 attr1 type scx_attrname value 'MV_VALUE',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of count_mismatch.

    constants: begin of field_not_found,
                 msgid type symsgid      value 'ZXC_FILE_MAPPER',
                 msgno type symsgno      value '005',
                 attr1 type scx_attrname value 'MV_VALUE',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of field_not_found.

    constants: begin of validation_error,
                 msgid type symsgid      value 'ZXC_FILE_MAPPER',
                 msgno type symsgno      value '006',
                 attr1 type scx_attrname value 'MV_VALUE',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of validation_error.

    constants: begin of transform_error,
                 msgid type symsgid      value 'ZXC_FILE_MAPPER',
                 msgno type symsgno      value '007',
                 attr1 type scx_attrname value 'MV_VALUE',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of transform_error.

    constants: begin of not_a_structure,
                 msgid type symsgid      value 'ZXC_FILE_MAPPER',
                 msgno type symsgno      value '008',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of not_a_structure.

    data mv_value type string read-only.

    methods constructor
      importing textid    like if_t100_message=>t100key optional
                !previous like previous                 optional
                !value    type string                   optional.

  protected section.

endclass.


class zcx_xc_file_mapper implementation.

  method constructor ##adt_suppress_generation.
    super->constructor( previous = previous ).
    mv_value = value.
    clear me->textid.
    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.
  endmethod.

endclass.
