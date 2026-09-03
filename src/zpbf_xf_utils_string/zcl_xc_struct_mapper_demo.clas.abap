class zcl_xc_struct_mapper_demo definition
  public final
  create public.

  public section.

    interfaces if_oo_adt_classrun.

  private section.

    types: begin of ty_linea,
             posnr    type c length 6,
             material type c length 18,
             concepto type c length 3,
             importe  type c length 13,
           end of ty_linea.

    types tt_linea type standard table of ty_linea with empty key.

    types: begin of ty_cabecera,
             bukrs type c length 4,
             belnr type c length 10,
             fecha type c length 8,
           end of ty_cabecera.

    methods config_cabecera returning value(result) type zxc_t_struct_map.
    methods config_lineas   returning value(result) type zxc_t_struct_map.

endclass.


class zcl_xc_struct_mapper_demo implementation.

  method if_oo_adt_classrun~main.

    " --- Datos: cabecera + líneas ---
    data(ls_cab) = value ty_cabecera( bukrs = '1000'
                                      belnr = '4900012345'
                                      fecha = '20260605' ).

    data(lt_lineas) = value tt_linea( ( posnr = '000010' material = 'MAT-ALPHA' concepto = 'HON' importe = '1500.00' )
                                      ( posnr = '000020' material = 'MAT-BETA'  concepto = 'GAS' importe = '320.50'  )
                                      ( posnr = '000030' material = 'MAT-GAMMA' concepto = 'IVA' importe = '382.61'  ) ).

    try.

        data(lo_doc) = new zcl_xc_file_document( ).

        " Header del ARCHIVO (texto fijo, no mapea)
        lo_doc->add_section( new zcl_xc_text_section( lines = value string_table( ( |HDR FACTURAS SALIDA| ) ) ) ).

        " Datos del DOCUMENTO (mapea la estructura de la factura)
        data(lo_factura) = new zcl_xc_struct_mapper( data   = ls_cab
                                                     config = config_cabecera( ) ).

        lo_factura->add_transformer( key         = 'SOCIEDAD'
                                     transformer = new lcl_sociedad_transformer( ) ).

        lo_doc->add_section( lo_factura ).

        " Posiciones de la factura (mapea la tabla de líneas)
        data(lo_posiciones) = new zcl_xc_struct_table_mapper( data   = lt_lineas
                                                              config = config_lineas( ) ).

        lo_posiciones->add_transformer( key         = 'CONCEPTO'
                                        transformer = new lcl_concepto_transformer( ) ).

        lo_doc->add_section( lo_posiciones ).

        " Footer del ARCHIVO (texto fijo, no mapea)
        lo_doc->add_section( new zcl_xc_text_section( lines = value string_table( ( |FIN ARCHIVO| ) ) ) ).

        out->write( lo_doc->render( ) ).

      catch zcx_xc_struct_mapper into data(error).

        out->write( |Error: { error->get_text( ) }| ).

    endtry.

  endmethod.

  method config_cabecera.

    " Línea única de cabecera: sociedad (transformada) + documento + fecha
    result = value zxc_t_struct_map( proceso      = 'DEMO_CAB'
                                     nro_registro = '0010'
                                     alineacion   = 'IZQ'
                                     activo       = abap_true
                                     ( item_id   = '000001'
                                       nro_campo = '0010'
                                       campo     = 'BUKRS'
                                       longitud  = '004'
                                       accion    = 'SOCIEDAD' )
                                     ( item_id   = '000002'
                                       nro_campo = '0020'
                                       campo     = 'BELNR'
                                       longitud  = '012'
                                       accion    = '' )
                                     ( item_id   = '000003'
                                       nro_campo = '0030'
                                       campo     = 'FECHA'
                                       longitud  = '008'
                                       accion    = '' ) ).

  endmethod.

  method config_lineas.

    " Una línea de salida por cada posición: posnr + concepto (transformado) + importe (DER)
    result = value zxc_t_struct_map( proceso      = 'DEMO_LIN'
                                     nro_registro = '0010'
                                     activo       = abap_true
                                     ( item_id    = '000001'
                                       nro_campo  = '0010'
                                       campo      = 'POSNR'
                                       longitud   = '006'
                                       alineacion = 'IZQ'
                                       accion     = '' )
                                     ( item_id    = '000002'
                                       nro_campo  = '0020'
                                       campo      = 'CONCEPTO'
                                       longitud   = '004'
                                       alineacion = 'IZQ'
                                       accion     = 'CONCEPTO' )
                                     ( item_id    = '000003'
                                       nro_campo  = '0030'
                                       campo      = 'IMPORTE'
                                       longitud   = '015'
                                       alineacion = 'DER'
                                       accion     = '' ) ).

  endmethod.

endclass.
