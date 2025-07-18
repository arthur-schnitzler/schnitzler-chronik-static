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
    <xsl:import href="./partials/LOD-idnos.xsl"/>
    <xsl:param name="relevant-eventtypes"
        select="'Arthur-Schnitzler-digital,schnitzler-tagebuch,schnitzler-briefe,pollaczek,schnitzler-interviews,schnitzler-bahr,schnitzler-orte,wienerschnitzler,schnitzler-chronik-manuell,schnitzler-events,pmb,schnitzler-cmif,schnitzler-mikrofilme-daten,schnitzler-traeume,schnitzler-kino-buch,schnitzler-kempny-buch,kalliope-verbund'"/>
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
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
        <html>
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"/>
                </xsl:call-template>
                <style>
                    .navBarNavDropdown ul li:nth-child(2) {
                        display: none !important;
                    }</style>
                <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"/>
                <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
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
                                <xsl:call-template name="karte-mit-datum">
                                    <xsl:with-param name="datum" select="$datum-iso"/>
                                </xsl:call-template>
                                <xsl:apply-templates select=".//tei:body"/>
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
                <script src="https://unpkg.com/de-micro-editor@0.2.6/dist/de-editor.min.js"/>
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
    <xsl:template match="tei:listEvent">
        <xsl:variable name="current-group" select="." as="node()"/>
        <xsl:for-each select="tokenize($relevant-eventtypes, ',')">
            <xsl:variable name="e-typ" as="xs:string" select="."/>
            <xsl:for-each
                select="$current-group/tei:event[not(preceding-sibling::tei:event/tei:idno[@type = $e-typ])]/tei:idno[@type = $e-typ][1]">
                <xsl:variable name="e-typ-farbe">
                    <xsl:choose>
                        <xsl:when
                            test="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color != '#fff'">
                            <xsl:value-of
                                select="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>blue</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="e-typ-farbe-blass" select="mam:hexNachRGBfarbe($e-typ-farbe)"/>
                <div class="card mb-3" style="background-color: rgba({$e-typ-farbe-blass}, 0.1)">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <!-- das macht den Titel des jeweiligen Typ-Abschnitts -->
                        <xsl:element name="a">
                            <xsl:attribute name="class">
                                <xsl:text>badge cornered-pill</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                                <xsl:text>_blank</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:text>color: white; text-decoration: none;</xsl:text>
                                <xsl:text>background-color: </xsl:text>
                                <xsl:choose>
                                    <xsl:when test="$e-typ-farbe">
                                        <xsl:value-of select="$e-typ-farbe"/>
                                        <xsl:text>; </xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>black; </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of
                                    select="$current-group/descendant::tei:idno[@type = $e-typ][1]"
                                />
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when
                                    test="key('only-relevant-uris', $e-typ, $relevant-uris)/*:caption">
                                    <xsl:value-of
                                        select="key('only-relevant-uris', $e-typ, $relevant-uris)/*:caption"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>Unexpected behaviour: </xsl:text>
                                    <xsl:value-of select="$e-typ"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                        <span class="toggle-icon" data-bs-toggle="collapse"
                            data-bs-target="#{$e-typ}" aria-expanded="true" aria-controls="content1"
                            >−</span>
                    </div>
                    <div class="collapse show">
                        <xsl:attribute name="id">
                            <xsl:value-of select="$e-typ"/>
                        </xsl:attribute>
                        <div class="card-body">
                            <xsl:apply-templates
                                select="$current-group/tei:event[tei:idno/@type = $e-typ]"/>
                        </div>
                    </div>
                </div>
                <xsl:for-each
                    select="tei:event[tei:idno/@type[not(contains($relevant-eventtypes, .))]]">
                    <!-- hier nun die einzelnen events -->
                    <div id="content1" class="collapse show">
                        <xsl:apply-templates mode="desc"/>
                    </div>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:event">
        <!-- jeder einzelne eintrag -->
        <xsl:variable name="e-typ" select="tei:idno[1]/@type" as="xs:string"/>
        <xsl:variable name="e-typ-farbe">
            <xsl:choose>
                <xsl:when test="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color != '#fff'">
                    <xsl:value-of select="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>blue</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="e-typ-multiple" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="key('only-relevant-uris', $e-typ, $relevant-uris)/@ana = 'multiple'">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <p>
            <xsl:choose>
                <xsl:when test="$e-typ='wienerschnitzler'">
                    <xsl:element name="a">
                        <xsl:attribute name="class">
                            <xsl:text>entry-title</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('http://wienerschnitzler.org/pmb', replace(@corresp, '#', ''), '.html')"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="tei:head/text()"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="starts-with(tei:idno[1]/text(), 'http')">
                    <xsl:element name="a">
                        <xsl:attribute name="class">
                            <xsl:text>entry-title</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of select="tei:idno[1]/text()"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="tei:head/text()"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="starts-with(tei:idno[1]/text(), 'doi')">
                    <xsl:element name="a">
                        <xsl:attribute name="class">
                            <xsl:text>entry-title</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('https://', tei:idno[1]/text())"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="tei:head/text()"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="tei:head[@corresp]">
                    <xsl:element name="a">
                        <xsl:attribute name="class">
                            <xsl:text>entry-title</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of
                                select="concat('https://pmb.acdh.oeaw.ac.at/entity/', replace(replace(tei:head/@corresp, '#', ''), 'pmb', ''), '/')"
                            />
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="tei:head/text()"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="span">
                        <xsl:attribute name="class">
                            <xsl:text>entry-title</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="tei:head/text()"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </p>
        <xsl:choose>
            <xsl:when test="tei:desc/child::*[1]">
                <xsl:element name="ul">
                    <xsl:attribute name="style">
                        <xsl:text>list-style-type: none; padding-left: 0px;</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates select="tei:desc" mode="desc"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="normalize-space(.) != ''">
                <xsl:element name="ul">
                    <xsl:attribute name="style">
                        <xsl:text>list-style-type: none; padding-left: 0px;</xsl:text>
                    </xsl:attribute>
                    <li>
                        <xsl:apply-templates select="tei:desc" mode="text"/>
                    </li>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="tei:idno[@type = $e-typ][2] and $e-typ-multiple">
                <xsl:for-each select="tei:idno[@type = $e-typ]">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                        <xsl:value-of select="concat('Link ', position())"/>
                    </xsl:element>
                    <xsl:if test="position() != last()">
                        <xsl:text> / </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:event/tei:desc" mode="text">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:event/tei:desc" mode="desc">
        <li>
            <xsl:if
                test="child::tei:listPerson or child::tei:listBibl or child::tei:listPlace or child::tei:listOrg">
                <ul>
                    <xsl:attribute name="style">
                        <xsl:text>list-style-type: none; padding-left: 0px;</xsl:text>
                    </xsl:attribute>
                    <xsl:for-each select="child::*[starts-with(name(), 'list')]">
                        <li>
                            <xsl:choose>
                                <xsl:when test="name() = 'listPlace'">
                                    <i title="Orte" class="fa-solid fa-location-dot"/>&#160;Orte </xsl:when>
                                <xsl:when test="name() = 'listPerson'">
                                    <i class="fa-solid fa-users" title="Personen"/>&#160;Personen </xsl:when>
                                <xsl:when test="name() = 'listOrg'">
                                    <i class="fa-solid fa-building-columns" title="Organisationen"
                                    />&#160; Organisationen </xsl:when>
                                <xsl:when test="name() = 'listBibl'">
                                    <i title="Werke" class="fa-regular fa-image"/>&#160;Werke
                                </xsl:when>
                            </xsl:choose>
                            <xsl:apply-templates select="." mode="desc"/>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:if>
            <xsl:if
                test="tei:*[not(self::tei:listPerson or self::tei:listBibl or self::tei:listPlace or self::tei:listOrg)]">
                <xsl:apply-templates
                    select="tei:*[not(self::tei:listPerson or self::tei:listBibl or self::tei:listPlace or self::tei:listOrg)]"
                    mode="desc"/>
            </xsl:if>
            <xsl:if test="text()[not(normalize-space(.) = '')]">
                <p>
                    <xsl:value-of select="normalize-space(text()[not(normalize-space(.) = '')])"/>
                </p>
            </xsl:if>
        </li>
    </xsl:template>
    <xsl:template match="tei:listPerson" mode="desc">
        <xsl:variable name="e-typ" select="ancestor::tei:event/tei:idno/@type"/>
        <xsl:variable name="e-type-farbe">
            <xsl:choose>
                <xsl:when test="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color != '#fff'">
                    <xsl:value-of select="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>blue</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div class="list-container">
            <ul class="horizontal-list">
                <xsl:attribute name="style">
                    <xsl:text>--dot-color: </xsl:text>
                    <xsl:value-of select="$e-type-farbe"/>
                    <xsl:text>;</xsl:text>
                </xsl:attribute>
                <xsl:for-each select="tei:person/tei:persName">
                    <xsl:variable name="ref" select="concat(@ref, @key)"/>
                    <xsl:choose>
                        <xsl:when
                            test="starts-with($ref, 'https://d-nb') or starts-with($ref, 'http://d-nb') and $e-typ = 'schnitzler-cmif'">
                            <xsl:variable name="normalize-gnd-ohne-http"
                                select="replace($ref, 'https', 'http')" as="xs:string"/>
                            <xsl:element name="li">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://correspsearch.net/de/suche.html?s=', $normalize-gnd-ohne-http)"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when
                            test="$e-typ = 'schnitzler-tagebuch' and starts-with($ref, 'person_')">
                            <xsl:element name="li">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://schnitzler-tagebuch.acdh.oeaw.ac.at/', $ref, '.html')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when
                            test="$e-typ = 'schnitzler-tagebuch' and starts-with($ref, 'person_')">
                            <xsl:element name="li">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://schnitzler-tagebuch.acdh.oeaw.ac.at/', $ref, '.html')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when
                            test="$e-typ = 'schnitzler-events' and (starts-with($ref, 'pmb') or starts-with($ref, 'person_'))">
                            <xsl:element name="li">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://pmb.acdh.oeaw.ac.at/entity/', replace(replace($ref, 'pmb', ''), 'person_', ''), '/')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="starts-with($ref, 'pmb') or starts-with($ref, 'person_')">
                            <xsl:element name="li">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://', $e-typ, '.acdh.oeaw.ac.at/', $ref, '.html')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <li>
                                <xsl:value-of select="."/>
                            </li>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> </xsl:text>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="tei:listOrg" mode="desc">
        <xsl:variable name="e-typ" select="ancestor::tei:event/tei:idno/@type"/>
        <xsl:variable name="e-type-farbe">
            <xsl:choose>
                <xsl:when test="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color != '#fff'">
                    <xsl:value-of select="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>blue</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div class="list-container">
            <ul class="horizontal-list">
                <xsl:attribute name="style">
                    <xsl:text>--dot-color: </xsl:text>
                    <xsl:value-of select="$e-type-farbe"/>
                    <xsl:text>;</xsl:text>
                </xsl:attribute>
                <xsl:for-each select="tei:org/tei:orgName">
                    <xsl:variable name="ref" select="concat(@ref, @key)"/>
                    <xsl:choose>
                        <xsl:when
                            test="starts-with($ref, 'https://d-nb') or starts-with($ref, 'http://d-nb') and $e-typ = 'schnitzler-cmif'">
                            <xsl:variable name="normalize-gnd-ohne-http"
                                select="replace($ref, 'https', 'http')" as="xs:string"/>
                            <xsl:element name="li">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://correspsearch.net/de/suche.html?s=', $normalize-gnd-ohne-http)"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$e-typ = 'schnitzler-events' and starts-with($ref, 'pmb')">
                            <xsl:element name="li">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://pmb.acdh.oeaw.ac.at/entity/', replace(replace($ref, 'pmb', ''), 'person_', ''), '/')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="starts-with($ref, 'pmb')">
                            <xsl:element name="li">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://', $e-typ, '.acdh.oeaw.ac.at/', $ref, '.html')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> </xsl:text>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="tei:listPlace" mode="desc">
        <xsl:variable name="e-typ" select="ancestor::tei:event/tei:idno/@type"/>
        <xsl:variable name="e-type-farbe">
            <xsl:choose>
                <xsl:when test="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color != '#fff'">
                    <xsl:value-of select="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>blue</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div class="list-container">
            <xsl:choose>
                <xsl:when test="$e-typ = 'wienerschnitzler'">
                    <ul>
                        <xsl:attribute name="style">
                            <xsl:text>--dot-color: </xsl:text>
                            <xsl:value-of select="$e-type-farbe"/>
                            <xsl:text>;</xsl:text>
                        </xsl:attribute>
                        <xsl:for-each select="tei:place">
                            <xsl:variable name="ref" select="replace(@corresp, '#', '')"/>
                            <xsl:element name="li">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:choose>
                                            <xsl:when
                                                test="starts-with($ref, 'pmb')">
                                                <xsl:value-of
                                                  select="concat('https://www.wienerschnitzler.org/', $ref, '.html')"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
                                                  select="concat('https://www.wienerschnitzler.org/pmb', $ref, '.html')"
                                                />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="tei:placeName[1]"/>
                                </xsl:element>
                                <xsl:if test="tei:listPlace">
                                    <xsl:apply-templates select="tei:listPlace" mode="desc"/>
                                </xsl:if>
                            </xsl:element>
                        </xsl:for-each>
                    </ul>
                </xsl:when>
                <xsl:otherwise>
                    <ul class="horizontal-list">
                        <xsl:attribute name="style">
                            <xsl:text>--dot-color: </xsl:text>
                            <xsl:value-of select="$e-type-farbe"/>
                            <xsl:text>;</xsl:text>
                        </xsl:attribute>
                        <xsl:for-each select="tei:place/tei:placeName">
                            <xsl:variable name="ref" select="concat(@ref, @key)"/>
                            <xsl:choose>
                                <xsl:when
                                    test="$e-typ = 'schnitzler-events' and starts-with($ref, 'pmb')">
                                    <xsl:element name="li">
                                        <xsl:element name="a">
                                            <xsl:attribute name="href">
                                                <xsl:value-of
                                                  select="concat('https://pmb.acdh.oeaw.ac.at/entity/', replace(replace($ref, 'pmb', ''), 'person_', ''), '/')"
                                                />
                                            </xsl:attribute>
                                            <xsl:attribute name="target">
                                                <xsl:text>_blank</xsl:text>
                                            </xsl:attribute>
                                            <xsl:value-of select="."/>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:when test="starts-with($ref, 'pmb')">
                                    <xsl:element name="li">
                                        <xsl:element name="a">
                                            <xsl:attribute name="href">
                                                <xsl:value-of
                                                  select="concat('https://', $e-typ, '.acdh.oeaw.ac.at/', $ref, '.html')"
                                                />
                                            </xsl:attribute>
                                            <xsl:attribute name="target">
                                                <xsl:text>_blank</xsl:text>
                                            </xsl:attribute>
                                            <xsl:value-of select="."/>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text> </xsl:text>
                        </xsl:for-each>
                    </ul>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <xsl:template match="tei:desc/tei:listBibl" mode="desc">
        <xsl:variable name="e-typ" select="ancestor::tei:event/tei:idno/@type"/>
        <xsl:variable name="e-type-farbe">
            <xsl:choose>
                <xsl:when test="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color != '#fff'">
                    <xsl:value-of select="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>blue</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div class="list-container">
            <ul class="horizontal-list">
                <xsl:attribute name="style">
                    <xsl:text>--dot-color: </xsl:text>
                    <xsl:value-of select="$e-type-farbe"/>
                    <xsl:text>;</xsl:text>
                </xsl:attribute>
                <xsl:for-each select="descendant::tei:title">
                    <xsl:variable name="ref" select="concat(@ref, @key)"/>
                    <xsl:choose>
                        <xsl:when test="$e-typ = 'schnitzler-events' and starts-with($ref, 'pmb')">
                            <xsl:element name="li">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://pmb.acdh.oeaw.ac.at/entity/', replace(replace($ref, 'pmb', ''), 'person_', ''), '/')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:choose>
                                        <!-- Titel werden nur bis 50 Zeichen wiedergegeben -->
                                        <xsl:when test="string-length(normalize-space(.)) &gt; 50">
                                            <xsl:value-of
                                                select="substring(normalize-space(.), 1, 50)"/>
                                            <xsl:text>…</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="."/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="starts-with($ref, 'pmb')">
                            <xsl:element name="li">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://', $e-typ, '.acdh.oeaw.ac.at/', $ref, '.html')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:choose>
                                        <!-- Titel werden nur bis 50 Zeichen wiedergegeben -->
                                        <xsl:when test="string-length(normalize-space(.)) &gt; 50">
                                            <xsl:value-of
                                                select="substring(normalize-space(.), 1, 50)"/>
                                            <xsl:text>…</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="."/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> </xsl:text>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="tei:bibl[parent::tei:desc]" mode="desc">
        <p>
            <xsl:text>Quelle: </xsl:text>
            <i>
                <xsl:value-of select="."/>
            </i>
        </p>
    </xsl:template>
    <xsl:function name="mam:hexNachRGBfarbe">
        <xsl:param name="hexColor" as="xs:string"/>
        <xsl:variable name="red" select="substring($hexColor, 2, 2)"/>
        <xsl:variable name="green" select="substring($hexColor, 4, 2)"/>
        <xsl:variable name="blue" select="substring($hexColor, 6, 2)"/>
        <xsl:variable name="red-dec" select="mam:hexToDec($red)"/>
        <xsl:variable name="green-dec" select="mam:hexToDec($green)"/>
        <xsl:variable name="blue-dec" select="mam:hexToDec($blue)"/>
        <xsl:value-of select="concat($red-dec, ', ', $green-dec, ', ', $blue-dec)"/>
    </xsl:function>
    <xsl:function name="mam:hexToDec">
        <xsl:param name="hex"/>
        <!-- Konvertiere Kleinbuchstaben in Großbuchstaben -->
        <xsl:variable name="uppercaseHex" select="translate($hex, 'abcdef', 'ABCDEF')"/>
        <xsl:variable name="dec"
            select="string-length(substring-before('0123456789ABCDEF', substring($uppercaseHex, 1, 1)))"/>
        <xsl:choose>
            <xsl:when test="matches($uppercaseHex, '([0-9]*|[A-F]*)')">
                <xsl:value-of select="
                        if ($uppercaseHex = '') then
                            0
                        else
                            $dec * mam:power(16, string-length($uppercaseHex) - 1) + mam:hexToDec(substring($uppercaseHex, 2))"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>Provided value is not hexadecimal...</xsl:message>
                <xsl:value-of select="$hex"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="mam:power">
        <xsl:param name="base"/>
        <xsl:param name="exp"/>
        <xsl:sequence select="
                if ($exp lt 0) then
                    mam:power(1.0 div $base, -$exp)
                else
                    if ($exp eq 0)
                    then
                        1e0
                    else
                        $base * mam:power($base, $exp - 1)"/>
    </xsl:function>
    <xsl:template name="karte-mit-datum">
        <xsl:param name="datum"/>
        <!-- HTML- und JS-Teil -->
        <div id="collapseMap">
            <div id="wienerschnitzler-map" style="height: 300px;" data-datum="{$datum}"/>
        </div>
        <script src="https://cdn.jsdelivr.net/gh/arthur-schnitzler/schnitzler-chronik-static@418b500/xslt/export/wienerschnitzler-map.js?v=4"></script>
    </xsl:template>
</xsl:stylesheet>
