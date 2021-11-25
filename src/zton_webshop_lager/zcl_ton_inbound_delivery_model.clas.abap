CLASS zcl_ton_inbound_delivery_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_log TYPE REF TO zcl_ton_webshop_log .

    METHODS constructor
      IMPORTING
        !io_log        TYPE REF TO zcl_ton_webshop_log
        !io_cntrl TYPE REF TO zcl_ton_inbound_delivery_cntrl .
    METHODS set_article_number_and_proof
      IMPORTING
        !iv_article_number TYPE zton_product_number
      RETURNING
        VALUE(rv_exists)   TYPE abap_bool .
    METHODS search_product_on_strg_place
      EXPORTING
                !ev_warehouse     TYPE zton_warehouse_number
                !ev_storage_place TYPE zton_storage_place
                !ev_storage_area  TYPE zton_storage_area
      RAISING   zcx_ton_webshop_exception_new.
    METHODS set_and_compare_str_place_scan
      IMPORTING
        !iv_storage_place       TYPE zton_storage_place
      RETURNING
        VALUE(rv_places_are_eq) TYPE abap_bool .
    METHODS set_quantity_and_meins
      IMPORTING
        !iv_quantity TYPE zton_amount
        !iv_meins    TYPE zton_unit .
    METHODS save_and_commit RAISING zcx_ton_webshop_exception_new.
    METHODS set_warehousenumber
      IMPORTING
        !iv_warehouse TYPE zton_warehouse_number .
    METHODS continue_if_password_is_equal
      IMPORTING
                !iv_warehousenum TYPE zton_warehouse_number
                !iv_userid       TYPE zton_user_id
                !iv_password     TYPE zton_password
      RAISING   zcx_ton_webshop_exception_new.
    METHODS check_user_and_password
      IMPORTING
                !iv_warehousenum TYPE zton_warehouse_number
                !iv_userid       TYPE zton_user_id
                !iv_password     TYPE zton_password
      RAISING   zcx_ton_webshop_exception_new .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mv_article_number TYPE zton_artikelnummer_de .
    DATA mo_cntrl TYPE REF TO zcl_ton_inbound_delivery_cntrl .
    DATA mv_warehousenumber TYPE zton_lgnum_de .
    DATA mv_storage_place_scan TYPE zton_lgplatzton_de .
    DATA mv_storage_place TYPE zton_lgplatzton_de .
    DATA mv_quantity TYPE zton_zton_menge_de .
    DATA mv_meins TYPE zton_meins_de .
    DATA mv_article_in_wh TYPE abap_bool .
    DATA mv_storage_area TYPE zton_db_lager-lagerbereich .

    METHODS search_product_in_wh .
    METHODS save_product_on_storage_place .
    METHODS update_product_on_warehouse
    RAISING zcx_ton_webshop_exception_new.
    METHODS check_article_exist
      IMPORTING
                !iv_article_number TYPE zton_product_number
      RETURNING
                VALUE(rv_exists)   TYPE abap_bool
      RAISING   zcx_ton_webshop_exception_new.
    METHODS search_free_warehouse_position RAISING zcx_ton_webshop_exception_new.
ENDCLASS.



