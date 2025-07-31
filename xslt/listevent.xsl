<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes"
        omit-xml-declaration="yes"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/event.xsl"/>
    <!--<xsl:import href="./partials/blockquote.xsl"/>-->
    <xsl:import href="./partials/tabulator_js.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:titleStmt/tei:title[1]/text()"/>
        </xsl:variable>
        <html class="h-100" lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="'Verzeichnis der Ereignisse'"/>
                </xsl:call-template>
                <link href="vendor/tabulator-tables/css/tabulator_bootstrap5.min.css"
                    rel="stylesheet"/>
                    
                    
            </head>
            <body class="d-flex flex-column h-100">
                <xsl:call-template name="nav_bar"/>
                <main class="flex-shrink-0 flex-grow-1">
                    <div class="container">
                        <h1>
                            <xsl:text>Verzeichnis der Veranstaltungen</xsl:text>
                        </h1>
                        <div class="text-center p-1"><span id="counter1"/> von <span id="counter2"/>
                            Ereignissen</div>
                        <table class="table table-sm display" id="tabulator-table-event">
                            <thead>
                                <tr>
                                    <th scope="col" tabulator-headerFilter="input"
                                        tabulator-formatter="html">Datum</th>
                                    <th scope="col" tabulator-headerFilter="input"
                                        tabulator-formatter="html">Ereignis</th>
                                    <th scope="col" tabulator-headerFilter="input"
                                        tabulator-formatter="html">Werk</th>
                                    <th scope="col" tabulator-headerFilter="input"
                                        tabulator-formatter="html">Ort</th>
                                    <th scope="col" tabulator-headerFilter="input"
                                        tabulator-formatter="html">Typ</th>
                                    <th scope="col" tabulator-headerFilter="input"
                                        tabulator-formatter="html">Arbeitskraft</th>
                                    <th scope="col" tabulator-headerFilter="input"
                                        tabulator-formatter="html">Teilnehmer_innen</th>
                                    <th scope="col" tabulator-headerFilter="input"
                                        tabulator-formatter="html">Organisation</th>
                                    
                                    
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select=".//tei:event[@xml:id]">
                                    <xsl:variable name="id">
                                        <xsl:value-of select="data(@xml:id)"/>
                                    </xsl:variable>
                                    <xsl:variable name="idhtml" select="concat($id, '.html')"/>
                                    <tr>
                                        <td>
                                            <xsl:value-of select="@when-iso"/>
                                        </td>
                                        <td>
                                            <span hidden="hidden">
                                                <xsl:value-of select="./tei:eventName[1]/text()"/>
                                            </span>
                                            <a>
                                                <xsl:attribute name="href">
                                                  <xsl:value-of select="$idhtml"/>
                                                </xsl:attribute>
                                                <xsl:value-of select="./tei:eventName[1]/text()"/>
                                            </a>
                                        </td>
                                        
                                        <td>
                                            <xsl:for-each
                                                select="tei:listBibl/tei:bibl[not(tei:note[contains(., 'rezensi')]) and normalize-space(tei:title)]">
                                                <xsl:element name="a">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat(tei:title/@key, '.html')"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of select="normalize-space(tei:title)"
                                                  />
                                                </xsl:element>
                                                <xsl:if test="not(position() = last())">
                                                  <br/>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </td>
                                        <td>
                                            <xsl:for-each select="tei:listPlace/tei:place">
                                                <xsl:element name="a">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat(tei:placeName/@key, '.html')"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of select="tei:placeName"/>
                                                </xsl:element>
                                                <xsl:if test="not(position() = last())">
                                                  <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </td>
                                        <td>
                                            <xsl:value-of select="tei:eventName/@n"/>
                                        </td>
                                        <td>
                                            <xsl:if
                                                test="tei:listPerson/tei:person[@role = 'hat als Arbeitskraft']/tei:persName/@key = 'pmb2121'">
                                                <xsl:text>AS</xsl:text>
                                                <xsl:if
                                                    test="tei:listPerson/tei:person[@role = 'hat als Arbeitskraft'][2]">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:if>
                                            <xsl:for-each
                                                select="tei:listPerson/tei:person[@role = 'hat als Arbeitskraft' and not(tei:persName/@key = 'pmb2121')]">
                                                <xsl:variable name="name" select="tei:persName"/>
                                                <xsl:choose>
                                                    <!-- Wenn genau ein Komma enthalten ist -->
                                                    <xsl:when
                                                        test="matches($name, '^[^,]+,\s*[^,]+$')">
                                                        <xsl:element name="a">
                                                            <xsl:attribute name="href">
                                                                <xsl:value-of select="concat($name/@key, '.html')"
                                                                />
                                                            </xsl:attribute>
                                                            <xsl:analyze-string select="$name"
                                                                regex="^([^,]+),\s*(.+)$">
                                                                <xsl:matching-substring>
                                                                    <xsl:value-of select="regex-group(2)"/>
                                                                    <xsl:text> </xsl:text>
                                                                    <xsl:value-of select="regex-group(1)"/>
                                                                </xsl:matching-substring>
                                                                <xsl:non-matching-substring>
                                                                    <xsl:value-of select="."/>
                                                                </xsl:non-matching-substring>
                                                            </xsl:analyze-string>
                                                        </xsl:element>
                                                    </xsl:when>
                                                    <!-- Wenn kein oder mehr als ein Komma enthalten ist -->
                                                    <xsl:otherwise>
                                                        <xsl:element name="a">
                                                            <xsl:attribute name="href">
                                                                <xsl:value-of select="concat($name/@key, '.html')"
                                                                />
                                                            </xsl:attribute>
                                                            <xsl:value-of select="$name"/>
                                                        </xsl:element>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <!-- Semikolon nur, wenn nicht letztes Element -->
                                                <xsl:if test="not(position() = last())">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </td>
                                        <td>
                                            <xsl:if
                                                test="tei:listPerson/tei:person[@role = 'hat als Teilnehmer:in']/tei:persName/@key = 'pmb2121'">
                                                <xsl:text>AS</xsl:text>
                                                <xsl:if
                                                    test="tei:listPerson/tei:person[@role = 'hat als Teilnehmer:in'][2]">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:if>
                                            <xsl:for-each
                                                select="tei:listPerson/tei:person[@role = 'hat als Teilnehmer:in' and not(tei:persName/@key = 'pmb2121')]">
                                                <xsl:variable name="name" select="tei:persName"/>
                                                <xsl:choose>
                                                    <!-- Wenn genau ein Komma enthalten ist -->
                                                    <xsl:when
                                                        test="matches($name, '^[^,]+,\s*[^,]+$')">
                                                        <xsl:element name="a">
                                                            <xsl:attribute name="href">
                                                                <xsl:value-of select="concat($name/@key, '.html')"
                                                                />
                                                            </xsl:attribute>
                                                            <xsl:analyze-string select="$name"
                                                                regex="^([^,]+),\s*(.+)$">
                                                                <xsl:matching-substring>
                                                                    <xsl:value-of select="regex-group(2)"/>
                                                                    <xsl:text> </xsl:text>
                                                                    <xsl:value-of select="regex-group(1)"/>
                                                                </xsl:matching-substring>
                                                                <xsl:non-matching-substring>
                                                                    <xsl:value-of select="."/>
                                                                </xsl:non-matching-substring>
                                                            </xsl:analyze-string>
                                                        </xsl:element>
                                                    </xsl:when>
                                                    <!-- Wenn kein oder mehr als ein Komma enthalten ist -->
                                                    <xsl:otherwise>
                                                        <xsl:element name="a">
                                                            <xsl:attribute name="href">
                                                                <xsl:value-of select="concat($name/@key, '.html')"
                                                                />
                                                            </xsl:attribute>
                                                            <xsl:value-of select="$name"/>
                                                        </xsl:element>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <!-- Semikolon nur, wenn nicht letztes Element -->
                                                <xsl:if test="not(position() = last())">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </td>
                                        <td>
                                            <xsl:for-each
                                                select="tei:note[@type = 'listorg']/tei:listOrg/tei:org">
                                                <xsl:element name="a">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat(tei:orgName/@key, '.html')"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of select="tei:orgName"/>
                                                </xsl:element>
                                                <xsl:if test="not(position() = last())">
                                                  <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </td>
                                        
                                        
                                        <!--<td>
                                            <a>
                                                <xsl:attribute name="href">
                                                  <xsl:value-of select="$idhtml"/>
                                                </xsl:attribute>
                                                <xsl:value-of select="$id"/>
                                            </a>
                                        </td>-->
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>
                        <xsl:call-template name="tabulator_dl_buttons"/>
                        <!--<div class="text-center p-4">
                            <xsl:call-template name="blockquote">
                                <xsl:with-param name="pageId" select="'listevent.html'"/>
                            </xsl:call-template>
                        </div>-->
                    </div>
                </main>
                <xsl:call-template name="html_footer"/>
                <script type="text/javascript" src="https://unpkg.com/tabulator-tables@6.2.1/dist/js/tabulator.min.js"/>
                <script src="tabulator-js/tabulator_event.js"/>
            </body>
        </html>
        <xsl:for-each select=".//tei:event[@xml:id]">
            <xsl:variable name="filename" select="concat(./@xml:id, '.html')"/>
            <xsl:variable name="name"
                select="normalize-space(string-join(./tei:eventName[1]//text()))"/>
            <xsl:result-document href="{$filename}">
                <html class="h-100" lang="{$default_lang}">
                    <head>
                        <xsl:call-template name="html_head">
                            <xsl:with-param name="html_title" select="$name"/>
                        </xsl:call-template>
                        <link rel="stylesheet"
                            href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
                            integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
                            crossorigin=""/>
                        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""/>
                        <link rel="stylesheet"
                            href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.css"/>
                        <link rel="stylesheet"
                            href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.Default.css"/>
                        <script src="https://unpkg.com/leaflet.markercluster@1.4.1/dist/leaflet.markercluster.js"/>
                    </head>
                    <body class="d-flex flex-column h-100">
                        <xsl:call-template name="nav_bar"/>
                        <main class="flex-shrink-0 flex-grow-1">
                            <div class="container">
                                <h1>
                                    <xsl:value-of select="$name"/>
                                </h1>
                                <xsl:call-template name="event_detail">
                                    
                                </xsl:call-template>
                            </div>
                        </main>
                        <xsl:call-template name="html_footer"/>
                    </body>
                    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
                        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
                        crossorigin=""/>
                    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""/>
                    <script>
                            var lat = <xsl:value-of select="replace(tokenize(descendant::tei:location[1]/tei:geo[1]/text(), ' ')[1], ',', '.')"/>;
                            var long = <xsl:value-of select="replace(tokenize(descendant::tei:location[1]/tei:geo[1]/text(), ' ')[2], ',', '.')"/>;
                            $("#map_detail").css("height", "300px");
                            var map = L.map('map_detail').setView([Number(lat), Number(long)], 13);
                            L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
                            maxZoom: 19,
                            attribution: '&amp;copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &amp;copy; <a href="https://carto.com/attributions">CARTO</a>'
                            }).addTo(map);
                            var marker = L.marker([Number(lat), Number(long)]).addTo(map);
                        </script>
                    <link
                        href="https://unpkg.com/tabulator-tables@6.2.1/dist/css/tabulator_bootstrap5.min.css"
                        rel="stylesheet"/>
                    
                </html>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
