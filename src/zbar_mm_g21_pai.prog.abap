*&---------------------------------------------------------------------*
*& Include          ZBAR_MM_G21_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  IF gv_select IS INITIAL.
*    MESSAGE 'Please enter select number' TYPE 'S' DISPLAY LIKE 'E'.
    MESSAGE s031(zms_mm_g21) DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_SELECT'.
    EXIT.
  ENDIF.

  CASE ok_code.
    WHEN 'ENTR' OR ''. "KHI NHAN ENTER TREN BAN PHIM HE THONG NHAN VALUE = ''
      PERFORM main_chosen.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
*      CLEAR gv_select.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
MODULE user_command_0200 INPUT.
  IF gv_select IS INITIAL.
*    MESSAGE 'Please enter select number' TYPE 'S' DISPLAY LIKE 'E'.
    MESSAGE s031(zms_mm_g21) DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_SELECT'.
    EXIT.
  ENDIF.
  CASE ok_code.
    WHEN 'ENTR' OR ''.
      PERFORM gr_chosen.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0201  INPUT
MODULE user_command_0201 INPUT.
  IF gv_select IS INITIAL.
*    MESSAGE 'Please enter select number' TYPE 'S' DISPLAY LIKE 'E'.
    MESSAGE s031(zms_mm_g21) DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_SELECT'.
    EXIT.
  ENDIF.
  CASE ok_code.
    WHEN 'ENTR' OR ''.
      PERFORM gr201_chosen.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
MODULE user_command_0300 INPUT.
  IF gv_select IS INITIAL.
    MESSAGE 'Please enter select number' TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_SELECT'.
    EXIT.
  ENDIF.
  CASE ok_code.
    WHEN 'ENTR' OR ''.
      PERFORM gr300_chosen.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0301  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0301 INPUT.
  IF gv_select IS INITIAL.
*    MESSAGE 'Please enter select number' TYPE 'S' DISPLAY LIKE 'E'.
    MESSAGE s031(zms_mm_g21) DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_SELECT'.
    EXIT.
  ENDIF.
  CASE ok_code.
    WHEN 'ENTER' OR ''.
      PERFORM gr301_chosen.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3010 INPUT.
  CASE ok_code.
    WHEN 'ENTER' OR ''.
      PERFORM frm_check_so_item.
      IF gv_valid_sono = abap_false.
        EXIT.
      ENDIF.

      PERFORM frm_check_werk_dl21 USING gv_sono.

      IF gv_valid_werks = abap_false.
        EXIT.
      ENDIF.

      PERFORM frm_get_outbound_delivery.

      IF gv_valid_outbound = abap_false.
        EXIT.
      ENDIF.

      CALL SCREEN 3011.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_3010  INPUT
MODULE exit_3010 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
*      CLEAR: gv_select, gv_sono.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3012  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3012 INPUT.
  CASE ok_code.
    WHEN 'ENTER' OR ''.
      PERFORM frm_check_so_item.
      IF gv_valid_sono = abap_false.
        EXIT.
      ENDIF.

      PERFORM frm_check_werk_sg21 USING gv_sono.

      IF gv_valid_werks = abap_false.
        EXIT.
      ENDIF.

      PERFORM frm_get_outbound_delivery.

      IF gv_valid_outbound = abap_false.
        EXIT.
      ENDIF.

      CALL SCREEN 3013.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_3012  INPUT
MODULE exit_3012 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
*      CLEAR: gv_select, gv_sono.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3011  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3011 INPUT.
  IF sy-ucomm = 'PICK'.
    GET CURSOR FIELD lv_field VALUE lv_value.
    " Double click đúng vào field hiển thị Material Document
    IF lv_field = 'LS_OUTBOUND-MATDOC_POSTED'.

      ls_outbound-matdoc_posted  = lv_value.
      PERFORM frm_display_migo USING ls_outbound-matdoc_posted ls_outbound-matyear_posted.
      CLEAR ok_code.
      RETURN.
    ENDIF.
  ENDIF.
  CASE ok_code.
    WHEN 'POSTGI'.
      PERFORM frm_post_gi_outbound_delivery.
    WHEN 'SORTUP'.
      PERFORM frm_sort_matdoc_up_generic USING 'matdoc_posted' 'posnr'
                                      CHANGING lt_outbound.
    WHEN 'SORTDOWN'.
      PERFORM frm_sort_matdoc_down_generic USING 'matdoc_posted' 'posnr'
                                      CHANGING lt_outbound.
    WHEN 'UNSORT'.
      PERFORM frm_get_outbound_delivery.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_3011  INPUT
