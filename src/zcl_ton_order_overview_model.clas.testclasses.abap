*"* use this source file for your ABAP unit test classes^
 CLASS ltc_web_shop_model DEFINITION DEFERRED.
 CLASS zcl_ton_order_overview_model DEFINITION LOCAL FRIENDS ltc_web_shop_model.                                  .

 CLASS ltc_web_shop_model DEFINITION FOR TESTING
 RISK LEVEL HARMLESS
 DURATION SHORT.

   PUBLIC SECTION.

   PRIVATE SECTION.
     CONSTANTS: lc_customer_number   TYPE zton_kd_numr_de VALUE '1',
                lc_order_number      TYPE zton_order_number VALUE  '1',
                lc_position_number_1 TYPE zton_position_number VALUE '1',
                lc_position_number_2 TYPE zton_position_number VALUE '2',
                lc_order_amount_1    TYPE zton_order_amount VALUE 01,
                lc_order_amount_2    TYPE zton_order_amount VALUE 02,
                mc_status_1          TYPE zton_status VALUE 'BE',
                mc_order_value_100   TYPE zton_order_value VALUE '100',
                mc_text_expception   TYPE string VALUE 'Es wurde eine Exception in der aufgerufnen Methode ausgelöst' ##NO_TEXT.

     DATA: m_cut               TYPE REF TO zcl_ton_order_overview_model,
           lt_order_data       TYPE TABLE OF zton_order,
           l_exception_occured TYPE abap_bool.

     CLASS-DATA: m_environment TYPE REF TO if_osql_test_environment.
     CLASS-METHODS class_setup.
     METHODS setup.

     "delete_order
     METHODS:
       delete_order_from_odernumber_1 FOR TESTING,
       delete_order_exception_exist FOR TESTING.

     "delete_position
     METHODS:
       delete_first_order_postion FOR TESTING,
       delete_second_order_position FOR TESTING,
       delete_position_exc_exist FOR TESTING.

     "get_data_type
     METHODS:
       get_datatyp_quan FOR TESTING,
       get_datatyp_status FOR TESTING,
       get_datayp_exc_exist FOR TESTING.

     "edit_position
     METHODS:
       edit_position_quan FOR TESTING,
       edit_position_exc_exist FOR TESTING.

     "get_positions
     METHODS get_positions_check FOR TESTING .

     "select_with_condition
     METHODS:
       select_with_condition FOR TESTING,
       select_by_order_number FOR TESTING,
       select_by_status FOR TESTING,
       select_by_customer_id FOR TESTING,
       select_by_customer_exc_exist FOR TESTING,
       select_by_ordernr_exc_exist FOR TESTING,
       select_by_status_exc_exist FOR TESTING.

 ENDCLASS.

 CLASS ltc_web_shop_model IMPLEMENTATION.

   METHOD setup.

     "given
     lt_order_data = VALUE #( ( order_number = lc_order_number position_number = lc_position_number_1 order_amount = lc_order_amount_1 status = mc_status_1 customer_number = lc_customer_number )
                              ( order_number = lc_order_number position_number = lc_position_number_2 order_amount = lc_order_amount_1 ) ).

     m_environment->clear_doubles( ).

     m_cut = NEW zcl_ton_order_overview_model( io_log = NEW zcl_ton_webshop_log( iv_object = 'ZTON'
                                                                         iv_suobj  = 'ZTON'  )  ).

     m_environment->insert_test_data( EXPORTING i_data = lt_order_data ).

     l_exception_occured = abap_false.

   ENDMETHOD.

   METHOD class_setup.

     m_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'zton_order' ) ) ).

   ENDMETHOD.

   METHOD delete_order_from_odernumber_1.

     TRY.
         "when
         m_cut->delete_order( iv_order_number = lc_order_number ).
         "then
       CATCH zcx_ton_webshop_exception_new.
         cl_abap_unit_assert=>fail( EXPORTING msg = mc_text_expception ).
     ENDTRY.
     SELECT SINGLE order_number
        FROM zton_order
        INTO @DATA(ls_data)
        WHERE order_number = @lc_order_number.

     IF sy-subrc = 0.
       cl_abap_unit_assert=>fail( EXPORTING msg = 'Bestellung wurde nicht gelöscht'  ).                            " Description
     ENDIF.

   ENDMETHOD.

   METHOD delete_order_exception_exist.

     TRY.
         "given
         m_environment->clear_doubles( ).
         "when
         m_cut->delete_order( iv_order_number = lc_order_number ).
       CATCH zcx_ton_webshop_exception_new.
         l_exception_occured = abap_true.
     ENDTRY.
     "then
     cl_abap_unit_assert=>assert_true( act = l_exception_occured
                                       msg = 'In der Methode delete_order wird keine Exception geworfen!').
   ENDMETHOD.

   METHOD delete_first_order_postion.

     TRY.
         "when
         m_cut->delete_position( is_position = VALUE #( order_number   = lc_order_number
                                                        position_number = lc_position_number_1 ) ).
       CATCH zcx_ton_webshop_exception_new.
         cl_abap_unit_assert=>fail( EXPORTING msg = mc_text_expception ).
     ENDTRY.
     "then
     SELECT *
       FROM zton_order
       INTO TABLE @DATA(lt_data)
       WHERE order_number = @lc_order_number.

     IF sy-subrc <> 0.
       cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden zu viele Datensätze gelöscht' ).
     ELSE.
       IF line_exists( lt_data[ position_number = 1 ] ).
         cl_abap_unit_assert=>fail( EXPORTING msg = 'Bestellung wurde nicht gelöscht'  ).
       ENDIF.
     ENDIF.

   ENDMETHOD.

   METHOD delete_second_order_position.

     TRY.
         "when
         m_cut->delete_position( is_position = VALUE #( order_number    = lc_order_number
                                                        position_number = lc_position_number_2 ) ).

       CATCH zcx_ton_webshop_exception_new.
         cl_abap_unit_assert=>fail( EXPORTING msg = mc_text_expception ).
     ENDTRY.
     "then
     SELECT *
        FROM zton_order
        INTO TABLE @DATA(lt_data)
        WHERE order_number = @lc_order_number.

     IF sy-subrc <> 0.
       cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden zu viele Datensätze gelöscht' ).
     ELSE.
       IF line_exists( lt_data[ position_number = 2 ] ).
         cl_abap_unit_assert=>fail( EXPORTING msg = 'Bestellung wurde nicht gelöscht'  ).
       ENDIF.
     ENDIF.

   ENDMETHOD.

   METHOD delete_position_exc_exist.

     TRY.
         "given
         m_environment->clear_doubles( ).
         "when
         m_cut->delete_position( is_position = VALUE #( order_number   = lc_order_number
                                                        position_number = lc_position_number_1 ) ).
       CATCH zcx_ton_webshop_exception_new.
         l_exception_occured = abap_true.
     ENDTRY.
     "then
     cl_abap_unit_assert=>assert_true( act = l_exception_occured
                                       msg = 'In der Methode delete_position wird keine Exception geworfen!').

   ENDMETHOD.

   METHOD get_datatyp_quan.

     "given
     DATA: lv_value    TYPE  zton_order_amount VALUE lc_order_amount_1,
           ls_position TYPE  zton_order.
     "when
     TRY.
         m_cut->change_structur_from_value( EXPORTING iv_wert =  lv_value CHANGING  cs_position    =  ls_position ).
         "then
       CATCH zcx_ton_webshop_exception_new.
         cl_abap_unit_assert=>fail( EXPORTING msg = mc_text_expception ).
     ENDTRY.
     cl_abap_unit_assert=>assert_equals( EXPORTING act =  ls_position-order_amount
                                                   exp =  lc_order_amount_1 ).

   ENDMETHOD.

   METHOD get_datatyp_status.

     "given
     DATA: lv_value    TYPE  zton_status VALUE mc_status_1,
           ls_position TYPE  zton_order.

     "when
     TRY.
         m_cut->change_structur_from_value( EXPORTING iv_wert        =  lv_value
                               CHANGING  cs_position    =  ls_position ).
         "then
       CATCH zcx_ton_webshop_exception_new.
         cl_abap_unit_assert=>fail( EXPORTING msg = mc_text_expception ).
     ENDTRY.
     cl_abap_unit_assert=>assert_equals( EXPORTING act =  ls_position-status
                                                   exp =  mc_status_1 ).

   ENDMETHOD.

   METHOD get_datayp_exc_exist.

     "given
     "lv_value enthält einen datentyp der nicht in ls_position vorhanden ist get_data_type würde so dumpen
     DATA: lv_value    TYPE  zton_order_value VALUE mc_order_value_100,
           ls_position TYPE  zton_order.
     "when
     TRY.
         m_cut->change_structur_from_value( EXPORTING iv_wert        =  lv_value
                               CHANGING  cs_position    =  ls_position ).
       CATCH zcx_ton_webshop_exception_new.
         l_exception_occured = abap_true.
     ENDTRY.
     "then
     cl_abap_unit_assert=>assert_true( act = l_exception_occured
                                       msg = 'In der Methode get_data_type wird keine Exception geworfen!').

   ENDMETHOD.

   METHOD edit_position_quan.

     "given
     DATA: lv_value       TYPE          zton_order_amount VALUE 4.
     "when
     TRY.
         m_cut->edit_postition( EXPORTING iv_wert     = lv_value
                                          is_position = lt_order_data[ 1 ] ).
       CATCH zcx_ton_webshop_exception_new.
         cl_abap_unit_assert=>fail( EXPORTING msg = mc_text_expception ).
     ENDTRY.
     "then
     SELECT SINGLE *
        FROM zton_order
        INTO @DATA(ls_position)
        WHERE position_number = @lc_position_number_1
        AND order_number      = @lc_order_number.

     cl_abap_unit_assert=>assert_equals( EXPORTING act =  ls_position-order_amount
                                                   exp =  lv_value ).

   ENDMETHOD.

   METHOD edit_position_exc_exist.

     "given
     DATA: lv_value       TYPE          zton_order_amount VALUE 4.
     m_environment->clear_doubles( ).

     TRY.
         "when
         m_cut->edit_postition( EXPORTING iv_wert     = lv_value
                                          is_position = lt_order_data[ 1 ] ).
       CATCH zcx_ton_webshop_exception_new.
         l_exception_occured = abap_true.

     ENDTRY.
     "then
     cl_abap_unit_assert=>assert_true( act = l_exception_occured
                                       msg = 'In der Methode edit_position wird keine Exception geworfen!').
   ENDMETHOD.

   METHOD get_positions_check.

     "given
     DATA: mt_positions TYPE STANDARD TABLE OF zton_order WITH DEFAULT KEY .
     "when
     m_cut->get_positions( lc_order_number ).
     mt_positions = m_cut->mt_positions.

     IF mt_positions IS INITIAL.
        cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden keine Daten ausgelesen' ).
     ELSE.
     "then
     cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_positions[ 1 ]-position_number
                                                   exp =  lc_position_number_1 ).
     cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_positions[ 2 ]-position_number
                                                   exp =  lc_position_number_2 ).
    ENDIF.
   ENDMETHOD.

   METHOD select_with_condition.

     "given
     DATA: mt_orders TYPE STANDARD TABLE OF zton_order WITH DEFAULT KEY .
     "when
     TRY.
         m_cut->select_with_condition( iv_condition_description = m_cut->lc_no_filter ).
         mt_orders = m_cut->mt_orders.
         "then
       CATCH zcx_ton_webshop_exception_new.
         cl_abap_unit_assert=>fail( EXPORTING msg = mc_text_expception ).
     ENDTRY.
     TRY.
         cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_orders[ 1 ]-order_number
                                                       exp =  lc_order_number ).
         cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_orders[ 1 ]-position_number
                                                       exp =  lc_position_number_1 ).
         cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_orders[ 1 ]-order_amount
                                                       exp =  lc_order_amount_1 ).
       CATCH cx_sy_itab_line_not_found .
         cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden keine Daten ausgelesen' ).
     ENDTRY.

   ENDMETHOD.

   METHOD select_by_order_number.

     "given
     DATA: mt_orders TYPE STANDARD TABLE OF zton_order WITH DEFAULT KEY .
     "when
     TRY.
         m_cut->select_with_condition( iv_condition             = lc_order_number
                                       iv_condition_description = m_cut->lc_order_number ).
         mt_orders = m_cut->mt_orders.
         "then
       CATCH zcx_ton_webshop_exception_new.
         cl_abap_unit_assert=>fail( EXPORTING msg = mc_text_expception ).
     ENDTRY.
     TRY.
         cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_orders[ 1 ]-order_number
                                                       exp =  lc_order_number ).
         cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_orders[ 1 ]-position_number
                                                       exp =  lc_position_number_1 ).
       CATCH cx_sy_itab_line_not_found .
         cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden keine Daten nach position_number ausgelesen' ).
     ENDTRY.

   ENDMETHOD.

   METHOD select_by_status.

     "given
     DATA: mt_orders TYPE STANDARD TABLE OF zton_order WITH DEFAULT KEY .
     "when
     TRY.
         m_cut->select_with_condition( iv_condition = mc_status_1 iv_condition_description = m_cut->lc_status ).
         mt_orders = m_cut->mt_orders.
         "then
       CATCH zcx_ton_webshop_exception_new.
         cl_abap_unit_assert=>fail( EXPORTING msg = mc_text_expception ).
     ENDTRY.
     TRY.
         cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_orders[ 1 ]-order_number
                                                       exp =  lc_order_number ).
         cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_orders[ 1 ]-status
                                                       exp =  mc_status_1 ).
       CATCH cx_sy_itab_line_not_found .
         cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden keine Daten nach Status ausgelesen' ).
     ENDTRY.

   ENDMETHOD.

   METHOD select_by_customer_id.

     "given
     DATA: mt_orders TYPE STANDARD TABLE OF zton_order WITH DEFAULT KEY .
     "when
     TRY.
         m_cut->select_with_condition( iv_condition = lc_customer_number iv_condition_description = m_cut->lc_customer_number ).
         mt_orders = m_cut->mt_orders.
         "then
       CATCH zcx_ton_webshop_exception_new.
         cl_abap_unit_assert=>fail( EXPORTING msg = mc_text_expception ).
     ENDTRY.
     TRY.
         cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_orders[ 1 ]-customer_number
                                                       exp =  lc_customer_number ).
         cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_orders[ 1 ]-order_number
                                                       exp =  lc_order_number ).
       CATCH cx_sy_itab_line_not_found .
         cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden keine Daten nach Kundennummer ausgelesen' ).
     ENDTRY.

   ENDMETHOD.

   METHOD select_by_customer_exc_exist.

     "given
     DATA: mt_orders TYPE STANDARD TABLE OF zton_order WITH DEFAULT KEY .
     m_environment->clear_doubles( ).

     TRY.
         "when
         m_cut->select_with_condition( iv_condition             = lc_customer_number
                                       iv_condition_description = m_cut->lc_customer_number ).
         mt_orders = m_cut->mt_orders.
       CATCH zcx_ton_webshop_exception_new.
         l_exception_occured = abap_true.
     ENDTRY.
     "then
     cl_abap_unit_assert=>assert_true( act = l_exception_occured
                                       msg = 'Kein ausreichendes Exceptionhandling in Methode select_with_condition vorhanden').
   ENDMETHOD.

   METHOD select_by_ordernr_exc_exist.
     "given
     DATA: mt_orders TYPE STANDARD TABLE OF zton_order WITH DEFAULT KEY .
     m_environment->clear_doubles( ).

     TRY.
         "when
         m_cut->select_with_condition( iv_condition = lc_order_number iv_condition_description = m_cut->lc_order_number ).
         mt_orders = m_cut->mt_orders.
       CATCH zcx_ton_webshop_exception_new.
         l_exception_occured = abap_true.
     ENDTRY.
     "then
     cl_abap_unit_assert=>assert_true(
       act = l_exception_occured
       msg = 'Kein ausreichendes Exceptionhandling in Methode select_with_condition für den Fall dass nicht nach Bestellnr. selektiert werden konnte!'
     ).

   ENDMETHOD.

   METHOD select_by_status_exc_exist.
     "given
     DATA: mt_orders TYPE STANDARD TABLE OF zton_order WITH DEFAULT KEY .
     m_environment->clear_doubles( ).

     TRY.
         "when
         m_cut->select_with_condition( iv_condition = mc_status_1 iv_condition_description = m_cut->lc_status ).
         mt_orders = m_cut->mt_orders.
       CATCH zcx_ton_webshop_exception_new.
         l_exception_occured = abap_true.
     ENDTRY.
     "then
     cl_abap_unit_assert=>assert_true( act = l_exception_occured
                                       msg = 'Kein ausreichendes Exceptionhandling in Methode select_with_condition für den Fall dass nicht nach Status selektiert werden konnte!').

   ENDMETHOD.
 ENDCLASS.




 CLASS ltc_web_shop_model_artikel DEFINITION DEFERRED.
 CLASS zcl_ton_order_overview_model DEFINITION LOCAL FRIENDS ltc_web_shop_model_artikel.
 CLASS ltc_web_shop_model_artikel DEFINITION
 FOR TESTING
 RISK LEVEL HARMLESS
 DURATION SHORT.

   PUBLIC SECTION.
     DATA: m_cut            TYPE REF TO zcl_ton_order_overview_model,
           lt_order_data    TYPE TABLE OF zton_article,
           lt_artikel_preis TYPE ltt_artikel_price.

     CLASS-DATA: m_environment TYPE REF TO if_osql_test_environment.
     CONSTANTS: lc_article_number_1 TYPE zton_article_number VALUE 1,
                lc_price_1          TYPE zton_price VALUE 20,
                lc_article_number_2 TYPE zton_article_number VALUE 2,
                lc_price_2          TYPE zton_price VALUE 10.

   PROTECTED SECTION.
   PRIVATE SECTION.
     CLASS-METHODS class_setup.
     METHODS setup.

     METHODS:
       "! Testmethode welche den Rückgabewert der get_article_price_table methode überprüft
       artikel_preis_price_check FOR TESTING.
 ENDCLASS.

 CLASS ltc_web_shop_model_artikel IMPLEMENTATION.

   METHOD setup.

     "given
     lt_order_data = VALUE #( ( article_number = lc_article_number_1 price = lc_price_1 )
                              ( article_number = lc_article_number_2 price = lc_price_2 ) ).

     m_environment->clear_doubles( ).
     m_cut = NEW zcl_ton_order_overview_model( io_log = new zcl_ton_webshop_log( iv_object = 'ZTON'
                                                                         iv_suobj  = 'ZTON') ).
     m_environment->insert_test_data( EXPORTING i_data = lt_order_data ).

   ENDMETHOD.


   METHOD class_setup.

     m_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'zton_article' ) ) ).

   ENDMETHOD.

   METHOD artikel_preis_price_check.

     "given
     DATA: lt_art_pr TYPE ltt_artikel_price.

     TRY.
         "when
         lt_art_pr = m_cut->get_article_price_table(  ).
         "then
         cl_abap_unit_assert=>assert_equals( EXPORTING act =  lt_art_pr[ 1 ]-artikel_number
                                                        exp =  lc_article_number_1 ).
       CATCH cx_sy_itab_line_not_found .
         cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden keine Daten nach Artikel und Preis selektiert!' ).
       CATCH zcx_ton_webshop_exception_new.
         cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden keine Daten nach Artikel und Preis selektiert!' ).
     ENDTRY.

   ENDMETHOD.

 ENDCLASS.
