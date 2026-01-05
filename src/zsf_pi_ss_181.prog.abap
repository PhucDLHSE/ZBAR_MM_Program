*&---------------------------------------------------------------------*
*& Include          ZSF_OD_SS_181
*&---------------------------------------------------------------------*

TABLES: ikpf.
*----------------------------------------------------------*
* Selection screen
*----------------------------------------------------------*
*SELECT-OPTIONS: s_iblnr FOR ls_ikpf-iblnr.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
    SELECT-OPTIONS:
      rg_iblnr FOR ikpf-iblnr,          "Physical Inventory Document
      rg_gjahr FOR ikpf-gjahr,          "Fiscal Year
      rg_werks FOR ikpf-werks,          "Plant
      rg_lgort FOR ikpf-lgort.          "Storage Location
  SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN SKIP. " tang khoang cach giua 2 selection screen

SELECTION-SCREEN BEGIN OF BLOCK b_print WITH FRAME TITLE TEXT-900.
PARAMETERS:
  p_prev RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND mode, " Print Preview
  p_prnt RADIOBUTTON GROUP g1.                             " Print thật
SELECTION-SCREEN END OF BLOCK b_print.

AT SELECTION-SCREEN.

  " Kiểm tra nếu tất cả đều trống
  IF sy-ucomm = 'ONLI'.
    IF rg_iblnr[] IS INITIAL
    AND rg_gjahr[] IS INITIAL
    AND rg_werks[] IS INITIAL
    AND rg_lgort[] IS INITIAL.
      MESSAGE 'Vui lòng chọn ít nhất 1 tiêu chí tìm kiếm!' TYPE 'E'.
    ENDIF.

    IF rg_iblnr[] IS NOT INITIAL.
      SELECT SINGLE iblnr
        FROM ikpf
        INTO @DATA(iv_iblnr)
        WHERE iblnr IN @rg_iblnr.
      IF sy-subrc <> 0.
        MESSAGE 'Physical Inventory Document không tồn tại!' TYPE 'E'.
      ENDIF.
    ENDIF.

    " 3. Check Ship-to-party
    IF rg_gjahr[] IS NOT INITIAL.
      SELECT SINGLE gjahr
        FROM ikpf
        INTO @DATA(iv_gjahr)
        WHERE gjahr IN @rg_gjahr.
      IF sy-subrc <> 0.
        MESSAGE 'PI Year không tồn tại!' TYPE 'E'.
      ENDIF.
    ENDIF.

    " 4. Check Delivery date
    IF rg_werks[] IS NOT INITIAL.
      SELECT SINGLE werks
        FROM ikpf
        INTO @DATA(iv_werks)
        WHERE werks IN @rg_werks.
      IF sy-subrc <> 0.
        MESSAGE 'Plant không tồn tại!' TYPE 'E'.
      ENDIF.
    ENDIF.

    " 5. Check Shipping point
    IF rg_lgort[] IS NOT INITIAL.
      SELECT SINGLE lgort
        FROM ikpf
        INTO @DATA(iv_lgort)
        WHERE lgort IN @rg_lgort.
      IF sy-subrc <> 0.
        MESSAGE 'Storage Location không tồn tại!' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR rg_iblnr-low.
  PERFORM f4_iblnr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR rg_iblnr-high.
  PERFORM f4_iblnr.
