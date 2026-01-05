PROCESS BEFORE OUTPUT.
*&SPWIZARD: PBO FLOW LOGIC FOR TABLECONTROL 'TC_OUT_DL21'
  MODULE tc_out_dl21_change_tc_attr.
*&SPWIZARD: MODULE TC_OUT_DL21_CHANGE_COL_ATTR.
  LOOP AT   lt_outbound
       INTO ls_outbound
       WITH CONTROL tc_out_dl21
       CURSOR tc_out_dl21-current_line.
    MODULE tc_out_dl21_get_lines.
*&SPWIZARD:   MODULE TC_OUT_DL21_CHANGE_FIELD_ATTR
  ENDLOOP.

  MODULE status_3011.
*
PROCESS AFTER INPUT.
*&SPWIZARD: PAI FLOW LOGIC FOR TABLECONTROL 'TC_OUT_DL21'
  LOOP AT lt_outbound.
    CHAIN.
      FIELD ls_outbound-vbeln.
      FIELD ls_outbound-posnr.
      FIELD ls_outbound-matnr.
      FIELD ls_outbound-lfimg.
      FIELD ls_outbound-vrkme.
      FIELD ls_outbound-werks.
      FIELD ls_outbound-lgort.
      FIELD ls_outbound-charg_ip.
      FIELD ls_outbound-sernr_ip.
      FIELD ls_outbound-matdoc_posted.
      FIELD ls_outbound-matyear_disp.
      MODULE tc_out_dl21_modify ON CHAIN-REQUEST.
    ENDCHAIN.
  ENDLOOP.
  MODULE tc_out_dl21_user_command.
*&SPWIZARD: MODULE TC_OUT_DL21_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE TC_OUT_DL21_CHANGE_COL_ATTR.
  MODULE exit_3011 AT EXIT-COMMAND.
  MODULE user_command_3011.


PROCESS ON VALUE-REQUEST.
  FIELD ls_outbound-charg_ip MODULE f4_ob_dl21_charg.
