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
    <xsl:variable name="teiSource">
        <xsl:value-of select="data(tei:TEI/@xml:id)"/>
    </xsl:variable>
    <xsl:variable name="link">
        <xsl:value-of select="replace($teiSource, '.xml', '.html')"/>
    </xsl:variable>
    <xsl:variable name="doc_title">
        <xsl:value-of select=".//tei:title[@level = 'a'][1]/text()"/>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:variable name="datum-iso" select="descendant::tei:titleStmt/tei:title/@when-iso"
            as="xs:date"/>
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
                                        <h3 align="center">
                                            <a href="{$teiSource}">
                                                <i class="fas fa-download" title="show TEI source"/>
                                            </a>
                                        </h3>
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
                                <xsl:apply-templates select=".//tei:body"/>
                            </div>
                            <div class="card-footer">
                                <p style="text-align:center;">
                                    <xsl:for-each select=".//tei:note[not(./tei:p)]">
                                        <div class="footnotes" id="{local:makeId(.)}">
                                            <xsl:element name="a">
                                                <xsl:attribute name="name">
                                                  <xsl:text>fn</xsl:text>
                                                  <xsl:number level="any" format="1"
                                                  count="tei:note"/>
                                                </xsl:attribute>
                                                <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:text>#fna_</xsl:text>
                                                  <xsl:number level="any" format="1"
                                                  count="tei:note"/>
                                                  </xsl:attribute>
                                                  <span
                                                  style="font-size:7pt;vertical-align:super; margin-right: 0.4em">
                                                  <xsl:number level="any" format="1"
                                                  count="tei:note"/>
                                                  </span>
                                                </a>
                                            </xsl:element>
                                            <xsl:apply-templates/>
                                        </div>
                                    </xsl:for-each>
                                </p>
                            </div>
                        </div>
                    </div>
                    <xsl:for-each select="//tei:back">
                        <div class="tei-back">
                            <xsl:apply-templates/>
                        </div>
                    </xsl:for-each>
                    <!-- <xsl:for-each select=".//tei:back//tei:org[@xml:id]">
                        
                        <div class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
                            <xsl:attribute name="id">
                                <xsl:value-of select="./@xml:id"/>
                            </xsl:attribute>
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">
                                            <xsl:value-of select=".//tei:orgName[1]/text()"/>
                                        </h5>
                                        
                                    </div>
                                    <div class="modal-body">
                                        <xsl:call-template name="org_detail">
                                            <xsl:with-param name="showNumberOfMentions" select="5"/>
                                        </xsl:call-template>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Schließen</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select=".//tei:back//tei:person[@xml:id]">
                        <xsl:variable name="xmlId">
                            <xsl:value-of select="data(./@xml:id)"/>
                        </xsl:variable>
                        
                        <div class="modal fade" tabindex="-1" role="dialog" aria-hidden="true" id="{$xmlId}">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">
                                            <xsl:value-of select="normalize-space(string-join(.//tei:persName[1]//text()))"/>
                                            <xsl:text> </xsl:text>
                                            <a href="{concat($xmlId, '.html')}">
                                                <i class="fas fa-external-link-alt"></i>
                                            </a>
                                        </h5>
                                        
                                    </div>
                                    <div class="modal-body">
                                        <xsl:call-template name="person_detail">
                                            <xsl:with-param name="showNumberOfMentions" select="5"/>
                                        </xsl:call-template>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Schließen</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select=".//tei:back//tei:place[@xml:id]">
                        <xsl:variable name="xmlId">
                            <xsl:value-of select="data(./@xml:id)"/>
                        </xsl:variable>
                        
                        <div class="modal fade" tabindex="-1" role="dialog" aria-hidden="true" id="{$xmlId}">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">
                                            <xsl:value-of select="normalize-space(string-join(.//tei:placeName[1]/text()))"/>
                                            <xsl:text> </xsl:text>
                                            <a href="{concat($xmlId, '.html')}">
                                                <i class="fas fa-external-link-alt"></i>
                                            </a>
                                        </h5>
                                    </div>
                                    <div class="modal-body">
                                        <xsl:call-template name="place_detail">
                                            <xsl:with-param name="showNumberOfMentions" select="5"/>
                                        </xsl:call-template>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Schließen</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </xsl:for-each> -->
                    <xsl:call-template name="html_footer"/>
                </div>
                <script src="https://unpkg.com/de-micro-editor@0.2.6/dist/de-editor.min.js"/>
                <script type="text/javascript" src="js/run.js"/>
                <script type="text/javascript" src="js/osd_scroll.js"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:p">
        <p id="{local:makeId(.)}" class="yes-index">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:div">
        <div id="{local:makeId(.)}" style="margin-top=1em;">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:listEvent">
        <xsl:apply-templates select="tei:event[tei:idno/@type = 'Arthur-Schnitzler-digital']"/>
        <xsl:apply-templates select="tei:event[tei:idno/@type = 'schnitzler-tagebuch']"/>
        <xsl:apply-templates select="tei:event[tei:idno/@type = 'schnitzler-briefe']"/>
        <xsl:apply-templates select="tei:event[tei:idno/@type = 'schnitzler-orte']"/>
        <xsl:apply-templates
            select="tei:event[not(tei:idno/@type = 'Arthur-Schnitzler-digital') and not(tei:idno/@type = 'schnitzler-tagebuch') and not(tei:idno/@type = 'schnitzler-briefe') and not(tei:idno/@type = 'schnitzler-orte')]"/>
        <div class="weiteres" style="margin-top=1em;">
            <ul>
                <li>
                    <xsl:text>Zeitungen vom </xsl:text>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of
                                select="concat('https://anno.onb.ac.at/cgi-content/anno?datum=', replace(ancestor::tei:TEI/descendant::tei:titleStmt/tei:title[@level = 'a'][1]/@when-iso, '-', ''))"
                            />
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of
                            select="ancestor::tei:TEI/descendant::tei:titleStmt/tei:title[@level = 'a'][1]"
                        />
                    </xsl:element>
                    <xsl:text> bei </xsl:text>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of
                                select="concat('https://anno.onb.ac.at/cgi-content/anno?datum=', replace(ancestor::tei:TEI/descendant::tei:titleStmt/tei:title[@level = 'a'][1]/@when-iso, '-', ''))"
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
                                select="concat('https://correspsearch.net/de/suche.html?d=', ancestor::tei:TEI/descendant::tei:titleStmt/tei:title[@level='a'][1]/@when-iso, '&amp;x=1&amp;w=0')"
                            />
                        </xsl:attribute>
                        <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of
                            select="ancestor::tei:TEI/descendant::tei:titleStmt/tei:title[@level = 'a'][1]"
                        />
                    </xsl:element>
                    <xsl:text> bei </xsl:text>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of
                                select="concat('https://correspsearch.net/de/suche.html?d=', ancestor::tei:TEI/descendant::tei:titleStmt/tei:title[@level='a'][1]/@when-iso, '&amp;x=1&amp;w=0')"
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
    </xsl:template>
    <xsl:template match="tei:event">
        <div class="{tei:idno[1]/@type}">
            <xsl:choose>
                <xsl:when test="tei:idno[@type]">
                    <xsl:variable name="idnos-of-current" as="node()">
                        <xsl:element name="nodeset">
                            <xsl:for-each select="tei:idno">
                                <xsl:copy-of select="."/>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:variable>
                    <p>
                        <xsl:call-template name="mam:idnosToLinks">
                            <xsl:with-param name="idnos-of-current" select="$idnos-of-current"/>
                        </xsl:call-template>
                    </p>
                </xsl:when>
                <xsl:otherwise>
                    <legend>Weitere Angaben</legend>
                </xsl:otherwise>
            </xsl:choose>
            <p>
                <strong>
                    <xsl:choose>
                        <xsl:when
                            test="starts-with(tei:idno[1]/text(), 'http') or starts-with(tei:idno[1]/text(), 'doi')">
                            <xsl:element name="a">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="tei:idno[1]/text()"/>
                                </xsl:attribute>
                                <xsl:attribute name="target">
                                    <xsl:text>_blank</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="tei:head"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="tei:head"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </strong>
            </p>
            <p>
                <xsl:if test="not(normalize-space(tei:desc) = '')">
                    <xsl:apply-templates select="tei:desc" mode="desc"/>
                </xsl:if>
            </p>
        </div>
    </xsl:template>
    <xsl:template match="tei:listPerson" mode="desc">
        <xsl:variable name="type" select="ancestor::tei:event/tei:idno/@type"/>
        <li>
            <xsl:for-each select="tei:person/tei:persName">
                <xsl:choose>
                    <xsl:when
                        test="starts-with(@ref, 'https://d-nb') or starts-with(@ref, 'http://d-nb')  and $type = 'schnitzler-cmif'">
                        <xsl:variable name="normalize-gnd-ohne-http"
                            select="replace(@ref, 'https', 'http')" as="xs:string"/>
                        <xsl:element name="span">
                            <xsl:attribute name="class">
                                <xsl:text>badge rounded-pill</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:text>background-color: olive;</xsl:text>
                                <xsl:text> color: white;</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="a">
                                <xsl:attribute name="style">
                                    <xsl:text>color: white; </xsl:text>
                                </xsl:attribute>
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
                    <xsl:when test="starts-with(@ref, 'pmb')">
                        <xsl:element name="span">
                            <xsl:attribute name="class">
                                <xsl:text>badge rounded-pill</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:text>background-color: olive;</xsl:text>
                                <xsl:text> color: white;</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="a">
                                <xsl:attribute name="style">
                                    <xsl:text>color: white; </xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="href">
                                    <xsl:choose>
                                        <xsl:when test="$type = 'schnitzler-briefe'">
                                            <xsl:value-of
                                                select="concat('https://schnitzler-briefe.acdh.oeaw.ac.at/', @ref, '.html')"
                                            />
                                        </xsl:when>
                                        <xsl:when test="$type = 'schnitzler-bahr'">
                                            <xsl:value-of
                                                select="concat('https://schnitzler-bahr.acdh.oeaw.ac.at/', @ref, '.html')"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/person/', replace(@ref, 'pmb', ''), '/detail')"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
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
                        <xsl:if test="not(position() = last())">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </li>
    </xsl:template>
    <xsl:template match="tei:listOrg" mode="desc">
        <xsl:variable name="type" select="ancestor::tei:event/tei:idno/@type"/>
        <li>
            <xsl:for-each select="tei:org/tei:orgName">
                <xsl:choose>
                    <xsl:when
                        test="starts-with(@ref, 'https://d-nb') or starts-with(@ref, 'http://d-nb') and $type = 'schnitzler-cmif'">
                        <xsl:variable name="normalize-gnd-ohne-http"
                            select="replace(@ref, 'https', 'http')" as="xs:string"/>
                        <xsl:element name="span">
                            <xsl:attribute name="class">
                                <xsl:text>badge rounded-pill</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:text>background-color: olive;</xsl:text>
                                <xsl:text> color: white;</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="a">
                                <xsl:attribute name="style">
                                    <xsl:text>color: white; </xsl:text>
                                </xsl:attribute>
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
                    <xsl:when test="starts-with(@ref, 'pmb')">
                        <xsl:element name="span">
                            <xsl:attribute name="class">
                                <xsl:text>badge rounded-pill</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:text>background-color: olive;</xsl:text>
                                <xsl:text> color: white;</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="a">
                                <xsl:attribute name="style">
                                    <xsl:text>color: white; </xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="href">
                                    <xsl:choose>
                                        <xsl:when test="$type = 'schnitzler-briefe'">
                                            <xsl:value-of
                                                select="concat('https://schnitzler-briefe.acdh.oeaw.ac.at/', @ref, '.html')"
                                            />
                                        </xsl:when>
                                        <xsl:when test="$type = 'schnitzler-bahr'">
                                            <xsl:value-of
                                                select="concat('https://schnitzler-bahr.acdh.oeaw.ac.at/', @ref, '.html')"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/institution/', replace(@ref, 'pmb', ''), '/detail')"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
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
                        <xsl:if test="not(position() = last())">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </li>
    </xsl:template>
    <xsl:template match="tei:listPlace" mode="desc">
        <xsl:variable name="type" select="ancestor::tei:event/tei:idno/@type"/>
        <li>
            <xsl:for-each select="tei:place/tei:placeName">
                <xsl:choose>
                    <xsl:when test="starts-with(@ref, 'pmb')">
                        <xsl:element name="span">
                            <xsl:attribute name="class">
                                <xsl:text>badge rounded-pill</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:text>background-color: olive;</xsl:text>
                                <xsl:text> color: white;</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="a">
                                <xsl:attribute name="style">
                                    <xsl:text>color: white; </xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="href">
                                    <xsl:choose>
                                        <xsl:when test="$type = 'schnitzler-briefe'">
                                            <xsl:value-of
                                                select="concat('https://schnitzler-briefe.acdh.oeaw.ac.at/', @ref, '.html')"
                                            />
                                        </xsl:when>
                                        <xsl:when test="$type = 'schnitzler-bahr'">
                                            <xsl:value-of
                                                select="concat('https://schnitzler-bahr.acdh.oeaw.ac.at/', @ref, '.html')"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/', replace(@ref, 'pmb', ''), '/detail')"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
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
                        <xsl:if test="not(position() = last())">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </li>
    </xsl:template>
    <xsl:template match="tei:listBibl" mode="desc">
        <xsl:variable name="type" select="ancestor::tei:event/tei:idno/@type"/>
        <li>
            <xsl:for-each select="tei:bibl/tei:title[1]">
                <xsl:choose>
                    <xsl:when test="starts-with(@ref, 'pmb')">
                        <xsl:element name="span">
                            <xsl:attribute name="class">
                                <xsl:text>badge rounded-pill</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:text>background-color: olive;</xsl:text>
                                <xsl:text> color: white;</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="a">
                                <xsl:attribute name="style">
                                    <xsl:text>color: white; </xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="href">
                                    <xsl:choose>
                                        <xsl:when test="$type = 'schnitzler-briefe'">
                                            <xsl:value-of
                                                select="concat('https://schnitzler-briefe.acdh.oeaw.ac.at/', @ref, '.html')"
                                            />
                                        </xsl:when>
                                        <xsl:when test="$type = 'schnitzler-bahr'">
                                            <xsl:value-of
                                                select="concat('https://schnitzler-bahr.acdh.oeaw.ac.at/', @ref, '.html')"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/', replace(@ref, 'pmb', ''), '/detail')"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
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
                        <xsl:if test="not(position() = last())">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </li>
    </xsl:template>
    <xsl:template match="tei:bibl[parent::tei:desc]" mode="desc">
        <li>
            <xsl:text>Erscheinungsort: </xsl:text>
            <i>
                <xsl:value-of select="."/>
            </i>
        </li>
    </xsl:template>
</xsl:stylesheet>
