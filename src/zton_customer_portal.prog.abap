*&---------------------------------------------------------------------*
*& Report ZTON_CUSTOMER_PORTAL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTON_CUSTOMER_PORTAL.

CONSTANTS: lc_logobject TYPE bal_s_log-object VALUE 'ZTON',
           lc_subobjec  TYPE bal_s_log-subobject VALUE 'ZTON'.

TRY.
   "logg error message and save in db
    DATA(lo_log) = NEW zcl_ton_webshop_log( iv_object = lc_logobject
                                              iv_suobj = lc_subobjec ).

    "start the application
    NEW zcl_ton_customer_login_cntrl( io_log = lo_log )->start( ).

  CATCH zcx_ton_webshop_exception_new INTO DATA(lo_exc).

    lo_log->add_msg( is_message = lo_exc->get_message( ) ).
    lo_log->safe_log( ).
    "output error message
    MESSAGE lo_exc.
    "If a Exception comes up in the Login oder Register Screen restart application
    SUBMIT zton_customer_portal.

ENDTRY.
