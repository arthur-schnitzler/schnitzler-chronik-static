<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:include href="./params.xsl"/>
    <xsl:template match="/" name="nav_bar">
        <nav class="navbar navbar-expand-md" role="navigation" aria-label="Hauptnavigation" style="padding-top:1px;">
            <div class="container-fluid">
                <a href="index.html" class="navbar-brand custom-logo-link" rel="home" itemprop="url" aria-label="Zur Startseite">
                    <img src="{$project_logo}" class="img-fluid" title="{$project_short_title}"
                        alt="{$project_short_title}" itemprop="logo"/>
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                    data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false"
                    aria-label="Toggle navigation" style="border: none;">
                    <span class="navbar-toggler-icon"/>
                </button>
                <div class="collapse navbar-collapse " id="navbarNav">
                    <ul class="navbar-nav">
                        <li class="nav-item">
                            <a class="nav-link" href="calendar.html">Kalender</a>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="schnitzlerLinksDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false" aria-haspopup="true">Schnitzler</a>
                            <ul class="dropdown-menu" aria-labelledby="schnitzlerLinksDropdown">
                                <li><a class="dropdown-item" href="https://de.wikipedia.org/wiki/Arthur_Schnitzler" target="_blank">Wikipedia</a></li>
                                <li><a class="dropdown-item" href="https://www.geschichtewiki.wien.gv.at/Arthur_Schnitzler" target="_blank">Wien Geschichte Wiki</a></li>
                                <li><a class="dropdown-item" href="https://schnitzler-tagebuch.acdh.oeaw.ac.at/" target="_blank">Tagebuch (1879–1931)</a></li>
                                <li><a class="dropdown-item" href="https://schnitzler-briefe.acdh.oeaw.ac.at/" target="_blank">Briefwechsel mit Autorinnen und Autoren</a></li>
                                <li><a class="dropdown-item" href="https://www.arthur-schnitzler.de" target="_blank">Werke digital (1905–1931)</a></li>
                                <li><a class="dropdown-item" href="https://schnitzler-mikrofilme.acdh.oeaw.ac.at/" target="_blank">Mikrofilme</a></li>
                                <li><a class="dropdown-item" href="https://schnitzler-zeitungen.acdh.oeaw.ac.at/" target="_blank">Archiv der Zeitungsausschnitte</a></li>
                                <li><a class="dropdown-item" href="https://schnitzler-interviews.acdh.oeaw.ac.at/" target="_blank">Interviews, Meinungen, Proteste</a></li>
                                <li><a class="dropdown-item" href="https://wienerschnitzler.org/" target="_blank">Wiener Schnitzler – Schnitzlers Wien</a></li>
                                <li><a class="dropdown-item" href="https://schnitzler-bahr.acdh.oeaw.ac.at/" target="_blank">Korrespondenz mit Hermann Bahr</a></li>
                                <li><a class="dropdown-item" href="https://schnitzler-kultur.acdh.oeaw.ac.at/" target="_blank">Kulturveranstaltungen</a></li>
                                <li><a class="dropdown-item" href="https://schnitzler-chronik.acdh.oeaw.ac.at/" target="_blank">Chronik</a></li>
                                <li><a class="dropdown-item" href="https://schnitzler-lektueren.acdh.oeaw.ac.at/" target="_blank">Lektüren</a></li>
                                <li><a class="dropdown-item" href="https://pollaczek.acdh.oeaw.ac.at/" target="_blank">Pollaczek: Schnitzler und ich</a></li>
                                <li><a class="dropdown-item" href="https://pmb.acdh.oeaw.ac.at/" target="_blank">PMB – Personen der Moderne Basis</a></li>
                            </ul>
                        </li>
                        <li class="nav-item ms-auto">
                            <a title="Suche" class="nav-link" href="search.html" aria-label="Zur Suchseite"><svg
                                    xmlns="http://www.w3.org/2000/svg" width="24" height="24"
                                    viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                                    class="feather feather-search" aria-hidden="true">
                                    <circle cx="11" cy="11" r="8"/>
                                    <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                                </svg> SUCHE</a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
    </xsl:template>
</xsl:stylesheet>
