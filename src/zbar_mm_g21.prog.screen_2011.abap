PROCESS BEFORE OUTPUT.
  MODULE status_2011.
*&SPWIZARD: PBO FLOW LOGIC FOR TABLECONTROL 'TCTR_INBOU_DL21'
  MODULE tctr_inbou_dl21_change_tc_attr.
*&SPWIZARD: MODULE TCTR_INBOU_DL21_CHANGE_COL_ATTR.
  LOOP AT   lt_inbound
       INTO ls_inbound
       WITH CONTROL tctr_inbou_dl21
       CURSOR tctr_inbou_dl21-current_line.
    MODULE tctr_inbou_dl21_get_lines.
*&SPWIZARD:   MODULE TCTR_INBOU_DL21_CHANGE_FIELD_ATTR
  ENDLOOP.


PROCESS AFTER INPUT.
*&SPWIZARD: PAI FLOW LOGIC FOR TABLECONTROL 'TCTR_INBOU_DL21'
  LOOP AT lt_inbound.
    CHAIN.
      FIELD ls_inbound-vbeln.
      FIELD ls_inbound-posnr.
      FIELD ls_inbound-matnr.
      FIELD ls_inbound-lfimg.
      FIELD ls_inbound-vrkme.
      FIELD ls_inbound-werks.
      FIELD ls_inbound-lgort.
      FIELD ls_inbound-charg_ip.
      FIELD ls_inbound-sernr_ip.
      FIELD ls_inbound-matdoc_posted.
      FIELD ls_inbound-matyear_disp.
      MODULE tctr_inbou_dl21_modify ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD ls_inbound-sel
      MODULE tctr_inbou_dl21_mark ON REQUEST.
  ENDLOOP.
  MODULE tctr_inbou_dl21_user_command.

  MODULE exit_2011 AT EXIT-COMMAND.
  MODULE user_command_2011.

PROCESS ON VALUE-REQUEST.
  FIELD ls_inbound-charg_ip MODULE f4_dl21_charg.
