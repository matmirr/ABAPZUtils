@EndUserText.label: 'Proyección RICEF Header'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_XC_RICEFH provider contract transactional_query as projection on ZI_XC_RICEFH
{
  @Search.defaultSearchElement: true
  key Ricefid,
  _LocalizedText.Description as SessionDescription,
  VariantsCount,
  CreatedBy, CreatedAt, LastChangedBy, LastChangedAt, LocalLastChg,
  
  _Item : redirected to composition child ZC_XC_RICEFI,
  _Text : redirected to composition child ZC_XC_RICEFT,
  _LocalizedText : redirected to ZC_XC_RICEFT
}
