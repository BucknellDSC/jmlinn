<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="tei xs"
    version="2.0">
    
    <!-- ============================================================
         TEI Named Entity Extractor → CSV
         Extracts: persName, placeName, orgName, objectName, name
         Captures: element name, @type, @subtype, @ref, text content,
                   source file, and approximate location (title/id)
         ============================================================ -->
    
    <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"/>
    
    <!-- Change this to the delimiter of your choice: , | ; or tab (&#9;) -->
    <xsl:param name="delimiter" select="','"/>
    
    <!-- ============================================================
         Helper: escape a value for CSV
         Wraps in double-quotes and escapes any internal double-quotes
         ============================================================ -->
    <xsl:function name="tei:csv-cell" as="xs:string">
        <xsl:param name="value" as="xs:string"/>
        <xsl:variable name="escaped" select="replace($value, '&quot;', '&quot;&quot;')"/>
        <xsl:value-of select="concat('&quot;', $escaped, '&quot;')"/>
    </xsl:function>
    
    <!-- ============================================================
         Root: write header row then process all target elements
         ============================================================ -->
    <xsl:template match="/">
        
        <!-- CSV header -->
        <xsl:value-of select="string-join((
            'element',
            'type',
            'subtype',
            'ref',
            'xml_id',
            'normalized_text',
            'raw_text',
            'document_title',
            'document_id',
            'ancestor_context'
            ), $delimiter)"/>
        <xsl:text>&#10;</xsl:text>
        
        <!-- Process all target elements regardless of namespace,
             excluding anything inside teiHeader -->
        <xsl:apply-templates select="
            //tei:persName   [not(ancestor::tei:teiHeader or ancestor::*[local-name()='teiHeader'])] |
            //tei:placeName  [not(ancestor::tei:teiHeader or ancestor::*[local-name()='teiHeader'])] |
            //tei:orgName    [not(ancestor::tei:teiHeader or ancestor::*[local-name()='teiHeader'])] |
            //tei:objectName [not(ancestor::tei:teiHeader or ancestor::*[local-name()='teiHeader'])] |
            //tei:name       [not(ancestor::tei:teiHeader or ancestor::*[local-name()='teiHeader'])] |
            //*[local-name() = 'persName'   and not(ancestor::*[local-name()='teiHeader'])] |
            //*[local-name() = 'placeName'  and not(ancestor::*[local-name()='teiHeader'])] |
            //*[local-name() = 'orgName'    and not(ancestor::*[local-name()='teiHeader'])] |
            //*[local-name() = 'objectName' and not(ancestor::*[local-name()='teiHeader'])] |
            //*[local-name() = 'name'       and not(ancestor::*[local-name()='teiHeader'])]
            "/>
        
    </xsl:template>
    
    <!-- ============================================================
         Named entity row template
         ============================================================ -->
    <xsl:template match="
        tei:dateline | tei:persName | tei:placeName | tei:orgName | tei:objectName | tei:name |
        *[local-name() = 'dateline' or local-name() = 'persName' or local-name() = 'placeName' or
        local-name() = 'orgName'  or local-name() = 'objectName' or
        local-name() = 'name']
        ">
        
        <!-- Gather field values  -->
        
        <!-- Element local name -->
        <xsl:variable name="element-name"  select="local-name(.)"/>
        
        <!-- @type (may be absent) -->
        <xsl:variable name="type"     select="if (@type)    then string(@type)    else ''"/>
<!--        <xsl:variable name="subtype"  select="if (@subtype) then string(@subtype) else ''"/>-->
        
        <!-- @ref / @key for linked authority records -->
<!--        <xsl:variable name="ref"      select="if (@ref)  then string(@ref)
            else if (@key)  then string(@key)
            else ''"/>-->
        
        <!-- @xml:id on this element -->
<!--        <xsl:variable name="xml-id"   select="if (@xml:id) then string(@xml:id) else ''"/>
-->        
        <!-- Normalized text (collapse whitespace) -->
        <xsl:variable name="norm-text" select="normalize-space(string(.))"/>
        
        <!-- Raw text (preserves internal spacing but strips leading/trailing) -->
        <xsl:variable name="raw-text"  select="string(.)"/>
        
        <!-- Document title: prefer tei:titleStmt/tei:title -->
        <xsl:variable name="doc-title" select="normalize-space(
            (ancestor::tei:TEI//tei:titleStmt/tei:title[1] |
            //*[local-name()='TEI']//*[local-name()='titleStmt']/*[local-name()='title'][1])[1]
            )"/>
        
        <!-- Document @xml:id (on TEI root or body) -->
        <xsl:variable name="doc-id" select="
            if (ancestor::*[local-name()='TEI']/@xml:id)
            then string(ancestor::*[local-name()='TEI']/@xml:id)
            else ''
            "/>
        
        <!-- Immediate named ancestor for context: div/@n, div/@xml:id, head -->
        <xsl:variable name="ancestor-context" select="normalize-space(
            (ancestor::*[local-name()='div' or local-name()='body' or local-name()='text'][1]
            /*[local-name()='head'][1])[1]
            )"/>
        
        <!-- Build the CSV row -->
        <xsl:value-of select="string-join((
            tei:csv-cell($element-name),
            tei:csv-cell($type),
(:            tei:csv-cell($subtype),:)
(:            tei:csv-cell($ref),:)
(:            tei:csv-cell($xml-id),:)
            tei:csv-cell($norm-text),
            tei:csv-cell($raw-text),
            tei:csv-cell($doc-title),
            tei:csv-cell($doc-id),
            tei:csv-cell($ancestor-context)
            ), $delimiter)"/>
        <xsl:text>&#10;</xsl:text>
        
    </xsl:template>
    
    <!-- Suppress all other text nodes from appearing in output -->
    <xsl:template match="text()"/>
    
</xsl:stylesheet>
