*&---------------------------------------------------------------------*
*& Report ZPG_IN1_178
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPG_IN1_178.
tables:likp.
"----- Parameter nhập Inbound Delivery -----
SELECTION-SCREEN BEGIN OF BLOCK b1.
PARAMETERS: p_vbeln TYPE vbeln_vl OBLIGATORY.
*  SELECT-OPTIONS: p_vbeln FOR likp-vbeln.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK b_print WITH FRAME TITLE TEXT-900.
PARAMETERS:
  p_prev RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND mode, " Print Preview
  p_prnt RADIOBUTTON GROUP g1.                             " Print thật
SELECTION-SCREEN END OF BLOCK b_print.

"----- Thêm nút Run -----
SELECTION-SCREEN SKIP 1.                         " Tạo khoảng cách với ô input
SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN POSITION 35.                  " Căn nút vào giữa gần input
  SELECTION-SCREEN PUSHBUTTON (10) btn_run USER-COMMAND run.  " Thu nhỏ nút
SELECTION-SCREEN END OF LINE.



INITIALIZATION.
  btn_run = 'Enter'.

"----- Khi bấm nút Run -----
AT SELECTION-SCREEN.
  IF sy-ucomm = 'RUN'.
    PERFORM run_smartform.
  ENDIF.

"----- Khi bấm Execute mặc định của SAP -----
START-OF-SELECTION.
  PERFORM run_smartform.

"----- Call SmartForm -----
FORM run_smartform.
  DATA: lv_fm_name TYPE rs38l_fnam,
        ls_ctrl    TYPE ssfctrlop,
        ls_comp    TYPE ssfcompop.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname = 'ZDEMO_IN1_178'
    IMPORTING
      fm_name  = lv_fm_name.

*  ls_ctrl-no_dialog = 'X'.
*  ls_ctrl-preview   = 'X'.
*
*  ls_comp-tddest = 'LP01'.  "Máy in mặc định

CLEAR: ls_ctrl, ls_comp.

  IF p_prev = 'X'.
    "===== CHẾ ĐỘ PRINT PREVIEW =====
    ls_ctrl-no_dialog = 'X'.   " Không hiện popup
    ls_ctrl-preview   = 'X'.   " Hiển thị Preview
    ls_comp-tddest        = 'LP01'. " Không dùng spool thật
  ELSE.
    "===== CHẾ ĐỘ PRINT THẬT =====
    ls_ctrl-no_dialog = 'X'.   " Không hiện popup
    ls_ctrl-preview   = ''.     " Không preview
    ls_comp-tddest        = 'LP01'. " Máy in thật hoặc spool
  ENDIF.


  CALL FUNCTION lv_fm_name
    EXPORTING
      control_parameters = ls_ctrl
      output_options     = ls_comp
      user_settings      = ' '
      ip_id              = p_vbeln.

  CASE sy-subrc.
    WHEN 0.
      IF p_prnt = 'X'.
        MESSAGE 'In thành công — kiểm tra spool trong SP01.' TYPE 'S'.
      ENDIF.
    WHEN 1.
      MESSAGE 'Lỗi định dạng SmartForm (formatting_error).' TYPE 'E'.
    WHEN 2.
      MESSAGE 'Lỗi nội bộ khi in SmartForm.' TYPE 'E'.
    WHEN 3.
      MESSAGE 'Lỗi gửi dữ liệu tới spool / printer.' TYPE 'E'.
    WHEN 4.
      MESSAGE 'Người dùng đã hủy quá trình in.' TYPE 'I'.
    WHEN OTHERS.
      MESSAGE 'Lỗi không xác định khi gọi SmartForm.' TYPE 'E'.
  ENDCASE.

ENDFORM.
