@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View RICEF Texts'
@ObjectModel.dataCategory: #TEXT  
define view entity ZI_XC_RICEFT as select from zxc_tbl_riceft
  association to parent ZI_XC_RICEFH as _Header on $projection.Ricefid = _Header.Ricefid {
  
  @ObjectModel.foreignKey.association: '_Header'
  key ricefid as Ricefid, 
  
  @Semantics.language: true      
  key spras as Spras, 
  
  @Semantics.text: true           
  description as Description,
  
  @Semantics.systemDateTime.localInstanceLastChangedAt: true 
  local_last_chg as LocalLastChg, 
  
  _Header
}