MODULE exit_3011 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
*      CLEAR gv_sono.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3013  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3013 INPUT.
  CASE ok_code.
    WHEN 'POSTGI'.
      PERFORM frm_post_gi_outbound_delivery.
    WHEN 'SORTUP'.
      PERFORM frm_sort_matdoc_up_generic USING 'matdoc_posted' 'posnr'
                                      CHANGING lt_outbound.
    WHEN 'SORTDOWN'.
      PERFORM frm_sort_matdoc_down_generic USING 'matdoc_posted' 'posnr'
                                      CHANGING lt_outbound.
    WHEN 'UNSORT'.
      PERFORM frm_get_outbound_delivery.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_3013  INPUT
MODULE exit_3013 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
*      CLEAR gv_sono.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0302  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0302 INPUT.
  CASE ok_code.
    WHEN 'NEXT' OR ''.
      PERFORM frm_get_reservation_data.
      IF gv_valid_reser = abap_true AND gt_resb IS NOT INITIAL.
        CALL SCREEN 3021.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_302  INPUT
MODULE exit_302 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
*      CLEAR gv_rsnum.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3021  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3021 INPUT.
  IF sy-ucomm = 'PICK'.
    GET CURSOR FIELD lv_field VALUE lv_value.

    " Double click đúng vào field hiển thị Material Document
    IF lv_field = 'GS_RESB-MATDOC'.
      gs_resb-matdoc  = lv_value.
      PERFORM frm_display_migo USING gs_resb-matdoc gs_resb-matyear.
      CLEAR ok_code.
      RETURN.
    ENDIF.
  ENDIF.

  CASE ok_code.
    WHEN 'POSTGI'.
      PERFORM frm_post_gi_reservation.
    WHEN 'SORTUP'.
      PERFORM frm_sort_matdoc_up_generic USING 'matdoc' 'rspos'
                                      CHANGING gt_resb.
    WHEN 'SORTDOWN'.
      PERFORM frm_sort_matdoc_down_generic USING 'matdoc' 'rspos'
                                      CHANGING gt_resb.
    WHEN 'UNSORT'.
      PERFORM frm_get_reservation_data.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_3021  INPUT
MODULE exit_3021 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
*      CLEAR gv_rsnum.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0303  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0303 INPUT.
  GET CURSOR FIELD lv_field VALUE lv_value.
  IF sy-ucomm = 'PICK' AND lv_field = 'gv_matdoc_rev'.
    gv_matdoc_rev = lv_value.
  ENDIF.
  CASE ok_code.
    WHEN 'PICK'.
      PERFORM frm_display_migo USING gv_matdoc_rev gv_matyear_rev.
    WHEN 'REVERSE'.
      IF gv_vbeln IS INITIAL.
        MESSAGE 'Please enter Outbound Delivery Number !' TYPE 'S' DISPLAY LIKE 'E'.
        SET CURSOR FIELD 'gv_vbeln'.
        EXIT.
      ELSE.

        SUBMIT z_reverse_gi_program WITH p_vbeln = gv_vbeln AND RETURN.

        DATA lv_matdoc_return TYPE mblnr.
        IMPORT matdoc_rev = lv_matdoc_return
               flag_reverse_ok    = gv_flag_reverse
               FROM MEMORY ID 'ZGI_REVERSE_RESULT'.

        IF lv_matdoc_return IS NOT INITIAL.
          gv_matdoc_rev = lv_matdoc_return.
          CLEAR: lv_matdoc_return.
        ENDIF.

        IF gv_flag_reverse = 'X'.
          PERFORM clear_batch_serial_ob.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_303  INPUT
