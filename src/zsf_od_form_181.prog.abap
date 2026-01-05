*&---------------------------------------------------------------------*
*& Include          ZSF_OD_FORM_181
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data.

  "--- Lấy danh sách header theo lựa chọn
  SELECT a~vbeln, a~kunnr, a~erdat, b~posnr, b~matnr, b~arktx, b~lfimg,
     b~meins, b~charg, b~werks, b~lgort
    FROM likp AS a
    INNER JOIN lips AS b
      ON a~vbeln = b~vbeln
    INTO TABLE @DATA(lt_full)
    WHERE a~vbeln IN @rg_vbeln
      AND a~kunnr IN @rg_kunnr
      AND a~erdat IN @rg_erdat
      AND a~vstel IN @rg_vstel.

  IF lt_full IS INITIAL.
    MESSAGE 'Không tìm thấy Outbound phù hợp điều kiện!' TYPE 'I'.
  ENDIF.

  SORT lt_full BY vbeln.
  LOOP AT lt_full INTO DATA(ls_full).
    READ TABLE lt_likp INTO ls_likp WITH KEY vbeln = ls_full-vbeln.
    IF sy-subrc <> 0.
      CLEAR ls_likp.
      ls_likp-vbeln = ls_full-vbeln.
      ls_likp-kunnr = ls_full-kunnr.
      ls_likp-erdat = ls_full-erdat.
      APPEND ls_likp TO lt_likp.
    ENDIF.

    CLEAR ls_lips.
    ls_lips-vbeln = ls_full-vbeln.
    ls_lips-posnr = ls_full-posnr.
    ls_lips-matnr = ls_full-matnr.
    ls_lips-arktx = ls_full-arktx.
    ls_lips-lfimg = ls_full-lfimg.
    ls_lips-meins = ls_full-meins.
    ls_lips-charg = ls_full-charg.
    ls_lips-werks = ls_full-werks.
    ls_lips-lgort = ls_full-lgort.
    APPEND ls_lips TO lt_lips.

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


  SORT lt_lips BY vbeln.
  DATA: lv_prev_vbeln TYPE likp-vbeln.
  CLEAR: lt_item, lv_prev_vbeln.

  LOOP AT lt_lips INTO ls_lips.

    IF lv_prev_vbeln IS INITIAL OR lv_prev_vbeln <> ls_lips-vbeln.

      " In form cũ trước
      IF lv_prev_vbeln IS NOT INITIAL.
        ADD 1 TO gv_form_count.
        PERFORM calling_form USING lv_path.
      ENDIF.

      CLEAR lt_item. " in xong xóa data de in tiep

      READ TABLE lt_likp INTO ls_likp WITH KEY vbeln = ls_lips-vbeln
      BINARY SEARCH.

      MOVE-CORRESPONDING ls_likp TO ls_header.
      ls_header-werks = ls_lips-werks.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ls_header-vbeln
        IMPORTING
          output = ls_header-vbeln.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ls_header-kunnr
        IMPORTING
          output = ls_header-kunnr.

      lv_prev_vbeln = ls_lips-vbeln.
    ENDIF.

    CLEAR ls_item.
    MOVE-CORRESPONDING ls_lips TO ls_item.
    APPEND ls_item TO lt_item.

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
      formname = 'ZSF_OUTBOUND_DELIVERY'
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
        ls_likp            = ls_header
        lt_lips            = lt_item.

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
        ls_likp            = ls_header
        lt_lips            = lt_item
      IMPORTING
        job_output_info    = ls_job_output_info
      EXCEPTIONS
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
        lv_pdf_name = |Outbound_{ ls_header-vbeln }.pdf|.
        CONCATENATE p_lv_path '\' lv_pdf_name INTO lv_fullpath.

        CALL METHOD cl_gui_frontend_services=>file_exist
          EXPORTING
            file   = lv_fullpath
          RECEIVING
            result = lv_exists
          EXCEPTIONS
            OTHERS = 1.

        WHILE lv_exists = abap_true.
          lv_pdf_name = |Outbound_{ ls_header-vbeln }({ lv_counter }).pdf|.
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

        CALL METHOD cl_gui_frontend_services=>file_exist
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
        MESSAGE |Lỗi khi convert OTF sang PDF cho { ls_header-vbeln }| TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
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
*&---------------------------------------------------------------------*
*& Form validate_inputs
*&---------------------------------------------------------------------*

FORM validate_inputs .
  IF sy-ucomm = 'ONLI'.
    IF rg_vbeln[] IS INITIAL
    AND rg_kunnr[] IS INITIAL
    AND rg_erdat[] IS INITIAL
    AND rg_vstel[] IS INITIAL.
      MESSAGE 'Vui lòng chọn ít nhất 1 tiêu chí tìm kiếm!' TYPE 'E'.
    ENDIF.

    IF rg_vbeln[] IS NOT INITIAL.
      SELECT SINGLE vbeln
        FROM likp
        INTO @DATA(iv_vbeln)
        WHERE vbeln IN @rg_vbeln.
      IF sy-subrc <> 0.
        MESSAGE 'Outbound Delivery không tồn tại!' TYPE 'E'.
      ENDIF.
    ENDIF.

    " 3. Check Ship-to-party
    IF rg_kunnr[] IS NOT INITIAL.
      SELECT SINGLE kunnr
        FROM likp
        INTO @DATA(iv_kunnr)
        WHERE kunnr IN @rg_kunnr.
      IF sy-subrc <> 0.
        MESSAGE 'Ship-to-party không tồn tại!' TYPE 'E'.
      ENDIF.
    ENDIF.

    " 4. Check Delivery date
    IF rg_erdat[] IS NOT INITIAL.
      SELECT SINGLE erdat
        FROM likp
        INTO @DATA(iv_erdat)
        WHERE erdat IN @rg_erdat.
      IF sy-subrc <> 0.
        MESSAGE 'Delivery date không tồn tại!' TYPE 'E'.
      ENDIF.
    ENDIF.

    " 5. Check Shipping point
    IF rg_vstel[] IS NOT INITIAL.
      SELECT SINGLE vstel
        FROM likp
        INTO @DATA(iv_vstel)
        WHERE vstel IN @rg_vstel.
      IF sy-subrc <> 0.
        MESSAGE 'Shipping point / Receiving plant không tồn tại!' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
