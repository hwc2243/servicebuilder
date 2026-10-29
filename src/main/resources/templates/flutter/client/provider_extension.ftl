import 'base/base_${entity.name?replace("([a-z0-9])([A-Z])", "$1_$2", "r")?lower_case}_provider.dart';

/// Application extension point for ${entity.name?cap_first} API operations.
///
/// This file is generated only when it does not already exist and is preserved
/// on subsequent service builds.
class ${entity.name?cap_first}Provider extends Base${entity.name?cap_first}Provider {
  ${entity.name?cap_first}Provider({
    required super.httpClient,
<#if entity.multitenant && tenantDiscriminator??>
    required super.tenantProvider,
</#if>
  });
}
