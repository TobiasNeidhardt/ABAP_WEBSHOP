*&---------------------------------------------------------------------*
*& Report ZTON_COLLECT_CUSTOMER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTON_COLLECT_CUSTOMER.

PARAMETERS:
  p_salut TYPE zton_salutation  OBLIGATORY,
  p_name   TYPE zton_name OBLIGATORY,
  p_fname TYPE zton_firstname OBLIGATORY,
  p_street TYPE zton_street OBLIGATORY,
  p_nr   TYPE zton_house_nr OBLIGATORY,
  p_plz    TYPE zton_postalcode     OBLIGATORY,
  p_city    TYPE zton_city     OBLIGATORY,
  p_email  TYPE zton_email   OBLIGATORY,
  p_phone TYPE zton_phone_number.


DATA: ls_customer     TYPE          zton_customer,
      lv_nummerint  TYPE          i,
      lv_nummerchar TYPE          zton_kd_numr_de.

CONSTANTS: lc_range_nr TYPE inri-nrrangenr VALUE '01'.

CALL FUNCTION 'NUMBER_GET_NEXT'
  EXPORTING
    nr_range_nr = lc_range_nr
    object      = 'ZTON_CUSTO'
  IMPORTING
    number      = lv_nummerint
  EXCEPTIONS
    OTHERS      = 1.
IF sy-subrc <> 0.
  MESSAGE e001(zton_shop) .
ENDIF.

lv_nummerchar = lv_nummerint.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    input  = lv_nummerchar
  IMPORTING
    output = lv_nummerchar.

ls_customer-customer_number = lv_nummerchar.
ls_customer-salutation = p_salut.
ls_customer-name = p_name.
ls_customer-first_name = p_fname.
ls_customer-street = p_street.
ls_customer-house_number = p_nr.
ls_customer-zip_code = p_plz.
ls_customer-city = p_city.
ls_customer-email = p_email.
ls_customer-telephone_number = p_phone.

CALL FUNCTION 'ZTON_ADD_CUSTOMER'
  EXPORTING is_customer = ls_customer.

CALL FUNCTION 'ZTON_SHOW_CUSTOMER_LIST'.
