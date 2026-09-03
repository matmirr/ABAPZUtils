@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help para Signo'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_XC_SIGN_VH as select from dd07t {
  @UI.hidden: true
  key domname    as DomainName,
  
  @UI.hidden: true
  key as4local   as As4local,
  
  @UI.hidden: true
  key valpos     as Valpos,
  
  @UI.hidden: true
  key as4vers    as As4vers,
  
  key domvalue_l as Sign,
  ddtext         as Description
} where domname = 'ZSIGN' 
  and as4local   = 'A'
