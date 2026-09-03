class zcx_xc_file_utils definition
                            public
                   inheriting from cx_static_check
                             final
                     create public.

  public section.

    interfaces if_t100_dyn_msg.
    interfaces if_t100_message.

    constants: begin of open_for_write_failed,
                 msgid type symsgid      value 'ZXC_FILE_UTILS',
                 msgno type symsgno      value '001',
                 attr1 type scx_attrname value 'MV_FILENAME',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of open_for_write_failed.

    constants: begin of open_for_read_failed,
                 msgid type symsgid      value 'ZXC_FILE_UTILS',
                 msgno type symsgno      value '002',
                 attr1 type scx_attrname value 'MV_FILENAME',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of open_for_read_failed.

    constants: begin of write_failed,
                 msgid type symsgid      value 'ZXC_FILE_UTILS',
                 msgno type symsgno      value '003',
                 attr1 type scx_attrname value 'MV_FILENAME',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of write_failed.

    constants: begin of file_not_found,
                 msgid type symsgid      value 'ZXC_FILE_UTILS',
                 msgno type symsgno      value '004',
                 attr1 type scx_attrname value 'MV_FILENAME',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of file_not_found.

    constants: begin of out_of_scope,
                 msgid type symsgid      value 'ZXC_FILE_UTILS',
                 msgno type symsgno      value '005',
                 attr1 type scx_attrname value 'MV_FILENAME',
                 attr2 type scx_attrname value 'MV_SCOPE',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of out_of_scope.

    constants: begin of scope_undetermined,
                 msgid type symsgid      value 'ZXC_FILE_UTILS',
                 msgno type symsgno      value '006',
                 attr1 type scx_attrname value 'MV_LOGICAL_PATH',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of scope_undetermined.

    constants: begin of lock_failed,
                 msgid type symsgid      value 'ZXC_FILE_UTILS',
                 msgno type symsgno      value '007',
                 attr1 type scx_attrname value 'MV_FILENAME',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of lock_failed.

    constants: begin of list_failed,
                 msgid type symsgid      value 'ZXC_FILE_UTILS',
                 msgno type symsgno      value '008',
                 attr1 type scx_attrname value 'MV_DIRNAME',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of list_failed.

    constants: begin of hash_error,
                 msgid type symsgid      value 'ZXC_FILE_UTILS',
                 msgno type symsgno      value '009',
                 attr1 type scx_attrname value '',
                 attr2 type scx_attrname value '',
                 attr3 type scx_attrname value '',
                 attr4 type scx_attrname value '',
               end of hash_error.

    data mv_filename     type string read-only.
    data mv_scope        type string read-only.
    data mv_logical_path type string read-only.
    data mv_dirname      type string read-only.

    methods constructor
      importing textid       like if_t100_message=>t100key optional
                !previous    like previous                 optional
                filename     type string                   optional
                !scope       type string                   optional
                logical_path type string                   optional
                dirname      type string                   optional.

    protected section.

endclass.


class zcx_xc_file_utils implementation.

  method constructor ##adt_suppress_generation.

    super->constructor( previous = previous ).
    mv_filename     = filename.
    mv_scope        = scope.
    mv_logical_path = logical_path.
    mv_dirname      = dirname.

    clear me->textid.

    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.

  endmethod.

endclass.
