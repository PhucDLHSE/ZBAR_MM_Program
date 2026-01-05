*---------------------------------------------------------------------*
* Include ZG21_RES_INPUT_PPPLDB1
*---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  IF sy-ucomm = 'ONLI'.
    IF s_rsnum[] IS INITIAL
     AND s_matnr[] IS INITIAL
     AND s_werks[] IS INITIAL
     AND s_bdter[] IS INITIAL
     AND s_kdauf[] IS INITIAL.
      MESSAGE 'Vui lòng chọn ít nhất 1 tiêu chí tìm kiếm!' TYPE 'E'.
    ENDIF.
  ENDIF.

START-OF-SELECTION.

* 1. Lấy danh sách DISTINCT Reservation Number (RSNUM) thỏa mãn tất cả tiêu chí
  SELECT DISTINCT rsnum
    INTO TABLE lt_rsnum
    FROM resb
    WHERE rsnum IN s_rsnum
      AND matnr IN s_matnr
      AND werks IN s_werks
      AND bdter IN s_bdter
      AND kdauf IN s_kdauf.

* 2. Kiểm tra kết quả
  IF lt_rsnum IS INITIAL.
    MESSAGE 'Không tìm thấy Reservation nào' TYPE 'I'.
    EXIT.
  ENDIF.

* 3. Chuyển đổi danh sách RSNUM thành Selection-Screen Parameters (RSPARAMS)
  LOOP AT lt_rsnum INTO lv_rsnum.
    APPEND INITIAL LINE TO lt_submit_params ASSIGNING FIELD-SYMBOL(<fs_param>).
    <fs_param>-selname = 'S_RSNUM'.
    <fs_param>-kind   = 'S'.
    <fs_param>-sign   = 'I'.
    <fs_param>-option = 'EQ'.
    <fs_param>-low    = lv_rsnum.
  ENDLOOP.

* 4. Gọi chương trình in Smartform MỘT LẦN duy nhất
  SUBMIT zsf_rs_program_181
    WITH SELECTION-TABLE lt_submit_params
    WITH p_prev = p_prev
    WITH p_prnt = p_prnt
    AND RETURN.
