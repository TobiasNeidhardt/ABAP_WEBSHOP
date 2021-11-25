FUNCTION-POOL ZTON_HOME_SCREEN.                "MESSAGE-ID ..

* INCLUDE LZTON_HOME_SCREEND...                 " Local class definition
DATA go_home_screen_view TYPE REF TO zcl_ton_homescreen_view.
DATA go_cart_view TYPE REF TO zcl_ton_cart_view.
DATA p_quantity TYPE zton_order_amount.
DATA p_search TYPE string.
DATA go_address_view TYPE REF TO zcl_ton_alternativ_adress.
DATA p_street TYPE zton_street.
DATA p_house_number TYPE zton_house_nr.
DATA p_zip_code TYPE zton_postalcode.
DATA p_address_city TYPE zton_city.
DATA go_order_overview_view TYPE REF TO zcl_ton_homescreen_order_view.