MODULE exit_303 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
      CLEAR: gv_vbeln, gv_matdoc_rev.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0304  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0304 INPUT.
  GET CURSOR FIELD lv_field VALUE lv_value.
  IF sy-ucomm = 'PICK' AND lv_field = 'GV_MATDOC_REV'.
    gv_matdoc_rev = lv_value.
  ENDIF.

  CASE ok_code.
    WHEN 'REVERSE'.
      IF gv_matdoc IS INITIAL.
        MESSAGE 'Please enter Material Document Number !' TYPE 'S' DISPLAY LIKE 'E'.
        SET CURSOR FIELD 'gv_matdoc'.
        EXIT.
      ELSE.
        PERFORM frm_reverse_gi_reservation USING gv_matdoc gv_matyear.
      ENDIF.
    WHEN ''.
      PERFORM frm_auto_fill_year.
    WHEN 'PICK'.
      PERFORM frm_display_migo USING gv_matdoc_rev gv_matyear_rev.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_304  INPUT
MODULE exit_304 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
      CLEAR: gv_matdoc, gv_matyear, gv_matdoc_rev.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.
  CASE ok_code.
    WHEN 'ENTR' OR ''.
      PERFORM pi_chosen.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0202  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0202 INPUT.
  GET CURSOR FIELD lv_field VALUE lv_value.

  IF sy-ucomm = 'PICK' AND lv_field = 'GV_MATDOC_REV'.
    gv_matdoc_rev = lv_value.
  ENDIF.

  CASE ok_code.
    WHEN 'ENTR' OR ''.
      PERFORM frm_auto_fill_year.
    WHEN 'REVGR'.
      IF gv_matdoc IS INITIAL.
        MESSAGE 'Please enter Material Document Number' TYPE 'S' DISPLAY LIKE 'E'.
        SET CURSOR FIELD 'gv_matdoc'.
        EXIT.
      ELSE.

        SUBMIT z_reverse_gr_program WITH p_matdoc = gv_matdoc
                                    WITH p_year = gv_matyear  AND RETURN.

        DATA: lv_matdoc_rev_return  TYPE mblnr,
              lv_matyear_rev_return TYPE mjahr.
        IMPORT matdoc_rev_return = lv_matdoc_rev_return
               matyear_rev_return = lv_matyear_rev_return
               flag_reverse_ok    = gv_flag_reverse
               FROM MEMORY ID 'ZGR_REVERSE_RESULT'.

        IF lv_matdoc_rev_return IS NOT INITIAL.
          gv_matdoc_rev = lv_matdoc_rev_return.
          CLEAR: lv_matdoc_rev_return.
        ENDIF.

        IF lv_matyear_rev_return IS NOT INITIAL.
          gv_matyear_rev = lv_matyear_rev_return.
          CLEAR: lv_matyear_rev_return.
        ENDIF.

        IF gv_flag_reverse = 'X'.
          PERFORM clear_batch_serial.
        ENDIF.

      ENDIF.

    WHEN 'PICK'.
      PERFORM frm_display_migo USING gv_matdoc_rev gv_matyear_rev.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_202  INPUT
MODULE exit_202 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
      CLEAR: gv_matdoc, gv_matyear, gv_matdoc_rev.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2010 INPUT.
  CASE ok_code.
    WHEN 'GET' OR ''.
      PERFORM frm_check_po_item.

      IF gv_valid_po = abap_false.
        EXIT.
      ENDIF.

      PERFORM frm_check_werks USING 'DL21'.

      IF gv_valid_werks = abap_false.
        EXIT.
      ENDIF.

      PERFORM frm_get_inbound_delivery.

      IF gv_valid_inbound = abap_false.
        EXIT.
      ENDIF.

      CALL SCREEN 2011.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_2010  INPUT
MODULE exit_2010 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
      CLEAR: gv_select, gv_pono.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_DL21_PONO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_dl21_pono INPUT.
  SELECT DISTINCT ebeln, matnr, werks, lgort
    FROM ekpo
    INTO TABLE @DATA(lt_po_search_dl21)
    WHERE werks = 'DL21'
    ORDER BY ebeln.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ebeln'
      dynpprog        = sy-repid " do ve program dang open
      dynpnr          = sy-dynnr " do ve screen dang open
      dynprofield     = 'gv_pono'
      value_org       = 'S'
    TABLES
      value_tab       = lt_po_search_dl21
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2020  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2020 INPUT.
  CASE ok_code.
    WHEN 'GET' OR ''.
      PERFORM frm_check_po_item.

      IF gv_valid_po = abap_false.
        EXIT.
      ENDIF.

      PERFORM frm_check_werks USING 'SG21'.

      IF gv_valid_werks = abap_false.
        EXIT.  " Không được vào CALL SCREEN 2011
      ENDIF.

      PERFORM frm_get_inbound_delivery.

      IF gv_valid_inbound = abap_false.
        EXIT.
      ENDIF.

      CALL SCREEN 2021.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_2020  INPUT
