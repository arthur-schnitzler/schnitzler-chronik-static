<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://dse-static.foo.bar"
    xmlns:mam="whatever" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes"
        omit-xml-declaration="yes"/>
    <!-- Einbindung in anderen Projekten:

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
                                    <xsl:with-param name="import-eventtypes" select="''"/>
                                </xsl:call-template>

    teiSource ist der aktuelle Dateiname/die xml:id ohne .xml-Endung (z. B. 'L000122'); Einträge,
    die auf das aktuelle Dokument selbst zeigen, werden ausgelassen.

    fetchContentsFromURL enthält bereits den Chronik-Tag; das erlaubt lokale Verarbeitung
    (schneller als der Download je Datei).

    Die Ausgabe ist selbsttragend (CSS im <style>-Block, gescoped auf .chronik-embed) und
    funktioniert sowohl in einem Bootstrap-Modal als auch in einem breiten Container
    (Querformat/Drawer): Die Kacheln packen sich über CSS-Spalten platzsparend zusammen,
    je nach verfügbarer Breite ein- oder mehrspaltig.
    -->
    <xsl:param name="relevant-uris"
        select="document('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-chronik-static/refs/heads/main/xslt/export/list-of-relevant-uris.xml')"/>
    <!--<xsl:param name="relevant-uris" select="document('list-of-relevant-uris.xml')"/>-->
    <xsl:import href="./LOD-idnos.xsl"/>
    <xsl:key match="item" use="abbr" name="relevant-uris-type"/>
    <!-- Farbe eines Eventtyps laut list-of-relevant-uris.xml, Fallback 'blue' -->
    <xsl:function name="mam:typ-farbe" as="xs:string">
        <xsl:param name="e-typ" as="xs:string?"/>
        <xsl:variable name="color"
            select="key('only-relevant-uris', $e-typ, $relevant-uris)/*:color[. != '#fff']"/>
        <xsl:sequence select="
                if (exists($color)) then
                    string($color[1])
                else
                    'blue'"/>
    </xsl:function>
    <xsl:template name="mam:schnitzler-chronik">
        <xsl:param name="datum-iso" as="xs:date"/>
        <xsl:param name="current-type" as="xs:string"/>
        <xsl:param name="teiSource" as="xs:string"/>
        <xsl:param name="fetchContentsFromURL" as="node()?"/>
        <xsl:param name="import-eventtypes" as="xs:string?"/>
        <!-- prominente Datums-Überschrift (klar als Link) über den Kacheln; in der
             Standalone-Chronikseite ausgeschaltet, weil dort schon der h1-Titel steht -->
        <xsl:param name="show-date-heading" as="xs:boolean" select="true()"/>
        <xsl:variable name="relevant-eventtypes" as="xs:string">
            <!-- falls keine typen übergeben werden, werden die standardwerte genommen -->
            <xsl:choose>
                <xsl:when test="empty($import-eventtypes) or $import-eventtypes = ''">
                    <xsl:text>Arthur-Schnitzler-digital,schnitzler-tagebuch,schnitzler-briefe,pollaczek,schnitzler-interviews,schnitzler-bahr,schnitzler-orte,wienerschnitzler,schnitzler-kultur,schnitzler-fischer,schnitzler-chronik-manuell,pmb,schnitzler-cmif,schnitzler-mikrofilme-daten,schnitzler-traeume,schnitzler-kino-buch,schnitzler-kempny-buch,dla-marbach,kalliope-verbund</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$import-eventtypes"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$fetchContentsFromURL/descendant::*:listEvent/*:event">
            <!-- Einträge, die auf das aktuelle Dokument selbst verweisen, werden entfernt -->
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
            <div id="chronik-modal-body" class="chronik-embed">
                <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"/>
                <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
                <!-- Selbsttragendes, auf .chronik-embed gescopetes CSS, damit importierende
                     Projekte nichts ergänzen müssen. Kachel-Farbe steckt je Kachel in der
                     Custom Property &#45;&#45;c; Hintergrund-Tönung via color-mix. -->
                <style>
                    .chronik-embed {
                        font-size: .85rem;
                        line-height: 1.35;
                    }
                    /* prominente, klar als Link erkennbare Datums-Überschrift */
                    .chronik-embed .chronik-date-heading {
                        margin: 0 0 .7rem 0;
                        text-align: center;
                        line-height: 1.2;
                    }
                    .chronik-embed .chronik-date-heading a {
                        display: inline-block;
                        font-size: 1.25rem;
                        font-weight: 700;
                        color: #008B8B;
                        text-decoration: underline;
                        text-decoration-thickness: .08em;
                        text-underline-offset: .18em;
                    }
                    .chronik-embed .chronik-date-heading a::after {
                        content: "\00A0\2197";
                        font-size: .7em;
                        text-decoration: none;
                        vertical-align: .15em;
                    }
                    .chronik-embed .chronik-date-heading a:hover {
                        color: #006d6d;
                        text-decoration: underline;
                    }
                    /* Masonry über CSS-Spalten: packt die Kacheln platzsparend,
                       im schmalen Modal einspaltig, im Querformat mehrspaltig */
                    .chronik-embed .chronik-cards {
                        column-width: 17rem;
                        column-gap: .6rem;
                    }
                    /* inline-block statt block: verhindert, dass der untere Außenabstand
                       am Spaltenumbruch in die nächste Spalte »blutet« und deren erste
                       Kachel nach unten schiebt */
                    .chronik-embed .chronik-card {
                        display: inline-block;
                        width: 100%;
                        vertical-align: top;
                        break-inside: avoid;
                        -webkit-column-break-inside: avoid;
                        margin: 0 0 .6rem 0;
                        border-radius: .45rem;
                        overflow: hidden;
                        background-color: #f4f4f4;
                        background-color: color-mix(in srgb, var(--c, #595959) 9%, white);
                    }
                    .chronik-embed .chronik-card-head {
                        background-color: var(--c, #595959);
                        padding: .2rem .65rem .25rem .65rem;
                        line-height: 1.2;
                    }
                    .chronik-embed .chronik-card-head a,
                    .chronik-embed .chronik-card-head span {
                        color: #fff;
                        text-decoration: none;
                        font-size: .72rem;
                        font-weight: 600;
                        text-transform: uppercase;
                        letter-spacing: .04em;
                    }
                    /* Kachel-Überschrift klar als Link kennzeichnen: dezenter
                       Unterstrich plus Pfeil-Symbol (nur am echten Link, nicht am span) */
                    .chronik-embed .chronik-card-head a {
                        text-decoration: underline;
                        text-decoration-thickness: .06em;
                        text-underline-offset: .18em;
                    }
                    .chronik-embed .chronik-card-head a::after {
                        content: "\00A0\2197";
                        font-size: .9em;
                        text-decoration: none;
                        vertical-align: .1em;
                    }
                    .chronik-embed .chronik-card-head a:hover {
                        color: #fff;
                        text-decoration: underline;
                    }
                    .chronik-embed .chronik-card-body {
                        padding: .45rem .65rem .55rem .65rem;
                    }
                    .chronik-embed .chronik-event p {
                        margin: 0 0 .2rem 0;
                    }
                    .chronik-embed .entry-title {
                        color: var(--c, inherit);
                        font-weight: 600;
                        text-decoration: none;
                    }
                    .chronik-embed a.entry-title:hover {
                        text-decoration: underline;
                    }
                    .chronik-embed .chronik-entities {
                        margin: 0 0 .2rem 0;
                        font-size: .8rem;
                    }
                    .chronik-embed .chronik-entities > i {
                        color: var(--c, #595959);
                        margin-right: .3rem;
                        font-size: .75em;
                    }
                    .chronik-embed ul.horizontal-list {
                        display: inline;
                        margin: 0;
                        padding: 0;
                        list-style: none;
                    }
                    .chronik-embed ul.horizontal-list li {
                        display: inline;
                        margin: 0;
                        padding: 0;
                    }
                    .chronik-embed ul.horizontal-list li::before {
                        content: none;
                    }
                    .chronik-embed ul.horizontal-list li:not(:last-child)::after {
                        content: ' · ';
                        color: var(--c, #888);
                    }
                    .chronik-embed ul.horizontal-list a {
                        color: inherit;
                    }
                    .chronik-embed .chronik-card-body a {
                        text-decoration: none;
                    }
                    .chronik-embed .chronik-card-body a:hover {
                        text-decoration: underline;
                    }
                    .chronik-embed ul.chronik-place-list {
                        margin: 0;
                        padding-left: 1.1em;
                        font-size: .8rem;
                    }
                    .chronik-embed .chronik-text {
                        margin: 0 0 .2rem 0;
                    }
                    .chronik-embed .chronik-quelle {
                        font-size: .75rem;
                        opacity: .75;
                    }
                    .chronik-embed .chronik-links {
                        font-size: .8rem;
                    }
                    .chronik-embed .chronik-card-map .chronik-card-body {
                        padding: 0;
                    }
                    .chronik-embed #wienerschnitzler-map {
                        height: 240px;
                        width: 100%;
                    }
                    .chronik-embed ul.chronik-misc-list {
                        margin: 0;
                        padding: 0;
                        list-style: none;
                    }
                    .chronik-embed ul.chronik-misc-list li + li {
                        margin-top: .2rem;
                    }
                </style>
                <xsl:if test="$show-date-heading">
                    <xsl:variable name="datum-written" select="
                            format-date($datum-iso, '[D1].&#160;[M1].&#160;[Y0001]',
                            'en',
                            'AD',
                            'EN')"/>
                    <xsl:variable name="wochentag" select="
                            ('Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag')[index-of(
                            ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
                            format-date($datum-iso, '[F]', 'en', 'AD', 'EN'))]"/>
                    <h2 class="chronik-date-heading">
                        <a href="{concat('https://schnitzler-chronik.acdh.oeaw.ac.at/', $datum-iso, '.html')}"
                            target="_blank">
                            <xsl:value-of select="concat($wochentag, ', ', $datum-written)"/>
                        </a>
                    </h2>
                </xsl:if>
                <div class="chronik-cards">
                    <xsl:call-template name="karte-mit-datum">
                        <xsl:with-param name="datum" select="$datum-iso"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="$fetchURLohneTeiSource" mode="schnitzler-chronik">
                        <xsl:with-param name="relevant-eventtypes" select="$relevant-eventtypes"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="mam:chronik-weiteres">
                        <xsl:with-param name="datum-iso" select="$datum-iso"/>
                    </xsl:call-template>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- Kachel »Weiteres«: externe Tagesangebote (ANNO, correspSearch) -->
    <xsl:template name="mam:chronik-weiteres">
        <xsl:param name="datum-iso" as="xs:date"/>
        <xsl:variable name="datum-written" select="
                format-date($datum-iso, '[D1].&#160;[M1].&#160;[Y0001]',
                'en',
                'AD',
                'EN')"/>
        <xsl:variable name="wochentag" select="
                ('Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag')[index-of(
                ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
                format-date($datum-iso, '[F]', 'en', 'AD', 'EN'))]"/>
        <xsl:variable name="anno-url"
            select="concat('https://anno.onb.ac.at/cgi-content/anno?datum=', replace(string($datum-iso), '-', ''))"/>
        <xsl:variable name="correspsearch-url"
            select="concat('https://correspsearch.net/de/suche.html?d=', $datum-iso, '&amp;x=1&amp;w=0')"/>
        <section class="chronik-card" id="chronik-card-weiteres" style="--c: #595959;">
            <header class="chronik-card-head">
                <span>Weiteres</span>
            </header>
            <div class="chronik-card-body">
                <ul class="chronik-misc-list">
                    <li>
                        <xsl:text>Zeitungen vom </xsl:text>
                        <a href="{$anno-url}" target="_blank">
                            <xsl:value-of select="concat($wochentag, ', ', $datum-written)"/>
                        </a>
                        <xsl:text> (ANNO)</xsl:text>
                    </li>
                    <li>
                        <xsl:text>Briefe vom </xsl:text>
                        <a href="{$correspsearch-url}" target="_blank">
                            <xsl:value-of select="concat($wochentag, ', ', $datum-written)"/>
                        </a>
                        <xsl:text> (correspSearch)</xsl:text>
                    </li>
                </ul>
            </div>
        </section>
    </xsl:template>
    <!-- eine Kachel je Ereignis, Typen in der Reihenfolge von $relevant-eventtypes;
         kleine Einheiten geben dem Spalten-Masonry mehr Spielraum beim Packen -->
    <xsl:template match="tei:listEvent" mode="schnitzler-chronik">
        <xsl:param name="relevant-eventtypes"/>
        <xsl:variable name="current-group" select="." as="node()"/>
        <xsl:for-each select="tokenize($relevant-eventtypes, ',')">
            <xsl:variable name="e-typ" as="xs:string" select="normalize-space(.)"/>
            <xsl:variable name="kopf-caption">
                <xsl:choose>
                    <xsl:when test="key('only-relevant-uris', $e-typ, $relevant-uris)/*:caption">
                        <xsl:value-of
                            select="key('only-relevant-uris', $e-typ, $relevant-uris)/*:caption"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$e-typ"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <!-- Wiener Schnitzler: alle Ereignisse des Tages in einem einzelnen Kästchen -->
                <xsl:when test="$e-typ = 'wienerschnitzler'">
                    <xsl:variable name="ws-events"
                        select="$current-group/tei:event[tei:idno[@type = $e-typ or @subtype = $e-typ]]"/>
                    <xsl:if test="$ws-events">
                        <xsl:variable name="ws-idno"
                            select="string($ws-events[1]/tei:idno[@type = $e-typ or @subtype = $e-typ][1])"/>
                        <xsl:variable name="ws-url">
                            <xsl:choose>
                                <xsl:when test="starts-with($ws-idno, 'http')">
                                    <xsl:value-of select="$ws-idno"/>
                                </xsl:when>
                                <xsl:when test="key('only-relevant-uris', $e-typ, $relevant-uris)/*:url">
                                    <xsl:value-of
                                        select="key('only-relevant-uris', $e-typ, $relevant-uris)/*:url"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <section class="chronik-card" id="chronik-card-{$e-typ}"
                            style="--c: {mam:typ-farbe($e-typ)};">
                            <header class="chronik-card-head">
                                <xsl:choose>
                                    <xsl:when test="$ws-url != ''">
                                        <a href="{$ws-url}" target="_blank">
                                            <xsl:value-of select="$kopf-caption"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <span>
                                            <xsl:value-of select="$kopf-caption"/>
                                        </span>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </header>
                            <div class="chronik-card-body">
                                <xsl:apply-templates select="$ws-events"/>
                            </div>
                        </section>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each
                        select="$current-group/tei:event[tei:idno[@type = $e-typ or @subtype = $e-typ]]">
                        <xsl:variable name="kopf-idno"
                            select="string(tei:idno[@type = $e-typ or @subtype = $e-typ][1])"/>
                        <xsl:variable name="kopf-url">
                            <xsl:choose>
                                <xsl:when test="starts-with($kopf-idno, 'http')">
                                    <xsl:value-of select="$kopf-idno"/>
                                </xsl:when>
                                <xsl:when test="starts-with($kopf-idno, 'doi')">
                                    <xsl:value-of select="concat('https://', $kopf-idno)"/>
                                </xsl:when>
                                <xsl:when test="key('only-relevant-uris', $e-typ, $relevant-uris)/*:url">
                                    <xsl:value-of
                                        select="key('only-relevant-uris', $e-typ, $relevant-uris)/*:url"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <section class="chronik-card" id="chronik-card-{$e-typ}-{position()}"
                            style="--c: {mam:typ-farbe($e-typ)};">
                            <header class="chronik-card-head">
                                <xsl:choose>
                                    <xsl:when test="$kopf-url != ''">
                                        <a href="{$kopf-url}" target="_blank">
                                            <xsl:value-of select="$kopf-caption"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <span>
                                            <xsl:value-of select="$kopf-caption"/>
                                        </span>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </header>
                            <div class="chronik-card-body">
                                <xsl:apply-templates select="."/>
                            </div>
                        </section>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!-- jeder einzelne Eintrag -->
    <xsl:template match="tei:event">
        <xsl:variable name="e-typ" select="(tei:idno/@type[. != 'URL'], tei:idno/@subtype)[1]"/>
        <xsl:variable name="e-typ-multiple" as="xs:boolean"
            select="key('only-relevant-uris', $e-typ, $relevant-uris)/@ana = 'multiple'"/>
        <div class="chronik-event">
            <xsl:if test="tei:head">
                <xsl:variable name="head-url">
                    <xsl:choose>
                        <xsl:when test="$e-typ = 'wienerschnitzler' and tei:head/@corresp">
                            <xsl:value-of
                                select="concat('https://wienerschnitzler.org/', replace(tei:head/@corresp, '#', ''), '.html')"
                            />
                        </xsl:when>
                        <xsl:when test="starts-with(tei:idno[1]/text(), 'http')">
                            <xsl:value-of select="tei:idno[1]/text()"/>
                        </xsl:when>
                        <xsl:when test="starts-with(tei:idno[1]/text(), 'doi')">
                            <xsl:value-of select="concat('https://', tei:idno[1]/text())"/>
                        </xsl:when>
                        <xsl:when test="tei:head/@corresp">
                            <xsl:value-of
                                select="concat('https://pmb.acdh.oeaw.ac.at/entity/', replace(replace(tei:head/@corresp, '#', ''), 'pmb', ''), '/')"
                            />
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <p>
                    <xsl:choose>
                        <xsl:when test="$head-url != ''">
                            <a class="entry-title" href="{$head-url}" target="_blank">
                                <xsl:value-of select="tei:head/text()"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="entry-title">
                                <xsl:value-of select="tei:head/text()"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </p>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="tei:desc/child::*[1]">
                    <xsl:apply-templates select="tei:desc" mode="desc"/>
                </xsl:when>
                <xsl:when test="normalize-space(tei:desc) != ''">
                    <p class="chronik-text">
                        <xsl:value-of select="normalize-space(tei:desc)"/>
                    </p>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="$e-typ-multiple and tei:idno[@type = $e-typ or @subtype = $e-typ][2]">
                <p class="chronik-links">
                    <xsl:for-each select="tei:idno[@type = $e-typ or @subtype = $e-typ]">
                        <a href="{.}" target="_blank">
                            <xsl:value-of select="concat('Link ', position())"/>
                        </a>
                        <xsl:if test="position() != last()">
                            <xsl:text> / </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </p>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="tei:event/tei:desc" mode="desc">
        <xsl:for-each select="*[starts-with(name(), 'list')]">
            <div class="chronik-entities">
                <xsl:choose>
                    <xsl:when test="self::tei:listPlace">
                        <i class="fa-solid fa-location-dot" role="img" title="Orte"
                            aria-label="Orte"/>
                    </xsl:when>
                    <xsl:when test="self::tei:listPerson">
                        <i class="fa-solid fa-users" role="img" title="Personen"
                            aria-label="Personen"/>
                    </xsl:when>
                    <xsl:when test="self::tei:listOrg">
                        <i class="fa-solid fa-building-columns" role="img" title="Organisationen"
                            aria-label="Organisationen"/>
                    </xsl:when>
                    <xsl:when test="self::tei:listBibl">
                        <i class="fa-regular fa-image" role="img" title="Werke" aria-label="Werke"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates select="." mode="desc"/>
            </div>
        </xsl:for-each>
        <xsl:apply-templates select="tei:*[not(starts-with(name(), 'list'))]" mode="desc"/>
        <xsl:if test="text()[normalize-space(.) != '']">
            <p class="chronik-text">
                <xsl:value-of
                    select="normalize-space(string-join(text()[normalize-space(.) != ''], ' '))"/>
            </p>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:listPerson" mode="desc">
        <xsl:variable name="e-typ"
            select="(ancestor::tei:event/tei:idno/@type[. != 'URL'], ancestor::tei:event/tei:idno/@subtype)[1]"/>
        <ul class="horizontal-list" style="--dot-color: {mam:typ-farbe($e-typ)};">
            <xsl:for-each select="tei:person/tei:persName[1]">
                <xsl:variable name="ref" select="replace(concat(@ref[1], @key[1]), '^#', '')"/>
                <li>
                    <xsl:call-template name="mam:entity-link">
                        <xsl:with-param name="ref" select="$ref"/>
                        <xsl:with-param name="e-typ" select="$e-typ"/>
                        <xsl:with-param name="label" select="normalize-space(.)"/>
                    </xsl:call-template>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    <xsl:template match="tei:listOrg" mode="desc">
        <xsl:variable name="e-typ"
            select="(ancestor::tei:event/tei:idno/@type[. != 'URL'], ancestor::tei:event/tei:idno/@subtype)[1]"/>
        <ul class="horizontal-list" style="--dot-color: {mam:typ-farbe($e-typ)};">
            <xsl:for-each select="tei:org/tei:orgName">
                <xsl:variable name="ref" select="replace(concat(@ref, @key), '^#', '')"/>
                <li>
                    <xsl:call-template name="mam:entity-link">
                        <xsl:with-param name="ref" select="$ref"/>
                        <xsl:with-param name="e-typ" select="$e-typ"/>
                        <xsl:with-param name="label" select="normalize-space(.)"/>
                    </xsl:call-template>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    <xsl:template match="tei:listPlace" mode="desc">
        <xsl:variable name="e-typ"
            select="(ancestor::tei:event/tei:idno/@type[. != 'URL'], ancestor::tei:event/tei:idno/@subtype)[1]"/>
        <xsl:choose>
            <!-- Wiener Schnitzler: Orte als Block-Liste, ggf. verschachtelt -->
            <xsl:when test="$e-typ = 'wienerschnitzler'">
                <ul class="chronik-place-list" style="--dot-color: {mam:typ-farbe($e-typ)};">
                    <xsl:for-each select="tei:place">
                        <xsl:variable name="ref" select="replace(@corresp, '#', '')"/>
                        <li>
                            <xsl:element name="a">
                                <xsl:attribute name="href">
                                    <xsl:choose>
                                        <xsl:when test="starts-with($ref, 'pmb')">
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
                            <xsl:apply-templates select="tei:listPlace" mode="desc"/>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <ul class="horizontal-list" style="--dot-color: {mam:typ-farbe($e-typ)};">
                    <xsl:for-each select="tei:place/tei:placeName">
                        <xsl:variable name="ref" select="replace(concat(@ref, @key), '^#', '')"/>
                        <li>
                            <xsl:call-template name="mam:entity-link">
                                <xsl:with-param name="ref" select="$ref"/>
                                <xsl:with-param name="e-typ" select="$e-typ"/>
                                <xsl:with-param name="label" select="normalize-space(.)"/>
                            </xsl:call-template>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:desc/tei:listBibl" mode="desc">
        <xsl:variable name="e-typ"
            select="(ancestor::tei:event/tei:idno/@type[. != 'URL'], ancestor::tei:event/tei:idno/@subtype)[1]"/>
        <ul class="horizontal-list" style="--dot-color: {mam:typ-farbe($e-typ)};">
            <xsl:for-each select="descendant::tei:title">
                <xsl:variable name="ref" select="replace(concat(@ref, @key), '^#', '')"/>
                <li>
                    <xsl:call-template name="mam:entity-link">
                        <xsl:with-param name="ref" select="$ref"/>
                        <xsl:with-param name="e-typ" select="$e-typ"/>
                        <xsl:with-param name="label" select="normalize-space(.)"/>
                        <xsl:with-param name="truncate" select="true()"/>
                    </xsl:call-template>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    <xsl:template match="tei:bibl[parent::tei:desc]" mode="desc">
        <p class="chronik-quelle">
            <xsl:text>Quelle: </xsl:text>
            <i>
                <xsl:value-of select="."/>
            </i>
        </p>
    </xsl:template>
    <!-- Erzeugt einen Link oder plain text, abhängig von $ref und $e-typ.
         $truncate: bei true() wird $label auf 50 Zeichen gekürzt (für Titel). -->
    <xsl:template name="mam:entity-link">
        <xsl:param name="ref" as="xs:string"/>
        <xsl:param name="e-typ" as="xs:string"/>
        <xsl:param name="label" as="xs:string"/>
        <xsl:param name="truncate" as="xs:boolean" select="false()"/>
        <xsl:variable name="url">
            <xsl:choose>
                <xsl:when
                    test="starts-with($ref, 'https://d-nb') or starts-with($ref, 'http://d-nb')">
                    <xsl:value-of
                        select="concat('https://correspsearch.net/de/suche.html?s=', replace($ref, 'https', 'http'))"
                    />
                </xsl:when>
                <xsl:when test="$e-typ = 'schnitzler-fischer' and starts-with($ref, 'pmb')">
                    <xsl:value-of
                        select="concat('https://pmb.acdh.oeaw.ac.at/entity/', replace($ref, 'pmb', ''), '/')"
                    />
                </xsl:when>
                <xsl:when test="$e-typ = 'schnitzler-kultur' and starts-with($ref, 'pmb')">
                    <xsl:value-of
                        select="concat('https://schnitzler-kultur.acdh.oeaw.ac.at/', $ref, '.html')"
                    />
                </xsl:when>
                <xsl:when test="starts-with($ref, 'pmb')">
                    <xsl:value-of
                        select="concat('https://', $e-typ, '.acdh.oeaw.ac.at/', $ref, '.html')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="display-label">
            <xsl:choose>
                <xsl:when test="$truncate and string-length(normalize-space($label)) > 50">
                    <xsl:value-of select="concat(substring(normalize-space($label), 1, 50), '…')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$label"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$url != ''">
                <a href="{$url}" target="_blank">
                    <xsl:value-of select="$display-label"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$label"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- mam:hexNachRGBfarbe/mam:hexToDec/mam:power werden hier nicht mehr gebraucht
         (Tönung via CSS color-mix), bleiben aber erhalten, weil importierende
         Stylesheets (z. B. editions.xsl der Chronik selbst) sie verwenden. -->
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
    <!-- Karten-Kachel; wird von einzelnen Projekten (schnitzler-briefe, Chronik selbst)
         mit eigener Version überschrieben -->
    <xsl:template name="karte-mit-datum">
        <xsl:param name="datum"/>
        <section class="chronik-card chronik-card-map" id="chronik-card-karte"
            style="--c: #595959;">
            <header class="chronik-card-head">
                <span>Aufenthaltsorte</span>
            </header>
            <div class="chronik-card-body">
                <div id="wienerschnitzler-map" data-datum="{$datum}"></div>
            </div>
        </section>
        <!-- Externes Leaflet-Script -->
        <script src="https://cdn.jsdelivr.net/gh/arthur-schnitzler/schnitzler-chronik-static@57de659/xslt/export/wienerschnitzler-map.js?v=5"></script>
        <!-- Initialisierung: im Bootstrap-Modal beim Öffnen, sonst (Drawer/Inline),
             sobald die Karte sichtbar wird. Doppelte Initialisierung wird über
             _leaflet_id verhindert.
             Achtung: kein && und kein < im Inline-JS verwenden – method="xhtml"
             serialisiert die als Entities, die der Browser in script nicht
             dekodiert (SyntaxError, Karte erscheint nicht). -->
        <script>
            (function () {
                function initMap() {
                    var el = document.getElementById('wienerschnitzler-map');
                    if (!el || el._leaflet_id) { return; }
                    if (window.initWienerschnitzlerMap) { window.initWienerschnitzlerMap(); }
                }
                var modal = document.getElementById('schnitzler-chronik-modal');
                if (modal) {
                    modal.addEventListener('shown.bs.modal', function () {
                        setTimeout(initMap, 100);
                        window.dispatchEvent(new Event('resize'));
                    });
                } else {
                    document.addEventListener('drawer:open', function () {
                        setTimeout(initMap, 100);
                        window.dispatchEvent(new Event('resize'));
                    });
                    var el = document.getElementById('wienerschnitzler-map');
                    if (!el) {
                        initMap();
                    } else if ('IntersectionObserver' in window) {
                        new IntersectionObserver(function (entries, obs) {
                            entries.forEach(function (entry) {
                                if (entry.isIntersecting) {
                                    obs.disconnect();
                                    initMap();
                                }
                            });
                        }).observe(el);
                    } else {
                        initMap();
                    }
                }
            })();
        </script>
    </xsl:template>
</xsl:stylesheet>
