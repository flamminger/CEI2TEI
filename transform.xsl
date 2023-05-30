<?xml version="1.0" encoding="UTF-8"?>
<?xml-model
        href="SCHEMA" type="application/relax-ng-compact-syntax"
        ?>
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
        <xsl:value-of select="//atom:id"/>
    </xsl:variable>
    <xsl:variable name="atomPath">
        <xsl:value-of select="substring-after($atomId, 'tag:www.monasterium.net,2011:/charter/')"
        />
    </xsl:variable>
    <xsl:variable name="atom_published" select="/atom:entry/atom:published"/>
    <xsl:variable name="atom_updated" select="/atom:entry/atom:updated"/>
    <xsl:variable name="atom_email" select="/atom:entry/atom:author/atom:email"/>
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
                            <orig corresp="https://www.monasterium.net/mom/{$atomPath}/charter">
                                Transformed to CEI:
                                <xsl:value-of select="$atomPath"/>
                            </orig>
                            <idno type="atom">
                                <xsl:value-of select="$atomId"/>
                            </idno>
                        </distributor>
                        <date when-iso="{$atom_published}">
                            <xsl:value-of select="substring($atom_published, 1, 9)"/>
                        </date>
                    </publicationStmt>
                    <sourceDesc>
                        <!-- CHECK ELEMENT ORDER OF MODEL -->
                        <msDesc>
                            <xsl:choose>
                                <!-- CHECK IF WITNESS ORIG EXISTS -->
                                <xsl:when test="//*[local-name() = 'witnessOrig'] !=''">
                                    <xsl:apply-templates
                                            select="//*[local-name() = 'witnessOrig']"
                                            mode="msDescId"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- IF NO WITNESS ORIG EXISTS, USE BODY/IDNO AS MANDATORY <msIdentifier> ID-->
                                    <msIdentifier>
                                        <xsl:apply-templates select="//cei:text/cei:body/cei:idno"
                                                             mode="msCharterId"/>
                                    </msIdentifier>
                                </xsl:otherwise>
                            </xsl:choose>

                            <xsl:apply-templates select="//*[local-name() = 'physicalDesc']" mode="msDescPhysical"/>
                            <diploDesc>
                                <xsl:apply-templates select="//*[local-name() = 'issued']" mode="issuedDiploDesc"/>
                                <xsl:apply-templates
                                        select="//*[local-name() = 'witnessOrig']//*[local-name() = 'traditioForm']"
                                        mode="copyStatusDiploDesc"/>
                                <xsl:apply-templates select="//*[local-name() = 'rubrum']"/>
                                <xsl:apply-templates select="//*[local-name() = 'diplomaticAnalysis']"
                                                     mode="diplomaticAnalysis"/>
                            </diploDesc>
                            <xsl:if test="//*[local-name() = 'witnessOrig']//*[local-name() = 'auth']">
                                <xsl:apply-templates
                                        select="//*[local-name() = 'witnessOrig']//*[local-name() = 'auth']"
                                        mode="auth"/>
                            </xsl:if>
                        </msDesc>
                        <xsl:if test="//*[local-name() = 'witListPar']/* != ''">
                            <xsl:apply-templates select="//*[local-name() = 'witListPar']"
                                                 mode="listWit"/>
                        </xsl:if>
                    </sourceDesc>
                </fileDesc>
                <profileDesc>
                    <xsl:apply-templates select="//*[local-name() = 'abstract'] | //*[local-name() = 'lang_MOM']"
                                         mode="abstract"/>
                    <xsl:apply-templates select="//*[local-name() = 'text']" mode="textAttributes"/>
                </profileDesc>
                <revisionDesc>
                    <change>
                        <date when-iso="{$atom_updated}">
                            <xsl:value-of select="substring($atom_updated, 1, 9)"/>
                        </date>
                    </change>
                </revisionDesc>
            </teiHeader>
            <xsl:if test="//*[local-name() = 'witnessOrig']//*[local-name() = 'figure']">
                <facsimile>
                    <!-- TODO FIX SURFACE -->
                    <xsl:apply-templates select="//*[local-name() = 'witnessOrig']//*[local-name() = 'figure']"
                                         mode="facsimile"/>
                </facsimile>
            </xsl:if>
            <text>
                <front>
                    <xsl:if test="//*[local-name() = 'sourceDesc']">
                        <xsl:apply-templates select="//*[local-name() = 'sourceDesc']" mode="sourceRegest"/>
                    </xsl:if>
                </front>
                <body>
                    <div type="tenor">
                        <p>
                            <xsl:apply-templates select="//*[local-name() = 'tenor']"/>
                        </p>
                    </div>
                </body>
                <back>
                    <xsl:apply-templates select="//*[local-name() = 'back']" mode="back"/>
                </back>
            </text>
        </TEI>
    </xsl:template>
    <!-- END: ROOT DOCUMENT -->

    <!-- START: ATOM CONTENT -->
    <!-- END: ATOM CONTENT -->

    <!-- START: TEI TITLE -->
    <xsl:template match="cei:idno" mode="teiTitle">
        <xsl:choose>
            <xsl:when test=". != ''">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="./@id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- END: TEI TITLE -->

    <!-- START: msDESC Identifier -->
    <xsl:template match="cei:idno" mode="msCharterId">
        <xsl:choose>
            <xsl:when test="./@id and ./@old and ./text() != ''">
                <idno>
                    <xsl:attribute name="source">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                    <xsl:attribute name="prev">
                        <xsl:value-of select="./@old"/>
                    </xsl:attribute>
                    <xsl:value-of select="normalize-space(./text())"/>
                </idno>
            </xsl:when>
            <xsl:when test="./@id and ./text() != ''">
                <idno>
                    <xsl:attribute name="source">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                    <xsl:value-of select="normalize-space(./text())"/>
                </idno>
            </xsl:when>
            <xsl:when test="./@id and ./text() = ''">
                <idno>
                    <xsl:value-of select="./@id"/>
                </idno>
            </xsl:when>
            <xsl:when test="./text() != ''">
                <idno>
                    <xsl:value-of select="normalize-space(./text())"/>
                </idno>
            </xsl:when>
            <xsl:otherwise>
                <idno>
                    <xsl:value-of select="normalize-space(./text())"/>
                </idno>
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
    <xsl:template match="cei:listBibl" mode="diplomaticAnalysis">
        <listBibl type="analysis">
            <xsl:apply-templates/>
        </listBibl>
    </xsl:template>
    <!-- END: diploDesc bibl -->


    <!-- START: copyStatus -->
    <xsl:template match="cei:traditioForm" mode="copyStatusDiploDesc">
        <copyStatus>
            <xsl:call-template name="traditioForm"/>
            <xsl:value-of select="."/>
        </copyStatus>
    </xsl:template>
    <!-- END: copyStatus -->

    <!-- START: date -->
    <xsl:template match="cei:date" mode="issuedDiploDesc">
        <origDate>
            <xsl:call-template name="date"/>
            <xsl:value-of select="."/>
        </origDate>
    </xsl:template>
    <!-- END: date -->

    <!-- START: dateRange -->
    <xsl:template match="cei:dateRange" mode="issuedDiploDesc">
        <origDate>
            <xsl:call-template name="dateRange"/>
            <xsl:value-of select="."/>
        </origDate>
    </xsl:template>
    <!-- END: dateRange -->

    <!-- START: placeName -->
    <xsl:template match="cei:placeName" mode="issuedDiploDesc">
        <placeName>
            <xsl:call-template name="placenameGeogName"/>
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
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </placeName>
    </xsl:template>
    <!-- END: placeName -->

    <!-- START: abstract -->
    <xsl:template match="cei:abstract" mode="abstract">
        <abstract>
            <p>
                <xsl:apply-templates/>
            </p>
        </abstract>
    </xsl:template>
    <!-- END: abstract -->

    <!-- START: lang_MOM -->
    <xsl:template match="cei:lang_MOM" mode="abstract">
        <xsl:if test=". != ''">
            <langUsage>
                <language ident="und">
                    <xsl:value-of select="."/>
                </language>
            </langUsage>
        </xsl:if>
    </xsl:template>

    <!-- END: lang_MOM -->

    <!-- START: witnessOrig -->
    <xsl:template match="cei:witnessOrig" mode="msDescId">
        <xsl:choose>
            <xsl:when test="cei:archIdentifier">
                <xsl:apply-templates select="cei:archIdentifier"/>
            </xsl:when>
            <xsl:otherwise>
                <msIdentifier>
                    <idno>
                        <xsl:apply-templates select="//cei:text/cei:body/cei:idno"
                                             mode="msCharterId"/>
                    </idno>
                </msIdentifier>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- END: witnessOrig -->

    <!-- START: archIdentifier -->
    <xsl:template match="cei:archIdentifier">
        <msIdentifier>
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
            <xsl:choose>
                <xsl:when test="./cei:arch">
                    <institution>
                        <xsl:value-of select="./cei:arch"/>
                    </institution>
                </xsl:when>
                <xsl:when test="./text()">
                    <institution><xsl:value-of select="./text()"/></institution>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="./cei:archFond">
                <collection>
                    <xsl:value-of select="./cei:archFond"/>
                </collection>
            </xsl:if>
            <xsl:if test="./cei:altIdentifier">
                <collection>
                    <xsl:value-of select="./cei:altIdentifier"/>
                </collection>
            </xsl:if>
            <xsl:apply-templates select="//*[local-name() = 'body']/*[local-name() = 'idno']" mode="msCharterId"/>
            <xsl:if test="./cei:idno">
                <altIdentifier>
                    <idno type="local">
                        <xsl:value-of select="./cei:idno"/>
                    </idno>
                </altIdentifier>
            </xsl:if>
            <xsl:if test="normalize-space(.) and not(*)">
                <institution>
                    <xsl:value-of select="."/>
                </institution>
            </xsl:if>
        </msIdentifier>
    </xsl:template>
    <!-- END: archIdentifier -->

    <!-- START: physicalDesc -->
    <xsl:template match="cei:physicalDesc" mode="msDescPhysical">
        <xsl:if test="normalize-space(.) != ''">
            <physDesc>
                <objectDesc>
                    <supportDesc>
                        <support>
                            <xsl:apply-templates select="cei:material | cei:dimensions"/>
                        </support>
                        <xsl:apply-templates select="cei:condition"/>
                    </supportDesc>
                    <xsl:if test="//cei:p[@type = 'layout']">
                        <layoutDesc>
                            <xsl:apply-templates select="//cei:p[@type = 'layout']" mode="pLayout"/>
                        </layoutDesc>
                    </xsl:if>
                </objectDesc>
                <xsl:choose>
                    <xsl:when test="./cei:decoDesc">
                        <decoDesc>
                            <xsl:apply-templates select="./cei:decoDesc"/>
                        </decoDesc>
                    </xsl:when>
                    <xsl:when test="//cei:p[@type = 'handDesc']">
                        <handDesc>
                            <xsl:apply-templates select="//cei:p[@type = 'handDesc']" mode="pHanddesc"/>
                        </handDesc>
                    </xsl:when>
                </xsl:choose>
            </physDesc>
        </xsl:if>
    </xsl:template>
    <!-- END: physicalDesc -->

    <!-- START: material -->
    <xsl:template match="cei:material">
        <material>
            <xsl:call-template name="supForeignTestisCitQuote"/>
            <xsl:value-of select="."/>
        </material>
    </xsl:template>
    <!-- END: material -->

    <!-- START: dimensions -->
    <xsl:template match="cei:dimensions">
        <xsl:choose>
            <xsl:when test="./text()">
                <measure>
                    <xsl:call-template name="measureDimensions"/>
                    <xsl:value-of select="./text()"/>
                </measure>
            </xsl:when>
            <xsl:otherwise>
                <dimensions>
                    <xsl:call-template name="measureDimensions"/>
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

    <!-- START: condition -->
    <xsl:template match="cei:condition">
        <condition>
            <xsl:call-template name="supForeignTestisCitQuote"/>
            <xsl:apply-templates/>
        </condition>
    </xsl:template>
    <!-- END: conidition -->

    <!-- START: num -->
    <xsl:template match="cei:num">
        <num>
            <xsl:call-template name="num"/>
            <xsl:apply-templates/>
        </num>
    </xsl:template>
    <!-- END: num -->

    <!-- START: p -->
    <xsl:template match="cei:p">
        <p>
            <xsl:call-template name="paragraph"/>
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
                <xsl:value-of select="./text()"/>
            </p>
        </xsl:for-each>
    </xsl:template>
    <!-- END: handDesc > p -->

    <!-- START: rubrum -->
    <xsl:template match="cei:rubrum">
        <xsl:if test="normalize-space(.) != ''">
            <p sameAs="rubrum">
                <xsl:apply-templates/>
            </p>
        </xsl:if>
    </xsl:template>
    <!-- END: rubrum -->

    <!-- START: surfaceGrp graphic -->
    <xsl:template match="cei:figure" mode="facsimile">
        <xsl:choose>
            <xsl:when test="./cei:zone">
                <surfaceGrp>
                    <xsl:for-each select="cei:zone">
                        <surface>
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="./@id"/>
                            </xsl:attribute>
                        </surface>
                    </xsl:for-each>
                </surfaceGrp>
            </xsl:when>
            <xsl:when test="./cei:graphic">
                <graphic url="{./cei:graphic/@url}">
                    <xsl:choose>
                        <xsl:when test="./@id">
                            <xsl:attribute name="corresp">
                                <xsl:value-of select="./@id"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="./@n">
                            <xsl:attribute name="n">
                                <xsl:value-of select="./@n"/>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <!-- to preserve <cei:graphic> element content -->
                    <!--                <xsl:choose>-->
                    <!--                    <xsl:when test="./cei:graphic/text()">-->
                    <!--                        <desc>-->
                    <!--                            <xsl:value-of select="./cei:graphic/text()"/>-->
                    <!--                        </desc>-->
                    <!--                    </xsl:when>-->
                    <!--                    <xsl:otherwise>-->
                    <!--                        <xsl:apply-templates select="./cei:figDesc" mode="facsimile"/>-->
                    <!--                    </xsl:otherwise>-->
                    <!--                </xsl:choose>-->
                    <xsl:apply-templates select="./cei:figDesc" mode="facsimile"/>
                </graphic>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- END: surfaceGrp graphic -->

    <!-- START: figDesc -->
    <xsl:template match="cei:figDesc" mode="facsimile">
        <desc>
            <xsl:apply-templates mode="facsimile"/>
        </desc>
    </xsl:template>
    <!-- END: figureDesc -->

    <!-- START: witnessList -->

    <!-- START: witListpar -->
    <xsl:template match="cei:witListPar" mode="listWit">
        <listWit>
            <xsl:apply-templates mode="witness"/>
        </listWit>
    </xsl:template>
    <!-- END: witnessListPar -->

    <!-- START: traditioForm -->
    <xsl:template match="cei:traditioForm" mode="witness">
        <distinct type="copyStatus">
            <xsl:apply-templates/>
        </distinct>
    </xsl:template>
    <!-- END: traditioForm -->

    <!-- START: witness -->
    <xsl:template match="cei:witness" mode="witness">
        <witness>
            <xsl:choose>
                <xsl:when test="./@id">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="./@lang">
                    <xsl:attribute name="xml:lang">
                        <xsl:value-of select="./@lang"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="./@n">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@*"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates mode="witness"/>
        </witness>
    </xsl:template>
    <!-- END: witness -->

    <!-- START: witness archIdentifier -->
    <xsl:template match="cei:archIdentifier" mode="witness">
        <idno>
            <xsl:apply-templates/>
        </idno>
    </xsl:template>
    <!-- END: witness archIdentifier -->

    <!-- START: witness figure -->
    <xsl:template match="cei:figure" mode="witness">
        <bibl type="graphic">
            <figure>
                <graphic url="{./cei:graphic/@url}">
                    <xsl:choose>
                        <xsl:when test="./@id">
                            <xsl:attribute name="corresp">
                                <xsl:value-of select="./@id"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="./@n">
                            <xsl:attribute name="n">
                                <xsl:value-of select="./@n"/>
                            </xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                </graphic>
            </figure>
        </bibl>
    </xsl:template>
    <!-- END: witness figure -->
    <!-- END: witnessList -->

    <!--     START: tenor -->
    <xsl:template match="cei:tenor">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="cei:pTenor">
            <xsl:apply-templates/>
    </xsl:template>

    <!-- START: pb -->
    <xsl:template match="cei:pb">
        <pb>
            <xsl:call-template name="note"/>
            <xsl:value-of select="."/>
        </pb>
    </xsl:template>
    <!-- END: pb -->

    <!-- START: lb -->
    <xsl:template match="cei:lb">
        <lb>
            <xsl:call-template name="lb"/>
        </lb>
    </xsl:template>
    <!-- END: lb -->

    <!-- START: w -->
    <xsl:template match="cei:w">
        <w>
            <xsl:choose>
                <xsl:when test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="./@note">
                    <xsl:attribute name="note">
                        <xsl:value-of select="./@note"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </w>
    </xsl:template>
    <!-- END: w -->

    <!-- START: c -->
    <xsl:template match="cei:c">
        <span type="char">
            <xsl:call-template name="char"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: c -->

    <!-- START: pc -->
    <xsl:template match="cei:pc">
        <pc>
            <xsl:choose>
                <xsl:when test="./@id">
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="./@id"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="./@facs">
                    <xsl:attribute name="facs">
                        <xsl:value-of select="./@facs"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </pc>
    </xsl:template>
    <!-- END: pc -->

    <!-- START: name -->
    <xsl:template match="cei:name">
        <name>
            <xsl:call-template name="name"/>
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    <!-- END: name -->

    <!-- START: expan -->
    <xsl:template match="cei:expan">
        <choice>
            <abbr>
                <xsl:value-of select="./@abbr"/>
            </abbr>
            <expan>
                <xsl:call-template name="expan"/>
                <xsl:value-of select="."/>
            </expan>
        </choice>
    </xsl:template>
    <!-- END: expan -->

    <!-- START: foreign -->
    <xsl:template match="cei:foreign">
        <foreign>
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureAppForeign"/>
            <xsl:apply-templates/>
        </foreign>
    </xsl:template>
    <!-- END: foreign -->

    <!-- START: app -->
    <xsl:template match="cei:app">
        <app>
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureAppForeign"/>
            <xsl:apply-templates/>
        </app>
    </xsl:template>
    <!-- END: app -->

    <!-- START: lem -->
    <xsl:template match="cei:lem">
        <lem>
            <xsl:call-template name="lem"/>
            <xsl:apply-templates/>
        </lem>
    </xsl:template>
    <!-- END: lem -->

    <!-- START: rdg -->
    <xsl:template match="cei:rdg">
        <rdg>
            <xsl:call-template name="rdg"/>
            <xsl:apply-templates/>
        </rdg>
    </xsl:template>
    <!-- END: rdg -->

    <!-- START: wit -->
    <xsl:template match="cei:witStart">
        <witStart>
            <xsl:if test="./@wit">
                <xsl:attribute name="wit">
                    <xsl:value-of select="./@wit"/>
                </xsl:attribute>
            </xsl:if>
        </witStart>
    </xsl:template>

    <xsl:template match="cei:witEnd">
        <witEnd>
            <xsl:if test="./@wit">
                <xsl:attribute name="wit">
                    <xsl:value-of select="./@wit"/>
                </xsl:attribute>
            </xsl:if>
        </witEnd>
    </xsl:template>

    <xsl:template match="cei:witDetail">
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
    <xsl:template match="cei:lacunaStart">
        <lacunaStart>
            <xsl:if test="./@wit">
                <xsl:attribute name="wit">
                    <xsl:value-of select="./@wit"/>
                </xsl:attribute>
            </xsl:if>
        </lacunaStart>
    </xsl:template>

    <xsl:template match="cei:lacunaEnd">
        <lacunaEnd>
            <xsl:if test="./@wit">
                <xsl:attribute name="wit">
                    <xsl:value-of select="./@wit"/>
                </xsl:attribute>
            </xsl:if>
        </lacunaEnd>
    </xsl:template>
    <!-- END: lacuna -->

    <!-- START seg -->
    <xsl:template match="cei:seg">
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
                        <xsl:value-of select="translate(./@type, ' ', '')"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="./@part">
                    <xsl:attribute name="n">
                        <xsl:value-of select="./@part"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
        </span>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- END seg -->

    <!-- START: figure -->
    <xsl:template match="cei:figure">
        <figure>
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureAppForeign"/>
            <xsl:apply-templates/>
        </figure>
    </xsl:template>
    <!-- END: figure -->

    <!-- START: figDesc -->
    <xsl:template match="cei:figDesc">
        <figDesc>
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureAppForeign"/>
            <xsl:apply-templates/>
        </figDesc>
    </xsl:template>
    <!-- END: figDesc -->

    <!-- START: graphic -->
    <xsl:template match="cei:graphic">
        <graphic url="{./@url}">
            <xsl:call-template name="graphic"/>
        </graphic>
    </xsl:template>
    <!-- END: graphic -->

    <!-- START: byline / rights -->
    <xsl:template match="cei:rights">
        <byline>
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureAppForeign"/>
            <xsl:apply-templates/>
        </byline>
    </xsl:template>
    <!-- END: byline / rights -->

    <!-- START: zone -->
    <xsl:template match="cei:zone">
        <note sameAs="zone">
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureAppForeign"/>
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    <!-- END: zone -->

    <!--START: AUTH -->
    <xsl:template match="cei:auth" mode="auth">
        <authDesc>
            <xsl:call-template name="authAttb"/>
            <xsl:apply-templates mode="auth"/>
            <xsl:apply-templates select="//*[local-name() = 'seal']" mode="auth"/>
        </authDesc>
    </xsl:template>

    <!-- START: sealDesc -->
    <xsl:template match="cei:sealDesc" mode="auth">
        <decoNote>
            <xsl:call-template name="sealDescConc"/>
            <xsl:apply-templates select="cei:p" mode="auth"/>
        </decoNote>
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
            <xsl:call-template name="sealDescConc"/>
            <xsl:apply-templates mode="auth"/>
        </condition>
    </xsl:template>
    <!-- END: sealCondition -->

    <!-- START: sealDimensions -->
    <xsl:template match="cei:sealDimensions" mode="auth">
        <measure>
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureAppForeign"/>
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
            <xsl:call-template name="legend"/>
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

    <!-- START: sourceDesc template for <physcDesc>-->
    <!--    <xsl:template match="cei:sourceDesc" mode="sourceRegest">-->
    <!--        <accMat>-->
    <!--            <xsl:apply-templates select="*" mode="sourceRegest"/>-->
    <!--        </accMat>-->
    <!--    </xsl:template>-->
    <!-- END: sourceDesc -->

    <!-- START: sourceRegest -->
    <xsl:template match="cei:sourceDesc" mode="sourceRegest">
        <listBibl>
            <xsl:apply-templates mode="sourceRegest"/>
        </listBibl>
    </xsl:template>
    <!-- END: sourceRegest -->

    <!-- START: sourceRegest bibl -->
    <xsl:template match="cei:bibl" mode="sourceRegest">
        <xsl:if test="normalize-space(.) != ''">
            <bibl>
                <xsl:choose>
                    <xsl:when test="ancestor::cei:sourceDescVolltext">
                        <xsl:attribute name="type">
                            <xsl:text>text</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="ancestor::cei:sourceDescRegest">
                        <xsl:attribute name="type">
                            <xsl:text>regest</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates/>
            </bibl>
        </xsl:if>
    </xsl:template>
    <!-- END: sourceRegest bibl -->

    <!-- START: diplomaticAnalysis listBiblEdition -->
    <xsl:template match="cei:diplomaticAnalysis/cei:listBiblEdition" mode="diplomaticAnalysis">
        <xsl:if test="normalize-space(.) != ''">
            <additional n="edition">
                <listBibl>
                    <xsl:apply-templates/>
                </listBibl>
            </additional>
        </xsl:if>
    </xsl:template>
    <!-- END: diplomaticAnalysis listBiblEdition -->

    <!-- START: diplomaticAnalysis listBiblErw -->
    <xsl:template match="cei:diplomaticAnalysis/cei:listBiblErw" mode="diplomaticAnalysis">
        <xsl:if test="normalize-space(.) != ''">
            <additional n="extension">
                <listBibl>
                    <xsl:apply-templates/>
                </listBibl>
            </additional>
        </xsl:if>
    </xsl:template>
    <!-- END: diplomaticAnalysis listBiblErw -->

    <!-- START: diplomaticAnalysis p -->
    <xsl:template match="cei:p" mode="diplomaticAnalysis">
        <xsl:if test="normalize-space(.) != ''">
            <p>
                <xsl:apply-templates/>
            </p>
        </xsl:if>
    </xsl:template>
    <!-- END: diplomaticAnalysis p -->

    <!-- START: diplomaticAnalysis quoteDate -->
    <xsl:template match="cei:quoteOriginaldatierung" mode="diplomaticAnalysis">
        <xsl:if test="normalize-space(.) != ''">
            <origDate>
                <q>
                    <xsl:apply-templates mode="diplomaticAnalysis"/>
                </q>
            </origDate>
        </xsl:if>
    </xsl:template>
    <!-- END: diplomaticAnalysis quoteDate -->
    <!-- START: back -->
    <!-- START: divNotes -->
    <xsl:template match="cei:divNotes" mode="back">
        <xsl:if test="normalize-space(.) != ''">
            <div>
                <xsl:apply-templates/>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- END: divNotes -->

    <!--     START: persName-->
    <xsl:template match="//*[local-name() = 'back']" mode="back">
        <xsl:if test="cei:placeName[normalize-space(.) != '']">
            <listPlace>
                <xsl:for-each select="cei:placeName[normalize-space(.) != '']">
                    <place>
                        <placeName>
                            <xsl:call-template name="placenameGeogName"/>
                            <xsl:choose>
                                <xsl:when test="./@reg">
                                    <choice>
                                        <reg>
                                            <xsl:value-of select="./@reg"/>
                                        </reg>
                                        <orig>
                                            <xsl:apply-templates/>
                                        </orig>
                                    </choice>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </placeName>
                    </place>
                </xsl:for-each>
            </listPlace>
        </xsl:if>
        <xsl:if test="cei:persName">
            <xsl:if test="cei:persName[normalize-space(.) != '']">
                <listPerson>
                    <xsl:for-each select="cei:persName[normalize-space(.) != '']">
                        <person>
                            <persName>
                                <xsl:call-template name="persname"/>
                                <xsl:choose>
                                    <xsl:when test="./@reg">
                                        <choice>
                                            <orig>
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </orig>
                                            <reg>
                                                <xsl:value-of select="./@reg"/>
                                            </reg>
                                        </choice>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </persName>
                        </person>
                    </xsl:for-each>
                </listPerson>
            </xsl:if>
        </xsl:if>
        <xsl:if test="cei:index">
            <xsl:if test="cei:index[normalize-space(.) != '']">
                <list type="index">
                    <xsl:for-each select="cei:index[normalize-space(.) != '']">
                        <item>
                            <index>
                                <xsl:call-template name="listIndex"/>
                                <term>
                                    <xsl:value-of select="normalize-space(.)"/>
                                </term>
                            </index>
                        </item>
                    </xsl:for-each>
                </list>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--     END: persName-->
    <!-- END: back -->

    <!-- START: cei:text attributes -->
    <xsl:template match="cei:text" mode="textAttributes">
        <xsl:if test="./@id | ./@b_name | ./@n">
            <settingDesc>
                <setting>
                    <xsl:if test="./@id">
                        <xsl:attribute name="corresp">
                            <xsl:value-of select="./@id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./@b_name">
                        <name type="bestand">
                            <xsl:value-of select="./@b_name"/>
                        </name>
                    </xsl:if>
                    <xsl:if test="./@n">
                        <locale>
                            <xsl:value-of select="./@n"/>
                        </locale>
                    </xsl:if>
                </setting>
            </settingDesc>
        </xsl:if>
    </xsl:template>
    <!-- END: cei:text attributes -->

    <!-- START: global elements -->
    <!-- START: foreign -->
    <xsl:template match="cei:foreign">
        <foreign>
            <xsl:call-template name="supForeignTestisCitQuote"/>
            <xsl:apply-templates/>
        </foreign>
    </xsl:template>
    <!-- END: foreign -->

    <!-- START: persName -->
    <xsl:template match="cei:persName">
        <persName>
            <xsl:call-template name="persname"/>
            <xsl:choose>
                <xsl:when test="./@reg">
                    <choice>
                        <orig>
                            <xsl:value-of select="."/>
                        </orig>
                        <reg>
                            <xsl:apply-templates/>
                        </reg>
                    </choice>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </persName>
    </xsl:template>
    <!-- END: persName -->

    <!-- START: placeName -->
    <xsl:template match="cei:placeName">
        <placeName>
            <xsl:call-template name="placenameGeogName"/>
            <xsl:choose>
                <xsl:when test="./@reg">
                    <choice>
                        <reg>
                            <xsl:value-of select="./@reg"/>
                        </reg>
                        <orig>
                            <xsl:apply-templates/>
                        </orig>
                    </choice>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </placeName>
    </xsl:template>
    <!-- END: placeName -->

    <!-- START: issuer -->
    <xsl:template match="cei:issuer">
        <legalActor type="issuer">
            <xsl:call-template name="issuerRecipient"/>
            <xsl:apply-templates/>
        </legalActor>
    </xsl:template>
    <!-- END: issuer -->

    <!-- START: roleName -->
    <xsl:template match="cei:rolename">
        <roleName>
            <xsl:call-template name="rolename"/>
            <xsl:apply-templates/>
        </roleName>
    </xsl:template>
    <!-- END: roleName -->

    <!-- START: orgName -->
    <xsl:template match="cei:orgName">
        <orgName>
            <xsl:call-template name="orgname"/>
            <xsl:choose>
                <xsl:when test="./@reg">
                    <choice>
                        <reg>
                            <xsl:value-of select="./@reg"/>
                        </reg>
                        <orig>
                            <xsl:apply-templates/>
                        </orig>
                    </choice>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </orgName>
    </xsl:template>
    <!-- END: orgName -->

    <!-- START: recipient -->
    <xsl:template match="cei:recipient">
        <legalActor type="recipient">
            <xsl:call-template name="issuerRecipient"/>
            <xsl:apply-templates/>
        </legalActor>
    </xsl:template>
    <!-- END: recipient -->

    <!-- START: hi -->
    <xsl:template match="cei:hi">
        <hi>
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureAppForeign"/>
            <xsl:apply-templates/>
        </hi>
    </xsl:template>
    <!-- END: hi -->

    <!-- START: anchor -->
    <xsl:template match="cei:anchor">
        <anchor>
            <xsl:call-template name="anchor"/>
        </anchor>
    </xsl:template>
    <!-- END: anchor -->

    <!-- START: testis / witness -->
    <xsl:template match="cei:testis">
        <legalActor type="other">
            <xsl:call-template name="supForeignTestisCitQuote"/>
            <xsl:apply-templates/>
        </legalActor>
    </xsl:template>
    <!-- END: testis / witness -->

    <!-- START: date -->
    <xsl:template match="cei:date">
        <origDate>
            <xsl:call-template name="date"/>
            <xsl:apply-templates/>
        </origDate>
    </xsl:template>
    <!-- END: date -->

    <!-- START: dateRange -->
    <xsl:template match="cei:dateRange">
        <origDate>
            <xsl:call-template name="dateRange"/>
            <xsl:apply-templates/>
        </origDate>
    </xsl:template>
    <!-- END: dateRange -->

    <!-- START: c -->
    <!-- c element cannot contain <choice> elements-->
    <!--    <xsl:template match="cei:c">-->
    <!--        <c>-->
    <!--            <xsl:if test="./@*">-->
    <!--                <xsl:if test="./@id">-->
    <!--                    <xsl:attribute name="corresp">-->
    <!--                        <xsl:value-of select="./@id"/>-->
    <!--                    </xsl:attribute>-->
    <!--                </xsl:if>-->
    <!--                <xsl:if test="./@facs">-->
    <!--                    <xsl:attribute name="facs">-->
    <!--                        <xsl:value-of select="./@facs"/>-->
    <!--                    </xsl:attribute>-->
    <!--                </xsl:if>-->
    <!--                <xsl:if test="./@type">-->
    <!--                    <xsl:attribute name="type">-->
    <!--                        <xsl:value-of select="translate(./@type, ' ', '')"/>-->
    <!--                    </xsl:attribute>-->
    <!--                </xsl:if>-->
    <!--                <xsl:if test="./@n">-->
    <!--                    <xsl:attribute name="n">-->
    <!--                        <xsl:value-of select="./@n"/>-->
    <!--                    </xsl:attribute>-->
    <!--                </xsl:if>-->
    <!--                <xsl:if test="./@rend">-->
    <!--                    <xsl:attribute name="rend">-->
    <!--                        <xsl:value-of select="./@rend"/>-->
    <!--                    </xsl:attribute>-->
    <!--                </xsl:if>-->
    <!--                <xsl:if test="./@resp">-->
    <!--                    <xsl:attribute name="resp">-->
    <!--                        <xsl:value-of select="./@resp"/>-->
    <!--                    </xsl:attribute>-->
    <!--                </xsl:if>-->
    <!--            </xsl:if>-->
    <!--            <xsl:apply-templates/>-->
    <!--        </c>-->
    <!--    </xsl:template>-->
    <!-- END: c -->

    <!-- START: cit -->
    <xsl:template match="cei:cit">
        <cit>
            <xsl:call-template name="supForeignTestisCitQuote"/>
            <xsl:apply-templates/>
        </cit>
    </xsl:template>
    <!-- END: cit -->

    <!-- START: quote -->
    <xsl:template match="cei:quote">
        <quote>
            <xsl:call-template name="supForeignTestisCitQuote"/>
            <xsl:apply-templates/>
        </quote>
    </xsl:template>
    <!-- END: quote -->

    <!-- START: bibl -->
    <xsl:template match="cei:bibl">
        <bibl>
            <xsl:call-template name="bibl"/>
            <xsl:apply-templates/>
        </bibl>
    </xsl:template>
    <!-- END: bibl -->

    <!-- START: geogName -->
    <xsl:template match="cei:geogName">
        <geogName>
            <xsl:call-template name="placenameGeogName"/>
            <xsl:choose>
                <xsl:when test="./@reg">
                    <choice>
                        <reg>
                            <xsl:value-of select="./@reg"/>
                        </reg>
                        <orig>
                            <xsl:apply-templates/>
                        </orig>
                    </choice>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </geogName>
    </xsl:template>
    <!-- END: geogName -->

    <!-- START: note -->
    <xsl:template match="cei:note">
        <note>
            <xsl:call-template name="note"/>
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    <!-- END: note -->

    <!-- START: cei:sup -->
    <xsl:template match="cei:sup">
        <num type="ordinal">
            <xsl:call-template name="supForeignTestisCitQuote"/>
            <xsl:apply-templates/>
        </num>
    </xsl:template>
    <!-- END: cei:sup -->

    <!-- START: cei:ref -->
    <xsl:template match="cei:ref">
        <ref>
            <xsl:call-template name="refAttributes"/>
            <xsl:apply-templates/>
        </ref>
    </xsl:template>
    <!-- END: cei:ref -->
    <!-- END: global elements -->

    <!-- START: attribute templates -->

    <!-- START: attributes lem -->
    <xsl:template name="lem">

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

    </xsl:template>
    <!-- END: attributes lem -->

    <!-- START: attributes rdg -->
    <xsl:template name="rdg">

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
                <xsl:value-of select="translate(./@type, ' ', '')"/>
            </xsl:attribute>
        </xsl:if>

    </xsl:template>
    <!-- END: attributes rdg -->

    <!-- START: attributes graphic -->
    <xsl:template name="graphic">

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

    </xsl:template>
    <!-- END: attributes graphic -->

    <!-- START: attributes auth -->
    <xsl:template name="authAttb">

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

    </xsl:template>
    <!-- END: attributes auth -->

    <!-- START: attributes sealDescCond -->
    <xsl:template name="sealDescConc">

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

    </xsl:template>
    <!-- END: attributes sealDescCond -->

    <!-- START: attributes legend -->
    <xsl:template name="legend">

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

    </xsl:template>
    <!-- END: attributes legend -->

    <!-- START: attribute list index -->
    <xsl:template name="listIndex">

        <xsl:if test="./@indexName">
            <xsl:attribute name="indexName">
                <xsl:value-of select="./@indexName"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@lemma">
            <xsl:attribute name="n">
                <xsl:value-of select="./@lemma"/>
            </xsl:attribute>
        </xsl:if>

    </xsl:template>
    <!-- END: attribute list index -->

    <!-- START: attribute persname -->
    <xsl:template name="persname">

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
                <xsl:value-of select="translate(./@type, ' ', '')"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@key">
            <xsl:attribute name="key">
                <xsl:value-of select="./@key"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@existent">
            <xsl:attribute name="evidence">
                <xsl:value-of select="./@existent"/>
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

    </xsl:template>
    <!-- END: attribute persname -->

    <!-- START: attribute rolename -->
    <xsl:template name="rolename">

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
                <xsl:value-of select="translate(./@type, ' ', '')"/>
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

    </xsl:template>
    <!-- END: attribute rolename -->

    <!-- START: attribute orgname -->
    <xsl:template name="orgname">

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
                <xsl:value-of select="translate(./@type, ' ', '')"/>
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

    </xsl:template>
    <!-- END: attribute orgname -->

    <!-- START: attribute hi sealDim zone rights figDesc figure app foreign -->
    <xsl:template name="hiSealdimZoneRightsFigdescFigureAppForeign">

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

    </xsl:template>
    <!-- END: attribute hi sealDim zone rights figDesc figure app fireign -->


    <!-- START: attribute anchor -->
    <xsl:template name="anchor">

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

    </xsl:template>
    <!-- END: attribute anchor -->

    <!-- START: attribute date -->
    <xsl:template name="date">
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
    </xsl:template>
    <!-- END: attribute date -->


    <!-- START: attribute dateRange -->
    <xsl:template name="dateRange">
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
    </xsl:template>
    <!-- END: attribute dateRange -->

    <!-- START: attribute bibl -->
    <xsl:template name="bibl">

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
                <xsl:value-of select="translate(./@type, ' ', '')"/>
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

    </xsl:template>
    <!-- END: attribute bibl -->

    <!-- START: attribute issuer recipient -->
    <xsl:template name="issuerRecipient">

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
        <xsl:if test="./@lang">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="./@lang"/>
            </xsl:attribute>
            ng"
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

    </xsl:template>
    <!-- END: attribute issuer recipient -->

    <!-- START: attributes placeName geogName -->
    <xsl:template name="placenameGeogName">
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
            <xsl:attribute name="type">
                <xsl:value-of select="translate(./@type, ' ', '')"/>
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
    </xsl:template>
    <!-- END: attributes placeName geogName -->

    <!-- START: attributes note -->
    <xsl:template name="note">

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
        <xsl:if test="./@type">
            <xsl:attribute name="type">
                <xsl:value-of select="translate(./@type, ' ', '')"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@place">
            <xsl:attribute name="place">
                <xsl:value-of select="./@place"/>
            </xsl:attribute>
        </xsl:if>

    </xsl:template>
    <!-- END: attributes note -->

    <!-- START: template facs id n rend resp -->
    <xsl:template name="traditioForm">

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

    </xsl:template>
    <!-- END: template facs id n rend resp -->

    <!-- START: ref attributes-->
    <xsl:template name="refAttributes">

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
        <xsl:if test="./@key">
            <xsl:attribute name="cRef">
                <xsl:value-of select="./@key"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@target">
            <xsl:attribute name="target">
                <xsl:value-of select="./@target"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@type">
            <xsl:attribute name="subtype">
                <xsl:value-of select="translate(./@type, ' ', '')"/>
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

    </xsl:template>
    <!-- END: ref attributes-->

    <!-- START: attirbutes for sup foreign testis cit quote  -->
    <xsl:template name="supForeignTestisCitQuote">

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

    </xsl:template>
    <!-- END: -->

    <!-- START: attributes expand -->
    <xsl:template name="expan">

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
                <xsl:value-of select="translate(./@type, ' ', '')"/>
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

    </xsl:template>
    <!-- END: attributes expand -->

    <!-- START: attributes name -->
    <xsl:template name="name">

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
                <xsl:value-of select="translate(./@type, ' ', '')"/>
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

    </xsl:template>
    <!-- END: attributes name -->

    <!-- START: attributes char -->
    <xsl:template name="char">

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
                <xsl:value-of select="translate(./@type, ' ', '')"/>
            </xsl:attribute>
        </xsl:if>

    </xsl:template>
    <!-- END: attributes char -->

    <!-- START: attributes lb -->
    <xsl:template name="lb">

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

    </xsl:template>
    <!-- END: attributes lb -->

    <!-- START: attributes paragraph -->
    <xsl:template name="paragraph">

        <xsl:if test="./@type">
            <xsl:attribute name="n">
                <xsl:value-of select="translate(./@type, ' ', '')"/>
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
        <xsl:if test="./@n">
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
        </xsl:if>

    </xsl:template>
    <!-- END: attributes paragraph -->

    <!-- START: attributes measure dimensions -->
    <xsl:template name="measureDimensions">

        <xsl:if test="./@facs">
            <xsl:attribute name="facs">
                <xsl:value-of select="./@facs"/>
            </xsl:attribute>
        </xsl:if>
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
        <xsl:if test="./@type">
            <xsl:attribute name="type">
                <xsl:value-of select="translate(./@type, ' ', '')"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@unit">
            <xsl:attribute name="unit">
                <xsl:value-of select="./@unit"/>
            </xsl:attribute>
        </xsl:if>

    </xsl:template>
    <!-- END: attributes measure dimensions -->

    <xsl:template name="num">
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
                <xsl:value-of select="translate(./@type, ' ', '')"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@value">
            <xsl:attribute name="value">
                <xsl:value-of select="./@value"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@id">
            <xsl:attribute name="coressp">
                <xsl:value-of select="./@id"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@lang">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="./@lang"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- END: attribute templates -->


</xsl:stylesheet>
