class zcx_xc_app_log definition
  public
  inheriting from cx_static_check final
  create public.

  public section.
    interfaces if_t100_dyn_msg.
    interfaces if_t100_message.

    aliases msgty   for if_t100_dyn_msg~msgty.
    aliases msgv1   for if_t100_dyn_msg~msgv1.
    aliases msgv2   for if_t100_dyn_msg~msgv2.
    aliases msgv3   for if_t100_dyn_msg~msgv3.
    aliases msgv4   for if_t100_dyn_msg~msgv4.
    aliases t100key for if_t100_message~t100key.

    constants: begin of header_inconsistent,
                 msgid type symsgid      value 'ZXC_APP_LOG',
                 msgno type symsgno      value '001',
                 attr1 type scx_attrname value 'MSGV1',
                 attr2 type scx_attrname value 'MSGV2',
                 attr3 type scx_attrname value 'MSGV3',
                 attr4 type scx_attrname value '',
               end of header_inconsistent.

    constants: begin of object_not_found,
                 msgid type symsgid      value 'ZXC_APP_LOG',
                 msgno type symsgno      value '002',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of object_not_found.

    constants: begin of msg_inconsistent,
                 msgid type symsgid      value 'ZXC_APP_LOG',
                 msgno type symsgno      value '003',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of msg_inconsistent.

    constants: begin of log_is_full,
                 msgid type symsgid      value 'ZXC_APP_LOG',
                 msgno type symsgno      value '004',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of log_is_full.

    constants: begin of log_not_found,
                 msgid type symsgid      value 'ZXC_APP_LOG',
                 msgno type symsgno      value '009',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of log_not_found.

    constants: begin of save_failed,
                 msgid type symsgid      value 'ZXC_APP_LOG',
                 msgno type symsgno      value '010',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of save_failed.

    constants: begin of handler_read_failed,
                 msgid type symsgid      value 'ZXC_APP_LOG',
                 msgno type symsgno      value '013',
                 attr1 type scx_attrname value 'MSGV1',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of handler_read_failed.

    methods constructor
      importing textid    like if_t100_message=>t100key optional
                !previous like previous                 optional
                msgv1     type symsgv                   optional
                msgv2     type symsgv                   optional
                msgv3     type symsgv                   optional
                msgv4     type symsgv                   optional.

    "! <p class="shorttext synchronized">Devuelve la estructura SYMSG de la excepción</p>
    methods get_message
      returning value(rs_msg) type symsg.

endclass.


class zcx_xc_app_log implementation.

  method constructor ##adt_suppress_generation.
    super->constructor( previous = previous ).

    me->msgv1 = msgv1.
    me->msgv2 = msgv2.
    me->msgv3 = msgv3.
    me->msgv4 = msgv4.

    clear me->textid.
    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.
  endmethod.

  method get_message.
    rs_msg = value #( msgid = t100key-msgid
                      msgno = t100key-msgno
                      msgty = msgty
                      msgv1 = msgv1
                      msgv2 = msgv2
                      msgv3 = msgv3
                      msgv4 = msgv4 ).
  endmethod.

endclass.