MODULE exit_2020 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
*      CLEAR: gv_pono, gv_select.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_SG21_PONO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_sg21_pono INPUT.
  SELECT DISTINCT ebeln, matnr, werks, lgort
   FROM ekpo
   INTO TABLE @DATA(lt_po_search_sg21)
   WHERE werks = 'SG21'
   ORDER BY ebeln.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ebeln'
      dynpprog        = sy-repid " do ve program dang open
      dynpnr          = sy-dynnr " do ve screen dang open
      dynprofield     = 'gv_pono'
      value_org       = 'S'
    TABLES
      value_tab       = lt_po_search_sg21
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2011  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2011 INPUT.

  IF sy-ucomm = 'PICK'.
    GET CURSOR FIELD lv_field VALUE lv_value.

    IF lv_field = 'LS_INBOUND-MATDOC_POSTED'.

      ls_inbound-matdoc_posted  = lv_value.
      PERFORM frm_display_migo USING ls_inbound-matdoc_posted ls_inbound-matyear_posted.
      CLEAR ok_code.
      RETURN.
    ENDIF.
  ENDIF.

  CASE ok_code.
    WHEN 'POSTGR'.
      PERFORM frm_post_gr.
    WHEN 'SORT_UP'.
*      PERFORM frm_sort_matdoc_up.
      PERFORM frm_sort_matdoc_up_generic USING 'matdoc_posted' 'posnr'
                                      CHANGING lt_inbound.
    WHEN 'SORT_DOWN'.
*      PERFORM frm_sort_matdoc_down.
      PERFORM frm_sort_matdoc_down_generic USING 'matdoc_posted' 'posnr'
                                      CHANGING lt_inbound.
    WHEN 'UNSORT'.
      PERFORM frm_get_inbound_delivery.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_2011  INPUT
MODULE exit_2011 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
*      CLEAR: gv_select, gv_pono.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TCTR_INBOU_DL21'. DO NOT CHANGE THIS LI
*&SPWIZARD: MODIFY TABLE
MODULE tctr_inbou_dl21_modify INPUT.
  MODIFY lt_inbound
    FROM ls_inbound
    INDEX tctr_inbou_dl21-current_line.
ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'TCTR_INBOU_DL21'. DO NOT CHANGE THIS LIN
*&SPWIZARD: MARK TABLE
MODULE tctr_inbou_dl21_mark INPUT.
  DATA: g_TCTR_INBOU_DL21_wa2 LIKE LINE OF lt_inbound.
  IF tctr_inbou_dl21-line_sel_mode = 1
  AND ls_inbound-sel = 'X'.
    LOOP AT lt_inbound INTO g_TCTR_INBOU_DL21_wa2
      WHERE sel = 'X'.
      g_TCTR_INBOU_DL21_wa2-sel = ''.
      MODIFY lt_inbound
        FROM g_TCTR_INBOU_DL21_wa2
        TRANSPORTING sel.
    ENDLOOP.
  ENDIF.
  MODIFY lt_inbound
    FROM ls_inbound
    INDEX tctr_inbou_dl21-current_line
    TRANSPORTING sel.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TCTR_INBOU_DL21'. DO NOT CHANGE THIS LI
*&SPWIZARD: PROCESS USER COMMAND
MODULE tctr_inbou_dl21_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TCTR_INBOU_DL21'
                              'LT_INBOUND'
                              'SEL'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  F4_DL21_CHARG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_dl21_charg INPUT.
