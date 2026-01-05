PROCESS BEFORE OUTPUT.
  MODULE status_2021.
*&SPWIZARD: PBO FLOW LOGIC FOR TABLECONTROL 'TCTR_INBOU_SG21'
  MODULE tctr_inbou_sg21_change_tc_attr.
*&SPWIZARD: MODULE TCTR_INBOU_SG21_CHANGE_COL_ATTR.
  LOOP AT   lt_inbound
       INTO ls_inbound
       WITH CONTROL tctr_inbou_sg21
       CURSOR tctr_inbou_sg21-current_line.
    MODULE tctr_inbou_sg21_get_lines.
*&SPWIZARD:   MODULE TCTR_INBOU_SG21_CHANGE_FIELD_ATTR
  ENDLOOP.



PROCESS AFTER INPUT.
*&SPWIZARD: PAI FLOW LOGIC FOR TABLECONTROL 'TCTR_INBOU_SG21'
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
      MODULE tctr_inbou_sg21_modify ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD ls_inbound-sel
      MODULE tctr_inbou_sg21_mark ON REQUEST.
  ENDLOOP.
  MODULE tctr_inbou_sg21_user_command.
*&SPWIZARD: MODULE TCTR_INBOU_SG21_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE TCTR_INBOU_SG21_CHANGE_COL_ATTR.

  MODULE exit_2021 AT EXIT-COMMAND.
  MODULE user_command_2021.

PROCESS ON VALUE-REQUEST.
  FIELD ls_inbound-charg_ip MODULE f4_sg21_charg.
