class zcl_xc_object_serializer definition
  public final
  create public.

  public section.
    interfaces zif_xc_object_serializer.

    "! <p class="shorttext synchronized">Constructor</p>
    "!
    "! @parameter compress | Si abap_true, el payload se comprime con GZIP
    "!                       en serialize y se descomprime en deserialize.
    "!                       Default: abap_true (preserva comportamiento legacy).
    methods constructor
      importing compress type abap_bool default abap_true.

  private section.
    data compress type abap_bool.

    methods to_xml
      importing !object        type ref to if_serializable_object
      returning value(payload) type xstring
      raising   zcx_xc_serialization.

    methods from_xml
      importing payload       type xstring
      returning value(object) type ref to if_serializable_object
      raising   zcx_xc_serialization.

    methods compress_payload
      importing payload           type xstring
      returning value(compressed) type xstring
      raising   zcx_xc_serialization.

    methods decompress_payload
      importing payload             type xstring
      returning value(decompressed) type xstring
      raising   zcx_xc_serialization.

endclass.


class zcl_xc_object_serializer implementation.

  method constructor.

    me->compress = compress.

  endmethod.

  method zif_xc_object_serializer~serialize.

    payload = to_xml( object ).

    if compress = abap_true.
      payload = compress_payload( payload ).
    endif.

  endmethod.

  method zif_xc_object_serializer~deserialize.

    data(xml) = payload.

    if compress = abap_true.
      xml = decompress_payload( payload ).
    endif.

    object = from_xml( xml ).

  endmethod.

  method to_xml.

    try.
        call transformation id
             source instance = object
             result xml payload
             options data_refs = 'heap-or-create'.
      catch cx_root into data(error).
        raise exception new zcx_xc_serialization( textid   = zcx_xc_serialization=>serialization_failed
                                                  previous = error ).
    endtry.

  endmethod.

  method from_xml.

    try.
        call transformation id
             source xml payload
             result instance = object.
      catch cx_root into data(error).
        raise exception new zcx_xc_serialization( textid   = zcx_xc_serialization=>deserialization_failed
                                                  previous = error ).
    endtry.

  endmethod.

  method compress_payload.

    try.
        cl_abap_gzip=>compress_binary( exporting raw_in   = payload
                                       importing gzip_out = compressed ).
      catch cx_parameter_invalid_range
            cx_sy_buffer_overflow
            cx_sy_compression_error into data(error).
        raise exception new zcx_xc_serialization( textid   = zcx_xc_serialization=>compression_failed
                                                  previous = error ).
    endtry.

  endmethod.

  method decompress_payload.

    try.
        cl_abap_gzip=>decompress_binary( exporting gzip_in = payload
                                         importing raw_out = decompressed ).
      catch cx_parameter_invalid_range
            cx_sy_buffer_overflow
            cx_sy_compression_error into data(error).

        raise exception new zcx_xc_serialization( textid   = zcx_xc_serialization=>decompression_failed
                                                  previous = error ).
    endtry.

  endmethod.

endclass.