*  TYPES: BEGIN OF zty_charg_f4,
*           charg TYPE charg_d,
*           matnr TYPE matnr,
*           werks TYPE werks_d,
*           lgort TYPE lgort_d,
*         END OF zty_charg_f4.
*
*  DATA: ls_line_no TYPE ty_inbound,
*        lt_f4      TYPE STANDARD TABLE OF zty_charg_f4,
*        ls_f4      TYPE zty_charg_f4.

  " 1. Lấy dòng hiện tại trong Table control
  READ TABLE lt_inbound INTO DATA(ls_line_no) INDEX tctr_inbou_dl21-current_line.

  DATA: lv_matnr_convert TYPE matnr.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input  = ls_line_no-matnr
    IMPORTING
      output = lv_matnr_convert.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  " 2. Lấy batch từ MCH1/MCHA — theo MATNR + WERKS người dùng nhập
  SELECT charg,
         matnr,
         werks,
         lgort
    FROM mchb
    INTO TABLE @DATA(lt_f4)
    WHERE matnr = @lv_matnr_convert
      AND werks = @ls_line_no-werks
      AND lgort = @ls_line_no-lgort
    ORDER BY charg.

  IF lt_f4 IS INITIAL.
    MESSAGE 'Can not found Batch !' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CHARG'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'LS_INBOUND-CHARG_IP'
      value_org       = 'S'
    TABLES
      value_tab       = lt_f4
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2021  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2021 INPUT.

  IF sy-ucomm = 'PICK'.
    GET CURSOR FIELD lv_field VALUE lv_value.
    IF lv_field = 'LS_INBOUND-MATDOC_POSTED'.
      ls_inbound-matdoc_posted  = lv_value.
      PERFORM frm_display_migo USING ls_inbound-matdoc_posted ls_inbound-matyear_posted.
      CLEAR ok_code.
      RETURN.
    ENDIF.
  ENDIF.

  CASE ok_code.
    WHEN 'POSTGR'.
      PERFORM frm_post_gr.
    WHEN 'SORT_UP'.
      PERFORM frm_sort_matdoc_up_generic USING 'matdoc_posted' 'posnr'
                                      CHANGING lt_inbound.
    WHEN 'SORT_DOWN'.
      PERFORM frm_sort_matdoc_down_generic USING 'matdoc_posted' 'posnr'
                                      CHANGING lt_inbound.
    WHEN 'UNSORT'.
      PERFORM frm_get_inbound_delivery.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_2021  INPUT
MODULE exit_2021 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
*      CLEAR: gv_pono, gv_select.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TCTR_INBOU_SG21'. DO NOT CHANGE THIS LI
*&SPWIZARD: MODIFY TABLE
MODULE tctr_inbou_sg21_modify INPUT.
  MODIFY lt_inbound
    FROM ls_inbound
    INDEX tctr_inbou_sg21-current_line.
ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'TCTR_INBOU_SG21'. DO NOT CHANGE THIS LIN
*&SPWIZARD: MARK TABLE
MODULE tctr_inbou_sg21_mark INPUT.
  DATA: g_TCTR_INBOU_SG21_wa2 LIKE LINE OF lt_inbound.
  IF tctr_inbou_sg21-line_sel_mode = 1
  AND ls_inbound-sel = 'X'.
    LOOP AT lt_inbound INTO g_TCTR_INBOU_SG21_wa2
      WHERE sel = 'X'.
      g_TCTR_INBOU_SG21_wa2-sel = ''.
      MODIFY lt_inbound
        FROM g_TCTR_INBOU_SG21_wa2
        TRANSPORTING sel.
    ENDLOOP.
  ENDIF.
  MODIFY lt_inbound
    FROM ls_inbound
    INDEX tctr_inbou_sg21-current_line
    TRANSPORTING sel.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TCTR_INBOU_SG21'. DO NOT CHANGE THIS LI
