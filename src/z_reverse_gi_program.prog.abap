*&---------------------------------------------------------------------*
*& Report Z_REVERSE_GI_PROGRAM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_REVERSE_GI_PROGRAM.

DATA: gv_vbeln TYPE likp-vbeln.
DATA: lv_flag_reverse_ok TYPE xfeld.

* Import từ memory
*IMPORT vbeln_outbound = gv_vbeln FROM MEMORY ID 'ZGI_VBELN'.

* Nếu import không có thì cho user nhập bằng selection-screen
PARAMETERS: p_vbeln TYPE likp-vbeln DEFAULT gv_vbeln.

START-OF-SELECTION.

  DATA: lv_vbeln_input TYPE likp-vbeln.
  lv_vbeln_input = p_vbeln.

  PERFORM frm_reverse_gi USING lv_vbeln_input.
*&---------------------------------------------------------------------*
*& Form frm_reverse_gi
*&---------------------------------------------------------------------*
FORM frm_reverse_gi  USING    p_lv_vbeln_input.
  DATA: lv_matdoc      TYPE mblnr,
        lv_matyear     TYPE mjahr,
        lv_wbstk       TYPE wbstk,
        lt_mesg        TYPE TABLE OF mesg,
        ls_mesg        TYPE mesg,
        lv_exist_vbeln TYPE likp-vbeln.

  DATA lv_vbeln_1 TYPE likp-vbeln.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_lv_vbeln_input
    IMPORTING
      output = lv_vbeln_1.
  "==============================================================
  " STEP 0: Kiểm tra input user
  "==============================================================
  IF p_lv_vbeln_input IS INITIAL.
    MESSAGE 'Please enter Outbound Delivery Number !' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.



  "==============================================================
  " STEP 1: Kiểm tra Delivery tồn tại
  "==============================================================
  DATA: ls_vbeln TYPE likp. " work area cùng cấu trúc likp

  SELECT SINGLE vbeln, vbtyp
    FROM likp
    INTO (@ls_vbeln-vbeln, @ls_vbeln-vbtyp)
    WHERE vbeln = @lv_vbeln_1.

  IF sy-subrc <> 0.
    MESSAGE |Outbound Delivery { p_lv_vbeln_input } does not exist !| TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "==============================================================
  " STEP 2: Lấy Material Document từ MSEG theo Outbound Delivery
  "==============================================================
  CLEAR: lv_matdoc, lv_matyear.

  SELECT SINGLE m~mblnr, m~mjahr
  FROM mseg AS m
  INNER JOIN mkpf AS k
  ON m~mblnr = k~mblnr
  AND m~mjahr = k~mjahr
  WHERE m~vbeln_im = @ls_vbeln-vbeln
    AND m~shkzg  = 'H'
    AND m~mblnr NOT IN (
        SELECT smbln FROM mseg WHERE shkzg = 'S' AND smbln IS NOT NULL
    )
  INTO (@lv_matdoc, @lv_matyear).

  IF lv_matdoc IS INITIAL.
    MESSAGE |Can not found Material Document for Delivery { p_lv_vbeln_input }. Please enter again !|
    TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
  "==============================================================
  " STEP 3: Gọi WS_REVERSE_GOODS_ISSUE để Reverse GI
  "==============================================================
  CLEAR lt_mesg.

  CALL FUNCTION 'WS_REVERSE_GOODS_ISSUE'
    EXPORTING
      i_vbeln                   = lv_vbeln_1
      i_budat                   = sy-datum
      i_tcode                   = 'VL09'
      i_vbtyp                   = ls_vbeln-vbtyp
    TABLES
      t_mesg                    = lt_mesg
    EXCEPTIONS
      error_reverse_goods_issue = 1
      error_message             = 2
      OTHERS                    = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ELSE.


    "==============================================================
    " STEP 4: Xử lý RETURN (E/A/X) từ t_mesg
    "==============================================================
    READ TABLE lt_mesg INTO ls_mesg WITH KEY msgty = 'E'.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      MESSAGE |Reverse failed Material Document { lv_matdoc }: { ls_mesg-text }| TYPE 'S' DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'p_gv_vbeln'.
      EXIT.
    ENDIF.


    " Nếu tới đây không có lỗi -> Commit
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    lv_flag_reverse_ok = 'X'.

    DATA: lv_mat_reverse  TYPE mblnr,
          lv_year_reverse TYPE mjahr.

    SELECT SINGLE m~mblnr, m~mjahr
    FROM mseg AS m
    INNER JOIN mkpf AS k
    ON m~mblnr = k~mblnr
    AND m~mjahr = k~mjahr
    WHERE m~vbeln_im = @ls_vbeln-vbeln
      AND m~shkzg  = 'S'
      AND smbln = @lv_matdoc
*    AND m~mblnr NOT IN (
*        SELECT smbln FROM mseg WHERE shkzg = 'H' AND smbln IS NOT NULL
*    )
    INTO (@lv_mat_reverse, @lv_year_reverse).

    "==============================================================
    " STEP 5: Thông báo kết quả
    "==============================================================
    MESSAGE |Reverse Document successfully! New Material Document { lv_mat_reverse }/{ lv_year_reverse }.| TYPE 'S'.
    EXPORT matdoc_rev = lv_mat_reverse
           flag_reverse_ok    = lv_flag_reverse_ok
           TO MEMORY ID 'ZGI_REVERSE_RESULT'.
  ENDIF.
ENDFORM.
