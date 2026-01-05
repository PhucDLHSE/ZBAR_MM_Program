**&---------------------------------------------------------------------*
**& Include          ZSF_PI_FORM_181
**&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .
  "--- Lấy danh sách header theo lựa chọn
  SELECT a~iblnr, a~gjahr, a~lgort, a~werks, b~matnr, b~menge, b~charg, b~xzael
    FROM ikpf AS a
    INNER JOIN iseg AS b
      ON a~iblnr = b~iblnr
      AND a~gjahr = b~gjahr
    INTO TABLE @DATA(lt_full)
    WHERE a~iblnr IN @rg_iblnr
    AND a~gjahr IN @rg_gjahr
    AND a~lgort IN @rg_lgort
    AND a~werks IN @rg_werks.

  IF lt_full IS INITIAL.
    MESSAGE 'Không tìm thấy Physical Inventory Document phù hợp điều kiện!' TYPE 'E'.
  ENDIF.

  SORT lt_full BY iblnr.
  LOOP AT lt_full INTO DATA(ls_full).
    READ TABLE lt_ikpf INTO ls_ikpf WITH KEY iblnr = ls_full-iblnr.
    IF sy-subrc <> 0.
      CLEAR ls_ikpf.
      ls_ikpf-iblnr = ls_full-iblnr.
      ls_ikpf-gjahr = ls_full-gjahr.
      ls_ikpf-lgort = ls_full-lgort.
      ls_ikpf-werks = ls_full-werks.
      APPEND ls_ikpf TO lt_ikpf.
    ENDIF.

    CLEAR ls_iseg.
    ls_iseg-iblnr = ls_full-iblnr.
    ls_iseg-gjahr = ls_full-gjahr.
    ls_iseg-matnr = ls_full-matnr.
    ls_iseg-menge = ls_full-menge.
    ls_iseg-charg = ls_full-charg.
    ls_iseg-werks = ls_full-werks.
    ls_iseg-lgort = ls_full-lgort.
    ls_iseg-xzael = ls_full-xzael.
    APPEND ls_iseg TO lt_iseg.

  ENDLOOP.

  LOOP AT lt_iseg ASSIGNING FIELD-SYMBOL(<fs_iseg>).
    IF <fs_iseg>-xzael = 'X'.
      <fs_iseg>-disp_menge = |{ <fs_iseg>-menge DECIMALS = 0 }|.
    ELSE.
      CLEAR <fs_iseg>-disp_menge.  "hiển thị rỗng
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_data
*&---------------------------------------------------------------------*
FORM process_data .
  "--- Nếu user chọn Print, cho chọn folder trước
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

  SORT lt_iseg BY iblnr.
  DATA: lv_prev_iblnr TYPE ikpf-iblnr.
  CLEAR: lt_item, lv_prev_iblnr.

  LOOP AT lt_iseg INTO ls_iseg.

    IF lv_prev_iblnr IS INITIAL OR lv_prev_iblnr <> ls_iseg-iblnr.

      " In form cũ trước
      IF lv_prev_iblnr IS NOT INITIAL.
        ADD 1 TO gv_form_count.
        PERFORM calling_form USING lv_path.
      ENDIF.

      CLEAR lt_item. " xóa item form trc in form tiep theo

      READ TABLE lt_ikpf INTO ls_ikpf WITH KEY iblnr = ls_iseg-iblnr
      BINARY SEARCH.

      MOVE-CORRESPONDING ls_ikpf TO ls_header.
      ls_header-matnr = ls_iseg-matnr.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ls_header-iblnr
        IMPORTING
          output = ls_header-iblnr.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
        EXPORTING
          input  = ls_header-matnr
        IMPORTING
          output = ls_header-matnr.

      lv_prev_iblnr = ls_iseg-iblnr.
    ENDIF.

    CLEAR ls_item.
    MOVE-CORRESPONDING ls_iseg TO ls_item.

    "--- Lấy serial number từ EQUI theo MATNR + CHARG
    SELECT SINGLE sernr
      FROM equi
      INTO @ls_item-sernr
      WHERE matnr  = @ls_iseg-matnr
        AND charge = @ls_iseg-charg.

    APPEND ls_item TO lt_item.

    SORT lt_item BY sernr ASCENDING.

  ENDLOOP.

  IF lt_item IS NOT INITIAL.
    ADD 1 TO gv_form_count.
    PERFORM calling_form USING lv_path.
  ENDIF.

  CLEAR gv_form_count.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form calling_form
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PATH
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
      formname = 'ZSF_PI_TEST'
    IMPORTING
      fm_name  = lv_fname
    EXCEPTIONS
      OTHERS   = 3.
  IF sy-subrc <> 0.
    MESSAGE 'Không tìm thấy SmartForm ZSF_OUTBOUND_DELIVERY' TYPE 'E'.
  ENDIF.

  CLEAR: ls_control_parameters, ls_output_options.

  IF p_prev = 'X'.
    "===== CHẾ ĐỘ PRINT PREVIEW =====
    ls_control_parameters-no_dialog = 'X'.
    ls_control_parameters-preview   = 'X'.
    ls_output_options-tddest        = 'LP01'.

    CALL FUNCTION lv_fname
      EXPORTING
        control_parameters = ls_control_parameters
        output_options     = ls_output_options
        user_settings      = ''
        ls_ikpf            = ls_header
        lt_iseg            = lt_item.


  ELSEIF p_prnt = 'X'.
    "===== CHẾ ĐỘ PRINT → XUẤT PDF CHO MỖI VBELN =====
    ls_control_parameters-no_dialog = 'X'.
    ls_control_parameters-getotf    = 'X'.
    ls_output_options-tddest        = 'LP01'.

    DATA: ls_job_output_info TYPE ssfcrescl.

    CALL FUNCTION lv_fname
      EXPORTING
        control_parameters = ls_control_parameters
        output_options     = ls_output_options
        user_settings      = ''
        ls_ikpf            = ls_header
        lt_iseg            = lt_item
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

        "=== Sinh tên file PDF và kiểm tra nếu file đã tồn tại thì thêm (1), (2), ...
        lv_pdf_name = |Physical inventory document_{ ls_header-iblnr }.pdf|.
        CONCATENATE p_lv_path '\' lv_pdf_name INTO lv_fullpath.

        CALL METHOD cl_gui_frontend_services=>file_exist " kiem tra lv_fullpath ton tai chua
          EXPORTING
            file   = lv_fullpath
          RECEIVING
            result = lv_exists
          EXCEPTIONS
            OTHERS = 1.

        WHILE lv_exists = abap_true.
          lv_pdf_name = |Physical inventory document_{ ls_header-iblnr }({ lv_counter }).pdf|.
          CONCATENATE p_lv_path '\' lv_pdf_name INTO lv_fullpath.
          ADD 1 TO lv_counter.

          CALL METHOD cl_gui_frontend_services=>file_exist " kiem tra lv_fullpath (them lv_counter) ton tai chua
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
        MESSAGE |Lỗi khi convert OTF sang PDF cho { ls_header-iblnr }| TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_iblnr
*&---------------------------------------------------------------------*
FORM f4_iblnr .
  DATA: lt_return TYPE TABLE OF ddshretval.

  " Lấy danh sách PI phù hợp điều kiện WERKS + LGORT
  SELECT iblnr, gjahr, werks, lgort
    FROM ikpf
    INTO TABLE @DATA(it_ikpf)
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