*&SPWIZARD: PROCESS USER COMMAND
MODULE tctr_inbou_sg21_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TCTR_INBOU_SG21'
                              'LT_INBOUND'
                              'SEL'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_SG21_CHARG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_sg21_charg INPUT.
  " 1. Lấy dòng hiện tại trong Table control
  READ TABLE lt_inbound INTO DATA(ls_line_sg21) INDEX tctr_inbou_sg21-current_line.

  DATA: lv_matnr_convert_sg21 TYPE matnr.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input  = ls_line_sg21-matnr
    IMPORTING
      output = lv_matnr_convert_sg21.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  " 2. Lấy batch từ MCH1/MCHA — theo MATNR + WERKS người dùng nhập
  SELECT charg,
         matnr,
         werks,
         lgort
    FROM mchb
    INTO TABLE @DATA(lt_f4_sg21)
    WHERE matnr = @lv_matnr_convert_sg21
      AND werks = @ls_line_sg21-werks
      AND lgort = @ls_line_sg21-lgort
    ORDER BY charg.

  IF lt_f4_sg21 IS INITIAL.
    MESSAGE 'Batch not found!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CHARG'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'LS_INBOUND-CHARG_IP'
      value_org       = 'S'
    TABLES
      value_tab       = lt_f4_sg21
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_RESERVATION'. DO NOT CHANGE THIS LIN
*&SPWIZARD: MODIFY TABLE
MODULE tc_reservation_modify INPUT.
  MODIFY gt_resb
    FROM gs_resb
    INDEX tc_reservation-current_line.
ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'TC_RESERVATION'. DO NOT CHANGE THIS LINE
*&SPWIZARD: MARK TABLE
MODULE tc_reservation_mark INPUT.
  DATA: g_TC_RESERVATION_wa2 LIKE LINE OF gt_resb.
  IF tc_reservation-line_sel_mode = 1
  AND gs_resb-sel = 'X'.
    LOOP AT gt_resb INTO g_TC_RESERVATION_wa2
      WHERE sel = 'X'.
      g_TC_RESERVATION_wa2-sel = ''.
      MODIFY gt_resb
        FROM g_TC_RESERVATION_wa2
        TRANSPORTING sel.
    ENDLOOP.
  ENDIF.
  MODIFY gt_resb
    FROM gs_resb
    INDEX tc_reservation-current_line
    TRANSPORTING sel.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_RESERVATION'. DO NOT CHANGE THIS LIN
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc_reservation_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_RESERVATION'
                              'GT_RESB'
                              'SEL'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0401  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0401 INPUT.
  CASE ok_code.
    WHEN 'ENTR' OR ''.
      PERFORM check_inven_doc.
      IF gv_valid_iblnr = abap_false.
        EXIT.
      ENDIF.
      CALL SCREEN 0402.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_401  INPUT
MODULE exit_401 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
      CLEAR: gv_iblnr, gv_zeili, gv_matnr, gv_werks_pi, gv_lgort_pi, gv_menge, gv_sernr_pi, gv_xnull.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0402  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0402 INPUT.
  CASE ok_code.
    WHEN 'SAVE'.
      PERFORM post_count_quantity.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_402  INPUT
MODULE exit_402 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
      CLEAR: gv_iblnr.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0403  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0403 INPUT.
  CASE ok_code.
    WHEN 'ENTR' OR ''.
      PERFORM get_inven_doc.
      IF gv_valid_iblnr = abap_false.
        EXIT.
      ENDIF.
      CALL SCREEN 0404.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_403  INPUT
