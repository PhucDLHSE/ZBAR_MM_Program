*&---------------------------------------------------------------------*
*& Include          ZBAR_MM_G21_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'STATUS_0200'.
  SET TITLEBAR 'TITLE_0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0201 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0201 OUTPUT.
  SET PF-STATUS 'STATUS_0201'.
  SET TITLEBAR 'TITLE_0201'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS 'STATUS_0300'.
  SET TITLEBAR 'TITLE_0300'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0301 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0301 OUTPUT.
  SET PF-STATUS 'STATUS_0301'.
  SET TITLEBAR 'TITLE_0301'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_3010 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_3010 OUTPUT.
  SET PF-STATUS 'STATUS_03010'.
  SET TITLEBAR 'TITLE_03010'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_3012 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_3012 OUTPUT.
  SET PF-STATUS 'STATUS_03012'.
  SET TITLEBAR 'TITLE_03012'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_3011 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_3011 OUTPUT.
  SET PF-STATUS 'STATUS_03011'.
  SET TITLEBAR 'TITLE_03011'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_3013 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_3013 OUTPUT.
  SET PF-STATUS 'STATUS_03013'.
  SET TITLEBAR 'TITLE_03013'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0302 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0302 OUTPUT.
  SET PF-STATUS 'STATUS_0302'.
  SET TITLEBAR 'TITLE_0302'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_3021 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_3021 OUTPUT.
  SET PF-STATUS 'STATUS_03021'.
  SET TITLEBAR 'TITLE_03021' WITH gv_rsnum.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0303 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0303 OUTPUT.
  SET PF-STATUS 'STATUS_0303'.
  SET TITLEBAR 'TITLE_0303'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_3031 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_3031 OUTPUT.
  SET PF-STATUS 'STATUS_3031'.
  SET TITLEBAR 'TITLE_3031'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0304 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0304 OUTPUT.
  SET PF-STATUS 'STATUS_0304'.
  SET TITLEBAR 'TITLE_0304'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_3041 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_3041 OUTPUT.
  SET PF-STATUS 'STATUS_03041'.
  SET TITLEBAR 'TITLE_03041'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0400 OUTPUT.
  SET PF-STATUS 'STATUS_0400'.
  SET TITLEBAR 'TITLE_0400'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0202 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0202 OUTPUT.
  SET PF-STATUS 'STATUS_0202'.
  SET TITLEBAR 'TITLE_0202'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_2010 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_2010 OUTPUT.
  SET PF-STATUS 'STATUS_2010'.
  SET TITLEBAR 'TITLE_2010'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_2020 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_2020 OUTPUT.
  SET PF-STATUS 'STATUS_2020'.
  SET TITLEBAR 'TITLE_2020'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_2011 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_2011 OUTPUT.
  SET PF-STATUS 'STATUS_2011'.
  SET TITLEBAR 'TITLE_2011'.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TCTR_INBOU_DL21'. DO NOT CHANGE THIS L
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tctr_inbou_dl21_change_tc_attr OUTPUT.
  DESCRIBE TABLE lt_inbound LINES tctr_inbou_dl21-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TCTR_INBOU_DL21'. DO NOT CHANGE THIS L
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tctr_inbou_dl21_get_lines OUTPUT.

  IF ls_inbound-wbsta = 'C'. "disable batch, serial for item posted
    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF ls_inbound-wbsta = 'C'.

    "--- Batch
    IF ls_inbound-charg IS NOT INITIAL.
      ls_inbound-charg_ip = ls_inbound-charg.
    ENDIF.


*    "--- Serial
    DATA(lv_matnr_int) = ls_inbound-matnr.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = ls_inbound-matnr
      IMPORTING
        output = lv_matnr_int.
*
    DATA(lv_vbeln_dl21) = ls_inbound-vbeln.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_inbound-vbeln
      IMPORTING
        output = lv_vbeln_dl21.
