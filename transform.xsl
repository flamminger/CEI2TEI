<?xml version="1.0" encoding="UTF-8"?>
<?xml-model
        href="SCHEMA" type="application/relax-ng-compact-syntax"
        ?>
<!--suppress ALL -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns="http://www.tei-c.org/ns/1.0" xmlns:cei="http://www.monasterium.net/NS/cei"
                xmlns:bf="http://betterform.sourceforge.net/xforms" xmlns:xalan="http://xml.apache.org/xslt"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                exclude-result-prefixes="xs" version="3.0">

    <xsl:output method="xml" indent="yes" xalan:indent-amount="4"/>
    <xsl:strip-space elements="*"/>

    <!--  START: ATOM VARIABLES  -->
    <xsl:variable name="atomId">
        <xsl:value-of select="substring-after(//atom:id, 'tag:www.monasterium.net,2011:/charter/')"
        />
    </xsl:variable>
    <xsl:variable name="atom_published" select="/atom:entry/atom:published"/>
    <xsl:variable name="atom_updated" select="/atom:entry/atom:updated"/>
    <xsl:variable name="atom_email" select="/atom:entry/atom:author/atom:email"/>
    <!--    <xsl:variable name="atom-rest">-->
    <!--        <xsl:value-of select="substring-after(atom:entry/atom:id, 'charter/')"/>-->
    <!--    </xsl:variable>-->
    <!--    <xsl:variable name="atom-last">-->
    <!--        <xsl:value-of select="concat('/', tokenize($atom-rest, '/')[last()])"/>-->
    <!--    </xsl:variable>-->
    <!--    <xsl:variable name="collection" select="substring-before($atom-rest, $atom-last)"/>-->
    <!--    <xsl:variable name="contextname">-->
    <!--        <xsl:value-of-->
    <!--                select="concat('context:cord.', lower-case(replace(substring-before($atom-rest, $atom-last), '/', '.')))"-->
    <!--        />-->
    <!--    </xsl:variable>-->
    <!--  END: ATOM VARIABLES  -->

    <!-- START: ROOT DOCUMENT -->
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">
            href="https://raw.githubusercontent.com/flamminger/CEI2TEI/develop/schema/tei_cei/rng/tei2cei.rnc"
        </xsl:processing-instruction>


        <TEI xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xmlns:bf="http://betterform.sourceforge.net/xforms"
             xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:xalan="http://xml.apache.org/xslt"
             xmlns:atom="http://www.w3.org/2005/Atom" xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>
                            <xsl:apply-templates select="//cei:text/cei:body/cei:idno"
                                                 mode="teiTitle"/>
                        </title>
                        <editor>
                            <email>
                                <xsl:value-of select="$atom_email"/>
                            </email>
                        </editor>
                    </titleStmt>
                    <publicationStmt>
                        <publisher>
                            <orgName ref="http://d-nb.info/gnd/1137284463"
                                     corresp="https://informationsmodellierung.uni-graz.at">Zentrum für
                                Informationsmodellierung - Austrian Centre for Digital Humanities,
                                Karl-Franzens-Universität Graz
                            </orgName>
                        </publisher>
                        <distributor>
                            <orgName ref="monasterium.net">Monasterium</orgName>
                        </distributor>
                        <date when-iso="{$atom_published}">
                            <xsl:call-template name="convertTimestamp">
                                <xsl:with-param name="timestamp" select="$atom_published"/>
                            </xsl:call-template>
                        </date>
                    </publicationStmt>
                    <sourceDesc>
                        <!-- CHECK ELEMENT ORDER OF MODEL -->
                        <msDesc>
                            <xsl:apply-templates
                                    select="//*[local-name() = 'body']/*[local-name() = 'idno']"
                                    mode="msDescId"/>
                            <xsl:apply-templates select="//*[local-name() = 'physicalDesc']"/>
                            <diploDesc>
                                <xsl:apply-templates select="//*[local-name() = 'issued']" mode="issuedDiploDesc"/>
                                <xsl:apply-templates select="//*[local-name() = 'traditioForm']"
                                                     mode="copyStatusDiploDesc"/>
                                <xsl:apply-templates select="//*[local-name() = 'rubrum']"/>
                                <xsl:apply-templates select="//*[local-name() = 'listBibl']" mode="diploListBibl"/>
                                <xsl:apply-templates select="//*[local-name() = 'diplomaticAnalysis']" mode="diplomaticAnalysis"/>
                            </diploDesc>
                            <xsl:if test="//*[local-name() = 'auth']">
                                <xsl:apply-templates select="//*[local-name() = 'auth']" mode="auth"/>
                            </xsl:if>
                        </msDesc>
                        <xsl:if test="//*[local-name() = 'witness']">
                            <listWit>
                                <xsl:apply-templates select="//*[local-name() = 'witness']"/>
                            </listWit>
                        </xsl:if>
                    </sourceDesc>
                </fileDesc>
                <profileDesc>
                    <xsl:apply-templates select="//*[local-name() = 'abstract'] | //*[local-name() = 'lang_MOM']" mode="abstract"/>
                </profileDesc>
                <revisionDesc>
                    <change>
                        <date when-iso="{$atom_updated}">
                            <xsl:call-template name="convertTimestamp">
                                <xsl:with-param name="timestamp" select="$atom_updated"/>
                            </xsl:call-template>
                        </date>
                    </change>
                </revisionDesc>
            </teiHeader>
            <facsimile>
                <!-- TODO FIX SURFACE -->
                <xsl:apply-templates select="//*[local-name() = 'figure']" mode="facsimile"/>
            </facsimile>

            <text>
                <front>

                </front>
                <body>
                    <div type="tenor">
                        <xsl:apply-templates select="//*[local-name() = 'tenor']"/>
                    </div>
                </body>
            </text>
        </TEI>
    </xsl:template>
    <!-- END: ROOT DOCUMENT -->

    <!-- START: ATOM CONTENT -->
    <!-- START: DATE TRANSFORM -->
    <xsl:template name="convertTimestamp">
        <xsl:param name="timestamp"/>
        <xsl:value-of select="substring($timestamp, 1, 4)"/> <!-- Year -->
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring($timestamp, 6, 2)"/> <!-- Month -->
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring($timestamp, 9, 2)"/> <!-- Day -->
    </xsl:template>
    <!-- END: DATE TRANSFORM -->
    <!-- END: ATOM CONTENT -->

    <!-- START: TEI TITLE -->
    <xsl:template match="cei:idno" mode="teiTitle">
        <xsl:choose>
            <xsl:when test=". != ''">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="./@id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- END: TEI TITLE -->

    <!-- START: msDESC Identifier -->
    <xsl:template match="cei:idno" mode="msDescId">
        <xsl:choose>
            <xsl:when test="./@id and ./@old and ./text()">
                <msIdentifier>
                    <xsl:apply-templates select="//*[local-name() = 'witnessOrig']"/>
                    <idno>
                        <xsl:attribute name="source">
                            <xsl:value-of select="./@id"/>
                        </xsl:attribute>
                        <xsl:attribute name="prev">
                            <xsl:value-of select="./@old"/>
                        </xsl:attribute>
                        <xsl:value-of select="./text()"/>
                    </idno>
                </msIdentifier>
            </xsl:when>
            <xsl:when test="./@id and ./text()">
                <msIdentifier>
                    <xsl:apply-templates select="//*[local-name() = 'witnessOrig']"/>
                    <idno>
                        <xsl:attribute name="source">
                            <xsl:value-of select="./@id"/>
                        </xsl:attribute>
                        <xsl:value-of select="./text()"/>
                    </idno>
                </msIdentifier>
            </xsl:when>
            <xsl:when test="./text() != ''">
                <msIdentifier>
                    <xsl:apply-templates select="//*[local-name() = 'witnessOrig']"/>
                    <idno>
                        <xsl:value-of select="."/>
                    </idno>
                </msIdentifier>
            </xsl:when>
            <xsl:when test="./@id and ./text() = ''">
                <msIdentifier>
                    <idno>
                        <xsl:value-of select="./@id"/>
                    </idno>
                    <xsl:apply-templates select="//*[local-name() = 'witnessOrig']"/>
                </msIdentifier>
            </xsl:when>
            <xsl:otherwise>
                <msIdentifier>
                    <xsl:apply-templates select="//*[local-name() = 'witnessOrig']"/>
                    <idno>
                        <xsl:value-of select="./text()"/>
                    </idno>
                    <altIdentifier>
                        <idno>
                            <xsl:value-of select="./@id"/>
                        </idno>
                    </altIdentifier>
                </msIdentifier>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- END: msDESC Identifier -->

    <!-- START: diploDesc issued -->
    <xsl:template match="cei:issued" mode="issuedDiploDesc">
        <issued>
            <xsl:apply-templates mode="issuedDiploDesc"/>
        </issued>
    </xsl:template>
    <!-- END: diploDesc issued -->

    <!-- START: diploDesc bibl -->
    <xsl:template match="cei:listBibl" mode="diploListBibl">
        <listBibl>
            <xsl:apply-templates/>
        </listBibl>
    </xsl:template>

    <xsl:template match="cei:bibl">
        <bibl>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@key">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@key"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@lang">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="./@lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@type">
                    <xsl:attribute name="type">
                        <xsl:value-of select="./@type"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@status">
                    <xsl:attribute name="status">
                        <xsl:value-of select="./@status"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="."/>
        </bibl>
    </xsl:template>

    <!-- END: diploDesc bibl -->


    <!-- START: copyStatus -->
    <xsl:template match="cei:traditioForm" mode="copyStatusDiploDesc">
        <copyStatus>
            <xsl:if test="./@*">
                <xsl:attribute name="n">
                    <xsl:value-of select="@*"/>"
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
        </copyStatus>
    </xsl:template>
    <!-- END: copyStatus -->

    <!-- START: date -->
    <xsl:template match="cei:date" mode="issuedDiploDesc">
        <origDate>
            <xsl:if test="./@value">
                <xsl:attribute name="when">
                    <xsl:value-of select="./@value"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@notBefore">
                <xsl:attribute name="notBefore">
                    <xsl:value-of select="./@notBefore"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@notAfter">
                <xsl:attribute name="notAfter">
                    <xsl:value-of select="./@notAfter"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
        </origDate>
    </xsl:template>
    <!-- END: date -->

    <!-- START: dateRange -->
    <xsl:template match="cei:dateRange" mode="issuedDiploDesc">
        <origDate>
            <xsl:if test="./@from">
                <xsl:attribute name="from">
                    <xsl:value-of select="./@from"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@to">
                <xsl:attribute name="to">
                    <xsl:value-of select="./@to"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
        </origDate>
    </xsl:template>
    <!-- END: dateRange -->

    <!-- START: placeName -->
    <xsl:template match="cei:placeName" mode="issuedDiploDesc">
        <placeName>
            <xsl:if test="./@id">
                <xsl:attribute name="corresp">
                    <xsl:value-of select="./@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@n">
                <xsl:attribute name="n">
                    <xsl:value-of select="./@n"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@lang">
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="./@lang"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@reg">
                <choice>
                    <orig>
                        <xsl:value-of select="."/>
                    </orig>
                    <reg>
                        <xsl:value-of select="./@reg"/>
                    </reg>
                </choice>
            </xsl:if>
            <xsl:apply-templates/>
        </placeName>
    </xsl:template>
    <!-- END: placeName -->

    <!-- START: abstract -->
    <xsl:template match="cei:abstract" mode="abstract">
        <abstract>
            <p>
                <xsl:apply-templates mode="abstract"/>
            </p>
        </abstract>
    </xsl:template>
    <!-- END: abstract -->

    <!-- START: lang_MOM TODO normalize language SEE workflow.xsl -->
    <xsl:template match="cei:lang_MOM" mode="abstract">
        <langUsage>
            <language ident="{.}"><xsl:value-of select="."/></language>
        </langUsage>
    </xsl:template>

    <!-- END: lang_MOM -->

    <!-- START: witnessOrig -->
    <xsl:template match="cei:witnessOrig">
        <xsl:apply-templates select="cei:archIdentifier"/>
    </xsl:template>
    <!-- END: witnessOrig -->

    <!-- START: traditioForm -->
    <xsl:template match="cei:traditioForm">
        <copyStatus>
            <xsl:apply-templates/>
        </copyStatus>
    </xsl:template>
    <!-- END: traditioForm -->

    <!-- START: archIdentifier -->
    <xsl:template match="cei:archIdentifier">
        <xsl:if test="./cei:country">
            <country>
                <xsl:value-of select="./cei:country"/>
            </country>
        </xsl:if>
        <xsl:if test="./cei:region">
            <region>
                <xsl:value-of select="./cei:region"/>
            </region>
        </xsl:if>
        <xsl:if test="./cei:geogName">

        </xsl:if>
        <xsl:if test="./cei:settlement">
            <settlement>
                <xsl:value-of select="./cei:settlement"/>
            </settlement>
        </xsl:if>
        <xsl:if test="./cei:repository">
            <repository>
                <xsl:value-of select="./cei:repository"/>
            </repository>
        </xsl:if>

        <xsl:if test="./cei:arch">
            <institution>
                <xsl:value-of select="./cei:arch"/>
            </institution>
        </xsl:if>
        <xsl:if test="./cei:archFond">
            <collection>
                <xsl:value-of select="./cei:archFond"/>
            </collection>
        </xsl:if>
    </xsl:template>
    <!-- END: archIdentifier -->

    <!-- START: physicalDesc -->
    <xsl:template match="cei:physicalDesc">
        <physDesc>
            <objectDesc>
                <supportDesc>
                    <support>
                        <xsl:apply-templates select="cei:material | cei:dimensions"/>
                    </support>
                </supportDesc>
                <xsl:if test="//cei:p[@type = 'layout']">
                    <layoutDesc>
                        <xsl:apply-templates select="//cei:p[@type = 'layout']" mode="pLayout"/>
                    </layoutDesc>
                </xsl:if>
            </objectDesc>
            <xsl:if test="//*[local-name() = 'sourceDesc']">
                <xsl:apply-templates select="//*[local-name() = 'sourceDesc']" mode="sourceRegest"/>
            </xsl:if>
            <xsl:if test="//cei:p[@type = 'handDesc']">
                <handDesc>
                    <xsl:apply-templates select="//cei:p[@type = 'handDesc']" mode="pHanddesc"/>
                </handDesc>
            </xsl:if>
        </physDesc>
    </xsl:template>
    <!-- END: physicalDesc -->

    <!-- START: material -->
    <xsl:template match="cei:material">
        <material>
            <xsl:value-of select="."/>
        </material>
    </xsl:template>
    <!-- END: material -->

    <!-- START: dimensions -->
    <xsl:template match="cei:dimensions">
        <xsl:choose>
            <xsl:when test="./text()">
                <measure>
                    <xsl:value-of select="./text()"/>
                </measure>
            </xsl:when>
            <xsl:otherwise>
                <dimensions>
                    <xsl:if test="./@type">
                        <xsl:attribute name="type">
                            <xsl:value-of select="./@type"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@unit">
                        <xsl:attribute name="unit">
                            <xsl:value-of select="./@unit"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates select="node()[text()]"/>
                </dimensions>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- END: dimensions -->

    <!-- START: height -->
    <xsl:template match="cei:height">
        <height>
            <xsl:apply-templates/>
        </height>
    </xsl:template>
    <!-- END: height -->

    <!-- START: width -->
    <xsl:template match="cei:width">
        <width>
            <xsl:apply-templates/>
        </width>
    </xsl:template>
    <!-- END: width -->

    <!-- START: plica -->
    <xsl:template match="cei:plica">
        <plica>
            <xsl:apply-templates/>
        </plica>
    </xsl:template>
    <!-- END: plica -->

    <!-- START: p -->
    <xsl:template match="cei:p">
        <p>
            <xsl:if test="./@type">
                <xsl:attribute name="n">
                    <xsl:value-of select="./@type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@lang">
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="./@lang"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@facs">
                <xsl:attribute name="facs">
                    <xsl:value-of select="./@facs"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@witness">
                <xsl:attribute name="coressp">
                    <xsl:value-of select="./@witness"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
        </p>
    </xsl:template>
    <!-- END: p -->

    <!-- START: layout > p -->
    <xsl:template name="pLayout" match="cei:p[@type = 'layout']" mode="pLayout">
        <layout>
            <xsl:for-each select=".">
                <p>
                    <xsl:value-of select="../cei:p/text()"/>
                </p>
            </xsl:for-each>
        </layout>
    </xsl:template>
    <!-- END: layout > p -->

    <!-- START: handDesc > p -->
    <xsl:template name="pHanddesc" match="cei:p[@type = 'handDesc']" mode="pHanddesc">
        <xsl:for-each select=".">
            <p>
                <xsl:value-of select="../cei:p/text()"/>
            </p>
        </xsl:for-each>
    </xsl:template>
    <!-- END: handDesc > p -->

    <!-- START: rubrum -->
    <xsl:template match="cei:rubrum">
        <p sameAs="rubrum">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <!-- END: rubrum -->

    <!-- START: surfaceGrp graphic -->
    <xsl:template match="cei:witnessOrig/cei:figure" mode="facsimile">
        <xsl:if test="./cei:zone">
            <surfaceGrp>
                <xsl:for-each select="cei:zone">
                    <surface>
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="./@id"/>
                        </xsl:attribute>
                    </surface>
                </xsl:for-each>
            </surfaceGrp>
        </xsl:if>
        <xsl:if test="./cei:graphic">
            <graphic url="{./cei:graphic/@url}">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="./cei:figDesc" mode="facsimile"/>
            </graphic>
        </xsl:if>
    </xsl:template>
    <!-- END: surfaceGrp graphic -->

    <!-- START: figDesc -->
    <xsl:template match="cei:figDesc" mode="facsimile">
        <desc>
            <xsl:apply-templates/>
        </desc>
    </xsl:template>
    <!-- END: figureDesc -->

    <!-- START: witness -->
    <xsl:template match="cei:witness">
        <witness>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@lang">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="./@lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@*"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <bibl>
                <xsl:value-of select="."/>
            </bibl>
        </witness>
    </xsl:template>
    <!-- END: witness -->

    <!-- START: tenor -->
    <!--    <xsl:template match="cei:tenor">-->
    <!--            <xsl:apply-templates/>-->
    <!--    </xsl:template>-->

    <xsl:template match="cei:pTenor">
        <xsl:apply-templates mode="tenor"/>
    </xsl:template>

    <!-- START: pb -->
    <xsl:template match="cei:pb" mode="tenor">
        <pb>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:value-of select="."/>
        </pb>
    </xsl:template>
    <!-- END: pb -->

    <!-- START: lb -->
    <xsl:template match="cei:lb" mode="tenor">
        <lb>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@break">
                    <xsl:attribute name="break">
                        <xsl:value-of select="./@break"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
        </lb>
    </xsl:template>
    <!-- END: lb -->

    <!-- START: w -->
    <xsl:template match="cei:w" mode="tenor">
        <span type="word">
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@note">
                    <xsl:attribute name="note">
                        <xsl:value-of select="./@note"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </span>
    </xsl:template>
    <!-- END: w -->

    <!-- START: c -->
    <xsl:template match="cei:c" mode="tenor">
        <span type="char">
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@type">
                    <xsl:attribute name="type">
                        <xsl:value-of select="./@type"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </span>
    </xsl:template>
    <!-- END: c -->

    <!-- START: pc -->
    <xsl:template match="cei:pc" mode="tenor">
        <span type="pc">
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </span>
    </xsl:template>
    <!-- END: pc -->

    <!-- START: persName -->
    <xsl:template match="cei:persName" mode="tenor">
        <span>
            <persName>
                <xsl:if test="./@*">
                    <xsl:if test="./@id">
                        <xsl:attribute name="corresp">
                            <xsl:value-of select="./@id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@facs">
                        <xsl:attribute name="facs">
                            <xsl:value-of select="./@facs"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@note">
                        <xsl:attribute name="type">
                            <xsl:value-of select="./@note"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:if>
                <xsl:apply-templates mode="tenor"/>
            </persName>
        </span>
    </xsl:template>
    <!-- END: persName -->

    <!-- START: name -->
    <xsl:template match="cei:name" mode="tenor">
        <name>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@key">
                    <xsl:attribute name="key">
                        <xsl:value-of select="./@key"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@target">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@target"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@type">
                    <xsl:attribute name="type">
                        <xsl:value-of select="./@type"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </name>
    </xsl:template>
    <!-- END: name -->

    <!-- START: rolename -->
    <xsl:template match="cei:rolename" mode="tenor">
        <roleName>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@lang">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="./@lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@type">
                    <xsl:attribute name="type">
                        <xsl:value-of select="./@type"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </roleName>
    </xsl:template>
    <!-- END: rolename -->

    <!-- START: expan -->
    <xsl:template match="cei:expan" mode="tenor">
        <choice>
            <abbr>
                <xsl:value-of select="./@abbr"/>
            </abbr>
            <expan>
                <xsl:if test="./@*">
                    <xsl:if test="./@id">
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="./@id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@facs">
                        <xsl:attribute name="facs">
                            <xsl:value-of select="./@facs"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@certainty">
                        <xsl:attribute name="cert">
                            <xsl:value-of select="./@certainty"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@n">
                        <xsl:attribute name="n">
                            <xsl:value-of select="./@n"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@type">
                        <xsl:attribute name="ana">
                            <xsl:value-of select="./@type"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@rend">
                        <xsl:attribute name="rend">
                            <xsl:value-of select="./@rend"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@resp">
                        <xsl:attribute name="resp">
                            <xsl:value-of select="./@resp"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:if>
                <xsl:value-of select="."/>
            </expan>
        </choice>
    </xsl:template>
    <!-- END: expan -->

    <!-- START: placeName -->
    <xsl:template match="cei:placeName" mode="tenor">
        <span>
            <placeName>
                <xsl:if test="./@*">
                    <xsl:if test="./@id">
                        <xsl:attribute name="corresp">
                            <xsl:value-of select="./@id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@facs">
                        <xsl:attribute name="facs">
                            <xsl:value-of select="./@facs"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@key">
                        <xsl:attribute name="key">
                            <xsl:value-of select="./@key"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@n">
                        <xsl:attribute name="n">
                            <xsl:value-of select="./@n"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@type">
                        <xsl:attribute name="role">
                            <xsl:value-of select="./@type"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@rend">
                        <xsl:attribute name="rend">
                            <xsl:value-of select="./@rend"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@resp">
                        <xsl:attribute name="resp">
                            <xsl:value-of select="./@resp"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@lang">
                        <xsl:attribute name="xml:lang">
                            <xsl:value-of select="./@lang"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@certainty">
                        <xsl:attribute name="cert">
                            <xsl:value-of select="./@certainty"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@existent">
                        <xsl:attribute name="evidence">
                            <xsl:value-of select="./@existent"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="./@reg">
                        <choice>
                            <reg>
                                <xsl:value-of select="./@reg"/>
                            </reg>
                            <orig>
                                <xsl:apply-templates mode="tenor"/>
                            </orig>
                        </choice>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="tenor"/>
                    </xsl:otherwise>
                </xsl:choose>
            </placeName>
        </span>
    </xsl:template>
    <!-- END: placeName -->

    <!-- START: ORGNAME -->
    <xsl:template match="cei:orgName" mode="tenor">
        <span>
            <orgName>
                <xsl:if test="./@*">
                    <xsl:if test="./@id">
                        <xsl:attribute name="corresp">
                            <xsl:value-of select="./@id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@facs">
                        <xsl:attribute name="facs">
                            <xsl:value-of select="./@facs"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@key">
                        <xsl:attribute name="key">
                            <xsl:value-of select="./@key"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@n">
                        <xsl:attribute name="n">
                            <xsl:value-of select="./@n"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@type">
                        <xsl:attribute name="role">
                            <xsl:value-of select="./@type"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@rend">
                        <xsl:attribute name="rend">
                            <xsl:value-of select="./@rend"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@resp">
                        <xsl:attribute name="resp">
                            <xsl:value-of select="./@resp"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@lang">
                        <xsl:attribute name="xml:lang">
                            <xsl:value-of select="./@lang"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@certainty">
                        <xsl:attribute name="cert">
                            <xsl:value-of select="./@certainty"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="./@reg">
                        <choice>
                            <reg>
                                <xsl:value-of select="./@reg"/>
                            </reg>
                            <orig>
                                <xsl:apply-templates mode="tenor"/>
                            </orig>
                        </choice>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="tenor"/>
                    </xsl:otherwise>
                </xsl:choose>
            </orgName>
        </span>
    </xsl:template>
    <!-- END: ORGNAME -->

    <!-- START: foreign -->
    <xsl:template match="cei:foreign" mode="tenor">
        <foreign>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </foreign>
    </xsl:template>
    <!-- END: foreign -->

    <!-- START: app -->
    <xsl:template match="cei:app" mode="tenor">
        <app>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </app>
    </xsl:template>
    <!-- END: app -->

    <!-- START: lem -->
    <xsl:template match="cei:lem" mode="tenor">
        <lem>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@wit">
                    <xsl:attribute name="wit">
                        <xsl:value-of select="./@wit"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </lem>
    </xsl:template>
    <!-- END: lem -->

    <!-- START: rdg -->
    <xsl:template match="cei:rdg" mode="tenor">
        <rdg>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@wit">
                    <xsl:attribute name="wit">
                        <xsl:value-of select="./@wit"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@type">
                    <xsl:attribute name="type">
                        <xsl:value-of select="./@type"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </rdg>
    </xsl:template>
    <!-- END: rdg -->

    <!-- START: wit -->
    <xsl:template match="cei:witStart" mode="tenor">
        <witStart>
            <xsl:if test="./@wit">
                <xsl:attribute name="wit">
                    <xsl:value-of select="./@wit"/>
                </xsl:attribute>
            </xsl:if>
        </witStart>
    </xsl:template>

    <xsl:template match="cei:witEnd" mode="tenor">
        <witEnd>
            <xsl:if test="./@wit">
                <xsl:attribute name="wit">
                    <xsl:value-of select="./@wit"/>
                </xsl:attribute>
            </xsl:if>
        </witEnd>
    </xsl:template>

    <xsl:template match="cei:witDetail" mode="tenor">
        <witDetail>
            <xsl:if test="./@wit">
                <xsl:attribute name="wit">
                    <xsl:value-of select="./@wit"/>
                </xsl:attribute>
            </xsl:if>
        </witDetail>
    </xsl:template>
    <!-- END: wit -->

    <!--START: lacuna -->
    <xsl:template match="cei:lacunaStart" mode="tenor">
        <lacunaStart>
            <xsl:if test="./@wit">
                <xsl:attribute name="wit">
                    <xsl:value-of select="./@wit"/>
                </xsl:attribute>
            </xsl:if>
        </lacunaStart>
    </xsl:template>

    <xsl:template match="cei:lacunaEnd" mode="tenor">
        <lacunaEnd>
            <xsl:if test="./@wit">
                <xsl:attribute name="wit">
                    <xsl:value-of select="./@wit"/>
                </xsl:attribute>
            </xsl:if>
        </lacunaEnd>
    </xsl:template>
    <!-- END: lacuna -->

    <!-- START: hi -->
    <xsl:template match="cei:hi" mode="tenor">
        <hi>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </hi>
    </xsl:template>
    <!-- END: hi -->

    <!-- START seg -->
    <xsl:template match="cei:seg" mode="tenor">
        <span inst="seg">
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@type">
                    <xsl:attribute name="type">
                        <xsl:value-of select="./@type"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@part">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@part"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
        </span>
        <xsl:apply-templates mode="tenor"/>
    </xsl:template>
    <!-- END seg -->

    <!-- START: date -->
    <xsl:template match="cei:date" mode="tenor">
        <span>
            <date>
                <xsl:if test="./@value">
                    <xsl:attribute name="when">
                        <xsl:value-of select="./@value"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@notBefore">
                    <xsl:attribute name="notBefore">
                        <xsl:value-of select="./@notBefore"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@notAfter">
                    <xsl:attribute name="notAfter">
                        <xsl:value-of select="./@notAfter"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates mode="tenor"/>
            </date>
        </span>
    </xsl:template>
    <!-- END: date -->

    <!-- START: dateRange -->
    <xsl:template match="cei:dateRange" mode="tenor">
        <span>
            <date>
                <xsl:if test="./@from">
                    <xsl:attribute name="from">
                        <xsl:value-of select="./@from"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@to">
                    <xsl:attribute name="to">
                        <xsl:value-of select="./@to"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates mode="tenor"/>
            </date>
        </span>
    </xsl:template>
    <!-- END: dateRange -->

    <!-- START: figure -->
    <xsl:template match="cei:figure" mode="tenor">
        <figure>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </figure>
    </xsl:template>
    <!-- END: figure -->

    <!-- START: figDesc -->
    <xsl:template match="cei:figDesc" mode="tenor">
        <figDesc>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </figDesc>
    </xsl:template>
    <!-- END: figDesc -->

    <!-- START: graphic -->
    <xsl:template match="cei:graphic" mode="tenor">
        <graphic url="{./@url}">
            <xsl:if test="./@id">
                <xsl:attribute name="corresp">
                    <xsl:value-of select="./@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@facs">
                <xsl:attribute name="facs">
                    <xsl:value-of select="./@facs"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@n">
                <xsl:attribute name="n">
                    <xsl:value-of select="./@n"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@rend">
                <xsl:attribute name="rend">
                    <xsl:value-of select="./@rend"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@resp">
                <xsl:attribute name="resp">
                    <xsl:value-of select="./@resp"/>
                </xsl:attribute>
            </xsl:if>
        </graphic>
    </xsl:template>
    <!-- END: graphic -->

    <!-- START: byline / rights -->
    <xsl:template match="cei:rights" mode="tenor">
        <byline>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </byline>
    </xsl:template>
    <!-- END: byline / rights -->

    <!-- START: zone -->
    <xsl:template match="cei:zone" mode="tenor">
        <note sameAs="zone">
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="tenor"/>
        </note>

    </xsl:template>
    <!-- END: zone -->
    <!-- END: tenor -->

    <!-- START: ABSTRACT MARK UP -->
    <xsl:template match="cei:persName" mode="abstract">
        <persName>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@type">
                    <xsl:attribute name="type">
                        <xsl:value-of select="./@type"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@key">
                    <xsl:attribute name="key">
                        <xsl:value-of select="./@key"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@lang">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="./@lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@certainty">
                    <xsl:attribute name="cert">
                        <xsl:value-of select="./@certainty"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="./@reg">
                    <choice>
                        <orig>
                            <xsl:value-of select="."/>
                        </orig>
                        <reg>
                            <xsl:value-of select="./@reg"/>
                        </reg>
                    </choice>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="abstract"/>
                </xsl:otherwise>
            </xsl:choose>

        </persName>
    </xsl:template>
    <!-- END: ABSTRACT MARK UP -->

    <!--START: AUTH -->
    <xsl:template match="cei:auth" mode="auth">
        <authDesc>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@lang">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="./@lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="auth"/>
        </authDesc>
    </xsl:template>


    <!-- START: sealDesc -->
    <xsl:template match="cei:sealDesc" mode="auth">
        <decoNote>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@lang">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="./@lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="cei:p" mode="auth"/>
        </decoNote>
        <xsl:apply-templates select="cei:seal" mode="auth"/>
    </xsl:template>
    <!-- END: sealDesc -->

    <!-- START: sealDesc -->
    <xsl:template match="cei:p" mode="auth">
        <p>
            <xsl:apply-templates mode="auth"/>
        </p>
    </xsl:template>
    <!-- END: sealDesc -->

    <!-- START: seal -->
    <xsl:template match="cei:seal" mode="auth">
        <seal>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@lang">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="./@lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="auth"/>
        </seal>
    </xsl:template>
    <!-- END: seal -->

    <!-- START: sealCondition -->
    <xsl:template match="cei:sealCondition" mode="auth">
        <condition>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@lang">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="./@lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="auth"/>
        </condition>
    </xsl:template>
    <!-- END: sealCondition -->

    <!-- START: sealDimensions -->
    <xsl:template match="cei:sealDimensions" mode="auth">
        <measure>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="auth"/>
        </measure>
    </xsl:template>
    <!-- END: sealDimensions -->

    <!-- START: sealMaterial -->
    <xsl:template match="cei:sealMaterial" mode="auth">
        <material>
            <xsl:apply-templates mode="auth"/>
        </material>
    </xsl:template>
    <!-- END: sealMaterial -->

    <!-- START: seal legend -->
    <xsl:template match="cei:legend" mode="auth">
        <legend>
            <xsl:if test="./@*">
                <xsl:if test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@lang">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="./@lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@n"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@rend">
                    <xsl:attribute name="rend">
                        <xsl:value-of select="./@rend"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@resp">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="./@resp"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@place">
                    <xsl:attribute name="rendition">
                        <xsl:value-of select="./@place"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="auth"/>
        </legend>

    </xsl:template>
    <!-- END: seal legend -->

    <!-- START: sigillant -->
    <xsl:template match="cei:sigillant" mode="auth">
        <legalActor type="sigillant">
            <xsl:apply-templates select="cei:persName" mode="abstract"/>
        </legalActor>
    </xsl:template>
    <!-- END: sigillant -->
    <!--END: AUTH -->

    <!-- START: sourceDesc -->
    <xsl:template match="cei:sourceDesc" mode="sourceRegest">
        <accMat>
            <xsl:apply-templates mode="sourceRegest"/>
        </accMat>
    </xsl:template>
    <!-- END: sourceDesc -->

    <!-- START: sourceRegest -->
    <xsl:template match="cei:sourceDescRegest" mode="sourceRegest">
    <listBibl>
        <xsl:apply-templates mode="sourceRegest"/>
    </listBibl>
    </xsl:template>
    <!-- END: sourceRegest -->

    <!-- START: sourceRegest bibl -->
    <xsl:template match="cei:bibl" mode="sourceRegest">
        <bibl type="regest">
            <xsl:value-of select="."/>
        </bibl>
    </xsl:template>
    <!-- END: sourceRegest bibl -->

    <!-- START: diplomaticAnalysis listBiblEdition -->
    <xsl:template match="cei:diplomaticAnalysis/cei:listBiblEdition" mode="diplomaticAnalysis">
        <additional n="edition">
            <listBibl>
                <xsl:apply-templates mode="diplomaticAnalysis"/>
            </listBibl>
        </additional>
    </xsl:template>
    <!-- END: diplomaticAnalysis listBiblEdition -->

    <!-- START: diplomaticAnalysis listBiblErw -->
    <xsl:template match="cei:diplomaticAnalysis/cei:listBiblErw" mode="diplomaticAnalysis">
        <additional n="extension">
            <listBibl>
                <xsl:apply-templates mode="diplomaticAnalysis"/>
            </listBibl>
        </additional>
    </xsl:template>
    <!-- END: diplomaticAnalysis listBiblErw -->

    <!-- START: bibl -->
    <xsl:template match="cei:bibl" mode="diplomaticAnalysis">
        <bibl>
            <xsl:value-of select="."/>
        </bibl>
    </xsl:template>
    <!-- END: bibl -->
</xsl:stylesheet>