MODULE exit_403 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
      CLEAR: gv_select, gv_iblnr.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_OUT_DL21'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE tc_out_dl21_modify INPUT.
  MODIFY lt_outbound
    FROM ls_outbound
    INDEX tc_out_dl21-current_line.
ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'TC_OUT_DL21'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE tc_out_dl21_mark INPUT.
  DATA: g_TC_OUT_DL21_wa2 LIKE LINE OF lt_outbound.
  IF tc_out_dl21-line_sel_mode = 1
  AND ls_outbound-sel = 'X'.
    LOOP AT lt_outbound INTO g_TC_OUT_DL21_wa2
      WHERE sel = 'X'.
      g_TC_OUT_DL21_wa2-sel = ''.
      MODIFY lt_outbound
        FROM g_TC_OUT_DL21_wa2
        TRANSPORTING sel.
    ENDLOOP.
  ENDIF.
  MODIFY lt_outbound
    FROM ls_outbound
    INDEX tc_out_dl21-current_line
    TRANSPORTING sel.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_OUT_DL21'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc_out_dl21_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_OUT_DL21'
                              'LT_OUTBOUND'
                              'SEL'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_OUT_SG21'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE tc_out_sg21_modify INPUT.
  MODIFY lt_outbound
    FROM ls_outbound
    INDEX tc_out_sg21-current_line.
ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'TC_OUT_SG21'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE tc_out_sg21_mark INPUT.
  DATA: g_TC_OUT_SG21_wa2 LIKE LINE OF lt_outbound.
  IF tc_out_sg21-line_sel_mode = 1
  AND ls_outbound-sel = 'X'.
    LOOP AT lt_outbound INTO g_TC_OUT_SG21_wa2
      WHERE sel = 'X'.
      g_TC_OUT_SG21_wa2-sel = ''.
      MODIFY lt_outbound
        FROM g_TC_OUT_SG21_wa2
        TRANSPORTING sel.
    ENDLOOP.
  ENDIF.
  MODIFY lt_outbound
    FROM ls_outbound
    INDEX tc_out_sg21-current_line
    TRANSPORTING sel.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_OUT_SG21'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc_out_sg21_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_OUT_SG21'
                              'LT_OUTBOUND'
                              'SEL'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_IBLNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_iblnr INPUT.
  SELECT iblnr, zeili, matnr, werks, lgort
    FROM iseg
    INTO TABLE @DATA(lt_iblnr_search)
    WHERE werks IN ('DL21', 'SG21')
    ORDER BY iblnr, zeili.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'iblnr'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'gv_iblnr'
      value_org       = 'S'
    TABLES
      value_tab       = lt_iblnr_search
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_ZEILI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_zeili INPUT.
  SELECT iblnr, zeili, matnr, werks, lgort
    FROM iseg
    INTO TABLE @DATA(lt_zeili_search)
    WHERE werks IN ('DL21', 'SG21')
    ORDER BY iblnr, zeili.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'zeili'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'gv_zeili'
      value_org       = 'S'
    TABLES
      value_tab       = lt_zeili_search
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0404  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0404 INPUT.
  CASE ok_code.
    WHEN 'SAVE'.
      PERFORM create_rec_inven_doc.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_404  INPUT
