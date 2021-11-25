CLASS zcl_ton_inbound_delivery_cntrl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_view TYPE REF TO zcl_ton_inbound_delivery_view .

    METHODS on_scan_quantity
      IMPORTING
        !iv_quantity TYPE zton_amount
        !iv_meins    TYPE zton_unit .
    METHODS on_confirm_scan_article
      IMPORTING
        !iv_article_number TYPE zton_product_number .
    METHODS start .
    METHODS constructor
      IMPORTING
        !io_log TYPE REF TO zcl_ton_webshop_log .
    METHODS check_user
      IMPORTING
        !iv_warehousenum TYPE zton_warehouse_number
        !iv_userid       TYPE zton_user_id
        !iv_password     TYPE zton_password .
    METHODS on_pbo_storage_place
      EXPORTING
        !ev_warehouse_num TYPE zton_warehouse_number
        !ev_storage_place TYPE zton_storage_place
        !ev_storage_area  TYPE zton_storage_area .
    METHODS on_confirm_storage_place
      IMPORTING
        VALUE(iv_storage_place) TYPE zton_storage_place .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS mc_logobject TYPE bal_s_log-object VALUE 'ZSBT' ##NO_TEXT.
    CONSTANTS mc_subobjec TYPE bal_s_log-subobject VALUE 'ZUBT' ##NO_TEXT.
    DATA mo_log TYPE REF TO zcl_ton_webshop_log .
    DATA mo_model TYPE REF TO zcl_ton_inbound_delivery_model .

    METHODS encrypt_password
      IMPORTING
        !iv_password               TYPE zton_password
      RETURNING
        VALUE(rv_password_as_hash) TYPE zton_password .
ENDCLASS.



CLASS zcl_ton_inbound_delivery_cntrl IMPLEMENTATION.


  METHOD check_user.
    TRY.
        me->mo_model->continue_if_password_is_equal( iv_warehousenum = iv_warehousenum
                                                     iv_userid       = iv_userid
                                                     iv_password     = me->encrypt_password( iv_password = iv_password ) ).
      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD constructor.

    me->mo_log = io_log.

    IF me->mo_view IS NOT BOUND.
      me->mo_view = NEW zcl_ton_inbound_delivery_view( io_cntrl = me
                                                          io_log = me->mo_log ).
    ENDIF.

    IF me->mo_model IS NOT BOUND.
      me->mo_model = NEW zcl_ton_inbound_delivery_model( io_log         = me->mo_log
                                                     io_cntrl  = me ).
    ENDIF.

  ENDMETHOD.


  METHOD encrypt_password.

    TRY.
        cl_abap_message_digest=>calculate_hash_for_char( EXPORTING if_data       = iv_password
                                                         IMPORTING ef_hashstring = rv_password_as_hash ).

      CATCH cx_abap_message_digest. " Ausnahmeklasse für Message Digest
        MESSAGE e042(zton_shop) INTO DATA(lv_message).
        me->mo_log->add_msg_from_sys( ).
    ENDTRY.

  ENDMETHOD.


  METHOD on_confirm_scan_article.

    IF iv_article_number IS INITIAL.
      MESSAGE i069(zton_shop) INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys( ).
      RAISE EXCEPTION TYPE zcx_ton_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    IF me->mo_model->set_article_number_and_proof( iv_article_number ).
      me->mo_view->call_dynpro_storage_place( ).
    ENDIF.

  ENDMETHOD.


  METHOD on_confirm_storage_place.

    IF me->mo_model->set_and_compare_str_place_scan( iv_storage_place = iv_storage_place ) = abap_false.
      MESSAGE i075(zton_shop) INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys( ).
    ENDIF.

    "Wenn alles passt rufe neues Dynpro auf
    me->mo_view->call_dynpro_quantity( ).

  ENDMETHOD.


  METHOD on_pbo_storage_place.

    "Daten im Controller zwischenspeicher und ins Model geben oder Model zum zwischenspeicher?
    me->mo_model->search_product_on_strg_place( IMPORTING ev_warehouse     = ev_warehouse_num
                                                          ev_storage_place = ev_storage_place
                                                          ev_storage_area  = ev_storage_area ).

  ENDMETHOD.


  METHOD on_scan_quantity.

    TRY.
        me->mo_model->set_quantity_and_meins( EXPORTING iv_quantity = iv_quantity
                                                        iv_meins    = iv_meins ).

        me->mo_model->save_and_commit( ).

        me->mo_log->safe_log( ).
        me->mo_log->display_log_as_popup( ).

        FREE: me->mo_model, me->mo_view, me->mo_log.

        me->mo_log = NEW zcl_ton_webshop_log( iv_object = me->mc_logobject
                                               iv_suobj  = me->mc_subobjec ).

        me->mo_model = NEW zcl_ton_inbound_delivery_model( io_log        = me->mo_log
                                                           io_cntrl = me ).


        me->mo_view = NEW zcl_ton_inbound_delivery_view( io_cntrl = me
                                                         io_log        = me->mo_log ).
        me->mo_view->call_dynpro_putaway_article( ).

        me->mo_log->safe_log( ).
        me->mo_log->display_log_as_popup( ).

      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
        me->mo_log->safe_log( ).
        me->mo_log->display_log_as_popup( ).
    ENDTRY.

  ENDMETHOD.


  METHOD start.

    me->mo_view->call_dynpro_login( ).

  ENDMETHOD.
ENDCLASS.
