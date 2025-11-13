<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://dse-static.foo.bar"
    xmlns:mam="whatever" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes"
        omit-xml-declaration="yes"/>
    <!-- This documentation is late in being generated thus it might not fully reflect what is going on 
    here. The idea is to call the templates in this file something like this:
    
    <xsl:import href="https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-chronik-static/refs/heads/main/xslt/export/schnitzler-chronik.xsl"/>
    <xsl:param name="schnitzler-chronik_fetch-locally" as="xs:boolean" select="true()"/>
    <xsl:param name="schnitzler-chronik_current-type" as="xs:string" select="'schnitzler-briefe'"/>
    <xsl:variable name="fetchContentsFromURL" as="node()?">
                                    <xsl:choose>
                                        <xsl:when test="$schnitzler-chronik_fetch-locally">
                                            <xsl:copy-of
                                                select="document(concat('../chronik-data/', $datum-iso, '.xml'))"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:copy-of
                                                select="document(concat('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-chronik-data/refs/heads/main/editions/data/', $datum-iso, '.xml'))"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:call-template name="mam:schnitzler-chronik">
                                    <xsl:with-param name="datum-iso" select="$datum-iso"/>
                                    <xsl:with-param name="current-type" select="$schnitzler-chronik_current-type"/>
                                    <xsl:with-param name="teiSource" select="$teiSource"/>
                                    <xsl:with-param name="fetchContentsFromURL" select="$fetchContentsFromURL"/>
                                    <xsl:with-param name="relevant-eventtypes" select="''"/>
                                </xsl:call-template>
                                
    where teiSource lists the current filename/xml:id without .xml-ending. This is to make sure the chronik doesn't reduplicate it, i.e. 'L000122'
    
   fetchContentsFromURL already contains the chronik-day. this allows for local processing of the chronik, which increases the speed
        
   -->
    <xsl:param name="relevant-uris"
        select="document('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-chronik-static/refs/heads/main/xslt/export/list-of-relevant-uris.xml')"/>
    <!--<xsl:param name="relevant-uris" select="document('list-of-relevant-uris.xml')"/>-->
    <xsl:import href="./LOD-idnos.xsl"/>
    <xsl:key match="item" use="abbr" name="relevant-uris-type"/>
    <xsl:template name="mam:schnitzler-chronik">
        <xsl:param name="datum-iso" as="xs:date"/>
        <xsl:param name="current-type" as="xs:string"/>
        <xsl:param name="teiSource" as="xs:string"/>
        <xsl:param name="fetchContentsFromURL" as="node()?"/>
        <xsl:param name="import-eventtypes" as="xs:string?"/>
        <xsl:variable name="relevant-eventtypes" as="xs:string">
            <!-- falls keine typen übergeben werden, werden die standardwerte genommen -->
            <xsl:choose>
                <xsl:when test="empty($import-eventtypes)">
                    <xsl:text>Arthur-Schnitzler-digital,schnitzler-tagebuch,schnitzler-briefe,pollaczek,schnitzler-interviews,schnitzler-bahr,schnitzler-orte,wienerschnitzler,schnitzler-kultur,schnitzler-chronik-manuell,pmb,schnitzler-cmif,schnitzler-mikrofilme-daten,schnitzler-traeume,schnitzler-kino-buch,schnitzler-kempny-buch,kalliope-verbund</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$import-eventtypes"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="link">
            <xsl:value-of select="replace($teiSource, '.xml', '.html')"/>
        </xsl:variable>
        <xsl:if test="$fetchContentsFromURL/descendant::*:listEvent/*:event">
            <xsl:variable name="fetchURLohneTeiSource" as="node()">
                <xsl:element name="listEvent" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each select="$fetchContentsFromURL/descendant::*:listEvent/*:event">
                        <xsl:choose>
                            <xsl:when
                                test="*:idno[@type = $current-type or @subtype = $current-type][1]/contains(., $teiSource)"/>
                            <xsl:otherwise>
                                <xsl:copy-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose> 
                    </xsl:for-each>
                </xsl:element>
            </xsl:variable>
            <xsl:variable name="doc_title">
                <xsl:value-of
                    select="$fetchContentsFromURL/descendant::*:titleStmt[1]/*:title[@level = 'a'][1]/text()"
                />
            </xsl:variable>
            <div id="chronik-modal-body">
                <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"/>
                <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
                <xsl:call-template name="karte-mit-datum">
                    <xsl:with-param name="datum" select="$datum-iso"/>
                </xsl:call-template>
                <xsl:apply-templates select="$fetchURLohneTeiSource" mode="schnitzler-chronik">
                    <xsl:with-param name="relevant-eventtypes" select="$relevant-eventtypes"/>
                </xsl:apply-templates>
                <div class="weiteres" style="margin-top:2.5em;">
                    <xsl:variable name="datum-written" select="
                            format-date($datum-iso, '[D1].&#160;[M1].&#160;[Y0001]',
                            'en',
                            'AD',
                            'EN')"/>
                    <xsl:variable name="wochentag">
                        <xsl:choose>
                            <xsl:when test="
                                    format-date($datum-iso, '[F]',
                                    'en',
                                    'AD',
                                    'EN') = 'Monday'">
                                <xsl:text>Montag</xsl:text>
                            </xsl:when>
                            <xsl:when test="
                                    format-date($datum-iso, '[F]',
                                    'en',
                                    'AD',
                                    'EN') = 'Tuesday'">
                                <xsl:text>Dienstag</xsl:text>
                            </xsl:when>
                            <xsl:when test="
                                    format-date($datum-iso, '[F]',
                                    'en',
                                    'AD',
                                    'EN') = 'Wednesday'">
                                <xsl:text>Mittwoch</xsl:text>
                            </xsl:when>
                            <xsl:when test="
                                    format-date($datum-iso, '[F]',
                                    'en',
                                    'AD',
                                    'EN') = 'Thursday'">
                                <xsl:text>Donnerstag</xsl:text>
                            </xsl:when>
                            <xsl:when test="
                                    format-date($datum-iso, '[F]',
                                    'en',
                                    'AD',
                                    'EN') = 'Friday'">
                                <xsl:text>Freitag</xsl:text>
                            </xsl:when>
                            <xsl:when test="
                                    format-date($datum-iso, '[F]',
                                    'en',
                                    'AD',
                                    'EN') = 'Saturday'">
                                <xsl:text>Samstag</xsl:text>
                            </xsl:when>
                            <xsl:when test="
                                    format-date($datum-iso, '[F]',
                                    'en',
                                    'AD',
                                    'EN') = 'Sunday'">
                                <xsl:text>Sonntag</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>DATUMSFEHLER</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <h3>Weiteres</h3>
                    <ul>
                        <li>
                            <xsl:text>Zeitungen vom </xsl:text>
                            <xsl:element name="a">
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                        select="concat('https://anno.onb.ac.at/cgi-content/anno?datum=', replace(string($datum-iso), '-', ''))"
                                    />
                                </xsl:attribute>
                                <xsl:attribute name="target">
                                    <xsl:text>_blank</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="concat($wochentag, ', ', $datum-written)"/>
                            </xsl:element>
                            <xsl:text> bei </xsl:text>
                            <xsl:element name="a">
                                <xsl:attribute name="style">
                                    <xsl:text>color: black;</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                        select="concat('https://anno.onb.ac.at/cgi-content/anno?datum=', replace(string($datum-iso), '-', ''))"
                                    />
                                </xsl:attribute>
                                <xsl:attribute name="target">
                                    <xsl:text>_blank</xsl:text>
                                </xsl:attribute>
                                <xsl:text>ANNO</xsl:text>
                            </xsl:element>
                        </li>
                        <li>
                            <xsl:text>Briefe vom </xsl:text>
                            <xsl:element name="a">
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                        select="concat('https://correspsearch.net/de/suche.html?d=', $datum-iso, '&amp;x=1&amp;w=0')"
                                    />
                                </xsl:attribute>
                                <xsl:attribute name="target">
                                    <xsl:text>_blank</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="concat($wochentag, ', ', $datum-written)"/>
                            </xsl:element>
                            <xsl:text> bei </xsl:text>
                            <xsl:element name="a">
                                <xsl:attribute name="style">
                                    <xsl:text>color: black;</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                        select="concat('https://correspsearch.net/de/suche.html?d=', $datum-iso, '&amp;x=1&amp;w=0')"
                                    />
                                </xsl:attribute>
                                <xsl:attribute name="target">
                                    <xsl:text>_blank</xsl:text>
                                </xsl:attribute>
                                <xsl:text>correspSearch</xsl:text>
                            </xsl:element>
                        </li>
                    </ul>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:listEvent" mode="schnitzler-chronik">
        <xsl:param name="relevant-eventtypes"/>
        <xsl:variable name="current-group" select="." as="node()"/>
        <xsl:for-each select="tokenize($relevant-eventtypes, ',')">
            <xsl:variable name="e-typ" as="xs:string" select="."/>
            <xsl:for-each
                select="$current-group/tei:event[not(preceding-sibling::tei:event/tei:idno[@type = $e-typ or @subtype = $e-typ])]/tei:idno[@type = $e-typ or @subtype = $e-typ][1]">
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
                    <div class="card-header d-flex justify-content-between align-items-center"
                        style="background-color: rgba({$e-typ-farbe-blass}, 0.1)">
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
                                    select="$current-group/descendant::tei:idno[@type = $e-typ or @subtype = $e-typ][1]"
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
                            data-bs-target="#{$e-typ}" aria-expanded="false" aria-controls="content1"
                            style="cursor: pointer; user-select: none;">+</span>
                    </div>
                    <div class="collapse">
                        <xsl:attribute name="id">
                            <xsl:value-of select="$e-typ"/>
                        </xsl:attribute>
                        <div class="card-body">
                            <xsl:apply-templates
                                select="$current-group/tei:event[tei:idno/@type = $e-typ or tei:idno/@subtype = $e-typ]"/>
                        </div>
                    </div>
                </div>
                <xsl:for-each
                    select="tei:event[tei:idno/@type[not(contains($relevant-eventtypes, .))] and tei:idno/@subtype[not(contains($relevant-eventtypes, .))]]">
                    <!-- hier nun die einzelnen events -->
                    <div id="content1" class="collapse">
                        <xsl:apply-templates mode="desc"/>
                    </div>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="tei:event[tei:idno/@type[not(contains($relevant-eventtypes, .))] and tei:idno/@subtype[not(contains($relevant-eventtypes, .))]]">
            <xsl:apply-templates mode="desc"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:event">
        <!-- jeder einzelne eintrag -->
        <xsl:variable name="e-typ" select="(tei:idno/@type[. != 'URL'], tei:idno/@subtype)[1]"/>
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
        <xsl:if test="tei:head">
            <p>
                <xsl:choose>
                    <xsl:when test="$e-typ='wienerschnitzler'">
                        <xsl:element name="a">
                            <xsl:attribute name="class">
                                <xsl:text>entry-title</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat('http://wienerschnitzler.org/', replace(tei:head/@corresp, '#', ''), '.html')"/>
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
                            <xsl:attribute name="style">
                                <xsl:text>color: </xsl:text>
                                <xsl:value-of select="$e-typ-farbe"/>
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
                            <xsl:attribute name="style">
                                <xsl:text>color: </xsl:text>
                                <xsl:value-of select="$e-typ-farbe"/>
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
                            <xsl:attribute name="style">
                                <xsl:text>color: </xsl:text>
                                <xsl:value-of select="$e-typ-farbe"/>
                            </xsl:attribute>
                            <xsl:value-of select="tei:head/text()"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
        </xsl:if>
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
            <xsl:when test="tei:idno[@type = $e-typ or @subtype = $e-typ][2] and $e-typ-multiple">
                <xsl:for-each select="tei:idno[@type = $e-typ or @subtype = $e-typ]">
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
        <xsl:variable name="e-typ" select="ancestor::tei:event/tei:idno[1]/@type"/>
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
                <xsl:for-each select="tei:person/tei:persName[1]">
                    <xsl:variable name="ref" select="concat(@ref[1], @key[1])"/>
                    <xsl:element name="li">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with($ref, 'https://d-nb') or starts-with($ref, 'http://d-nb') and $e-typ = 'schnitzler-cmif'">
                                <xsl:variable name="normalize-gnd-ohne-http"
                                    select="replace($ref, 'https', 'http')" as="xs:string"/>
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
                            </xsl:when>
                            <xsl:when
                                test="$e-typ = 'schnitzler-tagebuch' and starts-with($ref, 'person_')">
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
                            </xsl:when>
                            <xsl:when
                                test="$e-typ = 'schnitzler-tagebuch' and starts-with($ref, 'person_')">
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
                            </xsl:when>
                            <xsl:when
                                test="$e-typ = 'schnitzler-kultur' and (starts-with($ref, 'pmb'))">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://schnitzler-kultur.acdh.oeaw.ac.at/', $ref, '.html')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when
                                test="starts-with($ref, 'pmb') or starts-with($ref, 'person_')">
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
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="tei:listOrg" mode="desc">
        <xsl:variable name="e-typ" select="ancestor::tei:event/tei:idno[1]/@type"/>
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
                    <xsl:element name="li">
                        <xsl:choose>
                            <xsl:when
                                test="starts-with($ref, 'https://d-nb') or starts-with($ref, 'http://d-nb') and $e-typ = 'schnitzler-cmif'">
                                <xsl:variable name="normalize-gnd-ohne-http"
                                    select="replace($ref, 'https', 'http')" as="xs:string"/>
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
                            </xsl:when>
                            <xsl:when
                                test="$e-typ = 'schnitzler-kultur' and (starts-with($ref, 'pmb'))">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://schnitzler-kultur.acdh.oeaw.ac.at/', $ref, '.html')"
                                        />
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="starts-with($ref, 'pmb')">
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
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="tei:listPlace" mode="desc">
        <xsl:variable name="e-typ" select="ancestor::tei:event/tei:idno[1]/@type"/>
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
                                    test="$e-typ = 'schnitzler-kultur' and (starts-with($ref, 'pmb'))">
                                    <xsl:element name="li">
                                        <xsl:element name="a">
                                            <xsl:attribute name="href">
                                                <xsl:value-of
                                                    select="concat('https://schnitzler-kultur.acdh.oeaw.ac.at/', $ref, '.html')"
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
        <xsl:variable name="e-typ" select="ancestor::tei:event/tei:idno[1]/@type"/>
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
                    <xsl:element name="li">
                        <xsl:choose>
                           
                              
                            <xsl:when
                                test="$e-typ = 'schnitzler-kultur' and (starts-with($ref, 'pmb'))">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                            select="concat('https://schnitzler-kultur.acdh.oeaw.ac.at/', $ref, '.html')"
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
                            </xsl:when>
                            <xsl:when test="starts-with($ref, 'pmb')">
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
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
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
        <div id="collapseMap">
            <div id="wienerschnitzler-map" style="height: 300px; width: 100%;" data-datum="{$datum}"></div>
        </div>
        
        <!-- Externes Leaflet-Script -->
        <script src="https://cdn.jsdelivr.net/gh/arthur-schnitzler/schnitzler-chronik-static@e250eac/xslt/export/wienerschnitzler-map.js?v=4"></script>
        
        <!-- Event-Handler für das Bootstrap-Modal -->
        <script>
            document.getElementById('schnitzler-chronik-modal').addEventListener('shown.bs.modal', function () {
            console.log('Modal shown event triggered');
            // Kurz warten, dann initialisieren
            setTimeout(function() {
            if (!window._wienerschnitzlerMapInitialized) {
            window.initWienerschnitzlerMap();
            window._wienerschnitzlerMapInitialized = true;
            }
            }, 100);
            });

            // Zusätzlich: Map zurücksetzen beim Schließen
            document.getElementById('schnitzler-chronik-modal').addEventListener('hidden.bs.modal', function () {
            window._wienerschnitzlerMapInitialized = false;
            });
        </script>
    </xsl:template>
</xsl:stylesheet>
