*&---------------------------------------------------------------------*
*& Include ZG21_OUTB_INPUT_DB1 - Main Program Logic (Outbound - FINAL)
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  " Kiểm tra nếu tất cả đều trống
  IF sy-ucomm = 'ONLI'.
    IF rg_vbeln[] IS INITIAL
    AND rg_kunnr[] IS INITIAL
    AND rg_lfdat[] IS INITIAL
    AND rg_vstel[] IS INITIAL.
      MESSAGE 'Vui lòng chọn ít nhất 1 tiêu chí tìm kiếm!' TYPE 'E'.
    ENDIF.
  ENDIF.

START-OF-SELECTION.

* Lấy danh sách DISTINCT Delivery Number (VBELN) thỏa mãn các tiêu chí
  SELECT DISTINCT vbeln
    INTO TABLE lt_vbeln
    FROM likp
    WHERE vbeln IN rg_vbeln
      AND kunnr IN rg_kunnr
      AND lfdat IN rg_lfdat
      AND vstel IN rg_vstel.

* 1. Kiểm tra kết quả
  IF lt_vbeln IS INITIAL.
    MESSAGE 'Không tìm thấy Outbound Delivery nào phù hợp với tiêu chí chọn để in.' TYPE 'I'.
    EXIT.
  ENDIF.

* 2. Chuyển đổi danh sách VBELN thành Selection-Screen Parameters (RSPARAMS)
  LOOP AT lt_vbeln INTO lv_vbeln.
    APPEND INITIAL LINE TO lt_submit_params ASSIGNING FIELD-SYMBOL(<fs_param>).

    <fs_param>-selname = 'S_VBELN'.
    <fs_param>-kind   = 'S'.
    <fs_param>-sign   = 'I'.
    <fs_param>-option = 'EQ'.
    <fs_param>-low    = lv_vbeln.
  ENDLOOP.

* 3. Gọi chương trình in Smartform
  " Truyền thêm giá trị Print Mode (Preview / Print)
  SUBMIT zsf_od_program_181
    WITH SELECTION-TABLE lt_submit_params
    WITH p_prev = p_prev
    WITH p_prnt = p_prnt
    AND RETURN.
*&---------------------------------------------------------------------*
*& Form f4_vbeln
*&---------------------------------------------------------------------*
FORM f4_vbeln .
  DATA: lt_return TYPE TABLE OF ddshretval.

  " Lấy danh sách PI phù hợp điều kiện WERKS + LGORT
  SELECT vbeln, werks, lgort
  FROM lips
  INTO CORRESPONDING FIELDS OF TABLE @lt_lips
  WHERE pstyv = 'TAN'
    AND werks IN ('DL21', 'SG21').


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'VBELN'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'RG_VBELN-LOW'
      value_org   = 'S'
    TABLES
      value_tab   = lt_lips
      return_tab  = lt_return.

  IF sy-subrc = 0.
    READ TABLE lt_return INTO DATA(ls_val) INDEX 1.
    IF sy-subrc = 0.
      rg_vbeln-low = ls_val-fieldval.
    ENDIF.
  ENDIF.
ENDFORM.
