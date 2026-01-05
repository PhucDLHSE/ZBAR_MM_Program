
*& Include ZG21_PI_INPUT_DB1 - Main Program Logic (Physical Inventory - FINAL)
*&---------------------------------------------------------------------*

AT SELECTION-SCREEN.

  " Chỉ kiểm tra khi người dùng nhấn Execute (F8)
  IF sy-ucomm = 'ONLI'.
    IF rg_iblnr[] IS INITIAL
    AND rg_gjahr[] IS INITIAL
    AND rg_werks[] IS INITIAL
    AND rg_lgort[] IS INITIAL.
      MESSAGE 'Vui lòng chọn ít nhất 1 tiêu chí tìm kiếm!' TYPE 'E'.
    ENDIF.
  ENDIF.

START-OF-SELECTION.


* 1. Lấy danh sách DISTINCT Inventory Number (INVNU)
  SELECT DISTINCT iblnr
    INTO TABLE lt_iblnr
    FROM ikpf
    WHERE iblnr IN rg_iblnr
      AND gjahr IN rg_gjahr
      AND werks IN rg_werks
      AND lgort IN rg_lgort.

* 2. Kiểm tra kết quả
  IF lt_iblnr IS INITIAL.
    MESSAGE 'Không tìm thấy Physical Inventory nào phù hợp với tiêu chí chọn để xử lý.' TYPE 'I'.
    EXIT.
  ENDIF.

* 3. Chuyển danh sách INVNU thành bảng tham số để SUBMIT
  LOOP AT lt_iblnr INTO lv_iblnr.

    APPEND INITIAL LINE TO lt_submit_params ASSIGNING FIELD-SYMBOL(<fs_param>).

    <fs_param>-selname = 'S_IBLNR'.
    <fs_param>-kind    = 'S'.
    <fs_param>-sign    = 'I'.
    <fs_param>-option  = 'EQ'.
    <fs_param>-low     = lv_iblnr.
  ENDLOOP.

* 4. Gọi chương trình xử lý Smartform
  SUBMIT zsf_pi_test_181
    WITH SELECTION-TABLE lt_submit_params
    WITH p_prev = p_prev
    WITH p_prnt = p_prnt
    AND RETURN.
*&---------------------------------------------------------------------*
*& Form f4_iblnr
*&---------------------------------------------------------------------*
FORM f4_iblnr .
  DATA: lt_return TYPE TABLE OF ddshretval.

  " Lấy danh sách PI phù hợp điều kiện WERKS + LGORT
  SELECT iblnr, gjahr, werks, lgort
    FROM ikpf
    INTO CORRESPONDING FIELDS OF TABLE @it_ikpf
    WHERE werks IN ('DL21', 'SG21').

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'IBLNR'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'RG_IBLNR-LOW'
      value_org   = 'S'
    TABLES
      value_tab   = it_ikpf
      return_tab  = lt_return.

  IF sy-subrc = 0.
    READ TABLE lt_return INTO DATA(ls_val) INDEX 1.
    IF sy-subrc = 0.
      rg_iblnr-low = ls_val-fieldval.
    ENDIF.
  ENDIF.
ENDFORM.
