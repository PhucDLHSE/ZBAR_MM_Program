*&---------------------------------------------------------------------*
*& Report Z_REVERSE_GR_PROGRAM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_reverse_gr_program.

DATA: lv_flag_reverse_ok TYPE xfeld.
PARAMETERS:
  p_matdoc  TYPE mblnr OBLIGATORY,
  p_year TYPE mjahr OBLIGATORY.

DATA: lt_return  TYPE TABLE OF bapiret2,
      ls_return  TYPE bapiret2,
      ls_headret TYPE bapi2017_gm_head_ret.


"===========================================================
" 1. GỌI BAPI CANCEL GR
"===========================================================
CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
  EXPORTING
    materialdocument    = p_matdoc
    matdocumentyear     = p_year
    goodsmvt_pstng_date = sy-datum
    goodsmvt_pr_uname   = sy-uname
  IMPORTING
    goodsmvt_headret    = ls_headret
  TABLES
    return              = lt_return.

"===========================================================
" 2. CHECK LỖI
"===========================================================
READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
IF sy-subrc = 0.
  lv_flag_reverse_ok = ''.
  MESSAGE |Reverse failed for Material Document { p_matdoc }: { ls_return-message }|
      TYPE 'S' DISPLAY LIKE 'E'.
  EXIT.
ENDIF.



"===========================================================
" 3. COMMIT
"===========================================================
CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
  EXPORTING wait = 'X'.

lv_flag_reverse_ok = 'X'.

"===========================================================
" 4. EXPORT KẾT QUẢ NEW DOCUMENT về SCREEN 202
"===========================================================
EXPORT matdoc_rev_return  = ls_headret-mat_doc
       matyear_rev_return = ls_headret-doc_year
       flag_reverse_ok    = lv_flag_reverse_ok
       TO MEMORY ID 'ZGR_REVERSE_RESULT'.


"===========================================================
" 5. THÔNG BÁO
"===========================================================
MESSAGE |Reverse Document sucessfully! New Material Document: { ls_headret-mat_doc }/{ ls_headret-doc_year }.|
      TYPE 'S'.