CLASS zcl_ton_inbound_delivery_model IMPLEMENTATION.

  METHOD check_article_exist.
    "Proof if Article exists
    SELECT SINGLE @abap_true
        FROM zton_article
        INTO @rv_exists
        WHERE article_number = @iv_article_number.

    IF sy-subrc <> 0.
      me->mo_log->add_msg_from_sys( ).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD check_user_and_password.

    SELECT SINGLE password
     FROM zton_db_wh_ma
     WHERE warehouse_number = @iv_warehousenum
          AND   userid = @iv_userid
    INTO @DATA(lv_password).

    IF sy-subrc <> 0.
      MESSAGE i070(zton_web_shop) INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys(  ).
      RETURN.
    ENDIF.

    IF iv_password <> lv_password.
      MESSAGE i071(zton_web_shop) INTO lv_message.
      me->mo_log->add_msg_from_sys( ).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ENDIF.


  ENDMETHOD.


  METHOD constructor.

    me->mo_log = io_log.
    me->mo_cntrl = io_cntrl.

  ENDMETHOD.


  METHOD continue_if_password_is_equal.

    me->check_user_and_password( iv_password = iv_password iv_userid = iv_userid iv_warehousenum = iv_warehousenum ).
    me->set_warehousenumber( iv_warehouse = iv_warehousenum ).
    me->mo_cntrl->mo_view->call_dynpro_putaway_article( ).

  ENDMETHOD.


  METHOD save_and_commit.

    "Falls schon das Produkt vorhanden ist muss die Menge natürlich addiert werden
    SELECT SINGLE FROM zton_db_wh
      FIELDS amount, unit
      WHERE storage_area       = @me->mv_storage_area
        AND storage_place      = @me->mv_storage_place
        AND warehouse_number   = @me->mv_warehousenumber
        AND product       = @me->mv_article_number
       INTO @DATA(ls_quantity_meins).

    IF sy-subrc = 0 AND me->mv_meins = ls_quantity_meins-unit.
      mv_quantity = mv_quantity + ls_quantity_meins-amount.
    ELSEIF sy-subrc = 0 AND me->mv_meins <> ls_quantity_meins-unit.
      "Fehler Mengeneinheit stimmt nicht überein
      MESSAGE e083(zton_web_shop) INTO DATA(lv_message).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ENDIF.

    me->update_product_on_warehouse( ).

  ENDMETHOD.


  METHOD save_product_on_storage_place.

    "User scannt den Lagerplatz auf den der Artikel final gelagert wird
    "Überprüfen ob der Lagerplatz auch der ist der ihme Vorgeschlagen wurde
    "falls nicht -> Pop-UP
    "Überprüfen ob das möglich ist  wenn nicht Fehlermeldung
    "Ansonsten Speicher der Ware auf dem Lagerplatz oder Menge erhöhen falls das Produkt schon vorhanden ist
    "Meldung an den User

  ENDMETHOD.


  METHOD  search_free_warehouse_position.
    "Suche neuen Lagerplatz
    SELECT SINGLE FROM zton_db_wh
      FIELDS storage_area, storage_place
        WHERE warehouse_number = @me->mv_warehousenumber
        AND product = ''
        OR  amount = ''
      INTO (@me->mv_storage_area, @me->mv_storage_place).

    IF sy-subrc <> 0.
      MESSAGE e080(zton_web_shop) INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys( ).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD search_product_in_wh.

    "sucht ob das Produkt auf einen Lagerplatz vorhanden ist
    SELECT SINGLE FROM zton_db_wh
      FIELDS storage_area, storage_place
          WHERE product          = @me->mv_article_number
            AND warehouse_number = @me->mv_warehousenumber
      INTO @DATA(ls_storage_place).

    mv_storage_area  = ls_storage_place-storage_area.
    mv_storage_place = ls_storage_place-storage_place.

    IF sy-subrc <> 0.
      CLEAR ls_storage_place.
      "es wurde kein Platz gefunden es muss ein neuer vorgeschlagen werden
      MESSAGE e072(zton_web_shop) INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys( ).
      me->mv_article_in_wh = abap_false.
    ELSE.
      "es wurden ein Artikel mit Lagerplatz gefunden.
      MESSAGE s073(zton_web_shop) INTO lv_message.
      me->mo_log->add_msg_from_sys( ).
      me->mv_article_in_wh = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD search_product_on_strg_place.

    "Programmablauf
    me->search_product_in_wh( ).

    IF  me->mv_article_in_wh = abap_true.
      ev_storage_area        = me->mv_storage_area.
      ev_storage_place       = me->mv_storage_place.
      ev_warehouse           = me->mv_warehousenumber.
      RETURN.
    ENDIF.

    me->search_free_warehouse_position(  ).
    ev_warehouse     = mv_warehousenumber.
    ev_storage_place = me->mv_storage_place.
    ev_storage_area  = me->mv_storage_area.

  ENDMETHOD.


  METHOD set_and_compare_str_place_scan.

    me->mv_storage_place_scan = iv_storage_place.

    "Compare SCAN with our searched storage place
    IF me->mv_storage_place <> me->mv_storage_place.
      "if there are not the same
      MESSAGE e074(zton_web_shop) INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys( ).
      rv_places_are_eq = abap_true.
    ELSE.
      MESSAGE s075(zton_web_shop) INTO lv_message.
      me->mo_log->add_msg_from_sys( ).
      rv_places_are_eq = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD set_article_number_and_proof.

    "Proof if Article exists
    TRY.
        IF check_article_exist( iv_article_number = iv_article_number  ) = abap_true.
          me->mv_article_number = iv_article_number.
          MESSAGE s076(zton_web_shop) INTO DATA(lv_message).
          me->mo_log->add_msg_from_sys( ).
        ELSE.
          MESSAGE s077(zton_web_shop) INTO lv_message.
          me->mo_log->add_msg_from_sys( ).
        ENDIF.
      CATCH zcx_ton_webshop_exception_new.

    ENDTRY.

  ENDMETHOD.


  METHOD set_quantity_and_meins.

    me->mv_quantity = iv_quantity.
    me->mv_meins = iv_meins.

  ENDMETHOD.


  METHOD set_warehousenumber.

    me->mv_warehousenumber = iv_warehouse.

  ENDMETHOD.


  METHOD update_product_on_warehouse.

    "Produkt auf Lagerplatz updaten
    DATA(ls_warehouse) = VALUE zton_db_wh( warehouse_number = me->mv_warehousenumber
                                           storage_area     = me->mv_storage_area
                                           storage_place    = me->mv_storage_place
                                           product          = me->mv_article_number
                                           amount           = me->mv_quantity
                                           unit             = me->mv_meins ).

    UPDATE zton_db_wh FROM ls_warehouse.

    IF sy-subrc <> 0.
      ROLLBACK WORK.
      MESSAGE e077(zton_shop)  INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys( ).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ELSE.
      COMMIT WORK.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
