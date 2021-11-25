CLASS zcl_ton_homescreen_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA:
      mt_order                 TYPE zton_tt_order,
      mt_articles              TYPE TABLE OF zton_article WITH KEY mandt article_number,
      mt_articles_string_table TYPE TABLE OF string,
      mt_searched_articles     TYPE match_result_tab,
      mt_cart_order            TYPE TABLE OF zton_order,
      mt_articles_out          TYPE TABLE OF zton_article,
      mt_cart                  TYPE TABLE OF zton_s_cart,
      mo_log                   TYPE REF TO zcl_ton_webshop_log.

    METHODS: search_entries_to_new_table
      IMPORTING
        !iv_search_string TYPE string ,
      order_cart
        RAISING zcx_ton_webshop_exception_new,
      remove_item_from_cart
        IMPORTING
          !iv_article_number TYPE zton_article_number ,
      constructor
        IMPORTING
          !io_home_screen_cntrl TYPE REF TO zcl_ton_homescreen_cntrl
          !iv_customer_number        TYPE zton_customer_number
          !io_log                    TYPE REF TO zcl_ton_webshop_log,
      add_to_cart
        IMPORTING
                  !iv_number_of_articles TYPE zton_order_amount
                  !is_article            TYPE zton_article
        RAISING   zcx_ton_webshop_exception_new,
      get_address_of_customer
        RAISING zcx_ton_webshop_exception_new,
      set_order_address
        IMPORTING
          !is_order_address TYPE zton_s_adress ,
      return_address
        RETURNING
          VALUE(rv_address) TYPE zton_s_adress ,
      get_email_address_of_customer
        RETURNING
          VALUE(rv_email) TYPE zton_email ,
      set_customer_email
        IMPORTING
          !iv_email TYPE zton_email ,
      get_all_orders_from_customer
        RAISING zcx_ton_webshop_exception_new ,
      get_open_order_from_mt_order
        RETURNING
          VALUE(rt_openorder) TYPE zton_tt_order ,
      get_done_order_from_mt_order
        RETURNING
          VALUE(rt_done_order) TYPE zton_tt_order ,
      get_order
        IMPORTING
          !iv_order_number TYPE tv_nodekey
        RETURNING
          VALUE(rt_order)  TYPE zton_tt_order ,
      delete_position
        IMPORTING
                  !is_position TYPE zton_order
        RAISING   zcx_ton_webshop_exception_new ,
      edit_quantity_of_position
        IMPORTING
                  !is_position TYPE zton_order
                  !iv_quantity TYPE int4
        RAISING   zcx_ton_webshop_exception_new,
      add_up_item
        IMPORTING
          !iv_article_number TYPE zton_article_number
          !iv_quantity       TYPE zton_order_amount
        RETURNING
          VALUE(rv_quantity) TYPE zton_order_amount,
      check_if_order_exist
        IMPORTING is_selected_row TYPE zton_order
        RETURNING VALUE(rv_exist) TYPE boolean.

  PROTECTED SECTION.

  PRIVATE SECTION.

    CONSTANTS:
      mc_status_inactive    TYPE zton_status VALUE 'IN' ##NO_TEXT,  "Bestellung Inaktive
      mc_status_completed   TYPE zton_status VALUE 'AB' ##NO_TEXT,   "Bestellung Abgeschlossen
      mc_status_in_progress TYPE zton_status VALUE 'IB' ##NO_TEXT,   "Bestellung in Bearbeitung
      mc_status_ordered     TYPE zton_status VALUE 'BE' ##NO_TEXT,   "Bestellung Bestellt
      mc_range_nr           TYPE nrnr VALUE '01' ##NO_TEXT.

    DATA:
      mo_home_screen_cntrl TYPE REF TO zcl_ton_homescreen_cntrl,
      mv_customernumber         TYPE zton_customer_number,
      ms_order_address          TYPE zton_s_adress,
      mv_customer_email         TYPE zton_email.

    METHODS: select_articles ,
      get_ordernumber
        RETURNING
          VALUE(rv_order_number) TYPE numc10 ,
      insert_address_of_order
        IMPORTING
          !iv_order_number TYPE numc10 ,
      select_articles_as_char_fields
        RAISING zcx_ton_webshop_exception_new,
      find_occurences_of_regex
        IMPORTING
          !iv_search_string TYPE string ,
      add_to_cart_order_table
        IMPORTING
          !iv_order_number TYPE numc10.
ENDCLASS.



