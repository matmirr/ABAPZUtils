class zcx_xc_string_utils definition
  public
  inheriting from cx_static_check final
  create public.

  public section.
    interfaces if_t100_dyn_msg.
    interfaces if_t100_message.

    constants: begin of structure_not_found,
                 msgid type symsgid      value 'ZXC_STRING_UTILS',
                 msgno type symsgno      value '001',
                 attr1 type scx_attrname value 'MV_STRUCTURE',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of structure_not_found.

    constants: begin of not_a_structure,
                 msgid type symsgid      value 'ZXC_STRING_UTILS',
                 msgno type symsgno      value '002',
                 attr1 type scx_attrname value 'MV_STRUCTURE',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of not_a_structure.

    constants: begin of parse_failed,
                 msgid type symsgid      value 'ZXC_STRING_UTILS',
                 msgno type symsgno      value '003',
                 attr1 type scx_attrname value 'MV_STRUCTURE',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of parse_failed.

    constants: begin of column_mismatch,
                 msgid type symsgid      value 'ZXC_STRING_UTILS',
                 msgno type symsgno      value '004',
                 attr1 type scx_attrname value 'MV_STRUCTURE',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of column_mismatch.

    data mv_structure type string read-only.

    methods constructor
      importing textid     like if_t100_message=>t100key optional
                !previous  like previous                 optional
                !structure type string                   optional.

  protected section.

endclass.


class zcx_xc_string_utils implementation.

  method constructor ##adt_suppress_generation.

    super->constructor( previous = previous ).

    mv_structure = structure.

    clear me->textid.

    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.

  endmethod.

endclass.
