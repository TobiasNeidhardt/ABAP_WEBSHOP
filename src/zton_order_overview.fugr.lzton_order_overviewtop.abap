FUNCTION-POOL ZTON_ORDER_OVERVIEW.             "MESSAGE-ID ..

* INCLUDE LZTON_ORDER_OVERVIEWD...              " Local class definition

DATA: go_web_shop TYPE REF TO zcl_ton_order_overview_view.
DATA: p_ein       TYPE        zton_order_amount.
DATA: p_status    TYPE        zton_status.
