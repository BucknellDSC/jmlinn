<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <xsl:output
    method="html"
    encoding="UTF-8"
    doctype-public="-//W3C//DTD HTML 4.01//EN"
    indent="yes"/>

  <!-- ============================================================
       ROOT
  ============================================================ -->
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <title>
          <xsl:value-of select="//tei:titleStmt/tei:title"/>
        </title>
        <style>
          /* ── Page setup ── */
          @page {
            size: letter;
            margin: 2.5cm 3cm 2.5cm 3cm;
          }
          /* ── Base typography ── */
          body {
            font-family: "Georgia", "Times New Roman", serif;
            font-size: 12pt;
            line-height: 1.6;
            color: #1a1a1a;
            margin: 0;
            padding: 0;
          }

          /* ── Section headings ── */
          h1 { font-size: 18pt; margin-top: 0; }
          h2 { font-size: 14pt; margin-top: 1.6em; }
          h3 { font-size: 12pt; margin-top: 1.2em; }

          /* ── Diary entries ── */
          .entry {
            margin-bottom: 2.4em;
          }
          .dateline {
            font-variant: small-caps;
            font-weight: bold;
            font-size: 11pt;
            letter-spacing: 0.05em;
            color: #2c2c5e;
            margin-bottom: 0.4em;
            border-left: 3px solid #2c2c5e;
            padding-left: 0.6em;
          }
          .entry p {
            margin: 0.5em 0;
            text-align: justify;
            hyphens: auto;
          }

          /* ── Page-break / facsimile marker ── */
          .pb {
            display: block;
            font-size: 8.5pt;
            color: #888;
            font-family: "Courier New", monospace;
            border-top: 1px dashed #ccc;
            margin: 1.2em 0 0.6em;
            padding-top: 3px;
          }

          /* ── Named entities ── */
          .persName  { font-style: italic; }
          .orgName   { font-style: italic; }
          .placeName { text-decoration: underline; text-decoration-style: dotted; }

          /* ── Additions / deletions ── */
          .add { color: #1a5e1a; }
          del  { color: #8b0000; }

          /* ── Unclear text ── */
          .unclear {
            color: #888;
            font-style: italic;
          }
          .unclear::before { content: "["; }
          .unclear::after  { content: "?]"; }

          /* ── Notes (footnote-style) ── */
          .note {
            font-size: 9.5pt;
            color: #555;
            border-left: 2px solid #ddd;
            padding-left: 0.5em;
            margin: 0.4em 0 0.4em 1.5em;
          }

          /* ── Footer ── */
          .footer {
            font-size: 8.5pt;
            color: #888;
            text-align: center;
            margin-top: 3em;
            border-top: 1px solid #ddd;
            padding-top: 0.5em;
          }
        </style>
      </head>
      <body>
        <xsl:apply-templates select="tei:TEI/tei:text"/>
      </body>
    </html>
  </xsl:template>

  <!-- ============================================================
       TEXT BODY
  ============================================================ -->
  <xsl:template match="tei:text">
    <xsl:apply-templates select="tei:body"/>
  </xsl:template>

  <xsl:template match="tei:body">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- ── Diary entry div ── -->
  <xsl:template match="tei:div[@type='entry']">
    <div class="entry">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- ── Generic div ── -->
  <xsl:template match="tei:div">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- ── Dateline ── -->
  <xsl:template match="tei:dateline">
    <div class="dateline">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- ── Paragraph ── -->
  <xsl:template match="tei:p">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <!-- ── Page break ── -->
  <xsl:template match="tei:pb">
    <span class="pb">
      <xsl:if test="@n">
        <xsl:text> — p. </xsl:text>
        <xsl:value-of select="@n"/>
      </xsl:if>
    </span>
  </xsl:template>

  <!-- ── Line break ── -->
  <xsl:template match="tei:lb">
    <br/>
  </xsl:template>

  <!-- ── Named entities ── -->
  <xsl:template match="tei:persName">
    <span class="persName"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="tei:orgName">
    <span class="orgName"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="tei:placeName">
    <span class="placeName"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- ── Headings ── -->
  <xsl:template match="tei:head">
    <h2><xsl:apply-templates/></h2>
  </xsl:template>

  <!-- ── Additions and deletions ── -->
  <xsl:template match="tei:add">
    <span class="add"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="tei:del">
    <del><xsl:apply-templates/></del>
  </xsl:template>

  <!-- ── Unclear text ── -->
  <xsl:template match="tei:unclear">
    <span class="unclear"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- ── Notes ── -->
  <xsl:template match="tei:note">
    <div class="note"><xsl:apply-templates/></div>
  </xsl:template>

  <!-- ── Emphasis / hi ── -->
  <xsl:template match="tei:hi[@rend='italic']">
    <em><xsl:apply-templates/></em>
  </xsl:template>
  <xsl:template match="tei:hi[@rend='bold']">
    <strong><xsl:apply-templates/></strong>
  </xsl:template>
  <xsl:template match="tei:hi[@rend='underline']">
    <u><xsl:apply-templates/></u>
  </xsl:template>
  <xsl:template match="tei:hi">
    <span><xsl:apply-templates/></span>
  </xsl:template>

  <!-- ── Quoted text ── -->
  <xsl:template match="tei:q | tei:quote">
    <q><xsl:apply-templates/></q>
  </xsl:template>

  <!-- ── Titles ── -->
  <xsl:template match="tei:title">
    <cite><xsl:apply-templates/></cite>
  </xsl:template>

  <!-- ── Catch-all: pass through text content ── -->
  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

</xsl:stylesheet>
