<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all" version="2.0">
    <xsl:include href="./params.xsl"/>
    <xsl:template match="/" name="nav_bar">
        <div class="wrapper-fluid wrapper-navbar sticky-top hide-reading" id="wrapper-navbar">
            <a class="skip-link screen-reader-text sr-only" href="#content">Zum Inhalt</a>
            <nav class="navbar navbar-expand-lg">
            <a href="index.html" class="navbar-brand custom-logo-link" rel="home" itemprop="url">
                        <img src="{$project_logo}" class="img-fluid" alt="Schnitzler Tage" itemprop="logo"/>
                    </a><!-- end custom logo -->
                <div class="container-fluid" style="max-width:'100%'">
                                    

                   <!-- Your site title as branding in the menu -->
                    <!--<a class="navbar-brand site-title-with-logo" rel="home" href="index.html" title="{$project_short_title}" itemprop="url"><xsl:value-of select="$project_short_title"/></a>-->
                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNavDropdown" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="collapse navbar-collapse justify-content-end" id="navbarNavDropdown">
                        <ul class="navbar-nav mb-2 mb-lg-0">
                            <li class="nav-item">
                                <a title="Kalender" class="nav-link" href="calendar.html">Kalender</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
            
            <!-- .site-navigation -->
        </div>
    </xsl:template>
</xsl:stylesheet>