<#function dartDataType type>
  <#if type.value == "boolean">
    <#return "bool">
  <#elseif type.value == "int" || type.value == "long">
    <#return "int">
  <#elseif type.value == "float" || type.value == "double" || type.value == "money">
    <#return "double">
  <#else>
    <#return "String">
  </#if>
</#function>

import 'package:flutter/foundation.dart';

/// Holds the tenant selected by the application at runtime.
///
/// Generated entity providers listen to this object and notify their
/// consumers when the active tenant changes.
class TenantDiscriminatorProvider extends ChangeNotifier {
  ${dartDataType(tenantDiscriminator.type)}? _${tenantDiscriminator.name};

  ${dartDataType(tenantDiscriminator.type)}? get ${tenantDiscriminator.name} => _${tenantDiscriminator.name};

  void set${tenantDiscriminator.name?cap_first}(${dartDataType(tenantDiscriminator.type)}? value) {
    if (_${tenantDiscriminator.name} == value) {
      return;
    }
    _${tenantDiscriminator.name} = value;
    notifyListeners();
  }

  void clear() => set${tenantDiscriminator.name?cap_first}(null);
}
