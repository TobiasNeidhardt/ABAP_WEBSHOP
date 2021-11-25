FUNCTION-POOL ZTON_DLG_INBOUND_DELIVERY.    "MESSAGE-ID ..

* INCLUDE LZTON_DLG_INBOUND_DELIVERYD...     " Local class definition
DATA: go_login_view           TYPE REF TO zcl_ton_inbound_delivery_view,
      gs_login_data           TYPE zton_db_wh_ma,
      gv_article_number       TYPE zton_article_number,
      go_putaway_article_view TYPE REF TO zcl_ton_inbound_delivery_view,
      gv_lagernummer          TYPE zton_warehouse_number,
      gv_lagerbereich         TYPE zton_storage_area,
      gv_lagerplatz           TYPE zton_storage_place,
      gv_storage_place_in     TYPE zton_storage_place,
      gv_quantity             TYPE zton_amount,
      gv_meins                TYPE zton_unit.
