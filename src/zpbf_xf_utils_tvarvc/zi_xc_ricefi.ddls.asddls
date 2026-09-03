@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View RICEF Items'
define view entity ZI_XC_RICEFI as select from zxc_tbl_ricefi
association to parent ZI_XC_RICEFH as _Header on $projection.Ricefid = _Header.Ricefid
  
  association [0..1] to ZI_XC_RICEF_KIND_VH as _TypeVH on $projection.Type = _TypeVH.Type
                                                      and _TypeVH.DomainName = 'ZRICEF_KIND'
                                                      and _TypeVH.As4local   = 'A'
                                                      
  association [0..1] to ZI_XC_SIGN_VH       as _SignVH on $projection.Sign = _SignVH.Sign
                                                      and _SignVH.DomainName = 'ZSIGN'
                                                      and _SignVH.As4local   = 'A'
                                                      
  association [0..1] to ZI_XC_OPTI_VH       as _OptiVH on $projection.Opti = _OptiVH.Opti
                                                      and _OptiVH.DomainName = 'ZOPTI'
                                                      and _OptiVH.As4local   = 'A'
{
  key ricefid as Ricefid, 
  key item_uuid as ItemUuid, 
  
  name as Name, 
  type as Type, 
  _TypeVH.Description as TypeDescription,
  
  numb as Numb, 
  sign as Sign, 
  _SignVH.Description as SignDescription, 
  
  opti as Opti, 
  _OptiVH.Description as OptiDescription,
  
  low as Low, 
  high as High, 
  @Semantics.systemDateTime.localInstanceLastChangedAt: true 
  local_last_chg as LocalLastChg, 
  
  _Header
}
