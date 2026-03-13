<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:linn="http://jmlinn.bucknell.edu/xslt"
    exclude-result-prefixes="xs linn"
    version="2.0">
    
    <!--
        Linn Diary TEI to CSV Entity Extractor
        Captures from <text> only (teiHeader is excluded):
          persName   : element, key, ref, type, tagged_content, date, source_file
          placeName  : element, key, ref, type, tagged_content, date, source_file
          orgName    : element, [key], [ref], type, tagged_content, date, source_file
          name       : element, [key], [ref], type, tagged_content, date, source_file
          objectName : element, [key], [ref], type, tagged_content, date, source_file
        key/ref are blank for orgName, name, objectName.
    -->
    
    <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"/>
    
    <!-- Wrap a value in RFC-4180 double-quotes, escaping internal quotes -->
    <xsl:function name="linn:q" as="xs:string">
        <xsl:param name="v" as="xs:string"/>
        <xsl:value-of select="concat('&quot;', replace($v, '&quot;', '&quot;&quot;'), '&quot;')"/>
    </xsl:function>
    
    <!-- Root: write header, then process all target elements outside teiHeader -->
    <xsl:template match="/">
        <xsl:text>element,key,ref,type,tagged_content,date,source_file&#10;</xsl:text>
        <xsl:apply-templates select="
            //*[
            local-name() = ('persName','placeName','orgName','name','objectName')
            and not(ancestor::*[local-name() = 'teiHeader'])
            ]
            "/>
    </xsl:template>
    
    <!-- Entity row template -->
    <xsl:template match="
        *[
        local-name() = ('persName','placeName','orgName','name','objectName')
        and not(ancestor::*[local-name() = 'teiHeader'])
        ]
        ">
        <xsl:variable name="el" select="local-name(.)"/>
        
        <!-- @key and @ref: populated for persName and placeName only -->
        <xsl:variable name="key" select="
            if ($el = ('persName','placeName') and @key)
            then normalize-space(@key)
            else ''
            "/>
        <xsl:variable name="ref" select="
            if ($el = ('persName','placeName') and @ref)
            then normalize-space(@ref)
            else ''
            "/>
        
        <!-- @type: for all five elements -->
        <xsl:variable name="type" select="
            if (@type) then normalize-space(@type) else ''
            "/>
        
        <!-- Normalized text content -->
        <xsl:variable name="content" select="normalize-space(string(.))"/>
        
        <!-- Date from nearest dateline in the enclosing div, then whole text -->
        <xsl:variable name="date" select="
            string((
            ancestor::*[local-name() = 'div'][1]
            //*[local-name() = 'dateline'][1]
            //*[local-name() = 'date'][1]/@when,
            //*[local-name() = 'text']
            //*[local-name() = 'dateline'][1]
            //*[local-name() = 'date'][1]/@when
            )[1])
            "/>
        
        <!-- Source filename from document URI -->
        <xsl:variable name="source" select="
            if (document-uri(/))
            then tokenize(document-uri(/), '/')[last()]
            else ''
            "/>
        
        <xsl:value-of select="string-join((
            linn:q($el),
            linn:q($key),
            linn:q($ref),
            linn:q($type),
            linn:q($content),
            linn:q($date),
            linn:q($source)
            ), ',')"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <!-- Suppress stray text nodes -->
    <xsl:template match="text()"/>
    
</xsl:stylesheet>
