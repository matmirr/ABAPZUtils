class zcx_xc_serialization definition
  public
  inheriting from cx_static_check final
  create public.

  public section.
    interfaces if_t100_dyn_msg.
    interfaces if_t100_message.

    constants: begin of serialization_failed,
                 msgid type symsgid      value 'ZXC_SERIAL',
                 msgno type symsgno      value '001',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of serialization_failed.

    constants: begin of deserialization_failed,
                 msgid type symsgid      value 'ZXC_SERIAL',
                 msgno type symsgno      value '002',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of deserialization_failed.

    constants: begin of compression_failed,
                 msgid type symsgid      value 'ZXC_SERIAL',
                 msgno type symsgno      value '003',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of compression_failed.

    constants: begin of decompression_failed,
                 msgid type symsgid      value 'ZXC_SERIAL',
                 msgno type symsgno      value '004',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of decompression_failed.

    methods constructor
      importing textid    like if_t100_message=>t100key optional
                !previous like previous                 optional.

endclass.


class zcx_xc_serialization implementation.

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
