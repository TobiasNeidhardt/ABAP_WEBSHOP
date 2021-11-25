FUNCTION-POOL ZTON_CUSTOMER_LOGIN.             "MESSAGE-ID ..

* INCLUDE LZTON_CUSTOMER_LOGIND...              " Local class definition
DATA go_login_view TYPE REF TO zcl_ton_customer_login_view.
DATA go_customer_register_view TYPE REF TO zcl_ton_customer_register_view.
DATA p_email    TYPE zton_email.
DATA p_password TYPE zton_password.
DATA p_password_repeat TYPE zton_password.
DATA p_street TYPE zton_street.
DATA p_house_number TYPE zton_house_nr.
DATA p_zipcode TYPE zton_postalcode.
DATA p_city TYPE zton_city.
DATA p_telephone_number TYPE zton_phone_number.
DATA gs_register_data TYPE zton_s_register.
DATA p_salutation type zton_salutation.
DATA p_firstname type zton_firstname.
DATA p_name type zton_name.