*
    SELECT SINGLE sernr
      INTO @ls_inbound-sernr_ip
      FROM equi
      WHERE matnr = @lv_matnr_int
        AND charge = @ls_inbound-charg.

    CLEAR: ls_inbound-matdoc_posted,
           ls_inbound-matyear_posted.

    SELECT SINGLE m~mblnr, m~mjahr
      FROM mseg AS m
      INNER JOIN mkpf AS k ON m~mblnr = k~mblnr AND m~mjahr = k~mjahr
      INTO (@ls_inbound-matdoc_posted, @ls_inbound-matyear_posted)
      WHERE m~vbeln_im = @lv_vbeln_dl21
        AND m~vbelp_im = @ls_inbound-posnr
        AND m~shkzg = 'S'
        AND m~mblnr NOT IN ( SELECT smbln FROM mseg WHERE shkzg = 'H' AND smbln IS NOT NULL ).


    ls_inbound-matyear_disp = ls_inbound-matyear_posted.



    MODIFY lt_inbound FROM ls_inbound INDEX tctr_inbou_dl21-current_line.
  ENDIF.

  g_tctr_inbou_dl21_lines = sy-loopc.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_2021 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_2021 OUTPUT.
  SET PF-STATUS 'STATUS_2021'.
  SET TITLEBAR 'TITLE_2021'.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TCTR_INBOU_SG21'. DO NOT CHANGE THIS L
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tctr_inbou_sg21_change_tc_attr OUTPUT.
  DESCRIBE TABLE lt_inbound LINES tctr_inbou_sg21-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TCTR_INBOU_SG21'. DO NOT CHANGE THIS L
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tctr_inbou_sg21_get_lines OUTPUT.

  IF ls_inbound-wbsta = 'C'. "disable batch, serial for item posted
    LOOP AT SCREEN.
      IF screen-group1 = 'G2'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF ls_inbound-wbsta = 'C'.

    "--- Batch
    IF ls_inbound-charg IS NOT INITIAL.
      ls_inbound-charg_ip = ls_inbound-charg.
    ENDIF.

    "--- Serial
    DATA(lv_matnr_sg21) = ls_inbound-matnr.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = ls_inbound-matnr
      IMPORTING
        output = lv_matnr_sg21.

    DATA(lv_vbeln_sg21) = ls_inbound-vbeln.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_inbound-vbeln
      IMPORTING
        output = lv_vbeln_sg21.

    SELECT SINGLE sernr
      INTO @ls_inbound-sernr_ip
      FROM equi
      WHERE matnr = @lv_matnr_sg21
        AND charge = @ls_inbound-charg.

    CLEAR: ls_inbound-matdoc_posted,
           ls_inbound-matyear_posted.

    SELECT SINGLE m~mblnr, m~mjahr
      FROM mseg AS m
      INNER JOIN mkpf AS k ON m~mblnr = k~mblnr AND m~mjahr = k~mjahr
      INTO (@ls_inbound-matdoc_posted, @ls_inbound-matyear_posted)
      WHERE m~vbeln_im = @lv_vbeln_sg21
        AND m~vbelp_im = @ls_inbound-posnr
        AND m~shkzg = 'S'
        AND m~mblnr NOT IN ( SELECT smbln FROM mseg WHERE shkzg = 'H' AND smbln IS NOT NULL ).

    ls_inbound-matyear_disp = ls_inbound-matyear_posted.

    MODIFY lt_inbound FROM ls_inbound INDEX tctr_inbou_sg21-current_line.

  ENDIF.
  g_tctr_inbou_sg21_lines = sy-loopc.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_RESERVATION'. DO NOT CHANGE THIS LI
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_reservation_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_resb LINES tc_reservation-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_RESERVATION'. DO NOT CHANGE THIS LI
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_reservation_get_lines OUTPUT.
  IF gs_resb-kzear = 'X'.

