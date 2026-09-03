@EndUserText.label: 'Proyección RICEF Texts'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_XC_RICEFT as projection on ZI_XC_RICEFT {
  key Ricefid,
  key Spras,
  Description,
  LocalLastChg,
  _Header : redirected to parent ZC_XC_RICEFH
}
