<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mam="whatever" version="2.0" exclude-result-prefixes="xsl tei xs">
    <!-- Imports, Parameter, Index-Variablen, Keys, Relationen-CSV und -Vokabular -->
    <xsl:include href="./entities-setup.xsl"/>
    <!-- PERSON -->
    <xsl:template match="tei:person" name="person_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000"/>
        <xsl:variable name="selfLink" select="concat(data(@xml:id), '.html')"/>
        <xsl:variable name="lemma-name" select="tei:persName[(position() = 1)]" as="node()"/>
        <xsl:variable name="namensformen" as="node()">
            <xsl:element name="listPerson">
                <xsl:for-each select="descendant::tei:persName[not(position() = 1)]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:element>
        </xsl:variable>
        <xsl:variable name="idnos" as="node()">
            <xsl:element name="idnos">
                <xsl:copy-of select="tei:idno"/>
            </xsl:element>
        </xsl:variable>
        <div class="card-body-index entity-layout">
            <!-- Linke Spalte: Steckbrief -->
            <div class="entity-sidebar">
                <xsl:choose>
                    <xsl:when test="tei:figure/tei:graphic/@url">
                        <div class="WikimediaContainer">
                            <div class="WikimediaLeft-div">
                                <figure>
                                    <img src="{tei:figure/tei:graphic/@url}" alt="Image"
                                        width="200px;"/>
                                </figure>
                            </div>
                            <div class="WikimediaRight-div">
                                <xsl:call-template name="person-namen-block">
                                    <xsl:with-param name="entity" select="."/>
                                    <xsl:with-param name="namensformen" select="$namensformen"/>
                                    <xsl:with-param name="surname-fallback"
                                        select="string($lemma-name//tei:surname)"/>
                                </xsl:call-template>
                            </div>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div>
                            <xsl:call-template name="person-namen-block">
                                <xsl:with-param name="entity" select="."/>
                                <xsl:with-param name="namensformen" select="$namensformen"/>
                            </xsl:call-template>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="lod-reihe">
                    <xsl:with-param name="idno" select="$idnos"/>
                </xsl:call-template>
                <xsl:call-template name="person-korrespondenz">
                    <xsl:with-param name="entity" select="."/>
                    <xsl:with-param name="lemma-name" select="$lemma-name"/>
                </xsl:call-template>
            </div>
            <!-- Rechte Spalte: Tabs -->
            <div class="entity-main">
                <div class="entity-tabs">
                    <button class="entity-tab-btn active" data-tab="tab-erwaehnungen">Erwähnungen</button>
                    <button class="entity-tab-btn" data-tab="tab-relationen"
                        >Relationen</button>
                </div>
                <div id="tab-erwaehnungen" class="entity-tab-panel active">
                    <xsl:call-template name="person-mentions">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                </div>
                <div id="tab-relationen" class="entity-tab-panel">
                    <xsl:call-template name="relationen-block">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- PERSON: Sub-Templates -->
    <!-- Hauptname (alle persName mit Kindelementen) -->
    <xsl:template name="person-hauptname">
        <xsl:param name="namen" as="node()*"/>
        <xsl:for-each select="$namen">
            <p class="personenname">
                <xsl:choose>
                    <xsl:when test="./tei:forename/text() and ./tei:surname/text()">
                        <xsl:value-of
                            select="concat(./tei:forename/text(), ' ', ./tei:surname/text())"/>
                    </xsl:when>
                    <xsl:when test="./tei:forename/text()">
                        <xsl:value-of select="./tei:forename/text()"/>
                    </xsl:when>
                    <xsl:when test="./tei:surname/text()">
                        <xsl:value-of select="./tei:surname/text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
        </xsl:for-each>
    </xsl:template>
    <!-- Geburtsname; surname-fallback wird nur in der Wikimedia-Variante verwendet -->
    <xsl:template name="person-geburtsname">
        <xsl:param name="namen" as="node()*"/>
        <xsl:param name="surname-fallback" as="xs:string?" select="''"/>
        <xsl:variable name="geb_v" select="$namen[@type = 'person_geburtsname_vorname']"/>
        <xsl:variable name="geb_n" select="$namen[@type = 'person_geburtsname_nachname']"/>
        <xsl:if test="$geb_v or $geb_n">
            <p class="personenname">
                <xsl:text>geboren </xsl:text>
                <xsl:choose>
                    <xsl:when test="$geb_v and $geb_n">
                        <xsl:value-of select="concat($geb_v[1], ' ', $geb_n[1])"/>
                    </xsl:when>
                    <xsl:when test="$geb_v and $surname-fallback != ''">
                        <xsl:value-of select="concat($geb_v[1], ' ', $surname-fallback)"/>
                    </xsl:when>
                    <xsl:when test="$geb_v">
                        <xsl:value-of select="$geb_v[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$geb_n[1]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
        </xsl:if>
    </xsl:template>
    <!-- Berufsangaben (occupation) – sex-spezifische Form, '>>'-Bereinigung -->
    <xsl:template name="person-berufe">
        <xsl:param name="entity" as="node()"/>
        <xsl:if test="$entity//tei:occupation">
            <p>
                <i>
                    <xsl:for-each select="$entity/descendant::tei:occupation">
                        <xsl:variable name="beruf" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="contains(., '&gt;&gt;')">
                                    <xsl:value-of select="tokenize(., '&gt;&gt;')[last()]"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$entity/tei:sex/@value = 'male'">
                                <xsl:value-of select="tokenize($beruf, '/')[1]"/>
                            </xsl:when>
                            <xsl:when test="$entity/tei:sex/@value = 'female'">
                                <xsl:value-of select="tokenize($beruf, '/')[2]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$beruf"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="not(position() = last())">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </i>
            </p>
        </xsl:if>
    </xsl:template>
    <!-- Gesamtblock Hauptname + Geburtsname + Namensvarianten + Berufe -->
    <xsl:template name="person-namen-block">
        <xsl:param name="entity" as="node()"/>
        <xsl:param name="namensformen" as="node()"/>
        <xsl:param name="surname-fallback" as="xs:string?" select="''"/>
        <xsl:call-template name="person-hauptname">
            <xsl:with-param name="namen"
                select="$namensformen/descendant::tei:persName[descendant::*]"/>
        </xsl:call-template>
        <xsl:call-template name="person-geburtsname">
            <xsl:with-param name="namen" select="$namensformen/descendant::tei:persName"/>
            <xsl:with-param name="surname-fallback" select="$surname-fallback"/>
        </xsl:call-template>
        <xsl:call-template name="persName-gruppen">
            <xsl:with-param name="namen"
                select="$namensformen/descendant::tei:persName[not(descendant::*) and @type != 'person_geburtsname_vorname' and @type != 'person_geburtsname_nachname']"
            />
        </xsl:call-template>
        <xsl:call-template name="person-berufe">
            <xsl:with-param name="entity" select="$entity"/>
        </xsl:call-template>
    </xsl:template>
    <!-- Korrespondenz-Block (nur schnitzler-briefe) -->
    <xsl:template name="person-korrespondenz">
        <xsl:param name="entity" as="node()"/>
        <xsl:param name="lemma-name" as="node()"/>
        <xsl:if test="$current-edition = 'schnitzler-briefe'">
            <xsl:variable name="person-ref" as="xs:string"
                select="concat('#pmb', replace(replace($entity/@xml:id, 'person__', ''), 'pmb', ''))"/>
            <xsl:variable name="correspondence"
                select="key('correspondence-lookup', $person-ref, $listcorrespondence)"/>
            <xsl:if test="$correspondence">
                <div class="korrespondenz">
                    <legend>Korrespondenz</legend>
                    <ul class="dashed">
                        <li>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                        select="concat('toc_', replace($correspondence/@xml:id, 'correspondence_', ''), '.html')"
                                    />
                                </xsl:attribute>
                                <xsl:text>Zum Briefwechsel Schnitzler – </xsl:text>
                                <xsl:value-of select="$lemma-name"/>
                            </a>
                        </li>
                    </ul>
                </div>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!-- Mentions-Block (entweder aus events oder aus tei:note[@type='mentions']) -->
    <xsl:template name="person-mentions">
        <xsl:param name="entity" as="node()"/>
        <xsl:choose>
            <xsl:when test="$current-edition = 'schnitzler-kultur'">
                <xsl:variable name="notes" as="node()">
                    <xsl:call-template name="fill-event-variable">
                        <xsl:with-param name="xmlid" select="$entity/@xml:id"/>
                        <xsl:with-param name="entitityType" select="'persName'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="list-all-mentions">
                    <xsl:with-param name="mentions" select="$notes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$entity//tei:note[@type = 'mentions'][1]">
                <xsl:variable name="mentionsGrp">
                    <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:copy-of select="$entity//tei:note[@type = 'mentions']"/>
                    </xsl:element>
                </xsl:variable>
                <xsl:call-template name="list-all-mentions">
                    <xsl:with-param name="mentions" select="$mentionsGrp"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="fill-event-variable" as="node()">
        <xsl:param name="xmlid" as="xs:string"/>
        <xsl:param name="entitityType" as="xs:string"/>
        <xsl:variable name="matchingEvents"
            select="$events/tei:event[descendant::*[name() = $entitityType]/@key = $xmlid]"/>
        <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="$matchingEvents">
                <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>mentions</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="target">
                        <xsl:value-of select="@xml:id"/>
                    </xsl:attribute>
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="@when-iso"/>
                    </xsl:attribute>
                    <xsl:value-of select="tei:eventName"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <!-- WORK / WERKE -->
    <xsl:template match="tei:listBibl/tei:bibl" name="work_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000"/>
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="card-body-index entity-layout">
            <xsl:variable name="idnos" as="node()">
                <xsl:element name="idnos">
                    <xsl:copy-of select="tei:idno"/>
                </xsl:element>
            </xsl:variable>
            <!-- Linke Spalte: Steckbrief -->
            <div class="entity-sidebar">
                <xsl:call-template name="lod-reihe">
                    <xsl:with-param name="idno" select="$idnos"/>
                </xsl:call-template>
                <xsl:if test="tei:author">
                    <xsl:call-template name="work-erscheinungsdatum">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="work-links">
                    <xsl:with-param name="entity" select="."/>
                </xsl:call-template>
            </div>
            <!-- Rechte Spalte: Tabs -->
            <div class="entity-main">
                <div class="entity-tabs">
                    <button class="entity-tab-btn active" data-tab="tab-erwaehnungen">Erwähnungen</button>
                    <button class="entity-tab-btn" data-tab="tab-relationen"
                        >Relationen</button>
                </div>
                <div id="tab-erwaehnungen" class="entity-tab-panel active">
                    <xsl:call-template name="work-mentions">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                </div>
                <div id="tab-relationen" class="entity-tab-panel">
                    <xsl:call-template name="relationen-block">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- WORK: Sub-Templates -->
    <!-- Erscheinungsdatum (tei:date[1]) -->
    <xsl:template name="work-erscheinungsdatum">
        <xsl:param name="entity" as="node()"/>
        <div id="erscheinungsdatum" class="mt-2">
            <p>
                <xsl:if test="$entity/tei:date[1]">
                    <legend>Erschienen</legend>
                    <ul class="dashed">
                        <li>
                            <xsl:choose>
                                <xsl:when test="contains($entity/tei:date[1], '-')">
                                    <xsl:choose>
                                        <xsl:when
                                            test="normalize-space(tokenize($entity/tei:date[1], '-')[1]) = normalize-space(tokenize($entity/tei:date[1], '-')[2])">
                                            <xsl:value-of
                                                select="mam:normalize-date(normalize-space((tokenize($entity/tei:date[1], '-')[1])))"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="mam:normalize-date(normalize-space($entity/tei:date[1]))"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="mam:normalize-date($entity/tei:date[1])"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="not(ends-with($entity/tei:date[1], '.'))">
                                <xsl:text>.</xsl:text>
                            </xsl:if>
                        </li>
                    </ul>
                </xsl:if>
            </p>
        </div>
    </xsl:template>
    <!-- Bibliografische Angabe + Online-Links -->
    <xsl:template name="work-links">
        <xsl:param name="entity" as="node()"/>
        <xsl:if
            test="$entity/tei:title[@type = 'werk_bibliografische-angabe' or starts-with(@type, 'werk_link')]">
            <div id="labels" class="mt-2">
                <span class="infodesc mr-2">
                    <ul class="dashed">
                        <xsl:for-each
                            select="$entity/tei:title[@type = 'werk_bibliografische-angabe']">
                            <li>
                                <xsl:text>Bibliografische Angabe: </xsl:text>
                                <xsl:value-of select="."/>
                            </li>
                        </xsl:for-each>
                        <xsl:for-each
                            select="$entity/tei:title[@type = 'werk_link' or @type = 'anno']">
                            <li>
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="."/>
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:text>Online verfügbar</xsl:text>
                                </a>
                            </li>
                        </xsl:for-each>
                    </ul>
                </span>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- Mentions-Block (events oder tei:note[@type='mentions']) -->
    <xsl:template name="work-mentions">
        <xsl:param name="entity" as="node()"/>
        <xsl:choose>
            <xsl:when test="$current-edition = 'schnitzler-kultur'">
                <xsl:variable name="notes" as="node()">
                    <xsl:call-template name="fill-event-variable">
                        <xsl:with-param name="xmlid" select="$entity/@xml:id"/>
                        <xsl:with-param name="entitityType" select="'title'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="list-all-mentions">
                    <xsl:with-param name="mentions" select="$notes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$entity//tei:note[@type = 'mentions'][1]">
                <xsl:variable name="mentionsGrp">
                    <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:copy-of select="$entity//tei:note[@type = 'mentions']"/>
                    </xsl:element>
                </xsl:variable>
                <xsl:call-template name="list-all-mentions">
                    <xsl:with-param name="mentions" select="$mentionsGrp"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- PLACE -->
    <xsl:template match="tei:place" name="place_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000"/>
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="container-fluid">
            <div class="card-body-index entity-layout">
                <xsl:variable name="idnos" as="node()">
                    <xsl:element name="idnos">
                        <xsl:copy-of select="tei:idno"/>
                    </xsl:element>
                </xsl:variable>
                <!-- Linke Spalte: Steckbrief -->
                <div class="entity-sidebar">
                    <xsl:call-template name="lod-reihe">
                        <xsl:with-param name="idno" select="$idnos"/>
                    </xsl:call-template>
                    <xsl:call-template name="place-namensvarianten">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                    <xsl:call-template name="place-map">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                </div>
                <!-- Rechte Spalte: Tabs -->
                <div class="entity-main">
                    <div class="entity-tabs">
                        <button class="entity-tab-btn active" data-tab="tab-erwaehnungen"
                            >Erwähnungen</button>
                        <button class="entity-tab-btn" data-tab="tab-relationen"
                            >Relationen</button>
                    </div>
                    <div id="tab-erwaehnungen" class="entity-tab-panel active">
                        <xsl:call-template name="place-mentions">
                            <xsl:with-param name="entity" select="."/>
                        </xsl:call-template>
                    </div>
                    <div id="tab-relationen" class="entity-tab-panel">
                        <xsl:call-template name="relationen-block">
                            <xsl:with-param name="entity" select="."/>
                        </xsl:call-template>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- PLACE: Sub-Templates -->
    <!-- Leaflet-Karte mit dem ersten geo-Wert -->
    <xsl:template name="place-map">
        <xsl:param name="entity" as="node()"/>
        <xsl:if test="$entity//tei:geo/text()">
            <div id="mapid" style="height: 250px; width:100%; clear: both;"> </div>
            <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"
                integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A=="
                crossorigin=""/>
            <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js" integrity="sha512-XQoYMqMTK8LvdxXYG3nZ448hOEQiglfqkJs1NOQV44cWnUrBc8PkAOcXy20w0vlaXaVUearIOBhiXZ5V3ynxwA==" crossorigin=""/>
            <script>
                <xsl:variable name="laenge" select="replace(tokenize($entity/descendant::tei:geo[1]/text(), ' ')[2], ',', '.')"/>
                <xsl:variable name="breite" select="replace(tokenize($entity/descendant::tei:geo[1]/text(), ' ')[1], ',', '.')"/>

                window._mapData = {
                    lat: <xsl:value-of select="$breite"/>,
                    lng: <xsl:value-of select="$laenge"/>,
                    label: "<xsl:value-of select="$entity/tei:placeName[1]/text()"/>"
                };
                window.initEntityMap = function() {
                    if (window.mymap) return;
                    window.mymap = L.map('mapid').setView([window._mapData.lat, window._mapData.lng], 14);
                    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                        attribution: 'Map data © <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors',
                        maxZoom: 18
                    }).addTo(window.mymap);
                    L.marker([window._mapData.lat, window._mapData.lng])
                        .addTo(window.mymap)
                        .bindPopup("<b>" + window._mapData.label + "</b>")
                        .openPopup();
                };
            </script>
        </xsl:if>
    </xsl:template>
    <!-- Namensvarianten-Liste -->
    <xsl:template name="place-namensvarianten">
        <xsl:param name="entity" as="node()"/>
        <xsl:if test="count($entity//tei:placeName[contains(@type, 'namensvariante')]) gt 1">
            <legend>Namensvarianten</legend>
            <ul class="dashed">
                <xsl:for-each select="$entity//tei:placeName[contains(@type, 'namensvariante')]">
                    <li>
                        <xsl:value-of select="./text()"/>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </xsl:template>
    <!-- Mentions-Block (events oder tei:note[@type='mentions']) -->
    <xsl:template name="place-mentions">
        <xsl:param name="entity" as="node()"/>
        <xsl:choose>
            <xsl:when test="$current-edition = 'schnitzler-kultur'">
                <xsl:variable name="notes" as="node()">
                    <xsl:call-template name="fill-event-variable">
                        <xsl:with-param name="xmlid" select="$entity/@xml:id"/>
                        <xsl:with-param name="entitityType" select="'placeName'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="list-all-mentions">
                    <xsl:with-param name="mentions" select="$notes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$entity//tei:note[@type = 'mentions'][1]">
                <xsl:variable name="mentionsGrp">
                    <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:copy-of select="$entity//tei:note[@type = 'mentions']"/>
                    </xsl:element>
                </xsl:variable>
                <xsl:call-template name="list-all-mentions">
                    <xsl:with-param name="mentions" select="$mentionsGrp"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:function name="mam:pmbChange">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="entitytyp" as="xs:string"/>
        <xsl:value-of select="
                concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/', $entitytyp, '/',
                substring-after($url, 'https://pmb.acdh.oeaw.ac.at/entity/'), '/detail')"/>
    </xsl:function>
    <!-- ORG -->
    <xsl:key name="place-lookup" match="tei:place" use="@xml:id"/>
    <xsl:template match="tei:org" name="org_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000"/>
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="card-body-index entity-layout">
            <xsl:variable name="idnos" as="node()">
                <xsl:element name="idnos">
                    <xsl:copy-of select="tei:idno"/>
                </xsl:element>
            </xsl:variable>
            <!-- Linke Spalte: Steckbrief -->
            <div class="entity-sidebar">
                <xsl:call-template name="lod-reihe">
                    <xsl:with-param name="idno" select="$idnos"/>
                </xsl:call-template>
                <xsl:call-template name="org-namensvarianten">
                    <xsl:with-param name="entity" select="."/>
                </xsl:call-template>
                <xsl:call-template name="org-orte">
                    <xsl:with-param name="entity" select="."/>
                </xsl:call-template>
            </div>
            <!-- Rechte Spalte: Tabs -->
            <div class="entity-main">
                <div class="entity-tabs">
                    <button class="entity-tab-btn active" data-tab="tab-erwaehnungen">Erwähnungen</button>
                    <button class="entity-tab-btn" data-tab="tab-relationen"
                        >Relationen</button>
                </div>
                <div id="tab-erwaehnungen" class="entity-tab-panel active">
                    <xsl:call-template name="org-mentions">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                </div>
                <div id="tab-relationen" class="entity-tab-panel">
                    <xsl:call-template name="relationen-block">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- ORG: Sub-Templates -->
    <!-- Alternative orgName-Werte als Komma-Liste -->
    <xsl:template name="org-namensvarianten">
        <xsl:param name="entity" as="node()"/>
        <xsl:variable name="ersterName" select="$entity/tei:orgName[1]"/>
        <xsl:if test="$entity/tei:orgName[2]">
            <p>
                <xsl:for-each
                    select="distinct-values($entity/tei:orgName[@type = 'ort_alternative-name'])">
                    <xsl:if test=". != $ersterName">
                        <xsl:value-of select="."/>
                    </xsl:if>
                    <xsl:if test="not(position() = last())">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </p>
        </xsl:if>
    </xsl:template>
    <!-- Standorte (tei:location/tei:placeName) -->
    <xsl:template name="org-orte">
        <xsl:param name="entity" as="node()"/>
        <xsl:if test="$entity/tei:location">
            <div>
                <legend>Orte</legend>
                <ul class="dashed">
                    <li>
                        <xsl:for-each
                            select="$entity/tei:location/tei:placeName[not(. = preceding-sibling::tei:placeName)]">
                            <xsl:variable name="key-or-ref" as="xs:string?">
                                <xsl:value-of
                                    select="concat(replace(@key, 'place__', 'pmb'), replace(@ref, 'place__', 'pmb'))"
                                />
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="key('place-lookup', $key-or-ref, $places)">
                                    <xsl:element name="a">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="concat($key-or-ref, '.html')"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="."/>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="not(position() = last())">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </li>
                </ul>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- Mentions-Block (events oder tei:note[@type='mentions']) -->
    <xsl:template name="org-mentions">
        <xsl:param name="entity" as="node()"/>
        <xsl:choose>
            <xsl:when test="$current-edition = 'schnitzler-kultur'">
                <xsl:variable name="notes" as="node()">
                    <xsl:call-template name="fill-event-variable">
                        <xsl:with-param name="xmlid" select="$entity/@xml:id"/>
                        <xsl:with-param name="entitityType" select="'orgName'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="list-all-mentions">
                    <xsl:with-param name="mentions" select="$notes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$entity//tei:note[@type = 'mentions'][1]">
                <xsl:variable name="mentionsGrp">
                    <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:copy-of select="$entity//tei:note[@type = 'mentions']"/>
                    </xsl:element>
                </xsl:variable>
                <xsl:call-template name="list-all-mentions">
                    <xsl:with-param name="mentions" select="$mentionsGrp"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- EVENT -->
    <xsl:template match="tei:event" name="event_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000"/>
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="container-fluid">
            <div class="card-body-index entity-layout">
                <!-- Linke Spalte: Steckbrief -->
                <div class="entity-sidebar">
                    <xsl:call-template name="event-row-datum">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                    <xsl:call-template name="event-buttonreihe">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                    <xsl:call-template name="event-row-veranstaltungsort">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                    <xsl:call-template name="event-row-theaterzettel">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                    <xsl:call-template name="event-row-tageszeitungen">
                        <xsl:with-param name="entity" select="."/>
                    </xsl:call-template>
                </div>
                <!-- Rechte Spalte: Tabs -->
                <div class="entity-main">
                    <div class="entity-tabs">
                        <button class="entity-tab-btn active" data-tab="tab-erwaehnungen">Erwähnungen</button>
                        <button class="entity-tab-btn" data-tab="tab-relationen"
                            >Relationen</button>
                    </div>
                    <div id="tab-erwaehnungen" class="entity-tab-panel active">
                        <xsl:call-template name="event-mentions">
                            <xsl:with-param name="entity" select="."/>
                        </xsl:call-template>
                    </div>
                    <div id="tab-relationen" class="entity-tab-panel">
                        <xsl:call-template name="relationen-block">
                            <xsl:with-param name="entity" select="."/>
                        </xsl:call-template>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    <!-- EVENT: Sub-Templates -->
    <!-- Buttonreihe mit LOD-Idnos -->
    <xsl:template name="event-buttonreihe">
        <xsl:param name="entity" as="node()"/>
        <div id="mentions">
            <xsl:if test="key('only-relevant-uris', $entity/tei:idno/@subtype, $relevant-uris)[1]">
                <p class="buttonreihe">
                    <xsl:variable name="idnos-of-current" as="node()">
                        <xsl:element name="nodeset_place">
                            <xsl:for-each select="$entity/tei:idno">
                                <xsl:copy-of select="."/>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:variable>
                    <xsl:call-template name="mam:idnosToLinks">
                        <xsl:with-param name="idnos-of-current" select="$idnos-of-current"/>
                    </xsl:call-template>
                </p>
            </xsl:if>
        </div>
    </xsl:template>
    <!-- Datums-Zeile -->
    <xsl:template name="event-row-datum">
        <xsl:param name="entity" as="node()"/>
        <h6>
            <xsl:choose>
                <xsl:when test="$entity/@from-iso and $entity/@to-iso">
                    <xsl:value-of select="mam:wochentag($entity/@from-iso)"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="format-date($entity/@from-iso, '[D1]. ')"/>
                    <xsl:value-of select="mam:monat($entity/@from-iso)"/>
                    <xsl:value-of select="format-date($entity/@from-iso, ' [Y]')"/>
                    <xsl:text> bis </xsl:text>
                    <xsl:value-of select="mam:wochentag($entity/@to-iso)"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="format-date($entity/@to-iso, '[D1]. ')"/>
                    <xsl:value-of select="mam:monat($entity/@to-iso)"/>
                    <xsl:value-of select="format-date($entity/@to-iso, ' [Y]')"/>
                </xsl:when>
                <xsl:when
                    test="($entity/@from-iso = '' or not($entity/@from-iso)) and $entity/@to-iso">
                    <xsl:text>bis </xsl:text>
                    <xsl:value-of select="mam:wochentag($entity/@to-iso)"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="format-date($entity/@to-iso, '[D1]. ')"/>
                    <xsl:value-of select="mam:monat($entity/@to-iso)"/>
                    <xsl:value-of select="format-date($entity/@to-iso, ' [Y]')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="mam:wochentag($entity/@when-iso)"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="format-date($entity/@when-iso, '[D1]. ')"/>
                    <xsl:value-of select="mam:monat($entity/@when-iso)"/>
                    <xsl:value-of select="format-date($entity/@when-iso, ' [Y]')"/>
                </xsl:otherwise>
            </xsl:choose>
        </h6>
    </xsl:template>
    <!-- Veranstaltungsort-Zeile (mit Karte) -->
    <xsl:template name="event-row-veranstaltungsort">
        <xsl:param name="entity" as="node()"/>
        <ul class="list-unstyled">
            <xsl:for-each select="$entity/tei:listPlace/tei:place">
                <li>
                    <xsl:element name="a">
                        <xsl:attribute name="target">_blank</xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat(tei:placeName/@key, '.html')"/>
                        </xsl:attribute>
                        <xsl:value-of select="normalize-space(tei:placeName)"/>
                    </xsl:element>
                    <xsl:if test="./tei:location/tei:geo">
                        <div id="map_detail" style="height: 250px; width: 100%;"/>
                        <xsl:variable name="mlat"
                            select="replace(tokenize(./tei:location[1]/tei:geo[1], '\s')[1], ',', '.')"/>
                        <xsl:variable name="mlong"
                            select="replace(tokenize(./tei:location[1]/tei:geo[1], '\s')[2], ',', '.')"/>
                        <xsl:variable name="mappin"
                            select="concat('mlat=', $mlat, '&amp;mlon=', $mlong)" as="xs:string"/>
                        <xsl:variable name="openstreetmapurl"
                            select="concat('https://www.openstreetmap.org/?', $mappin, '#map=12/', $mlat, '/', $mlong)"/>
                        <div class="text-end">
                            <a class="small d-block mt-1" target="_blank">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="$openstreetmapurl"/>
                                </xsl:attribute>
                                <i class="bi bi-box-arrow-up-right"/> OpenStreetMap </a>
                        </div>
                    </xsl:if>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    <!-- Werke- bzw. Rezensions-Zeile (Filter über $rezension) -->
    <xsl:template name="event-row-werke">
        <xsl:param name="entity" as="node()"/>
        <xsl:param name="rezension" as="xs:boolean"/>
        <xsl:param name="label" as="xs:string"/>
        <xsl:variable name="bibls" select="
                if ($rezension)
                then
                    $entity/tei:listBibl/tei:bibl[(tei:note[contains(., 'rezensi')]) and normalize-space(tei:title)]
                else
                    $entity/tei:listBibl/tei:bibl[not(tei:note[contains(., 'rezensi')]) and normalize-space(tei:title)]"/>
        <xsl:if test="$bibls">
            <tr>
                <th>
                    <xsl:value-of select="$label"/>
                </th>
                <td>
                    <ul>
                        <xsl:for-each select="$bibls">
                            <li>
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat(tei:title/@key, '.html')"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="normalize-space(tei:title)"/>
                                </xsl:element>
                            </li>
                        </xsl:for-each>
                    </ul>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    <!-- Personen-Zeile (Arbeitskräfte / Teilnehmende) -->
    <xsl:template name="event-row-personen">
        <xsl:param name="persons" as="node()*"/>
        <xsl:param name="label" as="xs:string"/>
        <tr>
            <th>
                <xsl:value-of select="$label"/>
            </th>
            <td>
                <ul>
                    <xsl:for-each select="$persons">
                        <li>
                            <xsl:variable name="name" select="tei:persName"/>
                            <xsl:choose>
                                <xsl:when test="matches($name, '^[^,]+,\s*[^,]+$')">
                                    <xsl:element name="a">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="concat($name/@key, '.html')"/>
                                        </xsl:attribute>
                                        <xsl:analyze-string select="$name" regex="^([^,]+),\s*(.+)$">
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
                                <xsl:otherwise>
                                    <xsl:element name="a">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="concat($name/@key, '.html')"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="$name"/>
                                    </xsl:element>
                                </xsl:otherwise>
                            </xsl:choose>
                        </li>
                    </xsl:for-each>
                </ul>
            </td>
        </tr>
    </xsl:template>
    <!-- Beteiligte Institutionen -->
    <xsl:template name="event-row-institutionen">
        <xsl:param name="entity" as="node()"/>
        <xsl:if test="$entity/descendant::tei:listOrg">
            <tr>
                <th>Beteiligte Institution</th>
                <td>
                    <ul>
                        <xsl:for-each
                            select="$entity/tei:note[@type = 'listorg']/tei:listOrg/tei:org">
                            <li>
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat(tei:orgName/@key, '.html')"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="tei:orgName"/>
                                </xsl:element>
                            </li>
                        </xsl:for-each>
                    </ul>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    <!-- Theaterzettel-Zeile (nur Burgtheater-Vorstellungen) -->
    <xsl:template name="event-row-theaterzettel">
        <xsl:param name="entity" as="node()"/>
        <xsl:if
            test="($entity/descendant::tei:placeName/@key = 'pmb14' or $entity/descendant::tei:placeName/@key = 'pmb185621') and not(contains($entity/tei:eventName/@n, 'robe'))">
            <h6>Theaterzettel</h6>
            <p>
                <a>
                    <xsl:attribute name="target">
                        <xsl:text>_blank</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="year-from-date($entity/@when-iso) &lt; 1899">
                                <xsl:value-of
                                    select="concat('https://anno.onb.ac.at/cgi-content/anno?aid=wtz&amp;datum=', replace($entity/@when-iso, '-', ''))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="concat('https://anno.onb.ac.at/cgi-content/anno?aid=bth&amp;datum=', replace($entity/@when-iso, '-', ''))"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:text>ANNO</xsl:text>
                </a>
            </p>
        </xsl:if>
    </xsl:template>
    <!-- Tageszeitungen-Zeile (ANNO + DDB) -->
    <xsl:template name="event-row-tageszeitungen">
        <xsl:param name="entity" as="node()"/>
        <h6>Tageszeitungen vom aktuellen Tag</h6>
        <ul class="list-unstyled">
            <li>
                <a>
                    <xsl:attribute name="target">
                        <xsl:text>_blank</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of
                            select="concat('https://anno.onb.ac.at/cgi-content/anno?datum=', replace($entity/@when-iso, '-', ''))"
                        />
                    </xsl:attribute>
                    <xsl:text>Österreich</xsl:text>
                </a>
            </li>
            <li>
                <a>
                    <xsl:attribute name="target">
                        <xsl:text>_blank</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of
                            select="concat('https://www.deutsche-digitale-bibliothek.de/newspaper/select/month?day=', day-from-date($entity/@when-iso), '&amp;month=', month-from-date($entity/@when-iso), '&amp;year=', year-from-date($entity/@when-iso))"
                        />
                    </xsl:attribute>
                    <xsl:text>Deutschland</xsl:text>
                </a>
            </li>
        </ul>
    </xsl:template>
    <!-- Mentions-Block (events oder tei:note[@type='mentions']) -->
    <xsl:template name="event-mentions">
        <xsl:param name="entity" as="node()"/>
        <xsl:choose>
            <xsl:when test="$current-edition = 'schnitzler-kultur'">
                <xsl:variable name="notes" as="node()">
                    <xsl:call-template name="fill-event-variable">
                        <xsl:with-param name="xmlid" select="$entity/@xml:id"/>
                        <xsl:with-param name="entitityType" select="'eventName'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="list-all-mentions">
                    <xsl:with-param name="mentions" select="$notes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$entity//tei:note[@type = 'mentions'][1]">
                <xsl:variable name="mentionsGrp">
                    <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:copy-of select="$entity//tei:note[@type = 'mentions']"/>
                    </xsl:element>
                </xsl:variable>
                <xsl:call-template name="list-all-mentions">
                    <xsl:with-param name="mentions" select="$mentionsGrp"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:function name="mam:ahref-namen">
        <xsl:param name="typityp" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$typityp = 'schnitzler-tagebuch'">
                <xsl:text> Tagebuch</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'schnitzler-briefe'">
                <xsl:text> Briefe</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'schnitzler-lektueren'">
                <xsl:text> Lektüren</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'PMB'">
                <xsl:text> PMB</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'pmb'">
                <xsl:text> PMB</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'briefe_i'">
                <xsl:text> Briefe 1875–1912</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'briefe_ii'">
                <xsl:text> Briefe 1913–1931</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'DLAwidmund'">
                <xsl:text> Widmungsexemplar Deutsches Literaturarchiv</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'jugend-in-wien'">
                <xsl:text> Jugend in Wien</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'gnd'">
                <xsl:text> Wikipedia?</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'schnitzler-briefe'">
                <xsl:text> Bahr/Schnitzler</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'widmungDLA'">
                <xsl:text> Widmung DLA</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$typityp"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:template name="list-all-mentions">
        <xsl:param name="mentions" as="node()"/>
        <xsl:variable name="commentaryMentionCount"
            select="count($mentions//tei:note[@ana = 'comment'])"/>
        <xsl:variable name="mentionCount" select="count($mentions//tei:note)"/>
        <xsl:if test="count($mentions//tei:note) > 0">
            <!-- Balkendiagramm oben -->
            <div id="mentions">
                <span class="infodesc mr-2">
                    <legend>Erwähnungen</legend>
                    <xsl:if test="$commentaryMentionCount > 0">
                        <div class="annotation-toggle" data-type="commentary"
                            style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px; font-size: 0.9rem; font-weight: normal;">
                            <label class="switch" style="margin: 0;">
                                <input type="checkbox" id="toggle-commentary-mentions"
                                    checked="checked"/>
                                <span class="i-slider round" style="background-color: #A63437;"/>
                            </label>
                            <span class="opt-title">Kommentar ein-/ausblenden</span>
                        </div>
                    </xsl:if>
                    <div id="mentions-chart" class="mt-3 mb-3" style="max-width:600px;">
                        <xsl:variable name="start-year" as="xs:integer">
                            <xsl:choose>
                                <xsl:when test="$current-edition = 'schnitzler-kultur'"> 1876 </xsl:when>
                                <xsl:otherwise> 1879 </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="years" as="element()*">
                            <xsl:element name="years">
                                <xsl:for-each select="$start-year to 1931">
                                    <xsl:element name="year">
                                        <xsl:attribute name="val">
                                            <xsl:value-of select="."/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:element>
                        </xsl:variable>
                        <!-- SVG Balkendiagramm -->
                        <svg viewBox="0 0 600 200" style="width:100%; max-width:600px;"
                            height="300px" preserveAspectRatio="xMidYMid meet"
                            aria-label="Balkendiagramm der Erwähnungen pro Jahr" role="img">
                            <!-- Achsen -->
                            <line x1="50" y1="10" x2="50" y2="160" stroke="black" stroke-width="2"/>
                            <line x1="50" y1="160" x2="580" y2="160" stroke="black" stroke-width="2"/>
                            <!-- Y-Achse Beschriftung -->
                            <text x="30" y="165" font-size="10" text-anchor="end">0</text>
                            <text x="30" y="115" font-size="10" text-anchor="end">10</text>
                            <text x="30" y="65" font-size="10" text-anchor="end">20</text>
                            <text x="30" y="15" font-size="10" text-anchor="end">30</text>
                            <!-- X-Achse Beschriftung -->
                            <xsl:variable name="totalYears" select="1931 - $start-year + 1"/>
                            <xsl:variable name="stepWidth" select="(580 - 50) div $totalYears"/>
                            <xsl:for-each select="188 to 193">
                                <xsl:variable name="year" select="(.) * 10"/>
                                <xsl:variable name="xPos"
                                    select="50 + ($year - $start-year) * $stepWidth"/>
                                <text x="{$xPos}" y="175" font-size="10" text-anchor="middle">
                                    <xsl:value-of select="$year"/>
                                </text>
                            </xsl:for-each>
                            <!-- Balken -->
                            <xsl:for-each select="$years/*[local-name() = 'year']">
                                <xsl:variable name="year" select="number(@val)"/>
                                <xsl:variable name="editionstext-count"
                                    select="count($mentions//tei:note[substring(@corresp, 1, 4) = string($year) and not(@ana = 'comment')])"/>
                                <xsl:variable name="commentary-only-count"
                                    select="count($mentions//tei:note[substring(@corresp, 1, 4) = string($year) and @ana = 'comment'])"/>
                                <xsl:variable name="editionstext-height"
                                    select="($editionstext-count * 140) div 30"/>
                                <xsl:variable name="commentary-height"
                                    select="($commentary-only-count * 140) div 30"/>
                                <xsl:variable name="xPos"
                                    select="50 + ($year - $start-year) * $stepWidth - 2"/>
                                <!-- Editionstext-Balken (Hauptfarbe, unten) -->
                                <xsl:if test="$editionstext-count > 0">
                                    <rect x="{$xPos}" y="{160 - $editionstext-height}" width="4"
                                        height="{$editionstext-height}" fill="{$current-colour}">
                                        <title>
                                            <xsl:value-of select="
                                                    concat($year, ': ', $editionstext-count, ' Erwähnung', if ($editionstext-count = 1) then
                                                        ''
                                                    else
                                                        'en', ' (Editionstext)')"
                                            />
                                        </title>
                                    </rect>
                                </xsl:if>
                                <!-- Kommentar-Balken (hellere Farbe, oben gestapelt) -->
                                <xsl:if test="$commentary-only-count > 0">
                                    <xsl:variable name="commentary-colour">
                                        <xsl:choose>
                                            <xsl:when test="$current-colour = '#A63437'"
                                                >#D98B8E</xsl:when>
                                            <xsl:otherwise>#CCCCCC</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <rect x="{$xPos}"
                                        y="{160 - $editionstext-height - $commentary-height}"
                                        width="4" height="{$commentary-height}"
                                        fill="{$commentary-colour}" data-type="commentary">
                                        <title>
                                            <xsl:value-of select="
                                                    concat($year, ': ', $commentary-only-count, ' Erwähnung', if ($commentary-only-count = 1) then
                                                        ''
                                                    else
                                                        'en', ' (im Kommentar)')"
                                            />
                                        </title>
                                    </rect>
                                </xsl:if>
                            </xsl:for-each>
                        </svg>
                        <xsl:if test="$commentaryMentionCount > 0">
                            <div class="text-center" style="font-size: 0.85rem; margin-top: 5px;">
                                <span
                                    style="display: inline-block; width: 15px; height: 3px; background-color: {$current-colour}; vertical-align: middle; margin-right: 5px;"/>
                                <span style="margin-right: 15px;">Editionstext</span>
                                <xsl:variable name="legend-commentary-colour">
                                    <xsl:choose>
                                        <xsl:when test="$current-colour = '#A63437'"
                                            >#D98B8E</xsl:when>
                                        <xsl:otherwise>#CCCCCC</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <span
                                    style="display: inline-block; width: 15px; height: 3px; background-color: {$legend-commentary-colour}; vertical-align: middle; margin-right: 5px;"/>
                                <span>im Kommentar</span>
                            </div>
                        </xsl:if>
                    </div>
                    <div id="mentions-liste" class="mt-2">
                        <div id="mentions-liste" class="mt-2">
                            <xsl:choose>
                                <!-- Wenn mehr als 10 Erwähnungen -->
                                <xsl:when test="$mentionCount > 10">
                                    <div class="mentions-by-year">
                                        <!-- Gruppieren nach Jahr -->
                                        <xsl:for-each-group select="$mentions//tei:note"
                                            group-by="substring(@corresp, 1, 4)">
                                            <xsl:sort select="current-grouping-key()"
                                                data-type="number" order="ascending"/>
                                            <xsl:variable name="year"
                                                select="current-grouping-key()"/>
                                            <details class="year-details mb-3">
                                                <summary class="year-summary">
                                                  <xsl:choose>
                                                  <xsl:when test="count(current-group()) = 1">
                                                  <xsl:value-of
                                                  select="concat($year, ' (1 Eintrag)')"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="concat($year, ' (', count(current-group()), ' Einträge)')"
                                                  />
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </summary>
                                                <div class="year-content">
                                                  <xsl:choose>
                                                  <xsl:when test="count(current-group()) > 10">
                                                  <xsl:for-each-group select="current-group()"
                                                  group-by="substring(@corresp, 1, 7)">
                                                  <xsl:sort select="current-grouping-key()"
                                                  order="ascending"/>
                                                  <xsl:variable name="monthKey"
                                                  select="current-grouping-key()"/>
                                                  <details
                                                  class="month-details ms-4 mb-3 bg-light rounded p-2"
                                                  open="open">
                                                  <summary
                                                  class="month-summary p-2 bg-light rounded fw-medium">
                                                  <xsl:variable name="monthNum"
                                                  select="number(substring(current-grouping-key(), 6, 2))"/>
                                                  <xsl:choose>
                                                  <xsl:when test="$monthNum = 1">Jänner</xsl:when>
                                                  <xsl:when test="$monthNum = 2">Februar</xsl:when>
                                                  <xsl:when test="$monthNum = 3">März</xsl:when>
                                                  <xsl:when test="$monthNum = 4">April</xsl:when>
                                                  <xsl:when test="$monthNum = 5">Mai</xsl:when>
                                                  <xsl:when test="$monthNum = 6">Juni</xsl:when>
                                                  <xsl:when test="$monthNum = 7">Juli</xsl:when>
                                                  <xsl:when test="$monthNum = 8">August</xsl:when>
                                                  <xsl:when test="$monthNum = 9"
                                                  >September</xsl:when>
                                                  <xsl:when test="$monthNum = 10">Oktober</xsl:when>
                                                  <xsl:when test="$monthNum = 11"
                                                  >November</xsl:when>
                                                  <xsl:when test="$monthNum = 12"
                                                  >Dezember</xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="current-grouping-key()"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </summary>
                                                  <div class="month-content py-2">
                                                  <ul class="dashed">
                                                  <xsl:for-each select="current-group()">
                                                  <xsl:sort select="replace(@corresp, '-', '')"
                                                  order="ascending" data-type="number"/>
                                                  <xsl:variable name="linkToDocument"
                                                  select="replace(tokenize(data(.//@target), '/')[last()], '.xml', '.html')"/>
                                                  <li>
                                                  <xsl:attribute name="class">
                                                  <xsl:if test="@ana = 'comment'"
                                                  >mention-commentary</xsl:if>
                                                  </xsl:attribute>
                                                  <a href="{$linkToDocument}">
                                                  <xsl:value-of select="."/>
                                                  <xsl:text> </xsl:text>
                                                  <i class="fas fa-external-link-alt"/>
                                                  </a>
                                                  </li>
                                                  </xsl:for-each>
                                                  </ul>
                                                  </div>
                                                  </details>
                                                  </xsl:for-each-group>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <ul class="dashed">
                                                  <xsl:for-each select="current-group()">
                                                  <xsl:sort select="replace(@corresp, '-', '')"
                                                  order="ascending" data-type="number"/>
                                                  <xsl:variable name="linkToDocument">
                                                  <xsl:value-of
                                                  select="replace(tokenize(data(.//@target), '/')[last()], '.xml', '.html')"
                                                  />
                                                  </xsl:variable>
                                                  <li>
                                                  <xsl:attribute name="class">
                                                  <xsl:if test="@ana = 'comment'"
                                                  >mention-commentary</xsl:if>
                                                  </xsl:attribute>
                                                  <a href="{$linkToDocument}">
                                                  <xsl:value-of select="."/>
                                                  <xsl:text> </xsl:text>
                                                  <i class="fas fa-external-link-alt"/>
                                                  </a>
                                                  </li>
                                                  </xsl:for-each>
                                                  </ul>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </div>
                                            </details>
                                        </xsl:for-each-group>
                                    </div>
                                </xsl:when>
                                <!-- Weniger als oder gleich 10: Standardliste -->
                                <xsl:otherwise>
                                    <ul class="dashed" id="simple-mentions-list">
                                        <xsl:for-each select="$mentions//tei:note">
                                            <xsl:sort select="replace(@corresp, '-', '')"
                                                order="ascending" data-type="number"/>
                                            <xsl:variable name="linkToDocument">
                                                <xsl:value-of
                                                  select="replace(tokenize(data(.//@target), '/')[last()], '.xml', '.html')"
                                                />
                                            </xsl:variable>
                                            <li>
                                                <xsl:attribute name="class">
                                                  <xsl:if test="@ana = 'comment'"
                                                  >mention-commentary</xsl:if>
                                                </xsl:attribute>
                                                <a href="{$linkToDocument}">
                                                  <xsl:value-of select="."/>
                                                  <xsl:text> </xsl:text>
                                                  <i class="fas fa-external-link-alt"/>
                                                </a>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>
                </span>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template name="lod-reihe">
        <xsl:param name="idno" as="node()"/>
        <div id="lod-mentions">
            <xsl:if
                test="key('only-relevant-uris', $idno/tei:idno[not(@subtype = $current-edition)]/@subtype, $relevant-uris)[1]">
                <legend>Ressourcen</legend>
                <p class="buttonreihe">
                    <xsl:variable name="idnos-of-current" as="node()">
                        <xsl:element name="nodeset_person">
                            <xsl:for-each select="$idno/tei:idno[not(@subtype = $current-edition)]">
                                <xsl:copy-of select="."/>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:variable>
                    <xsl:call-template name="mam:idnosToLinks">
                        <xsl:with-param name="idnos-of-current" select="$idnos-of-current"/>
                    </xsl:call-template>
                </p>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:function name="mam:monat" as="xs:string">
        <xsl:param name="iso-datum" as="xs:date"/>
        <xsl:variable name="month-of-the-year" as="xs:string"
            select="format-date($iso-datum, '[MNn]')"/>
        <xsl:choose>
            <xsl:when test="$month-of-the-year = 'January'">
                <xsl:text>Jänner</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'February'">
                <xsl:text>Februar</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'March'">
                <xsl:text>März</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'April'">
                <xsl:text>April</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'May'">
                <xsl:text>Mai</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'June'">
                <xsl:text>Juni</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'July'">
                <xsl:text>Juli</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'August'">
                <xsl:text>August</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'September'">
                <xsl:text>September</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'October'">
                <xsl:text>Oktober</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'November'">
                <xsl:text>November</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'December'">
                <xsl:text>Dezember</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Unbekannter Monat</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="mam:wochentag" as="xs:string">
        <xsl:param name="iso-datum" as="xs:date"/>
        <xsl:variable name="day-of-the-week" as="xs:string" select="format-date($iso-datum, '[F]')"/>
        <xsl:choose>
            <xsl:when test="$day-of-the-week = 'Monday'">
                <xsl:text>Montag</xsl:text>
            </xsl:when>
            <xsl:when test="$day-of-the-week = 'Tuesday'">
                <xsl:text>Dienstag</xsl:text>
            </xsl:when>
            <xsl:when test="$day-of-the-week = 'Wednesday'">
                <xsl:text>Mittwoch</xsl:text>
            </xsl:when>
            <xsl:when test="$day-of-the-week = 'Thursday'">
                <xsl:text>Donnerstag</xsl:text>
            </xsl:when>
            <xsl:when test="$day-of-the-week = 'Friday'">
                <xsl:text>Freitag</xsl:text>
            </xsl:when>
            <xsl:when test="$day-of-the-week = 'Saturday'">
                <xsl:text>Samstag</xsl:text>
            </xsl:when>
            <xsl:when test="$day-of-the-week = 'Sunday'">
                <xsl:text>Sonntag</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Unbekannt</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- Hilfsfunktion: Schlüssel auf "pmb<zahl>"-Form bringen -->
    <xsl:function name="mam:to-pmb" as="xs:string">
        <xsl:param name="key" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="not($key) or normalize-space($key) = ''">
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="starts-with($key, 'pmb')">
                <xsl:value-of select="$key"/>
            </xsl:when>
            <xsl:when
                test="starts-with($key, 'person__') or starts-with($key, 'place__') or starts-with($key, 'org__') or starts-with($key, 'event__') or starts-with($key, 'work__')">
                <xsl:value-of select="concat('pmb', substring-after($key, '__'))"/>
            </xsl:when>
            <xsl:when test="matches($key, '^\d+$')">
                <xsl:value-of select="concat('pmb', $key)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$key"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- Hilfsfunktion: Prüft, ob eine pmb-ID in einem der Projekt-Indizes vorkommt -->
    <xsl:function name="mam:in-project" as="xs:boolean">
        <xsl:param name="pmbId" as="xs:string"/>
        <xsl:sequence select="
                $pmbId != '' and (
                ($listperson and exists(key('project-person-xmlid', $pmbId, $listperson))) or
                ($listorg and exists(key('project-org-xmlid', $pmbId, $listorg))) or
                ($places and exists(key('project-place-xmlid', $pmbId, $places))) or
                ($events and exists(key('project-event-xmlid', $pmbId, $events))) or
                ($works and exists(key('project-bibl-xmlid', $pmbId, $works)))
                )"/>
    </xsl:function>
    <!-- Einzelnes Werk-Listenelement (von Werke-Block und "alle Werke anzeigen" wiederverwendet) -->
    <xsl:template name="work-list-item">
        <xsl:param name="author-ref" as="xs:string"/>
        <li>
            <xsl:if test="@role = 'editor' or @role = 'hat-herausgegeben'">
                <xsl:text> (Herausgabe)</xsl:text>
            </xsl:if>
            <xsl:if test="@role = 'translator' or @role = 'hat-ubersetzt'">
                <xsl:text> (Übersetzung)</xsl:text>
            </xsl:if>
            <xsl:if test="@role = 'illustrator' or @role = 'hat-illustriert'">
                <xsl:text> (Illustration)</xsl:text>
            </xsl:if>
            <xsl:if test="@role = 'hat-einen-beitrag-geschaffen-zu'">
                <xsl:text> (Beitrag)</xsl:text>
            </xsl:if>
            <xsl:if test="@role = 'hat-ein-vorwortnachwort-verfasst-zu'">
                <xsl:text> (Vor-/Nachwort)</xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="tei:author[2]">
                    <xsl:for-each
                        select="tei:author[not(replace(@*[name() = 'key' or name() = 'ref'], '#', '') = $author-ref)]">
                        <xsl:choose>
                            <xsl:when test="tei:persName/tei:forename and tei:persName/tei:surname">
                                <xsl:value-of select="tei:persName/tei:forename"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="tei:persName/tei:surname"/>
                            </xsl:when>
                            <xsl:when test="tei:persName/tei:surname">
                                <xsl:value-of select="tei:persName/tei:surname"/>
                            </xsl:when>
                            <xsl:when test="tei:persName/tei:forename">
                                <xsl:value-of select="tei:persName/tei:forename"/>
                            </xsl:when>
                            <xsl:when test="contains(tei:persName, ', ')">
                                <xsl:value-of
                                    select="concat(substring-after(tei:persName, ', '), ' ', substring-before(tei:persName, ', '))"
                                />
                            </xsl:when>
                            <xsl:when test="contains(., ', ')">
                                <xsl:value-of
                                    select="concat(substring-after(., ', '), ' ', substring-before(., ', '))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="@role = 'editor' or @role = 'hat-herausgegeben'">
                            <xsl:text> (Herausgabe)</xsl:text>
                        </xsl:if>
                        <xsl:if test="@role = 'translator' or @role = 'hat-ubersetzt'">
                            <xsl:text> (Übersetzung)</xsl:text>
                        </xsl:if>
                        <xsl:if test="@role = 'illustrator' or @role = 'hat-illustriert'">
                            <xsl:text> (Illustration)</xsl:text>
                        </xsl:if>
                        <xsl:if test="@role = 'hat-einen-beitrag-geschaffen-zu'">
                            <xsl:text> (Beitrag)</xsl:text>
                        </xsl:if>
                        <xsl:if test="@role = 'hat-ein-vorwortnachwort-verfasst-zu'">
                            <xsl:text> (Vor-/Nachwort)</xsl:text>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="position() = last()"/>
                            <xsl:otherwise>
                                <xsl:text>, </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                    <xsl:text>: </xsl:text>
                </xsl:when>
            </xsl:choose>
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:value-of select="concat(@xml:id, '.html')"/>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(tei:title[1])"/>
            </xsl:element>
            <xsl:if test="tei:date[not(. = 'None')][1]">
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(tei:date[1], '–')">
                        <xsl:choose>
                            <xsl:when
                                test="normalize-space(tokenize(tei:date[1], '–')[1]) = normalize-space(tokenize(tei:date[1], '–')[2])">
                                <xsl:value-of
                                    select="mam:normalize-date(normalize-space((tokenize(tei:date[1], '–')[1])))"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="mam:normalize-date(normalize-space(tei:date[1]))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="mam:normalize-date(tei:date[1])"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </li>
    </xsl:template>
    <!-- CSV-Zeile in Felder zerlegen (mit Anführungszeichen-Unterstützung) -->
    <xsl:function name="mam:split-csv-line" as="xs:string*">
        <xsl:param name="line" as="xs:string"/>
        <xsl:variable name="tokens" as="element(t)*">
            <xsl:analyze-string select="$line" regex='"([^"]*)"(,|$)|([^,]*)(,|$)'>
                <xsl:matching-substring>
                    <xsl:choose>
                        <xsl:when test="starts-with(., '&quot;')">
                            <t>
                                <xsl:value-of select="regex-group(1)"/>
                            </t>
                        </xsl:when>
                        <xsl:otherwise>
                            <t>
                                <xsl:value-of select="regex-group(3)"/>
                            </t>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:for-each select="$tokens">
            <xsl:sequence select="string(.)"/>
        </xsl:for-each>
    </xsl:function>
    <!-- Numerischen Anteil einer pmb-ID extrahieren -->
    <xsl:function name="mam:pmb-num" as="xs:string">
        <xsl:param name="key" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="matches($key, '^pmb\d+$')">
                <xsl:value-of select="substring-after($key, 'pmb')"/>
            </xsl:when>
            <xsl:when test="matches($key, '^\d+$')">
                <xsl:value-of select="$key"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- PMB-Entitätstyp (dt.) auf JSON-Vokabular-Token abbilden -->
    <xsl:function name="mam:pmb-type" as="xs:string">
        <xsl:param name="type" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$type = 'Ereignis'">event</xsl:when>
            <xsl:when test="$type = 'Werk'">work</xsl:when>
            <xsl:when test="$type = 'Person'">person</xsl:when>
            <xsl:when test="$type = 'Ort'">place</xsl:when>
            <xsl:when test="$type = 'Institution'">institution</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="lower-case(string($type))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- Personennamen umkehren: "Nachname, Vorname" → "Vorname Nachname" -->
    <xsl:function name="mam:vn-nn" as="xs:string">
        <xsl:param name="name" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="matches($name, '^[^,]+,\s*.+$')">
                <xsl:value-of select="replace($name, '^([^,]+),\s*(.+)$', '$2 $1')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- Plural-Label für Entitätstyp (für Relationen-Sektionen) -->
    <xsl:function name="mam:type-label" as="xs:string">
        <xsl:param name="type" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$type = 'Person'">Personen</xsl:when>
            <xsl:when test="$type = 'Werk'">Werke</xsl:when>
            <xsl:when test="$type = 'Ereignis'">Ereignisse</xsl:when>
            <xsl:when test="$type = 'Ort'">Orte</xsl:when>
            <xsl:when test="$type = 'Institution'">Institutionen</xsl:when>
            <xsl:when test="$type = 'Organisation'">Institutionen</xsl:when>
            <xsl:when test="$type = 'Veranstaltung'">Veranstaltungen</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string($type)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- Sortier-Schlüssel für Entitätstyp-Sektionen -->
    <xsl:function name="mam:type-order" as="xs:string">
        <xsl:param name="type" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$type = 'Person'">1</xsl:when>
            <xsl:when test="$type = 'Werk'">2</xsl:when>
            <xsl:when test="$type = 'Ereignis'">3</xsl:when>
            <xsl:when test="$type = 'Ort'">4</xsl:when>
            <xsl:when test="$type = 'Institution'">5</xsl:when>
            <xsl:when test="$type = 'Organisation'">5</xsl:when>
            <xsl:when test="$type = 'Veranstaltung'">6</xsl:when>
            <xsl:otherwise>9</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- Einklappbarer Relationen-Block (nur Relationen, deren Gegenstelle im Projekt existiert) -->
    <xsl:template name="relationen-block">
        <xsl:param name="entity" as="node()" select="."/>
        <xsl:variable name="pmbId" select="mam:to-pmb(string($entity/@xml:id))"/>
        <xsl:variable name="num" select="mam:pmb-num($pmbId)"/>
        <!-- Alte Relationen aus tei:affiliation und tei:listEvent als rel-item -->
        <xsl:variable name="legacy-items" as="element(rel-item)*">
            <xsl:for-each select="$entity/tei:affiliation">
                <xsl:variable name="targetNode"
                    select="(tei:orgName | tei:persName | tei:placeName)[1]"/>
                <xsl:variable name="pmbId2" select="mam:to-pmb(string($targetNode/@key))"/>
                <xsl:if test="$targetNode and mam:in-project($pmbId2)">
                    <xsl:variable name="dn" select="
                            if (normalize-space(tei:term) != '') then
                                normalize-space(tei:term)
                            else
                                '(ohne Bezeichnung)'"/>
                    <xsl:variable name="ot" select="
                            if ($targetNode/self::tei:orgName) then 'Organisation'
                            else if ($targetNode/self::tei:persName) then 'Person'
                            else 'Ort'"/>
                    <rel-item display-name="{$dn}" other-type="{$ot}"
                        other-id="{$pmbId2}" other-name="{normalize-space($targetNode)}"/>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="$entity/tei:listEvent/tei:event">
                <xsl:variable name="pmbId2" select="mam:to-pmb(string(@key))"/>
                <xsl:if test="mam:in-project($pmbId2)">
                    <xsl:variable name="dn" select="
                            if (normalize-space(tei:desc) != '') then
                                normalize-space(tei:desc)
                            else
                                '(ohne Bezeichnung)'"/>
                    <rel-item display-name="{$dn}" other-type="Veranstaltung"
                        other-id="{$pmbId2}" other-name="{normalize-space(tei:label)}"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <!-- Relationen aus relations.csv als strukturierte Items (beide Richtungen) -->
        <xsl:variable name="csv-items" as="element(rel-item)*">
            <xsl:if test="$num != '' and exists($relations-lines)">
                <xsl:for-each select="
                        key('rel-by-src', $num, $relations-doc)
                        | key('rel-by-tgt', $num, $relations-doc)">
                    <xsl:variable name="is-source" select="@src-id = $num"/>
                    <xsl:variable name="other-id" as="xs:string" select="
                            concat('pmb', (if ($is-source) then
                                @tgt-id
                            else
                                @src-id))"/>
                    <xsl:variable name="other-type" as="xs:string" select="
                            if ($is-source) then
                                string(@tgt-type)
                            else
                                string(@src-type)"/>
                    <xsl:variable name="other-name" as="xs:string" select="
                            if ($is-source) then
                                string(@tgt-name)
                            else
                                string(@src-name)"/>
                    <!-- Anzeigename via Vokabular aus relations.json -->
                    <xsl:variable name="class-key" as="xs:string"
                        select="concat(mam:pmb-type(@src-type), mam:pmb-type(@tgt-type), 'relation')"/>
                    <xsl:variable name="vocab-entry"
                        select="key('vocab-by-cn', concat($class-key, '|', @type), $vocab-doc)"/>
                    <!-- Bei person–person und person–event ist die Richtung im CSV
                         umgekehrt zur gewünschten Anzeigerichtung: swap -->
                    <xsl:variable name="swap" as="xs:boolean"
                        select="$class-key = 'personpersonrelation'
                                or $class-key = 'personeventrelation'"/>
                    <xsl:variable name="display-name" as="xs:string" select="
                            if ($is-source and not($swap)
                                or not($is-source) and $swap) then
                                string(@type)
                            else
                                if ($vocab-entry and $vocab-entry/@reverse != '') then
                                    string($vocab-entry/@reverse)
                                else
                                    string(@type)"/>
                    <xsl:variable name="self-type" as="xs:string" select="
                            if ($is-source) then
                                string(@src-type)
                            else
                                string(@tgt-type)"/>
                    <!-- Schnitzler (pmb2121) ⇄ Ort in beide Richtungen ausblenden -->
                    <xsl:if test="
                            not($num = '2121' and $other-type = 'Ort')
                            and not($other-id = 'pmb2121' and $self-type = 'Ort')
                            and mam:in-project($other-id)">
                        <rel-item display-name="{$display-name}" other-type="{$other-type}"
                            other-id="{$other-id}" other-name="{$other-name}"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        <!-- Alle Items zusammenführen und auf eindeutige (display-name, other-id)-Paare reduzieren -->
        <xsl:variable name="all-items" as="element(rel-item)*"
            select="$legacy-items | $csv-items"/>
        <xsl:variable name="all-items-deduped" as="element(rel-item)*">
            <xsl:for-each-group select="$all-items" group-by="concat(@display-name, '|', @other-id)">
                <xsl:sequence select="current-group()[1]"/>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:if test="exists($all-items-deduped)">
            <details class="relationen mb-3" open="open">
                <summary>
                    <legend>Relationen</legend>
                </summary>
                <!-- Pro Entitätstyp eine ein-/ausklappbare Sektion -->
                <xsl:for-each-group select="$all-items-deduped" group-by="@other-type">
                    <xsl:sort select="mam:type-order(current-grouping-key())"/>
                    <details class="relationen-typ" open="open" style="padding-left:1em">
                        <summary>
                            <xsl:value-of select="mam:type-label(current-grouping-key())"/>
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="count(current-group())"/>
                            <xsl:text>)</xsl:text>
                        </summary>
                        <ul class="dashed">
                            <!-- Pro display-name eine Zeile mit Semikolon-getrennten Zielen -->
                            <xsl:for-each-group select="current-group()" group-by="@display-name">
                                <xsl:sort select="current-grouping-key()"/>
                                <xsl:variable name="sorted-targets" as="element(rel-item)*">
                                    <xsl:for-each select="current-group()">
                                        <xsl:sort select="@other-name"/>
                                        <xsl:sequence select="."/>
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:variable name="total" select="count($sorted-targets)"/>
                                <li>
                                    <xsl:value-of select="current-grouping-key()"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:for-each select="$sorted-targets[position() le 10]">
                                        <a href="{concat(@other-id, '.html')}">
                                            <xsl:value-of select="mam:vn-nn(@other-name)"/>
                                        </a>
                                        <xsl:if test="position() != last() or $total gt 10">
                                            <xsl:text>; </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                    <xsl:if test="$total gt 10">
                                        <details class="rel-inline">
                                            <summary>
                                                <xsl:text>… </xsl:text>
                                                <xsl:value-of select="$total - 10"/>
                                                <xsl:text> weitere</xsl:text>
                                            </summary>
                                            <xsl:for-each select="subsequence($sorted-targets, 11)">
                                                <a href="{concat(@other-id, '.html')}">
                                                    <xsl:value-of select="mam:vn-nn(@other-name)"/>
                                                </a>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </details>
                                    </xsl:if>
                                </li>
                            </xsl:for-each-group>
                        </ul>
                    </details>
                </xsl:for-each-group>
            </details>
        </xsl:if>
    </xsl:template>
    <!-- Namensvarianten gruppiert ausgeben (eine Zeile pro Typ, Werte kommagetrennt) -->
    <xsl:template name="persName-gruppen">
        <xsl:param name="namen"/>
        <xsl:for-each-group select="$namen" group-by="@type">
            <xsl:variable name="typ" select="current-grouping-key()"/>
            <xsl:variable name="anzahl" select="count(current-group())"/>
            <xsl:variable name="label">
                <xsl:choose>
                    <xsl:when test="$typ = 'person_rufname_vorname'">
                        <xsl:choose>
                            <xsl:when test="$anzahl &gt; 1">Rufnamen</xsl:when>
                            <xsl:otherwise>Rufname</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$typ = 'person_ehename_nachname'">
                        <xsl:choose>
                            <xsl:when test="$anzahl &gt; 1">Ehenamen</xsl:when>
                            <xsl:otherwise>Ehename</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$typ = 'person_pseudonym'">
                        <xsl:choose>
                            <xsl:when test="$anzahl &gt; 1">Pseudonyme</xsl:when>
                            <xsl:otherwise>Pseudonym</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$typ = 'person_namensvariante'">
                        <xsl:choose>
                            <xsl:when test="$anzahl &gt; 1">Namensvarianten</xsl:when>
                            <xsl:otherwise>Namensvariante</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$typ = 'person_namensvariante-nachname'">Namensvariante
                        Nachname</xsl:when>
                    <xsl:when test="$typ = 'person_namensvariante-vorname'">Namensvariante
                        Vorname</xsl:when>
                    <xsl:when test="$typ = 'person_adoptierter-nachname'">Nachname durch
                        Adoption</xsl:when>
                    <xsl:when test="$typ = 'person_geschieden_nachname'">geschieden</xsl:when>
                    <xsl:when test="$typ = 'person_verwitwet_nachname'">verwitwet</xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="$label != ''">
                <p class="personenname">
                    <xsl:value-of select="$label"/>
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="string-join(current-group()/string(.), ', ')"/>
                </p>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>
