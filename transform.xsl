<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns="http://www.tei-c.org/ns/1.0" xmlns:cei="http://www.monasterium.net/NS/cei"
                xmlns:bf="http://betterform.sourceforge.net/xforms" xmlns:xalan="http://xml.apache.org/xslt"
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
        <TEI xmlns="http://www.tei-c.org/ns/1.0"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://www.tei-c.org/ns/1.0 file:/Users/florian/Downloads/tei_ms/document.xsd">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>
                            <xsl:apply-templates select="//cei:text/cei:body/cei:idno" mode="teiTitle"/>
                        </title>
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
                    </publicationStmt>
                    <sourceDesc>
                        <!-- CHECK ELEMENT ORDER OF MODEL -->
                        <msDesc>
                            <xsl:apply-templates select="//cei:text/cei:body/cei:idno" mode="msDescId"/>
                            <xsl:apply-templates select="//*[local-name()='physicalDesc']"/>
                            <xsl:apply-templates select="//*[local-name()='issued']" mode="issuedHistory"/>
                        </msDesc>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <front>
                    <xsl:apply-templates select="//*[local-name()='abstract']"/>
                </front>
                <body>
                    <p></p>
                </body>
            </text>
        </TEI>
    </xsl:template>
    <!-- END: ROOT DOCUMENT -->

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
            <xsl:when test="./@id and ./text()">
                <msIdentifier>
                    <idno>
                        <xsl:attribute name="xml:id">
                            <xsl:value-of select="./@id"/>
                        </xsl:attribute>
                        <xsl:value-of select="./text()"/>
                    </idno>
                </msIdentifier>
            </xsl:when>
            <xsl:when test="./text() != ''">
                <msIdentifier>
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
                </msIdentifier>
            </xsl:when>
            <xsl:otherwise>
                <msIdentifier>
                    <idno>
                        <xsl:value-of select="./text()"/>
                    </idno>
                </msIdentifier>
                <altIdentifier>
                    <idno>
                        <xsl:value-of select="./@id"/>
                    </idno>
                </altIdentifier>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- END: msDESC Identifier -->

    <!-- START: msDESC issued -->
    <xsl:template match="cei:issued" mode="issuedHistory">
        <xsl:if test="./cei:date">
            <history>
                <origin xml:id="issued">
                    <xsl:apply-templates/>
                    <xsl:apply-templates select="//*[local-name()='witnessOrig']"/>
                </origin>
            </history>
        </xsl:if>
    </xsl:template>
    <!-- END: msDESC issued -->

    <!-- START: date -->
    <xsl:template match="cei:date">
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
    <xsl:template match="cei:dateRange">
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
    <xsl:template match="cei:placeName">
        <placeName>
            <xsl:if test="./@id">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="./@n"/>
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
    <xsl:template match="cei:abstract">
        <div type="abstract">
            <p>
                <xsl:value-of select="."/>
            </p>
        </div>
    </xsl:template>
    <!-- END: abstract -->

    <!-- START: witnessOrig -->
    <xsl:template match="cei:witnessOrig">
        <bibl type="witnessOrig">
            <xsl:apply-templates select="cei:traditioForm | cei:archIdentifier"/>
        </bibl>
    </xsl:template>
    <!-- END: witnessOrig -->

    <!-- START: traditioForm -->
    <xsl:template match="cei:traditioForm">
        <orig>
            <xsl:apply-templates/>
        </orig>
    </xsl:template>
    <!-- END: traditioForm -->

    <!-- START: archIdentifier -->
    <xsl:template match="cei:archIdentifier">
        <xsl:if test="./cei:settlement">
            <placeName>
                <xsl:value-of select="./cei:settlement"/>
            </placeName>
        </xsl:if>

        <xsl:if test="./cei:arch">
            <orgName>
                <xsl:value-of select="./cei:arch"/>
            </orgName>
        </xsl:if>
        <xsl:if test="./cei:idno">
            <idno>
                <xsl:value-of select="./cei:idno"/>
            </idno>
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
                <layoutDesc>
                    <!-- TODO FIX layout p -->
                    <xsl:apply-templates select="//cei:p[@type = 'layout']"/>
                </layoutDesc>
            </objectDesc>
            <handDesc>
                <xsl:apply-templates select="//cei:p[@type = 'handDesc']"/>
            </handDesc>
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
    <xsl:template name="pLayout" match="cei:p[@type = 'layout']">
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
    <xsl:template name="pHanddesc" match="cei:p[@type = 'handDesc']">
            <xsl:for-each select=".">
                <p>
                    <xsl:value-of select="../cei:p/text()"/>
                </p>
            </xsl:for-each>
    </xsl:template>
    <!-- END: handDesc > p -->
</xsl:stylesheet>