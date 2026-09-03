class zcx_xc_struct_mapper definition
  public
  inheriting from cx_static_check final
  create public.

  public section.
    interfaces if_t100_dyn_msg.
    interfaces if_t100_message.

    constants: begin of field_not_found,
                 msgid type symsgid      value 'ZXC_STRUCT_MAPPER',
                 msgno type symsgno      value '001',
                 attr1 type scx_attrname value 'MV_VALUE',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of field_not_found.

    constants: begin of not_a_structure,
                 msgid type symsgid      value 'ZXC_STRUCT_MAPPER',
                 msgno type symsgno      value '002',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of not_a_structure.

    constants: begin of transformer_not_found,
                 msgid type symsgid      value 'ZXC_STRUCT_MAPPER',
                 msgno type symsgno      value '003',
                 attr1 type scx_attrname value 'MV_VALUE',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of transformer_not_found.

    constants: begin of config_not_found,
                 msgid type symsgid      value 'ZXC_STRUCT_MAPPER',
                 msgno type symsgno      value '004',
                 attr1 type scx_attrname value 'MV_VALUE',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of config_not_found.

    constants: begin of transform_error,
                 msgid type symsgid      value 'ZXC_STRUCT_MAPPER',
                 msgno type symsgno      value '005',
                 attr1 type scx_attrname value 'MV_VALUE',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of transform_error.

    data mv_value type string read-only.

    methods constructor
      importing textid    like if_t100_message=>t100key optional
                !previous like previous                 optional
                !value    type string                   optional.

  protected section.

endclass.


class zcx_xc_struct_mapper implementation.

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
