class zcl_xc_html_demo definition
  public final
  create public.

  public section.
    interfaces if_oo_adt_classrun.

  private section.

    "! Construye un documento HTML de ejemplo con todos los elementos.
    "!
    "! @parameter result      | Documento HTML
    "! @raising   zcx_xc_html | Excepción
    methods build_document
      returning value(result) type ref to zcl_xc_html_document
      raising   zcx_xc_html.

endclass.


class zcl_xc_html_demo implementation.

  method if_oo_adt_classrun~main.

    try.

        data(lo_doc) = build_document( ).

        " Renderiza el HTML completo a la consola.
        out->write( lo_doc->zif_xc_html_element~to_html( ) ).

      catch zcx_xc_html into data(error).

        out->write( |Error: { error->get_text( ) }| ).

    endtry.

  endmethod.

  method build_document.

    " --- Datos de ejemplo en memoria (sin dependencia de tablas DDIC) ---
    types: begin of ty_flight,
             carrid   type c length 3,
             connid   type n length 4,
             fldate   type d,
             price    type p length 8 decimals 2,
             currency type c length 5,
           end of ty_flight.
    types tt_flight type standard table of ty_flight with empty key.

    types: begin of ty_booking,
             customid type n length 8,
             custtype type c length 1,
             class    type c length 1,
             passname type c length 25,
           end of ty_booking.
    types tt_booking type standard table of ty_booking with empty key.

    data(ls_header) = value ty_flight( carrid   = 'AA'
                                       connid   = '0017'
                                       fldate   = '20230307'
                                       price    = '422.94'
                                       currency = 'USD' ).

    data(lt_flights) = value tt_flight( carrid   = 'AA'
                                        connid   = '0017'
                                        currency = 'USD'
                                        ( fldate = '20230307' price = '422.94' )
                                        ( fldate = '20230407' price = '430.00' ) ).

    data(lt_bookings) = value tt_booking( ( customid = '00000001' custtype = 'P' class = 'Y' passname = 'John Doe' )
                                          ( customid = '00000002' custtype = 'B' class = 'C' passname = 'Jane Roe' ) ).

    " --- Documento ---
    result = new zcl_xc_html_document( 'Información de las reservas' ).

    " Estilo CSS en el head
    data(lv_css) =
      |p { '{' } font-family: Garamond, sans-serif; font-weight: bold; { '}' } | &&
      |table { '{' } border: 1px solid #000; border-collapse: collapse; { '}' } | &&
      |table td, table th { '{' } border: 1px solid #000; padding: 10px; { '}' } | &&
      |table tr:nth-child(even) { '{' } background: #D0E4F5; { '}' } | &&
      |th { '{' } background-color: #7EA8F8; { '}' }|.

    result->get_head( )->add_child( new zcl_xc_html_style( lv_css ) ).

    " Párrafo con atributos (texto resuelto, sin SO10)
    data(lo_p) = new zcl_xc_html_paragraph( text = 'Detalle del vuelo y sus reservas' ).
    lo_p->zif_xc_html_element~add_attribute( name  = 'style'
                                             value = 'color:blue'
      )->add_attribute( name  = 'title'
                        value = 'Información de vuelo' ).
    result->get_body( )->add_child( lo_p ).

    " Tabla a partir de estructura (cabecera del vuelo) con labels configurados
    data(lo_head_table) = new zcl_xc_html_table( ).

    lo_head_table->set_struct_data( data           = ls_header
                                    visible_fields = 'CARRID,CONNID,FLDATE'
                                    labels         = value #( ( field = 'CARRID' label = 'Aerolínea' )
                                                              ( field = 'CONNID' label = 'Conexión' )
                                                              ( field = 'FLDATE' label = 'Fecha' ) ) ).
    result->get_body( )->add_child( lo_head_table ).
    result->line_break( ).

    " Tabla a partir de tabla interna (vuelos)
    data(lo_flights_table) = new zcl_xc_html_table( ).
    lo_flights_table->set_table_data( data           = lt_flights
                                      visible_fields = 'CARRID,CONNID,FLDATE,PRICE,CURRENCY' ).
    result->get_body( )->add_child( lo_flights_table ).
    result->line_break( ).

    " Tabla a partir de tabla interna (reservas)
    data(lo_book_table) = new zcl_xc_html_table( ).
    lo_book_table->set_table_data( data           = lt_bookings
                                   visible_fields = 'CUSTOMID,CUSTTYPE,CLASS,PASSNAME' ).
    result->get_body( )->add_child( lo_book_table ).
    result->line_break( ).

    " Imagen por URL
    data(lo_img) = new zcl_xc_html_image(
        src = 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/SAP_2011_logo.svg/960px-SAP_2011_logo.svg.png'
        alt = 'SAP Logo' ).
    lo_img->set_width( '150' ).
    result->get_body( )->add_child( lo_img ).
    result->line_break( ).

    " Imagen embebida en base64 (binario de ejemplo)
    data(lo_img_embed) = new zcl_xc_html_image( alt = 'Imagen embebida' ).
    lo_img_embed->embed_base64(
        content   = conv xstring(
                                  |FFD8FFE000104A46494600010100000100010000FFDB00430006040506050406060506070706080A100A0A09090A| &&
                                  |140E0F0C1017141818171416161A1D251F1A1B231C1616202C20232627292A29191F2D302D283025282928FFDB00| &&
                                  |43010707070A080A130A0A13281A161A282828282828282828282828282828282828282828282828282828282828| &&
                                  |2828282828282828282828282828282828282828FFC00011080096009603012200021101031101FFC4001B000100| &&
                                  |02030101000000000000000000000004050203060701FFC400391000010401030204040306050500000000010002| &&
                                  |030411051221063113415161142271813291A10715234272B1435262B2E18292A2D1F0FFC4001A01010003010101| &&
                                  |0000000000000000000000030405020601FFC4003111000201020405020405050000000000000001020311041221| &&
                                  |3141516171810591132242A132B1C1D1F0146272E1F1FFDA000C03010002110311003F00F024445A267044440111| &&
                                  |100444401111004444011110044440111100444401111004444011110045BBE166F8316C464D7F13C22F1C80EC67| &&
                                  |07D091C8CF7C1C7657F4F46975EE9A1634B87C6D434E716598631F3BE13CB2403F9B69DCD38E7185055C44292529| &&
                                  |3D2F66F977F3A792585294DB4B7B5FB94366ACB5E2AD24806CB11F8B191E637169FB82D216CB745F5A950B0F7716| &&
                                  |D8F91A31D835E59FAE0AE9E3D3A3D6FF006762E579036EE82E7B668CFF00890C8FDC1C3DC12EFC8AF9D554E293A1| &&
                                  |3A4F5389C04BE14949D1FAED7B9C08FB939FA855238EBCE307BE7717ECDAF75664EF0D68B92DB2A6BDD27ECEE8E5| &&
                                  |65A92C54E0B2F6E229DCF6C67CDDB7009FA64E3EC5685DCF5EE87333A9F45D12900E71A55E18221C6D7127767EAE| &&
                                  |DCE27DD50754C7568DF3A5D2198E839D1493B861D3CB9C3DDECDC8C347A0F5254985C6C6BC60D6F24DF65C2FF65D| &&
                                  |EFC8E2B61DD272BF0D3C94A8B75BA93D391B1DA89D148E607EC7F0E00F6C8F2C8E707CB0B4ABA9A92BA2BB4D3B30| &&
                                  |888BE9F022220088880222200888802DD4E06D9B2C89F3C35C3B8124C48603E59201C0F7EC3CD69565A5696DD49B| &&
                                  |B21BF4E1B59C360B2E316FFE9791B73EC4851D59A845B6EDD4EE11729592B96141D77A5F509A2D5B4C7CD4A66065| &&
                                  |AAD283E1CD1E720B5E38C83CB5C0FF0075D04B1D6D065A3D59D0F3599A831DB2DD7932E7C1D8963FCF6B8799F300| &&
                                  |E7B2B0D1A9F5FF004BE95BE0AECBBA5B07CD4CC8DB0D0DF3C341C81FD27ECA6F48D7AB3EAED7F4C4FF00BBADDB6E| &&
                                  |753D16FC6ED821CFCDE19DA3D4E3D8F9765E67138B52CD56EA4B6795DE325C5496B95DB67AF04DD8D9A3876AD0D5| &&
                                  |3E17566BFC5F15CD69CD2308344AF1F54EB94A391F628F5169F2D8A6EAE38CEEDFB49ED9047EA07195954E9992E5| &&
                                  |1E84AD7B49BD1D7AC2796EE5BC379DD870F2DC47D7070BD2B4D8746E9CA5169B565AF5218F25914938C8C9C9FC47| &&
                                  |3DD58CF6A0AF089679E28A23D9EF78683F72BCC54F59AD75F0D3E8DEEFE5714F4E366B9EA8DB87A753B7CED755E5| &&
                                  |4ADDAE9F8678B56B7F0562FF005D5826D5DB7664AFA5539410E393B43C8EF86B78007E7CA80CA83A6747B9AEEB8F| &&
                                  |8C753DD25D4AB48017C05C72E99CCF23C9233DB8F33C7AEEB1A6D7D54B355D20D39B5AA91BE3A73BE42E8E373BD4| &&
                                  |34E3D7F35E55349A450D4BF78455ADF56EBAF909B0FD8E15A39B3D800DF9B07B0ED8FB2D8C0E3162934A2F826B8D| &&
                                  |97E185F44A3CDBB3936D58CEC4E19D0B36D747D5EF2B6EE5C92D169A9C8BB42D4E6AC753D488AB5E6264F88BB26D| &&
                                  |74C7CCB5A7E7793EC1522EE3A8F42D7B54B126B9D53629693E39C462E485A703B318C6873B007FCAE3EF410D79BC| &&
                                  |3AF6E3B4D039923639ADCFA0DC013F5C05EAF0588F8D1D649BFEDD974BECFEDD918588A3F0DECD77DDF5B70FE6A4| &&
                                  |7444578AC111100444401111004444015B69BA5D2B91B7C6D728D390F76588A5007FD41A41552AC74CABA74CDDDA| &&
                                  |8EA6EA833F823ACE99D8FCC0FD5435DB50BA6D76577ED6649495E56B27DDDBF547531697D39A7881D47AE6586E87| &&
                                  |026482AC9E1B4FB16E08FBAF51E84BE2FEA3A8EEEA3A9AEBE18E36B5F1D5113E369CF7701C827C81EE1799D1BDA3| &&
                                  |BD91E9DD29D24758B6D1B9F66FB37BDDEFB1A7007DC05DD68DACDDD2B53A6EEA2B7A6D47DDDB599A469F5C39EC7E| &&
                                  |406B9E41246071E60670BC67AB53A9569B8CAEE5ADB364CDBA7A28C5C92B2E2D75E47A3F4F9C29CD3564BA66B7BB| &&
                                  |767ECCE8F5CE91A9ABEA02DBECDA865380E11B8169C63B02383C775574FA6AB6ADA2E9D1497AC363ABE3B21DAE6B| &&
                                  |8BDBE29C39D9EFC340EDE6BB67038201DA7C8E3B2E6B43D02D69FACD8B72D985D1BF3F82089AE933EBB63696F97F| &&
                                  |31CAF33471753E1B4EA5B2EDECD5B6EA6D55C3C33DD42F7DFECCB2E9FD16BE8751D0D79269371DCE7CAEC92718FB| &&
                                  |0F65E77D53A896DDD5E9C3D73574A6B2C65B522AA63734E3905ED193EE467DD75DFB46D4351D2F438ED69960407C| &&
                                  |611C876827041C633EEBCC2C752DA929C55F57ADA6EB75A77EE985888C53C78E00F1063271D9C327B82B5BD23095| &&
                                  |6B378A93CD77D2FA6BF545ADB6D57728FA8568535F023A5BBDBECD3FCC87AD68DA6BD8CB7ACF5D457A77370CF062| &&
                                  |7D97E3FEEE07E4B91D4AB55AEF68A7A832EB4F9B617C647D4387F6CAB6D69DD3F35ADDA6D6929C0DEEC360CC5C7E| &&
                                  |BE5F6501D6EB570DF85898E246727396FB1CAF6D845521157727D1A8A4BD97EA799AF924DE89754E4DFDDFE84010| &&
                                  |4BE13A4D8431BDC9E16B52A6BF3CC1CD7380691820051568C737D454965FA42222E8E422220088880222200B7536| &&
                                  |40FB0D16E67C30777398CDEEFA0191CFD480B4AB1AA68C9C4916D77902E763F35C5495971F07708DDFEE5F52EA39| &&
                                  |2BD41A274855969BAEC8D649664903EC4EE270064001839EC3DF9578F741D1BA8C9A274C46DD4BA92CB3C1B1764C| &&
                                  |6D85C7BB631E4477249E38CFA0E62AC2CA761935332433B4FC92C6F735CD38F220FA287146C1A8590E6308C02449| &&
                                  |F3F7EE7272B1E785A751BB7E1DDA7F53E199DEED2E57B78468C6ACE095F7D9745D3826F99EB7D3FAE8D2F531A269| &&
                                  |77E1BBA6E954A59AECF61FF3493649DAC79E300FDB19EEACF4FEB79AD0E99F169D683F7C3252E71B00885CD04B46| &&
                                  |3DF8EF8EF8EEBC6C4111DA3C18FEF1B7FF004BE18206977C91127B7C8DEFF92CBABE8787AADCA5ABE76D6F67AE8D| &&
                                  |7177F096C5E87A8D682B476FF9A7B2B79B9D5754EA336BFD3D25DB76D875BD16CBA0B3042710BE22F20481B9E790| &&
                                  |0647A72A9F4A3ACD391FAF68223923A8D2D9776D7B71E63693938EFC72156F81101CC511C1F2637E9C70B2F06B82| &&
                                  |4F8316703BB1A703F25A54F0F1A54DD28DB2DF66B4B3DD5B4EB6E57E3629CEA4A72CF2DF9DF5BAD9FE57E667AA6B| &&
                                  |B43A843DFAA50AF42FF765BA3190D79F4963CF3FD4391E85732AFE6F8684FF001040DE3B16B73FD955DCB51CADD9| &&
                                  |0C2C637D4B0077E8B470D18D35969A797BE8BB7EC52AF797CD37A9111115C2B04444011110044440111100444406| &&
                                  |F86D4B0B76B5D967F948E16EAF74B2C492BD8487E338F253E0AD59B421179D107386F6E7F86707DF193FD97C3046| &&
                                  |5B3410B5E227105C064904763CF9F3C1ECE1E855275E9B6D65F3E4B6A8CD24EE488656CAC0E64996E3F99C01FF00| &&
                                  |72C89181970DDDCE1C31FEE51A8426BC92445E4E30EFF2E339F70A50711821D9206305FDFF00F2504AC9E84F1BB5| &&
                                  |A9A2CDA6C31193249CE0341F3FA67B2A896ED893FC47347A3490ACEEC6CB1E135D239ADCB9C4E7DB27B9F4CF2B5F| &&
                                  |C1C0DCBCC2EF0DB82774C0719F33953539D382F996A4338CE6F47A1504971C9249F525149D4218E19FF80E0E8DCD| &&
                                  |0E18787633E5C12A32B9192924D15251717661111747C08888022220088880222200888809B0B6D8ACDD9046630F| &&
                                  |232E8DA4E78F5E54B8596268818DD343C7F2B8EC07CF000EDF7C2F9A7D7D4AEC6FB91D88C450C8D639F66D363697| &&
                                  |10486FCCE19E1A7B7A293F0172BCD4612E8257DBCF82CAE1B2890EE2DC07825BDFBFA2A9384B8A5E0B309479B363| &&
                                  |237319F386B9C4F390F1CFB607D16418F6B890D1823B61FC7E8A453D1EF4D78D2218EBD825D0B0463B0DDC1EC46D| &&
                                  |E411F8B231DF9C2B50B17EE41528B7C79E425AD606B1BF303CE49C01819CE7D1557BD8B2B6B9A248E59E3DA06D73| &&
                                  |7E607E63B4FAF650E517E09016358627100131E5A79E33B873F753C51BF1C31CB2C9A730484B98259E188BD992DC| &&
                                  |ED71C8F99A47FF00656034DD46DDBB54E1858EB750EF96B3A36E4608C8DC387649180397640014D1A725BABA2294| &&
                                  |D3D9EA51D8A762132192325ACC1739BCB467B723851D7D73CB8B88E038E70381F92F8AEC735BE629CAD7D02222E8| &&
                                  |F811110044440111100444401111017BA1DF91BA74BA656AF5E5B162CB260EB31324606B23783C381C1E7BFB2B8A| &&
                                  |AFBF583E7B74EBDA9BC1756A91C2E10C70C6FC995E03307241C6476DC73E4B93A0E8193B5F6249E30D39CC206EFB| &&
                                  |1CF0AF0DBE9D74A2423591B3903C605C4F6EFE4BA8C337148E255726966FB1751CD33EB42C76942B4F1D592AB76C| &&
                                  |8E707B1EC708C12EF9B7308703CF0303C82CE1D5036DC537C2ECB523996AEC9E2371346C91A46CC76DE70F767BB8| &&
                                  |7902428BA2DFE8A89CF9B51A5AB4BB1BF241E3FE3711C9DC3B1FF9531FABFECF62DE1BA36AD6A1710042E984786E| &&
                                  |73B7393F2E71DB955EAC72CAC95FB1628CF3C733D3BFFA22D89AC5B81B0D7828C8CA919AE4CF5D921F18CAE76097| &&
                                  |349C61F8F4E162D9ACB284A65AB1D8B66D7C55CB4FB0F88F8CD38635BB3030D0723DC9F2016ABFAAF4ADE9A491D4| &&
                                  |75185A5FB9913262E6C63C80C9F2502E6A1A2B9EDF87FDF0181B8C19C73ECAC2A3657CC8ABFD4B6ED91FF3C955AE| &&
                                  |5BAFA86A72DCAB5FE19B3E247C20E5AC90FE3DBFE9CE48CF2338F2501673988CA4C0D7B63F20F392B05C92DEE111| &&
                                  |10044440111100444401111004444011110044440111100444401111004444011110044440111100444401111004| &&
                                  |44401111004444011110044440111101FFD9| )
        mime_type = 'image/jpeg' ).
    lo_img_embed->set_width( '100' ).
    result->get_body( )->add_child( lo_img_embed ).

  endmethod.

endclass.
