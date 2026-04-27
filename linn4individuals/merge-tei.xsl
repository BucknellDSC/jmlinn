<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    version="2.0">

    <!--
        merge-tei.xsl
        =============
        Merges a set of single-entry TEI files that share a common teiHeader
        into one TEI document.

        HOW TO USE:
        Apply this stylesheet to any ONE of the source files (it will supply
        the shared teiHeader). Point $collection-uri at the directory that
        holds all the files you want to merge.

        Saxon command-line example:
          java -jar saxon-he.jar \
               -s:1862-06-09.xml \
               -xsl:merge-tei.xsl \
               -o:merged.xml \
               collection-uri=file:///path/to/your/files/

        Parameters:
          collection-uri   URI of the directory containing the source files.
                           Must end with a forward slash.
                           Defaults to the directory of the primary input file.

          select-pattern   Glob passed to the collection() function to filter
                           which files are included.
                           Default: *.xml
    -->

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <!-- Parameters -->

    <!-- Directory URI for the collection; defaults to the folder of the primary input document. -->
    <xsl:param name="collection-uri"
               select="replace(document-uri(/), '[^/]+$', '')"/>

    <!-- File-name glob used to select documents from the collection. -->
    <xsl:param name="select-pattern" select="'*.xml'"/>

    <!-- Collect and sort all source documents -->

    <xsl:variable name="collection-query"
                  select="concat($collection-uri, '?select=',
                                 $select-pattern, ';recurse=no')"/>

    <xsl:variable name="source-docs"
                  select="collection($collection-query)"/>

    <!-- Root template -->

    <xsl:template match="/">

        <!-- Re-emit the xml-model processing instructions from the primary input
             so schema associations are preserved in the output. -->
        <xsl:for-each select="processing-instruction()">
            <xsl:copy/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>

        <TEI>

            <!-- Take the shared teiHeader verbatim from the primary input document. -->
            <xsl:copy-of select="tei:TEI/tei:teiHeader"/>

            <text>
                <body>

                    <!-- Copy every div found across the collection,
                         sorted lexicographically by the base URI of each div
                         (i.e. by file name, which here encodes the date).
                         Note: base-uri() is used rather than document-uri(root(.))
                         because some XSLT processors return empty from document-uri()
                         on collection members when called from the element context. -->
                    <xsl:for-each select="$source-docs
                                            /tei:TEI
                                            /tei:text
                                            /tei:body
                                            /tei:div">
                        <xsl:sort select="base-uri(.)"/>
                        <xsl:copy-of select="."/>
                    </xsl:for-each>

                </body>
            </text>

        </TEI>
    </xsl:template>

</xsl:stylesheet>
