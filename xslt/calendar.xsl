<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">

    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:title[@type='a'][1]/text()"/>
        </xsl:variable>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html lang="de">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
            </xsl:call-template>
            <body class="page">
                <script src="js-data/calendarData.js"></script>
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>

                    <main id="calendar-main"
                        style="max-width:1240px;margin:0 auto;padding:30px 32px 80px;">
                        <div
                            style="display:flex;align-items:flex-end;justify-content:space-between;flex-wrap:wrap;gap:16px;margin-bottom:24px;">
                            <div>
                                <h1
                                    style="font-weight:600;font-size:34px;line-height:1.05;margin:0 0 6px;color:#26241f;">
                                    <xsl:text>Kalender</xsl:text>
                                </h1>
                                <p style="margin:0;font-size:14px;color:#6f6b62;max-width:60ch;">
                                    <xsl:text>Chronologische Einträge zu Leben und Werk Arthur Schnitzlers. Tage anklicken für die Einträge; Quellen unten ein- und ausblenden.</xsl:text>
                                </p>
                            </div>
                            <div style="display:flex;gap:14px;align-items:center;">
                                <a href="js-data/calendarData.js"
                                    aria-label="Kalenderdaten herunterladen">
                                    <i class="fas fa-download" title="Kalenderdaten herunterladen"/>
                                </a>
                            </div>
                        </div>

                        <!-- Calendar Container -->
                        <div id="calendar"/>
                    </main>

                    <script type="text/javascript" src="js/calendar.js" charset="UTF-8"/>
                    <xsl:call-template name="html_footer"/>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
