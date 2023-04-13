<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:include href="./params.xsl"/>
    <xsl:template match="/" name="nav_bar">
        <div class="wrapper-fluid wrapper-navbar sticky-top hide-reading" id="wrapper-navbar">
            <a class="skip-link screen-reader-text sr-only" href="#content">Zum Inhalt</a>
            <nav class="navbar">
                <a href="index.html" class="navbar-brand custom-logo-link" rel="home" itemprop="url">
                    <img src="{$project_logo}" class="img-fluid" alt="Schnitzler Tage"
                        itemprop="logo"/>
                </a>
                <!-- end custom logo -->
                <span style="text-align: right; margin-left: 10em; margin-right: 10em;">
                    <a title="Kalender" class="nav-link" href="calendar.html">Kalender</a>

                </span>
            </nav>
            <!-- .site-navigation -->
        </div>
    </xsl:template>
</xsl:stylesheet>