MODULE exit_404 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'BACK1'.
      CLEAR: gv_select, gv_iblnr, gv_zeili, gv_matnr, gv_werks_pi, gv_lgort_pi, gv_menge, gv_sernr_pi, gv_xnull.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT' OR 'CANC' OR 'LOGOFF'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_PI_RECNT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE tc_pi_recnt_modify INPUT.
  MODIFY lt_iseg
    FROM ls_iseg
    INDEX tc_pi_recnt-current_line.
ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'TC_PI_RECNT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE tc_pi_recnt_mark INPUT.
  DATA: g_TC_PI_RECNT_wa2 LIKE LINE OF lt_iseg.
  IF tc_pi_recnt-line_sel_mode = 1
  AND ls_iseg-sel = 'X'.
    LOOP AT lt_iseg INTO g_TC_PI_RECNT_wa2
      WHERE sel = 'X'.
      g_TC_PI_RECNT_wa2-sel = ''.
      MODIFY lt_iseg
        FROM g_TC_PI_RECNT_wa2
        TRANSPORTING sel.
    ENDLOOP.
  ENDIF.
  MODIFY lt_iseg
    FROM ls_iseg
    INDEX tc_pi_recnt-current_line
    TRANSPORTING sel.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_PI_RECNT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc_pi_recnt_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_PI_RECNT'
                              'LT_ISEG'
                              'SEL'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_DL21_SONO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_dl21_sono INPUT.
  SELECT DISTINCT vbeln, matnr, werks
    FROM vbap
    INTO TABLE @DATA(lt_so_search)
    WHERE werks = 'DL21'
    ORDER BY vbeln.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VBELN'
      dynpprog        = sy-repid " do ve program dang open
      dynpnr          = sy-dynnr " do ve screen dang open
      dynprofield     = 'gv_sono'
      value_org       = 'S'
    TABLES
      value_tab       = lt_so_search
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_SG21_SONO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_sg21_sono INPUT.
  SELECT DISTINCT vbeln, matnr, werks
    FROM vbap
    INTO TABLE @DATA(lt_so_sg21)
    WHERE werks = 'SG21'
    ORDER BY vbeln.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VBELN'
      dynpprog        = sy-repid " do ve program dang open
      dynpnr          = sy-dynnr " do ve screen dang open
      dynprofield     = 'gv_sono'
      value_org       = 'S'
    TABLES
      value_tab       = lt_so_sg21
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_OB_DL21_CHARG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_ob_dl21_charg INPUT.
  TYPES: BEGIN OF zty_ob_charg_f4,
           charg TYPE charg_d,
           matnr TYPE matnr,
           werks TYPE werks_d,
           lgort TYPE lgort_d,
         END OF zty_ob_charg_f4.

  DATA: ls_line     TYPE ty_outbound,
        lt_f4_charg TYPE STANDARD TABLE OF zty_ob_charg_f4,
        ls_f4_charg TYPE zty_ob_charg_f4.

  " 1. Lấy dòng hiện tại trong Table control
  READ TABLE lt_outbound INTO ls_line INDEX tc_out_dl21-current_line.

  DATA: lv_matnr_ob TYPE matnr.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input  = ls_line-matnr
    IMPORTING
      output = lv_matnr_ob.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  " 2. Lấy batch từ MCH1/MCHA — theo MATNR + WERKS người dùng nhập
  SELECT charg,
         matnr,
         werks,
         lgort
    FROM mchb
    INTO TABLE @lt_f4_charg
    WHERE matnr = @lv_matnr_ob
      AND werks = @ls_line-werks
      AND lgort = @ls_line-lgort
    ORDER BY charg.

  IF lt_f4_charg IS INITIAL.
    MESSAGE 'Không tìm thấy Batch phù hợp!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CHARG'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'LS_OUTBOUND-CHARG_IP'
      value_org       = 'S'
    TABLES
      value_tab       = lt_f4_charg
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_OB_SG21_CHARG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_ob_sg21_charg INPUT.
  TYPES: BEGIN OF zty_charg_sg21,
           charg TYPE charg_d,
           matnr TYPE matnr,
           werks TYPE werks_d,
           lgort TYPE lgort_d,
         END OF zty_charg_sg21.

  DATA: ls_line_ob_sg21 TYPE ty_outbound,
        lt_sg21_charg   TYPE STANDARD TABLE OF zty_charg_sg21,
        ls_sg21_charg   TYPE zty_charg_sg21.

  " 1. Lấy dòng hiện tại trong Table control
  READ TABLE lt_outbound INTO ls_line_ob_sg21 INDEX tc_out_sg21-current_line.

  DATA: lv_matnr_ob_sg21 TYPE matnr.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input  = ls_line_ob_sg21-matnr
    IMPORTING
      output = lv_matnr_ob_sg21.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  " 2. Lấy batch từ MCH1/MCHA — theo MATNR + WERKS người dùng nhập
  SELECT charg,
         matnr,
         werks,
         lgort
    FROM mchb
    INTO TABLE @lt_sg21_charg
    WHERE matnr = @lv_matnr_ob_sg21
      AND werks = @ls_line_ob_sg21-werks
      AND lgort = @ls_line_ob_sg21-lgort
    ORDER BY charg.

  IF lt_sg21_charg IS INITIAL.
    MESSAGE 'Batch not found !' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CHARG'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'LS_OUTBOUND-CHARG_IP'
      value_org       = 'S'
    TABLES
      value_tab       = lt_sg21_charg
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_RSNUM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_rsnum INPUT.
  SELECT DISTINCT rsnum, matnr, werks, lgort
    FROM resb
    INTO TABLE @DATA(lt_rsnum)
    WHERE werks IN ('SG21', 'DL21')
    ORDER BY rsnum.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'rsnum'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'gv_rsnum_rep'
      value_org       = 'S'
    TABLES
      value_tab       = lt_rsnum
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_COUNT_PI'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE tc_count_pi_modify INPUT.
  MODIFY lt_iseg
    FROM ls_iseg
    INDEX tc_count_pi-current_line.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_COUNT_PI'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc_count_pi_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_COUNT_PI'
                              'LT_ISEG'
                              ' '
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_OBNO  INPUT
MODULE f4_obno INPUT.
  SELECT DISTINCT vbeln, matnr, werks, lgort
    FROM lips
    INTO TABLE @DATA(lt_ob_search)
    WHERE werks IN ('DL21', 'SG21')
    AND pstyv = 'TAN'
    ORDER BY vbeln.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'vbeln'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'gv_vbeln'
      value_org       = 'S'
    TABLES
      value_tab       = lt_ob_search
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMODULE.
