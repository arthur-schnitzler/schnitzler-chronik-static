<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://dse-static.foo.bar"
    xmlns:mam="whatever" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes"
        omit-xml-declaration="yes"/>
    <xsl:import href="./partials/shared.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./export/schnitzler-chronik.xsl"/>
    <!-- Lokale Datei hat Vorrang vor der GitHub-URL in schnitzler-chronik.xsl -->
    <xsl:param name="relevant-uris" select="document('./export/list-of-relevant-uris.xml')"/>
    <xsl:param name="relevant-eventtypes"
        select="'Arthur-Schnitzler-digital,schnitzler-tagebuch,schnitzler-briefe,pollaczek,schnitzler-interviews,schnitzler-bahr,schnitzler-fischer,wienerschnitzler,schnitzler-orte,schnitzler-kultur,schnitzler-chronik-manuell,pmb,schnitzler-cmif,schnitzler-mikrofilme-daten,schnitzler-traeume,schnitzler-kino-buch,schnitzler-kempny-buch,kalliope-verbund,dla-marbach'"/>
    <xsl:variable name="teiSource">
        <xsl:value-of select="data(tei:TEI/@xml:id)"/>
    </xsl:variable>
    <xsl:variable name="link">
        <xsl:value-of select="replace($teiSource, '.xml', '.html')"/>
    </xsl:variable>
    <xsl:variable name="doc_title">
        <xsl:value-of select=".//tei:title[@level = 'a'][1]/text()"/>
    </xsl:variable>
    <xsl:variable name="datum-iso" select="descendant::tei:titleStmt/tei:title/@when-iso"
        as="xs:date"/>
    <xsl:template match="/">
        <xsl:variable name="prev">
            <xsl:value-of select="concat($datum-iso - xs:dayTimeDuration('P1D'), '.html')"/>
        </xsl:variable>
        <xsl:variable name="next">
            <xsl:value-of select="concat($datum-iso + xs:dayTimeDuration('P1D'), '.html')"/>
        </xsl:variable>
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:title[@level = 'a'][1]/text()"/>
        </xsl:variable>
        <xsl:variable name="doc_description">
            <xsl:choose>
                <xsl:when test="//tei:event[1]/tei:desc[normalize-space(.) != '']">
                    <xsl:value-of select="concat('Am ', format-date($datum-iso, '[D1]. [MNn] [Y]', 'de', (), ()), ': ', substring(normalize-space(//tei:event[1]/tei:desc[1]), 1, 160))"/>
                    <xsl:if test="string-length(normalize-space(//tei:event[1]/tei:desc[1])) > 160">
                        <xsl:text>...</xsl:text>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('Ereignisse und Dokumentation zu Arthur Schnitzler am ', format-date($datum-iso, '[D1]. [MNn] [Y]', 'de', (), ()))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
        <html>
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="concat($doc_title, ' | ', $project_title)"/>
                    <xsl:with-param name="html_description" select="$doc_description"/>
                    <xsl:with-param name="page_url" select="$link"/>
                    <xsl:with-param name="page_date" select="$datum-iso"/>
                </xsl:call-template>
                <style>
                    .navBarNavDropdown ul li:nth-child(2) {
                        display: none !important;
                    }</style>
            </head>
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    <div class="container-fluid">
                        <div class="card" data-index="true">
                            <div class="card-header">
                                <div class="row">
                                    <div class="col-md-2 col-lg-2 col-sm-12">
                                        <xsl:if test="ends-with($prev, '.html')">
                                            <h1>
                                                <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="$prev"/>
                                                  </xsl:attribute>
                                                  <i class="fas fa-chevron-left" title="prev"/>
                                                </a>
                                            </h1>
                                        </xsl:if>
                                    </div>
                                    <div class="col-md-8 col-lg-8 col-sm-12">
                                        <h1 align="center">
                                            <xsl:value-of select="$doc_title"/>
                                        </h1>
                                    </div>
                                    <div class="col-md-2 col-lg-2 col-sm-12"
                                        style="text-align:right">
                                        <xsl:if test="ends-with($next, '.html')">
                                            <h1>
                                                <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="$next"/>
                                                  </xsl:attribute>
                                                  <i class="fas fa-chevron-right" title="next"/>
                                                </a>
                                            </h1>
                                        </xsl:if>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body">
                                <!-- gemeinsames Kachel-Layout aus export/schnitzler-chronik.xsl
                                     (inkl. Karte und »Weiteres«); teiSource/current-type greifen
                                     hier nicht, da die Chronik sich nicht selbst referenziert -->
                                <xsl:call-template name="mam:schnitzler-chronik">
                                    <xsl:with-param name="datum-iso" select="$datum-iso"/>
                                    <xsl:with-param name="current-type"
                                        select="'schnitzler-chronik'"/>
                                    <xsl:with-param name="teiSource" select="string($teiSource)"/>
                                    <xsl:with-param name="fetchContentsFromURL" select="/"/>
                                    <xsl:with-param name="import-eventtypes"
                                        select="$relevant-eventtypes"/>
                                    <!-- Datums-Überschrift aus, da hier schon der h1-Titel steht -->
                                    <xsl:with-param name="show-date-heading" select="false()"/>
                                </xsl:call-template>
                            </div>
                        </div>
                    </div>
                    <xsl:for-each select="//tei:back">
                        <div class="tei-back">
                            <xsl:apply-templates/>
                        </div>
                    </xsl:for-each>
                    <xsl:call-template name="html_footer"/>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:p">
        <p id="{local:makeId(.)}" class="yes-index">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:div">
        <div id="{local:makeId(.)}" style="margin-top:1.5em;">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
</xsl:stylesheet>