*    DATA(lv_rsnum) = gs_resb-rsnum.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        input  = gs_resb-rsnum
*      IMPORTING
*        output = lv_rsnum.
    SELECT SINGLE m~mblnr, m~mjahr
      FROM mseg AS m
      INNER JOIN mkpf AS k ON m~mblnr = k~mblnr AND m~mjahr = k~mjahr
      INTO (@gs_resb-matdoc, @gs_resb-matyear)
      WHERE m~rsnum = @gs_resb-rsnum
        AND m~rspos = @gs_resb-rspos
        AND m~shkzg = 'H'
        AND m~mblnr NOT IN ( SELECT smbln FROM mseg WHERE shkzg = 'S' AND smbln IS NOT NULL ).


    gs_resb-matyear_disp = gs_resb-matyear.

    MODIFY gt_resb FROM gs_resb INDEX tc_reservation-current_line.

  ENDIF.
  g_tc_reservation_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0401 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0401 OUTPUT.
  SET PF-STATUS 'STATUS_0401'.
  SET TITLEBAR 'TITLE_0401'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISABLE_QUANTITY OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE disable_quantity OUTPUT.
  IF gv_xnull = 'X'. "disable batch, serial for item posted
    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0402 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0402 OUTPUT.
  SET PF-STATUS 'STATUS_0402'.
  SET TITLEBAR 'TITLE_0402'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0403 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0403 OUTPUT.
  SET PF-STATUS 'STATUS_0403'.
  SET TITLEBAR 'TITLE_0403'.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_OUT_DL21'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_out_dl21_change_tc_attr OUTPUT.
  DESCRIBE TABLE lt_outbound LINES tc_out_dl21-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_OUT_DL21'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_out_dl21_get_lines OUTPUT.

  IF ls_outbound-wbsta = 'C'. "disable batch, serial for item posted
    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF ls_outbound-wbsta = 'C'.

    "--- Batch
    IF ls_outbound-charg IS NOT INITIAL.
      ls_outbound-charg_ip = ls_outbound-charg.
    ENDIF.

    "--- Serial
    DATA(lv_matnr_dl21_out) = ls_outbound-matnr.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = ls_outbound-matnr
      IMPORTING
        output = lv_matnr_dl21_out.

    DATA(lv_vbeln_dl21_out) = ls_outbound-vbeln.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_outbound-vbeln
      IMPORTING
        output = lv_vbeln_dl21_out.

    SELECT SINGLE sernr
      INTO @ls_outbound-sernr_ip
      FROM equi
      WHERE matnr = @lv_matnr_dl21_out
        AND charge = @ls_outbound-charg.

    CLEAR: ls_outbound-matdoc_posted,
           ls_outbound-matyear_posted.

    SELECT SINGLE m~mblnr, m~mjahr
      FROM mseg AS m
      INNER JOIN mkpf AS k ON m~mblnr = k~mblnr AND m~mjahr = k~mjahr
      INTO (@ls_outbound-matdoc_posted, @ls_outbound-matyear_posted)
      WHERE m~vbeln_im = @lv_vbeln_dl21_out
        AND m~vbelp_im = @ls_outbound-posnr
        AND m~shkzg = 'H'
        AND m~mblnr NOT IN ( SELECT smbln FROM mseg WHERE shkzg = 'S' AND smbln IS NOT NULL ).


    ls_outbound-matyear_disp = ls_outbound-matyear_posted.

    MODIFY lt_outbound FROM ls_outbound INDEX tc_out_dl21-current_line.
  ENDIF.
  g_tc_out_dl21_lines = sy-loopc.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_OUT_SG21'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_out_sg21_change_tc_attr OUTPUT.
  DESCRIBE TABLE lt_outbound LINES tc_out_sg21-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_OUT_SG21'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_out_sg21_get_lines OUTPUT.
  IF ls_outbound-wbsta = 'C'. "disable batch, serial for item posted
    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF ls_outbound-wbsta = 'C'.

    "--- Batch
    IF ls_outbound-charg IS NOT INITIAL.
      ls_outbound-charg_ip = ls_outbound-charg.
    ENDIF.

    "--- Serial
    DATA(lv_matnr_sg21_out) = ls_outbound-matnr.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = ls_outbound-matnr
      IMPORTING
        output = lv_matnr_sg21_out.

    DATA(lv_vbeln_sg21_out) = ls_outbound-vbeln.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_outbound-vbeln
      IMPORTING
        output = lv_vbeln_sg21_out.

    SELECT SINGLE sernr
      INTO @ls_outbound-sernr_ip
      FROM equi
      WHERE matnr = @lv_matnr_sg21_out
        AND charge = @ls_outbound-charg.

    CLEAR: ls_outbound-matdoc_posted,
           ls_outbound-matyear_posted.

    SELECT SINGLE m~mblnr, m~mjahr
      FROM mseg AS m
      INNER JOIN mkpf AS k ON m~mblnr = k~mblnr AND m~mjahr = k~mjahr
      INTO (@ls_outbound-matdoc_posted, @ls_outbound-matyear_posted)
      WHERE m~vbeln_im = @lv_vbeln_sg21_out
        AND m~vbelp_im = @ls_outbound-posnr
        AND m~shkzg = 'H'
        AND m~mblnr NOT IN ( SELECT smbln FROM mseg WHERE shkzg = 'S' AND smbln IS NOT NULL ).


    ls_outbound-matyear_disp = ls_outbound-matyear_posted.

    MODIFY lt_outbound FROM ls_outbound INDEX tc_out_sg21-current_line.
  ENDIF.
  g_tc_out_sg21_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0404 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0404 OUTPUT.
  SET PF-STATUS 'STATUS_0404'.
  SET TITLEBAR 'TITLE_0404'.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_PI_RECNT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_pi_recnt_change_tc_attr OUTPUT.
  DESCRIBE TABLE lt_iseg LINES tc_pi_recnt-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_PI_RECNT'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_pi_recnt_get_lines OUTPUT.
  g_tc_pi_recnt_lines = sy-loopc.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_COUNT_PI'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_count_pi_change_tc_attr OUTPUT.
  DESCRIBE TABLE lt_iseg LINES tc_count_pi-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_COUNT_PI'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_count_pi_get_lines OUTPUT.
  g_tc_count_pi_lines = sy-loopc.
ENDMODULE.
