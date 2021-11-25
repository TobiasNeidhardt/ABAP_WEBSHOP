*----------------------------------------------------------------------*
***INCLUDE LZTON_CUSTOMER_LOGINO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module Status_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS '9000'.
  SET TITLEBAR 'Login Screen'.
  TRY.
    go_login_view->mo_customer_login_cntrl->on_pbo_login_screen( ).
  CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
  MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
  ENDTRY.
ENDMODULE.
