PROCESS BEFORE OUTPUT.
  MODULE status_0402.
*&SPWIZARD: PBO FLOW LOGIC FOR TABLECONTROL 'TC_COUNT_PI'
  MODULE tc_count_pi_change_tc_attr.
*&SPWIZARD: MODULE TC_COUNT_PI_CHANGE_COL_ATTR.
  LOOP AT   lt_iseg
       INTO ls_iseg
       WITH CONTROL tc_count_pi
       CURSOR tc_count_pi-current_line.
    MODULE tc_count_pi_get_lines.
*&SPWIZARD:   MODULE TC_COUNT_PI_CHANGE_FIELD_ATTR
  ENDLOOP.

PROCESS AFTER INPUT.
*&SPWIZARD: PAI FLOW LOGIC FOR TABLECONTROL 'TC_COUNT_PI'
  LOOP AT lt_iseg.
    CHAIN.
      FIELD ls_iseg-iblnr.
      FIELD ls_iseg-gjahr.
      FIELD ls_iseg-zeili.
      FIELD ls_iseg-matnr.
      FIELD ls_iseg-werks.
      FIELD ls_iseg-lgort.
      FIELD ls_iseg-charg.
      FIELD ls_iseg-sernr.
      FIELD ls_iseg-bstar.
      FIELD ls_iseg-menge_disp.
      FIELD ls_iseg-xnull.
      MODULE tc_count_pi_modify ON CHAIN-REQUEST.
    ENDCHAIN.
  ENDLOOP.
  MODULE tc_count_pi_user_command.
*&SPWIZARD: MODULE TC_COUNT_PI_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE TC_COUNT_PI_CHANGE_COL_ATTR.


  MODULE exit_402 AT EXIT-COMMAND.
  MODULE user_command_0402.
