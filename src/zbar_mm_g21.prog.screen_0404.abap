PROCESS BEFORE OUTPUT.
*&SPWIZARD: PBO FLOW LOGIC FOR TABLECONTROL 'TC_PI_RECNT'
  MODULE tc_pi_recnt_change_tc_attr.
*&SPWIZARD: MODULE TC_PI_RECNT_CHANGE_COL_ATTR.
  LOOP AT   lt_iseg
       INTO ls_iseg
       WITH CONTROL tc_pi_recnt
       CURSOR tc_pi_recnt-current_line.
    MODULE tc_pi_recnt_get_lines.
*&SPWIZARD:   MODULE TC_PI_RECNT_CHANGE_FIELD_ATTR
  ENDLOOP.

  MODULE status_0404.

PROCESS AFTER INPUT.
*&SPWIZARD: PAI FLOW LOGIC FOR TABLECONTROL 'TC_PI_RECNT'
  LOOP AT lt_iseg.
    CHAIN.
      FIELD ls_iseg-iblnr.
      FIELD ls_iseg-gjahr.
      FIELD ls_iseg-zeili.
      FIELD ls_iseg-matnr.
      FIELD ls_iseg-charg.
      FIELD ls_iseg-bstar.
      FIELD ls_iseg-diff_disp.
      FIELD ls_iseg-meins.
      MODULE tc_pi_recnt_modify ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD ls_iseg-sel
      MODULE tc_pi_recnt_mark ON REQUEST.
  ENDLOOP.
  MODULE tc_pi_recnt_user_command.
*&SPWIZARD: MODULE TC_PI_RECNT_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE TC_PI_RECNT_CHANGE_COL_ATTR.
  MODULE exit_404 AT EXIT-COMMAND.
  MODULE user_command_0404.
