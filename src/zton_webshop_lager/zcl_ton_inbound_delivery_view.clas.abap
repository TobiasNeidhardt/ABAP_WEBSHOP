class ZCL_TON_INBOUND_DELIVERY_VIEW definition
  public
  final
  create public .

public section.

  data MO_LOG type ref to ZCL_TON_WEBSHOP_LOG .

  methods CONSTRUCTOR
    importing
      !IO_CNTRL type ref to ZCL_TON_INBOUND_DELIVERY_CNTRL
      !IO_LOG type ref to ZCL_TON_WEBSHOP_LOG .
  methods LOGIN_PAI
    importing
      !IV_WAREHOUSENUM type ZTON_WAREHOUSE_NUMBER
      !IV_USERID type ZTON_USER_ID
      !IV_PASSWORD type ZTON_PASSWORD .
  methods CALL_DYNPRO_LOGIN .
  methods CALL_DYNPRO_PUTAWAY_ARTICLE .
  methods PAI_PUTAWAY_ARTICLE
    importing
      !IV_ARTICLE_NUMBER type ZTON_PRODUCT_NUMBER .
  methods CALL_DYNPRO_STORAGE_PLACE .
  methods PAI_STORAGE_PLACE
    importing
      !IV_STORAGE_PLACE type ZTON_STORAGE_PLACE .
  methods PBO_STORAGE_PLACE
    exporting
      !EV_WAREHOUSE_NUM type ZTON_WAREHOUSE_NUMBER
      !EV_STORAGE_PLACE type ZTON_STORAGE_PLACE
      !EV_STORAGE_AREA type ZTON_STORAGE_AREA .
  methods PAI_SCAN_QUANTITY
    importing
      !IV_QUANTITY type ZTON_AMOUNT
      !IV_MEINS type ZTON_UNIT .
  methods CALL_DYNPRO_QUANTITY .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mo_cntrl TYPE REF TO zcl_ton_inbound_delivery_cntrl .
ENDCLASS.



CLASS ZCL_TON_INBOUND_DELIVERY_VIEW IMPLEMENTATION.


  METHOD call_dynpro_login.

    CALL FUNCTION 'ZTON_INBOUND_DELIVERY_LOGIN'
      EXPORTING
        io_view = me.

  ENDMETHOD.


  METHOD call_dynpro_putaway_article.

    CALL FUNCTION 'ZTON_DLG_PUTAWAY_ARTICLE'
      EXPORTING
        io_view = me.

  ENDMETHOD.


  METHOD call_dynpro_quantity.

    CALL FUNCTION 'ZTON_DLG_PUTAWAY_QUANTITY'.

  ENDMETHOD.


  METHOD call_dynpro_storage_place.

    CALL FUNCTION 'ZTON_DLG_PUTAWAY_STORAGE_PLACE'.

  ENDMETHOD.


  METHOD constructor.

    me->mo_log = io_log.
    me->mo_cntrl = io_cntrl.

  ENDMETHOD.


  METHOD login_pai.

    CASE sy-ucomm.

      WHEN 'BACK'.
        LEAVE TO SCREEN 0.
      WHEN 'LEAVE'.
        LEAVE PROGRAM.
      WHEN 'LOGIN'.
        me->mo_cntrl->check_user( EXPORTING iv_warehousenum   = iv_warehousenum
                                                 iv_userid         = iv_userid
                                                 iv_password       = iv_password ).
    ENDCASE.

  ENDMETHOD.


  METHOD pai_putaway_article.

    CASE sy-ucomm.

      WHEN 'BACK'.
        "normaly implement Methods from the cntrl class
        LEAVE TO SCREEN 0.

      WHEN 'LEAVE'.
        LEAVE PROGRAM.

      WHEN 'CONFIRM'.
        "weiter im Programmanblauf
        me->mo_cntrl->on_confirm_scan_article( iv_article_number = iv_article_number ).

        when others.
        "does not happen

    ENDCASE.

  ENDMETHOD.


  METHOD pai_scan_quantity.

    CASE sy-ucomm.

      WHEN 'CONFIRM'.
        me->mo_cntrl->on_scan_quantity( iv_quantity = iv_quantity
                                             iv_meins = iv_meins ).

      WHEN 'BACK'.
        LEAVE TO SCREEN 0.

      WHEN 'LEAVE'.
        LEAVE PROGRAM.
    ENDCASE.

  ENDMETHOD.


  METHOD pai_storage_place.

    CASE sy-ucomm.

      WHEN 'BACK'.
        LEAVE TO SCREEN 0.

      WHEN 'LEAVE'.
        LEAVE PROGRAM.

      WHEN 'CONFIRM'.
        me->mo_cntrl->on_confirm_storage_place( iv_storage_place = iv_storage_place ).

    ENDCASE.


  ENDMETHOD.


  METHOD pbo_storage_place.

    me->mo_cntrl->on_pbo_storage_place( IMPORTING  ev_warehouse_num =  ev_warehouse_num
                                                        ev_storage_place =  ev_storage_place
                                                        ev_storage_area  =  ev_storage_area ).

  ENDMETHOD.
ENDCLASS.
