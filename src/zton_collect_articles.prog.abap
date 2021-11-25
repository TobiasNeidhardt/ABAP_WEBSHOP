*&---------------------------------------------------------------------*
*& Report ZTON_COLLECT_ARTICLES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zton_collect_articles.

PARAMETERS: p_desig TYPE zton_designation  OBLIGATORY,
            p_descr TYPE zton_description OBLIGATORY,
            p_curr  TYPE zton_currency     OBLIGATORY,
            p_unit  TYPE zton_unit      OBLIGATORY,
            p_price TYPE zton_price        OBLIGATORY.

DATA: lv_art_nr  TYPE                          i,
      ls_article TYPE           zton_article,
      lt_article TYPE TABLE OF  zton_article,
      lo_alv     TYPE REF TO    cl_salv_table.

CONSTANTS: lc_range_nr TYPE nrnr VALUE '01'.

CALL FUNCTION 'NUMBER_GET_NEXT'
  EXPORTING
    nr_range_nr = lc_range_nr
    object      = 'ZTON_ART'
  IMPORTING
    number      = lv_art_nr
  EXCEPTIONS
    OTHERS      = 1.
IF sy-subrc <> 0.
  MESSAGE e001(zton_shop).
ENDIF.

ls_article-article_number = lv_art_nr.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    input  = ls_article-article_number
  IMPORTING
    output = ls_article-article_number.

ls_article-designation   = p_desig.
ls_article-description  = p_descr.
ls_article-currency      = p_curr.
ls_article-price         = p_price.
ls_article-unit       = p_unit.

CALL FUNCTION 'ZTON_ADD_ARTICLE'
  EXPORTING
    is_article = ls_article.

CALL FUNCTION 'ZTON_SHOW_ARTICLE_LIST'.
