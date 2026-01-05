*&---------------------------------------------------------------------*
*& Include          ZSF_RS_FORM_181
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .
  "--- Lấy danh sách header theo lựa chọn
  SELECT
      k~rsnum,
      k~bwart,
      k~rsdat,
      k~usnam,
      r~rspos,
      r~matnr,
      r~werks,
      r~lgort,
      r~charg,
      r~bdmng,
      r~meins
    FROM rkpf AS k
    INNER JOIN resb AS r
      ON r~rsnum = k~rsnum
    INTO TABLE @DATA(lt_raw)
    WHERE ( k~rsnum IN @rg_rsnum )
      AND ( k~rsdat IN @rg_rsdat )
      AND ( r~matnr IN @rg_matnr )
      AND ( r~werks IN @rg_werks ).

  IF lt_raw IS INITIAL.
    MESSAGE 'Không tìm thấy Reservation phù hợp điều kiện!' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  SORT lt_raw BY rsnum rspos.

  "=========================================================
  " 2. BUILD HEADER + ITEM
  "=========================================================
  LOOP AT lt_raw INTO DATA(ls_raw).

    "---------- HEADER ----------
    READ TABLE lt_rkpf INTO ls_rkpf
      WITH KEY rsnum = ls_raw-rsnum.
    IF sy-subrc <> 0.
      CLEAR ls_rkpf.
      ls_rkpf-rsnum = ls_raw-rsnum.
      ls_rkpf-bwart = ls_raw-bwart.
      ls_rkpf-rsdat = ls_raw-rsdat.
      ls_rkpf-usnam = ls_raw-usnam.
      APPEND ls_rkpf TO lt_rkpf.
    ENDIF.

    "---------- ITEM ----------
    CLEAR ls_resb.
    ls_resb-rsnum = ls_raw-rsnum.
    ls_resb-rspos = ls_raw-rspos.
    ls_resb-matnr = ls_raw-matnr.
    ls_resb-werks = ls_raw-werks.
    ls_resb-lgort = ls_raw-lgort.
    ls_resb-charg = ls_raw-charg.
    ls_resb-bdmng = ls_raw-bdmng.
    ls_resb-meins = ls_raw-meins.
    APPEND ls_resb TO lt_resb.

  ENDLOOP.

  "=========================================================
  " 3. LẤY MATERIAL DESCRIPTION
  "=========================================================
  SELECT matnr maktx
    FROM makt
    INTO TABLE lt_makt
    FOR ALL ENTRIES IN lt_resb
    WHERE matnr = lt_resb-matnr
      AND spras = sy-langu.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_data
*&---------------------------------------------------------------------*
FORM process_data .

  DATA: lv_path TYPE string.

  IF p_prnt = 'X'.
    CALL METHOD cl_gui_frontend_services=>directory_browse
      CHANGING
        selected_folder      = lv_path
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        OTHERS               = 4.

    IF sy-subrc <> 0 OR lv_path IS INITIAL.
      MESSAGE 'Người dùng đã hủy chọn thư mục lưu file PDF.' TYPE 'I'.
      EXIT.
    ENDIF.
  ENDIF.

  SORT lt_resb BY rsnum rspos.

  DATA: lv_prev_rsnum TYPE rkpf-rsnum.

  DATA: lt_makt_h TYPE HASHED TABLE OF ty_makt
        WITH UNIQUE KEY matnr.

  lt_makt_h = lt_makt.

  CLEAR: lv_prev_rsnum, lt_item.

  LOOP AT lt_resb INTO ls_resb.

    "===== Khi sang Reservation mới =====
    IF lv_prev_rsnum IS INITIAL OR lv_prev_rsnum <> ls_resb-rsnum.

      " In form cũ trước
      IF lv_prev_rsnum IS NOT INITIAL.
        ADD 1 TO gv_form_count.
        PERFORM calling_form USING lv_path.
      ENDIF.

      " Reset item
      CLEAR lt_item.

      " Build header
      READ TABLE lt_rkpf INTO ls_rkpf
        WITH KEY rsnum = ls_resb-rsnum
        BINARY SEARCH.

      MOVE-CORRESPONDING ls_rkpf TO ls_header.
      ls_header-werks = ls_resb-werks.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ls_header-rsnum
        IMPORTING
          output = ls_header-rsnum.

      lv_prev_rsnum = ls_resb-rsnum.
    ENDIF.

    "===== Build item =====
    CLEAR ls_item.
    MOVE-CORRESPONDING ls_resb TO ls_item.

    READ TABLE lt_makt_h INTO ls_makt
      WITH KEY matnr = ls_resb-matnr.
    IF sy-subrc = 0.
      ls_item-maktx = ls_makt-maktx.
    ENDIF.

    APPEND ls_item TO lt_item.

  ENDLOOP.

  "===== In reservation cuối =====
  IF lt_item IS NOT INITIAL.
    ADD 1 TO gv_form_count.
    PERFORM calling_form USING lv_path.
  ENDIF.

  CLEAR gv_form_count.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form calling_form
