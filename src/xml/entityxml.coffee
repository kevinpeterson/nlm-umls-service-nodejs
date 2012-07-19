conf = require('../conf')

build_descriptions = (descriptions) ->
  text = ""
  for description in descriptions
    text += """
          <designation designationRole="#{if description.is_preferred then "PREFERRED" else "ALTERNATIVE"}">
            <core:value>#{encode(description.value)}</core:value>
          </designation>
    """
  return text

build_definitions = (definitions) ->
  text = ""
  if definitions
    for definition in definitions
      text += """
            <definition definitionRole="NORMATIVE">
              <core:value>#{encode(definition.value)}</core:value>
            </definition>
      """
  return text

build_unknown_entity = (name) ->
  return """
  <?xml version="1.0" encoding="UTF-8"?>
  <UnknownEntity xmlns="http://schema.omg.org/spec/CTS2/1.0/Exceptions"
      xmlns:core="http://schema.omg.org/spec/CTS2/1.0/Core"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schema.omg.org/spec/CTS2/1.0/Exceptions http://informatics.mayo.edu/svn/trunk/cts2/spec/psm/rest/serviceSchema/Exceptions.xsd">
      <exceptionType>INVALID_SERVICE_INPUT</exceptionType>
      <message>
          <core:value>Resource with Identifier: #{name} not found.</core:value>
      </message>
      <severity>ERROR</severity>
  </UnknownEntity>
  """
  
build_entity = (entity) ->
  """
<?xml version="1.0" encoding="UTF-8"?> 
<EntityDescriptionMsg
    xmlns="http://schema.omg.org/spec/CTS2/1.0/Entity"
    xmlns:core="http://schema.omg.org/spec/CTS2/1.0/Core"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://schema.omg.org/spec/CTS2/1.0/Entity http://informatics.mayo.edu/svn/trunk/cts2/spec/psm/rest/schema/Entity.xsd">
    <core:heading>
        <core:resourceRoot>codesystem/#{entity.code_system}/entity/#{entity.name}</core:resourceRoot>
        <core:resourceURI>#{conf.server_root}/codesystem/#{entity.code_system}/entity/#{entity.name}</core:resourceURI>
        <core:accessDate>#{new Date().toISOString()}</core:accessDate>
    </core:heading>
    <EntityDescription>
        <namedEntity
            about="http://id.nlm.org/code/#{entity.name}"
            entryState="ACTIVE">
            <entityID>
                <core:namespace>#{entity.code_system}</core:namespace>
                <core:name>#{entity.name}</core:name>
            </entityID>
            <describingCodeSystemVersion>
                <core:version>#{entity.code_system}</core:version>
                <core:codeSystem>#{entity.code_system}</core:codeSystem>
            </describingCodeSystemVersion>
            #{build_descriptions(entity.descriptions)}
            #{build_definitions(entity.definitions)}
            <entityType uri="http://www.w3.org/2002/07/owl#Class">
                <core:namespace>owl</core:namespace>
                <core:name>Class</core:name>
            </entityType>
        </namedEntity>
    </EntityDescription>
</EntityDescriptionMsg>
  """


encode = (str) ->
  return str.replace(/&/g, '&amp;')
              .replace(/</g, '&lt;')
              .replace(/>/g, '&gt;')
              .replace(/"/g, '&quot;')


module.exports.build_entity = build_entity
module.exports.build_unknown_entity = build_unknown_entity