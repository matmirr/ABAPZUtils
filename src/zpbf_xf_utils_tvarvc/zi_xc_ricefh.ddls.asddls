@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View RICEF Header'
define root view entity ZI_XC_RICEFH
  as select from zxc_tbl_ricefh as Header
  composition [0..*] of ZI_XC_RICEFI       as _Item
  composition [0..*] of ZI_XC_RICEFT       as _Text
  association [0..1] to ZI_XC_RICEFT       as _LocalizedText on $projection.Ricefid = _LocalizedText.Ricefid 
                                                            and _LocalizedText.Spras = $session.system_language
  association [0..1] to ZI_XC_RICEFI_COUNT as _Count on $projection.Ricefid = _Count.ricefid
{
  @EndUserText.label: 'RICEFID'
  @ObjectModel.text.association: '_LocalizedText'  
  key ricefid                  as Ricefid,
  
      _Count.VariantsCount     as VariantsCount,
      @Semantics.user.createdBy: true
      created_by               as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at               as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by          as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at          as LastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_chg           as LocalLastChg,
      
      _Item,
      _Text,
      _LocalizedText,
      _Count
}
