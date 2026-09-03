class zcx_xc_html definition
  public
  inheriting from cx_static_check final
  create public.

  public section.
    interfaces if_t100_dyn_msg.
    interfaces if_t100_message.

    constants: begin of not_a_table,
                 msgid type symsgid      value 'ZXC_HTML',
                 msgno type symsgno      value '001',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of not_a_table.

    constants: begin of not_a_structure,
                 msgid type symsgid      value 'ZXC_HTML',
                 msgno type symsgno      value '002',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of not_a_structure.

    methods constructor
      importing textid    like if_t100_message=>t100key optional
                !previous like previous                 optional.

  protected section.

endclass.


class zcx_xc_html implementation.

  method constructor ##adt_suppress_generation.

    super->constructor( previous = previous ).

    clear me->textid.

    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.

  endmethod.

endclass.
