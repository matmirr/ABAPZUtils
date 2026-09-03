@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Conteo de Variantes por RICEF'
define view entity ZI_XC_RICEFI_COUNT as select from zxc_tbl_ricefi {
  key ricefid, count( * ) as VariantsCount
} group by ricefid
