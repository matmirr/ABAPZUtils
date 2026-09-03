@EndUserText.label: 'Proyección RICEF Items'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_XC_RICEFI
  as projection on ZI_XC_RICEFI
{
  key Ricefid,
  key ItemUuid,
  Name,
  
  @ObjectModel.text.element: ['TypeDescription']
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_XC_RICEF_KIND_VH', element: 'Type' } }]
  Type,
  TypeDescription, 
  
  Numb,
  
  @ObjectModel.text.element: ['SignDescription']
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_XC_SIGN_VH', element: 'Sign' } }]
  @UI.textArrangement: #TEXT_LAST
  Sign,
  SignDescription, 
  
  @ObjectModel.text.element: ['OptiDescription']
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_XC_OPTI_VH', element: 'Opti' } }]
  @UI.textArrangement: #TEXT_LAST
  Opti,
  OptiDescription, 
  
  Low,
  High,
  LocalLastChg,
  
  /* Associations */
  _Header : redirected to parent ZC_XC_RICEFH
}