*&---------------------------------------------------------------------*
FORM calling_form  USING    p_lv_path.

  DATA: lv_fname       TYPE rs38l_fnam,
        lv_pdf_size    TYPE i,
        lt_pdf_bin     TYPE STANDARD TABLE OF solix,
        lv_fullpath    TYPE string,
        lv_pdf_name    TYPE string,
        lv_pdf_xstring TYPE xstring,
        lv_counter     TYPE i VALUE 1,
        lv_exists      TYPE abap_bool.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZSF_RESERVATION'
    IMPORTING
      fm_name            = lv_fname
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    MESSAGE 'No function module found!' TYPE 'E'.
  ENDIF.


  CLEAR: ls_control_parameters, ls_output_options.

  IF p_prev = 'X'.
    "===== CHẾ ĐỘ PRINT PREVIEW =====
    ls_control_parameters-no_dialog = 'X'.   " Không hiện popup
    ls_control_parameters-preview   = 'X'.   " Hiển thị Preview
    ls_output_options-tddest        = 'LP01'. " Không dùng spool thật

    CALL FUNCTION lv_fname
      EXPORTING
        control_parameters = ls_control_parameters
        output_options     = ls_output_options
        user_settings      = ''
        ls_rkpf            = ls_header
        lt_resb            = lt_item
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
  ELSEIF p_prnt = 'X'.
    "===== CHẾ ĐỘ PRINT THẬT =====
    ls_control_parameters-no_dialog = 'X'.   " Không hiện popup
    ls_control_parameters-getotf = 'X'.
    ls_output_options-tddest        = 'LP01'. " Máy in thật hoặc spool

    DATA: ls_job_output_info TYPE ssfcrescl.

    CALL FUNCTION lv_fname
      EXPORTING
        control_parameters = ls_control_parameters
        output_options     = ls_output_options
        user_settings      = ''
        ls_rkpf            = ls_header
        lt_resb            = lt_item
      IMPORTING
        job_output_info    = ls_job_output_info
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    IF sy-subrc = 0 AND ls_job_output_info-otfdata[] IS NOT INITIAL.
      DATA: lt_lines TYPE STANDARD TABLE OF tline.

      CALL FUNCTION 'CONVERT_OTF'
        EXPORTING
          format                = 'PDF'
        IMPORTING
          bin_file              = lv_pdf_xstring
          bin_filesize          = lv_pdf_size
        TABLES
          otf                   = ls_job_output_info-otfdata
          lines                 = lt_lines
        EXCEPTIONS
          err_max_linewidth     = 1
          err_format            = 2
          err_conv_not_possible = 3
          OTHERS                = 4.

      IF sy-subrc = 0.
        " Convert XSTRING -> BINARY để lưu ra file
        CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
          EXPORTING
            buffer     = lv_pdf_xstring
          TABLES
            binary_tab = lt_pdf_bin.

        "=== Sinh tên file PDF theo header-rsnum
        lv_pdf_name = |Reservation_{ ls_header-rsnum }.pdf|.
        CONCATENATE p_lv_path '\' lv_pdf_name INTO lv_fullpath.

        CALL METHOD cl_gui_frontend_services=>file_exist
          EXPORTING
            file   = lv_fullpath
          RECEIVING
            result = lv_exists
          EXCEPTIONS
            OTHERS = 1.

        WHILE lv_exists = abap_true.
          lv_pdf_name = |Reservation_{ ls_header-rsnum }({ lv_counter }).pdf|.
          CONCATENATE p_lv_path '\' lv_pdf_name INTO lv_fullpath.
          ADD 1 TO lv_counter.

          CALL METHOD cl_gui_frontend_services=>file_exist
            EXPORTING
              file   = lv_fullpath
            RECEIVING
              result = lv_exists
            EXCEPTIONS
              OTHERS = 1.
        ENDWHILE.

        "=== Lưu file PDF thật
        CALL METHOD cl_gui_frontend_services=>gui_download
          EXPORTING
            bin_filesize = lv_pdf_size
            filename     = lv_fullpath
            filetype     = 'BIN'
          CHANGING
            data_tab     = lt_pdf_bin
          EXCEPTIONS
            OTHERS       = 1.

        "========================================================
        "  CHECK LẠI FILE CÓ TỒN TẠI HAY KHÔNG (CASE USER DENY)
        "========================================================
        DATA lv_exist_after TYPE abap_bool.

        CALL METHOD cl_gui_frontend_services=>file_exist " check 1 lan cuoi xem lv_fullpath ton tai ko
          EXPORTING
            file   = lv_fullpath
          RECEIVING
            result = lv_exist_after
          EXCEPTIONS
            OTHERS = 1.

        IF lv_exist_after = abap_true.
          IF gv_form_count = 1.
            MESSAGE |Đã lưu PDF: { lv_fullpath }| TYPE 'S'.
          ELSEIF gv_form_count > 1.
            MESSAGE |Đã lưu các PDF: { p_lv_path }| TYPE 'S'.
          ENDIF.
        ELSE.
          MESSAGE |Không lưu được PDF. Người dùng đã từ chối quyền ghi file.| TYPE 'E'.
          RETURN.  " dừng form hiện tại
        ENDIF.
      ELSE.
        MESSAGE |Lỗi khi convert OTF sang PDF cho { ls_header-rsnum }| TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_rsnum
*&---------------------------------------------------------------------*
FORM f4_rsnum .
  DATA: lt_return TYPE TABLE OF ddshretval.

  " Lấy danh sách PI phù hợp điều kiện WERKS + LGORT
  SELECT DISTINCT rsnum, werks, lgort
  FROM resb
  INTO TABLE @DATA(it_resb)
    WHERE werks IN ('DL21', 'SG21').


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'rsnum'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'RG_RSNUM-LOW'
      value_org   = 'S'
    TABLES
      value_tab   = it_resb
      return_tab  = lt_return.

  IF sy-subrc = 0.
    READ TABLE lt_return INTO DATA(ls_val) INDEX 1.
    IF sy-subrc = 0.
      rg_rsnum-low = ls_val-fieldval.
    ENDIF.
  ENDIF.
ENDFORM.