CLASS ZCL_TON_HOMESCREEN_MODEL IMPLEMENTATION.


  METHOD add_to_cart.
    DATA: lc_status_in_cart TYPE char15 VALUE 'Im Warenkorb'.

    DATA(ls_cart) = VALUE zton_s_cart( article_number      = is_article-article_number
                                       article_designation = is_article-designation
                                       article_description = is_article-description
                                       unit                = is_article-unit
                                       currency            = is_article-currency
                                       number_of_articles  = iv_number_of_articles
                                       price_per_article   = is_article-price
                                       price               = is_article-price * iv_number_of_articles
                                       status              = lc_status_in_cart ).

    APPEND ls_cart TO me->mt_cart.
    IF sy-subrc <> 0.
      MESSAGE i087(zton_web_shop) INTO DATA(ls_msg)..
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ENDIF.
  ENDMETHOD.


  METHOD add_to_cart_order_table.
    CLEAR mt_cart_order.
    DATA: ls_order TYPE zton_order.
    LOOP AT me->mt_cart ASSIGNING FIELD-SYMBOL(<ls_cart>).

      ls_order = VALUE #( article         = <ls_cart>-article_number
                          order_amount    = <ls_cart>-number_of_articles
                          order_number   = iv_order_number
                          unit   = <ls_cart>-unit
                          position_number = sy-tabix
                          status          = me->mc_status_ordered
                          customer_number           = me->mv_customernumber ).

      APPEND ls_order TO mt_cart_order.
    ENDLOOP.
  ENDMETHOD.


  METHOD add_up_item.

    rv_quantity = iv_quantity.
    "sum new quantity, delete current entry and add item with new quantity
    LOOP AT me->mt_cart ASSIGNING FIELD-SYMBOL(<ls_item>) WHERE article_number = iv_article_number.
      rv_quantity = rv_quantity + <ls_item>-number_of_articles.
      me->remove_item_from_cart( iv_article_number = iv_article_number ).
    ENDLOOP.

  ENDMETHOD.


  METHOD check_if_order_exist.
    DATA: lt_order_to_show TYPE zton_tt_order.
    lt_order_to_show = me->mo_home_screen_cntrl->mt_order_to_show.
    SELECT SINGLE @abap_true
    FROM @lt_order_to_show AS orders
    WHERE orders~order_number = @is_selected_row-order_number
    INTO @DATA(lv_exists).

    rv_exist = lv_exists.
  ENDMETHOD.


  METHOD constructor.

    me->mo_home_screen_cntrl = io_home_screen_cntrl.
    me->mv_customernumber         = iv_customer_number.
    me->mo_log = io_log.
    me->select_articles( ).

  ENDMETHOD.


  METHOD delete_position.
    IF is_position-status = mc_status_in_progress OR is_position-status = mc_status_completed.
      MESSAGE i061(zton_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ELSE.
      DELETE me->mo_home_screen_cntrl->mt_order_to_show WHERE order_number   = is_position-order_number
                                                               AND position_number = is_position-position_number.
      DELETE zton_order FROM is_position.
      IF sy-subrc <> 0.
        MESSAGE i060(zton_web_shop) INTO ls_msg.
        RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD edit_quantity_of_position.
    DATA(ls_position_to_update) = VALUE zweb_order( BASE is_position order_amount = iv_quantity ).

    UPDATE zton_order FROM @ls_position_to_update.

    IF sy-subrc <> 0.
      ROLLBACK WORK.
      MESSAGE i068(zton_web_shop) INTO DATA(lv_msg).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ENDIF.

    COMMIT WORK.
  ENDMETHOD.


  METHOD find_occurences_of_regex.
    CLEAR mt_searched_articles.
    "search entries
    FIND ALL OCCURRENCES OF REGEX iv_search_string
    IN TABLE me->mt_articles_string_table
    IGNORING CASE
    RESULTS mt_searched_articles.
  ENDMETHOD.


  METHOD get_address_of_customer.
SELECT SINGLE street house_number zip_code city
      FROM zton_customer
      INTO ms_order_address
      WHERE customer_number = mv_customernumber.

    IF sy-subrc <> 0.
      MESSAGE i059(zton_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ENDIF.
  ENDMETHOD.


  METHOD get_all_orders_from_customer.
CLEAR me->mt_order.

    SELECT *
      FROM zton_order
      INTO TABLE me->mt_order
      WHERE customer_number = mv_customernumber.
    IF sy-subrc <> 0.
      MESSAGE i086(zton_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.

    ENDIF.

  ENDMETHOD.


  METHOD get_done_order_from_mt_order.
    SORT me->mt_order BY order_number.

    LOOP AT me->mt_order ASSIGNING FIELD-SYMBOL(<ls_order>) WHERE status = mc_status_completed OR status = mc_status_inactive.
      APPEND <ls_order> TO rt_done_order.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM rt_done_order.
  ENDMETHOD.


  METHOD get_email_address_of_customer.

    rv_email = me->mv_customer_email.

  ENDMETHOD.


  METHOD get_open_order_from_mt_order.
    SORT me->mt_order BY order_number.

    LOOP AT me->mt_order ASSIGNING FIELD-SYMBOL(<ls_order>) WHERE status = mc_status_ordered OR status = mc_status_in_progress.
      APPEND <ls_order> TO rt_openorder.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM rt_openorder COMPARING order_number.

  ENDMETHOD.


  METHOD get_order.

    LOOP AT me->mt_order ASSIGNING FIELD-SYMBOL(<ls_position>) WHERE order_number = iv_order_number.

      APPEND <ls_position> TO rt_order.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_ordernumber.

    DATA: lv_ordernumber TYPE n LENGTH 10.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = me->mc_range_nr
        object                  = 'ZTON_BEST'
      IMPORTING
        number                  = lv_ordernumber
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      MESSAGE i046(zton_web_shop) WITH sy-subrc.
    ENDIF.

    rv_order_number = lv_ordernumber.

  ENDMETHOD.


  METHOD insert_address_of_order.
    DATA(ls_order_adress_to_insert) = VALUE zton_order_ad(  order_number = iv_order_number
                                                       street       = me->ms_order_address-street
                                                       house_number = me->ms_order_address-houese_number
                                                       zip_code     = me->ms_order_address-zip_code
                                                       city         = me->ms_order_address-city ).

    INSERT zton_order_ad FROM ls_order_adress_to_insert.
  ENDMETHOD.


  METHOD order_cart.

    DATA(lv_order_number) = me->get_ordernumber( ).

    me->add_to_cart_order_table( iv_order_number = lv_order_number ).

    me->insert_address_of_order( iv_order_number = lv_order_number ).
    INSERT zton_order FROM TABLE mt_cart_order.

    IF sy-subrc <> 0.
      MESSAGE i045(zton_web_shop) INTO DATA(ls_msg).
      me->mo_log->add_msg_from_sys( ).
      me->mo_log->safe_log( ).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ENDIF.

    me->mo_home_screen_cntrl->send_order_confirmation( iv_email = me->get_email_address_of_customer( )
                                                            iv_order_number = lv_order_number ).

    CLEAR me->mt_cart.

  ENDMETHOD.


  METHOD remove_item_from_cart.
 DELETE mt_cart WHERE article_number = iv_article_number.
  ENDMETHOD.


  METHOD return_address.

    rv_address = me->ms_order_address.

  ENDMETHOD.


  METHOD search_entries_to_new_table.

    TRY.
        IF iv_search_string IS NOT INITIAL.
          CLEAR me->mt_articles_out.
          me->select_articles_as_char_fields(  ).
          me->find_occurences_of_regex( iv_search_string = iv_search_string  ).
          "build new output table of searched entries
          LOOP AT mt_searched_articles ASSIGNING FIELD-SYMBOL(<ls_searched_entries>).

            APPEND me->mt_articles[ <ls_searched_entries>-line ] TO me->mt_articles_out.

          ENDLOOP.
        ELSE.
          me->mt_articles_out = me->mt_articles.
        ENDIF.

      CATCH zcx_ton_webshop_exception_new INTO DATA(lo_exc).
        MESSAGE lo_exc.
        me->mt_articles_out = me->mt_articles.
    ENDTRY.

  ENDMETHOD.


  METHOD select_articles.
    SELECT *
      FROM zton_article
      INTO TABLE @mt_articles.
  ENDMETHOD.


  METHOD select_articles_as_char_fields.
    SELECT designation
           FROM @me->mt_articles AS articles
           INTO TABLE @mt_articles_string_table.
    IF sy-subrc <> 0.
      MESSAGE i058(zton_web_shop) INTO DATA(ls_msg).
      me->mo_log->add_msg_from_sys( ).
      me->mo_log->safe_log( ).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ENDIF.
  ENDMETHOD.


  METHOD set_customer_email.

    me->mv_customer_email = iv_email.

  ENDMETHOD.


  METHOD set_order_address.

    CLEAR me->ms_order_address.

    me->ms_order_address = is_order_address.

  ENDMETHOD.
ENDCLASS.
