<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes"
        omit-xml-declaration="yes"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select="descendant::tei:titleSmt[1]/tei:title[@level = 'a']/text()"/>
        </xsl:variable>
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"/>
                </xsl:call-template>
            </head>
            <body class="page" style="background-color:#f1f1f1;">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    <div class="container">
                        <div class="row intro">
                            <div class="col-md-6 col-lg-6 col-sm-12 wp-intro_left">
                                <div class="intro_left">
                                    <h1>Arthur Schnitzler Tag für Tag</h1>
                                    <h3>schnitzler-tage</h3>
                                </div>
                            </div>
                            <div class="col-md-6 col-lg-6 col-sm-12">
                                <div class="intro_right wrapper">
                                    <img src="images/background-index.jpg" class="d-block w-100"
                                        alt="..."/>
                                </div>
                            </div>
                        </div>
                    </div>
                    <p class="mt-3">In den letzten Jahren wurden von mehreren Forschungsprojekten
                        Texte von Arthur Schnitzler (1862–1931) ediert und digitalisiert. Neben seiner
                        Bedeutung als literarischer Schriftsteller und Dramatiker wurde und wird sein 
                        Tagebuch und seine Korrespondenz zugänglich gemacht.</p>
                    <p class="mt-3">Diese Webseite stellt ein
                        einfaches Frontend dar, über welches veröffentlichte Informationen zu jedem Tag seines
                        Lebens abgerufen werden können, sowohl als HTML-Ansicht, als auch als JSON-Datei:
                        <ul>
                            <li><a href="1927-11-07.html">1927-11-07.html</a></li>
                            <li><a href="1927-11-07.json">1927-11-07.json</a></li>
                        </ul>
                    </p>
                    <p>Eingebunden sind derzeit Daten aus folgenden Websites:</p>
                    <ul>
                        <li><a href="https://schnitzler-tagebuch.acdh.oeaw.ac.at/" target="_blank">Arthur Schnitzler: <i>Tagebuch</i></a></li>
                        <li><a href="https://www.arthur-schnitzler.de/" target="_blank">Arthur Schnitzler digital: <i>Digitale historisch-kritische Edition (1905–1931)</i></a> (Wuppertal/Cambridge)</li>
                        <li><a href="https://schnitzler-briefe.acdh.oeaw.ac.at/" target="_blank">Arthur Schnitzler: <i>Briefe</i></a></li>
                        <li><a href="https://pollaczek.acdh.oeaw.ac.at/" target="_blank">Clara Katharina Pollaczek: <i>Arthur Schnitzler und ich</i></a></li>
                        <li><a href="https://schnitzler-bahr.acdh.oeaw.ac.at/" target="_blank">Hermann Bahr, Arthur Schnitzler: <i>Briefwechsel, Aufzeichungen, Dokumente (1891–1931)</i></a></li>
                    </ul>
                    <p>Weiters sind folgende digitale Daten berücksichtigt:</p>
                    <ul>
                        <li><a href="https://schnitzler-orte.acdh.oeaw.ac.at/" target="_blank"><i>Aufenthaltsorte von Arthur Schnitzler</i></a></li>
                        <li><a href="https://correspsearch.net/de/suche.html?s=http://d-nb.info/gnd/118609807" target="_blank"><i>Gedruckte und digitale Korrespondenzstücke</i></a> Schnitzlers bei correspSearch</li>
                        <li><a href="https://pmb.acdh.oeaw.ac.at/apis/entities/entity/event/list/?name=&amp;related_entity_name=schnitzler">Ereignisse in der PMB</a> (Teilnahme an Theateraufführungen)</li>
                        <li>Ergänzungen im kleineren Umfang, teilweise manuell</li>
                    </ul>
                    <p>Geplant ist die Erweiterung und Fortführung, unter anderem unter Einbindung von Erscheinungsdaten von Werken und Besprechungen, die ebenfalls in der <a href="https://pmb.acdh.oeaw.ac.at/apis/entities/entity/work/list/&amp;related_entity_name=schnitzler">PMB</a>
                    gesammelt sind.</p>
                    <p>Das verwendete Datenkorpus kann zur Gänze oder in Teilen auf <a href="https://github.com/arthur-schnitzler/schnitzler-tage/" target="_blank">gitHub</a> geladen oder eingesehen werden. Die vorliegende
                    Website findet sich gleich <a href="https://github.com/arthur-schnitzler/schnitzler-tage-static" target="_blank">daneben</a>.</p>
                    <p>Der eigentliche Nutzen findet sich nicht auf der vorliegenden Seite, sondern
                        in den jeweiligen Online-Editionen, die durch Anbindung an die vorliegende Ressource
                        einfach zu jedem Tag weitere Informationen aus dem Leben Schnitzlers verlinken 
                        können.</p>
                    <div class="container-fluid" style="margin:2em auto;">
                        <div class="col-md-6 col-lg-6 col-sm-12">
                            <a href="https://schnitzler.acdh.oeaw.ac.at/" class="index-link"
                                target="_blank">
                                <div class="card index-card">
                                    <div class="card-body">
                                        <img class="d-block w-100"
                                            src="https://shared.acdh.oeaw.ac.at/schnitzler-briefe/img/schnitzler-acdh.jpg"
                                            title="Schnitzler am ACDH-CH"
                                            alt="Schnitzler am ACDH-CH"/>
                                    </div>
                                    <div class="card-header">
                                        <p>Schnitzler am ACDH-CH</p>
                                    </div>
                                </div>
                            </a>
                        </div>
                        <div class="col-md-6 col-lg-6 col-sm-12">
                            <a href="https://github.com/arthur-schnitzler" class="index-link">
                                <div class="card index-card">
                                    <div class="card-body">
                                        <img class="d-block w-100"
                                            src="https://shared.acdh.oeaw.ac.at/schnitzler-briefe/img/schnitzler-github.jpg"
                                            title="Schnitzler Repositories auf Github"
                                            alt="Schnitzler Repositories auf Github"/>
                                    </div>
                                    <div class="card-header">
                                        <p>Quelldaten dieser Website auf Github</p>
                                    </div>
                                </div>
                            </a>
                        </div>
                    </div>
                    <xsl:call-template name="html_footer"/>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:div//tei:head">
        <h2 id="{generate-id()}">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
    <xsl:template match="tei:p">
        <p id="{generate-id()}">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:list">
        <ul id="{generate-id()}">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="tei:item">
        <li id="{generate-id()}">
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="tei:ref">
        <xsl:choose>
            <xsl:when test="starts-with(data(@target), 'http')">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="@target"/>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
