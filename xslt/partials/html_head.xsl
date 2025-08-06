<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:include href="./params.xsl"/>
    <xsl:template match="/" name="html_head">
        <xsl:param name="html_title" select="$project_short_title"></xsl:param>
        <xsl:param name="html_description" select="''"></xsl:param>
        <xsl:param name="page_url" select="''"></xsl:param>
        <xsl:param name="page_date" select="''"></xsl:param>
        
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
        <meta name="mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-title" content="{$html_title}" />
        <meta name="msapplication-TileColor" content="#ffffff" />
        <meta name="msapplication-TileImage" content="{$project_logo}" />
        
        <!-- SEO Meta Tags -->
        <xsl:choose>
            <xsl:when test="$html_description != ''">
                <meta name="description" content="{$html_description}" />
            </xsl:when>
            <xsl:otherwise>
                <meta name="description" content="Chronologische Dokumentation zu Arthur Schnitzlers Leben und Werk. Tageweise Darstellung von Ereignissen, Begegnungen und literarischem Schaffen." />
            </xsl:otherwise>
        </xsl:choose>
        <meta name="author" content="Arthur Schnitzler Digital" />
        <meta name="keywords" content="Arthur Schnitzler, Literatur, Chronik, Wien, österreichische Literatur, Tagebuch" />
        <meta name="robots" content="index, follow" />
        
        <!-- Canonical URL -->
        <xsl:if test="$page_url != ''">
            <link rel="canonical" href="{concat($base_url, '/', $page_url)}" />
        </xsl:if>
        
        <!-- Open Graph Tags -->
        <meta property="og:type" content="article" />
        <meta property="og:title" content="{$html_title}" />
        <xsl:choose>
            <xsl:when test="$html_description != ''">
                <meta property="og:description" content="{$html_description}" />
            </xsl:when>
            <xsl:otherwise>
                <meta property="og:description" content="Chronologische Dokumentation zu Arthur Schnitzlers Leben und Werk" />
            </xsl:otherwise>
        </xsl:choose>
        <meta property="og:site_name" content="{$project_title}" />
        <xsl:if test="$page_url != ''">
            <meta property="og:url" content="{concat($base_url, '/', $page_url)}" />
        </xsl:if>
        <meta property="og:image" content="{concat($base_url, '/img/schnitzler-chronik-og.jpg')}" />
        <meta property="og:image:alt" content="Arthur Schnitzler Chronik" />
        <meta property="og:locale" content="de_AT" />
        <xsl:if test="$page_date != ''">
            <meta property="article:published_time" content="{$page_date}" />
        </xsl:if>
        
        <link rel="icon" type="image/svg+xml" href="{$project_logo}" sizes="any" />
        <link rel="profile" href="http://gmpg.org/xfn/11"></link>
        <title><xsl:value-of select="$html_title"/></title>
        <link rel="stylesheet"
            href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
            integrity="sha512-iecdLmaskl7CVkqkXNQ/ZH/XLlvWZOJyj7Yy7tcenmpD1ypASozpmT/E0iPtmFIB46ZmdtAc9eNBvH0H/ZpiBw=="
            crossorigin="anonymous" referrerpolicy="no-referrer"/>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous"/>
        <link rel="stylesheet" href="css/style.css" type="text/css"></link>
        <link rel="stylesheet" href="css/micro-editor.css" type="text/css"></link>
        <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/bs4/jq-3.3.1/jszip-2.5.0/dt-1.11.0/b-2.0.0/b-html5-2.0.0/cr-1.5.4/r-2.2.9/sp-1.4.0/datatables.min.css"></link>

        <!-- Matomo -->
            <script type="text/javascript">
                var _paq = _paq || [];
                /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
                _paq.push(['trackPageView']);
                _paq.push(['enableLinkTracking']);
                (function() {
                var u="https://matomo.acdh.oeaw.ac.at/";
                _paq.push(['setTrackerUrl', u+'piwik.php']);
                _paq.push(['setSiteId', '234']); <!--  is Matomo Code schnitzler-chronik 234 -->
                var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
                g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
                })();
            </script>
            <!-- End Matomo Code -->
    </xsl:template>
</xsl:stylesheet>