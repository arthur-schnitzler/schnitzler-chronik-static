<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:include href="./params.xsl"/>
    <xsl:template match="/" name="nav_bar">
        <div class="wrapper-fluid wrapper-navbar sticky-top hide-reading" id="wrapper-navbar">
            <a class="skip-link screen-reader-text sr-only" href="#content">Zum Inhalt</a>
            <nav class="navbar" aria-label="Hauptnavigation">
                <a href="index.html" class="navbar-brand custom-logo-link" rel="home" aria-label="Zur Startseite">
                    <img src="{$project_logo}" class="img-fluid" alt="Arthur Schnitzler Chronik Logo"
                        width="150" height="50"/>
                </a>
                <!-- end custom logo -->
                <span style="text-align: right; margin-left: 10px; margin-right: 3em; font-weight: bold;">
                    <a class="nav-link" href="calendar.html" aria-label="Zur Kalenderansicht">Kalender</a>

                </span>
                <span style="text-align: right; margin-left: 10px; margin-right: 3em; font-weight: bold;">
                    <a class="nav-link" href="search.html" aria-label="Zur Suche">Suche</a>

                </span>
            </nav>
            <!-- .site-navigation -->
        </div>
    </xsl:template>
</xsl:stylesheet>
