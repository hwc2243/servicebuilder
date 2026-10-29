<#include "/functions.ftl">

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

<#function dartKeyType key>
  <#if key.type.value == "int" || key.type.value == "long">
    <#return "int">
  <#else>
    <#return "String">
  </#if>
</#function>

<#assign className = entity.name?cap_first>
<#assign providerClassName = "Base" + className + "Provider">
<#assign dtoClassName = className + "Dto">
<#assign serverKeyName = "server" + entity.key.name?cap_first>
<#assign modelFileName = entity.name?replace("([a-z0-9])([A-Z])", "$1_$2", "r")?lower_case + "_dto.dart">
<#assign hasExternalApi = entity.api?? && entity.api.external??>
<#assign hasCreate = hasExternalApi && entity.api.external.operations?seq_contains("CREATE")>
<#assign hasRead = hasExternalApi && entity.api.external.operations?seq_contains("READ")>
<#assign hasUpdate = hasExternalApi && entity.api.external.operations?seq_contains("UPDATE")>
<#assign hasDelete = hasExternalApi && entity.api.external.operations?seq_contains("DELETE")>
<#assign searchableAttributes = entity.attributes?filter(a -> a.name != "id" && a.type == "string")>
import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../../models/${modelFileName}';
<#if hasExternalApi>
import '../../network/service_builder_http_client.dart';
</#if>
<#if entity.multitenant && tenantDiscriminator??>
import '../tenant_discriminator_provider.dart';
</#if>

/// Holds ${className} DTOs and provides its configured external API operations.
class ${providerClassName} extends ChangeNotifier {
<#if hasExternalApi>
  final ServiceBuilderHttpClient httpClient;
</#if>
<#if entity.multitenant && tenantDiscriminator??>
  final TenantDiscriminatorProvider tenantProvider;
</#if>
  final List<${dtoClassName}> _items = <${dtoClassName}>[];
  bool _isLoading = false;
  Object? _error;

  ${providerClassName}({
<#if hasExternalApi>
    required this.httpClient,
</#if>
<#if entity.multitenant && tenantDiscriminator??>
    required this.tenantProvider,
</#if>
  }) {
<#if entity.multitenant && tenantDiscriminator??>
    tenantProvider.addListener(_tenantChanged);
</#if>
  }

  List<${dtoClassName}> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  Object? get error => _error;
<#if entity.multitenant && tenantDiscriminator??>
  ${dartDataType(tenantDiscriminator.type)}? get ${tenantDiscriminator.name} =>
      tenantProvider.${tenantDiscriminator.name};
</#if>

<#if hasCreate>
  Future<${dtoClassName}> create(${dtoClassName} value) async {
    return execute(() async {
      final response = await httpClient.post(
        resourcePath,
        headers: requestHeaders,
        body: jsonEncode(value.toJson()),
      );
      httpClient.ensureSuccess(response);
      final created = ${dtoClassName}.fromJson(decodeObject(response));
      _items.add(created);
      notifyListeners();
      return created;
    });
  }
</#if>

<#if hasRead>
  Future<${dtoClassName}?> get(${dartKeyType(entity.key)} ${serverKeyName}) async {
    return execute(() async {
      final response = await httpClient.get(
        '$resourcePath/$${serverKeyName}',
        headers: requestHeaders,
      );
      if (response.statusCode == 404) {
        return null;
      }
      httpClient.ensureSuccess(response);
      return ${dtoClassName}.fromJson(decodeObject(response));
    });
  }

  Future<List<${dtoClassName}>> list() async {
    return execute(() async {
      final response = await httpClient.get(resourcePath, headers: requestHeaders);
      httpClient.ensureSuccess(response);
      final values = jsonDecode(response.body) as List<dynamic>;
      final result = values
          .map((value) => ${dtoClassName}.fromJson(value as Map<String, dynamic>))
          .toList();
      replaceAll(result);
      return result;
    });
  }

  Future<List<${dtoClassName}>> search(<#if searchableAttributes?size gt 0>{
<#list searchableAttributes as attribute>
    String? ${attribute.name},
</#list>
  }<#else>)</#if> async {
    return execute(() async {
      final response = await httpClient.get(
        '$resourcePath/search',
        headers: requestHeaders,
<#if searchableAttributes?size gt 0>        queryParameters: {
<#list searchableAttributes as attribute>
          if (${attribute.name} != null) '${attribute.name}': ${attribute.name},
</#list>
        },
</#if>
      );
      httpClient.ensureSuccess(response);
      final values = jsonDecode(response.body) as List<dynamic>;
      final result = values
          .map((value) => ${dtoClassName}.fromJson(value as Map<String, dynamic>))
          .toList();
      replaceAll(result);
      return result;
    });
  }
</#if>

<#if hasUpdate>
  Future<${dtoClassName}> update(
    ${dartKeyType(entity.key)} ${serverKeyName},
    ${dtoClassName} value,
  ) async {
    return execute(() async {
      final response = await httpClient.put(
        '$resourcePath/$${serverKeyName}',
        headers: requestHeaders,
        body: jsonEncode(value.toJson()),
      );
      httpClient.ensureSuccess(response);
      final updated = ${dtoClassName}.fromJson(decodeObject(response));
      final index = _items.indexWhere((item) => item.${serverKeyName} == updated.${serverKeyName});
      if (index >= 0) {
        _items[index] = updated;
      }
      notifyListeners();
      return updated;
    });
  }
</#if>

<#if hasDelete>
  Future<void> delete(${dartKeyType(entity.key)} ${serverKeyName}) async {
    await execute(() async {
      final response = await httpClient.delete(
        '$_path/$${serverKeyName}',
        headers: requestHeaders,
      );
      httpClient.ensureSuccess(response);
      _items.removeWhere((item) => item.${serverKeyName} == ${serverKeyName});
      notifyListeners();
    });
  }
</#if>

  void replaceAll(Iterable<${dtoClassName}> values) {
    _items
      ..clear()
      ..addAll(values);
    _error = null;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Future<T> execute<T>(Future<T> Function() operation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      return await operation();
    } catch (error) {
      _error = error;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

<#if hasExternalApi>
  Map<String, String> get requestHeaders {
    final headers = <String, String>{};
<#if entity.multitenant && tenantDiscriminator??>
    final selectedTenant = tenantProvider.${tenantDiscriminator.name};
    if (selectedTenant == null) {
      throw StateError('A ${tenantDiscriminator.name} is required for ${className} requests');
    }
    headers['${tenantDiscriminator.name}'] = selectedTenant.toString();
</#if>
    return headers;
  }

  Map<String, dynamic> decodeObject(dynamic response) =>
      jsonDecode(response.body) as Map<String, dynamic>;

  String get resourcePath => '/api/external/${entity.name}';
</#if>
<#if entity.multitenant && tenantDiscriminator??>
  void _tenantChanged() => notifyListeners();

  @override
  void dispose() {
    tenantProvider.removeListener(_tenantChanged);
    super.dispose();
  }
</#if>
}
