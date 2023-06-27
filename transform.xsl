<?xml version="1.0" encoding="UTF-8"?>
<?xml-model
        href="SCHEMA" type="application/relax-ng-compact-syntax"
        ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns="http://www.tei-c.org/ns/1.0" xmlns:cei="http://www.monasterium.net/NS/cei"
                xmlns:bf="http://betterform.sourceforge.net/xforms" xmlns:xalan="http://xml.apache.org/xslt"
                xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns:csl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xs" version="3.0">

    <xsl:output method="xml" indent="yes" xalan:indent-amount="4" encoding="UTF-8"/>
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
            href="https://raw.githubusercontent.com/flamminger/CEI2TEI/develop/relax_ng_compact/tei_cei.rnc"
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
                            <xsl:apply-templates
                                    select="//*[local-name() = 'witnessOrig']//*[local-name() = 'physicalDesc']"
                                    mode="msDescPhysical"/>
                            <diploDesc>
                                <xsl:apply-templates select="//*[local-name() = 'issued']" mode="issuedDiploDesc"/>
                                <xsl:apply-templates
                                        select="//*[local-name() = 'witnessOrig']//*[local-name() = 'traditioForm']"
                                        mode="copyStatusDiploDesc"/>
                                <xsl:apply-templates
                                        select="//*[local-name() = 'witnessOrig']//*[local-name() = 'rubrum']"/>
                                <xsl:apply-templates select="//*[local-name() = 'witnessOrig']//*[local-name() = 'p']"/>
                                <xsl:apply-templates select="//*[local-name() = 'diplomaticAnalysis']"
                                                     mode="diplomaticAnalysis"/>
                                <xsl:apply-templates select="//*[local-name() = 'diplomaticAnalysis']"
                                                     mode="diplomaticAnalysisNota"/>
                                <xsl:apply-templates select="//*[local-name() = 'witnessOrig']"
                                                     mode="nota"/>
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
                    <xsl:apply-templates select="//*[local-name() = 'back']//*[local-name() = 'class']" mode="class"/>
                </profileDesc>
                <revisionDesc>
                    <change>
                        <date when-iso="{$atom_updated}">
                            <xsl:value-of select="substring($atom_updated, 1, 9)"/>
                        </date>
                    </change>
                </revisionDesc>
            </teiHeader>
            <xsl:if test="//*[local-name() = 'witnessOrig']//*[local-name() = 'figure'] != '' or //*[local-name() = 'witnessOrig']//*[local-name() = 'graphic']/@url">
                <facsimile>
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
                    <xsl:if test="//*[local-name() = 'tenor']/cei:head">
                        <head>
                            <xsl:apply-templates select="//*[local-name() = 'tenor']/cei:head" mode="head"/>
                        </head>
                    </xsl:if>
                    <div type="tenor">
                        <xsl:apply-templates select="//*[local-name() = 'tenor']"/>
                    </div>
                </body>
                <back>
                    <xsl:apply-templates select="//*[local-name() = 'back']" mode="indices"/>
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
            <xsl:apply-templates select="../cei:issuedPlace" mode="issuedDiploDesc"/>
        </issued>
    </xsl:template>
    <!-- END: diploDesc issued -->

    <!-- START: copyStatus -->
    <xsl:template match="cei:traditioForm" mode="copyStatusDiploDesc">
        <copyStatus>
            <xsl:call-template name="traditioForm"/>
            <xsl:value-of select="."/>
        </copyStatus>
    </xsl:template>

    <xsl:template match="cei:traditioFor" mode="copyStatusDiploDesc">
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

    <!-- START: issuedPlace -->
    <xsl:template match="cei:issuedPlace" mode="issuedDiploDesc">
        <xsl:call-template name="issuedPlace"/>
    </xsl:template>
    <!-- END: issuedPlace -->

    <!-- START: placeName -->
    <xsl:template match="cei:placeName" mode="issuedDiploDesc" name="issuedPlace">
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
        <xsl:choose>
            <xsl:when test="./parent::cei:witnessOrig">
                <xsl:call-template name="msIdentifier"/>
            </xsl:when>
            <xsl:when test="./parent::cei:witness">
                <xsl:call-template name="msIdentifier"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="contentIdent"/>
            </xsl:otherwise>
        </xsl:choose>

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
                </objectDesc>
                <xsl:if test="./cei:decoDesc">
                    <decoDesc>
                        <xsl:apply-templates select="./cei:decoDesc"/>
                    </decoDesc>
                </xsl:if>
                <xsl:if test="../cei:p[@type = 'handDesc']">
                    <handDesc>
                        <xsl:apply-templates select="../cei:p[@type = 'handDesc']"/>
                    </handDesc>
                </xsl:if>
            </physDesc>
        </xsl:if>
    </xsl:template>
    <!-- END: physicalDesc -->

    <!-- START: decoDesc -->
    <xsl:template match="cei:decoDesc/text()">
        <p>
            <xsl:value-of select="."/>
        </p>
    </xsl:template>
    <!-- END: decoDesc -->

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
            <xsl:when test="./text() and not(*)">
                <measure>
                    <xsl:call-template name="measureDimensions"/>
                    <xsl:value-of select="./text()"/>
                </measure>
            </xsl:when>
            <xsl:when test="normalize-space(.) != ''">
                <dimensions>
                    <xsl:call-template name="measureDimensions"/>
                    <xsl:apply-templates select="node()[text()]"/>
                </dimensions>
            </xsl:when>
            <!--            <xsl:otherwise>-->
            <!--                <dimensions>-->
            <!--                    <xsl:call-template name="measureDimensions"/>-->
            <!--                    <xsl:apply-templates select="node()[text()]"/>-->
            <!--                </dimensions>-->
            <!--            </xsl:otherwise>-->
        </xsl:choose>
    </xsl:template>
    <!-- END: dimensions -->

    <!-- START: height -->
    <xsl:template match="*[local-name() = 'height']">
        <height>
            <xsl:if test="./@unit">
                <xsl:attribute name="unit">
                    <xsl:value-of select="./@unit"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </height>
    </xsl:template>
    <!-- END: height -->

    <!-- START: width -->
    <xsl:template match="*[local-name() = 'width']">
        <width>
            <xsl:if test="./@unit">
                <xsl:attribute name="unit">
                    <xsl:value-of select="./@unit"/>
                </xsl:attribute>
            </xsl:if>
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

    <!-- START: measure -->
    <xsl:template match="cei:measure">
        <measure>
            <xsl:call-template name="measure"/>
            <xsl:apply-templates/>
        </measure>
    </xsl:template>
    <!-- END: measure -->

    <!-- START: p -->
    <xsl:template match="cei:p">
        <p>
            <xsl:call-template name="paragraph"/>
            <xsl:apply-templates/>
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
    <!--    <xsl:template name="pHanddesc" match="cei:p[@type = 'handDesc']" mode="pHanddesc">-->
    <!--        <p sameAs="handDesc">-->
    <!--            <xsl:value-of select="."/>-->
    <!--        </p>-->
    <!--    </xsl:template>-->
    <!-- END: handDesc > p -->

    <!-- START: rubrum -->
    <xsl:template match="cei:rubrum">
        <xsl:if test="normalize-space(.) != ''">
            <p sameAs="rubrum">
                <xsl:call-template name="rubrum"/>
                <xsl:apply-templates/>
            </p>
        </xsl:if>
    </xsl:template>
    <!-- END: rubrum -->


    <!-- START: cei:zone -->
    <xsl:template match="cei:figure/cei:zone">
        <surface>
            <xsl:call-template name="graphic"/>
            <xsl:apply-templates/>
        </surface>
    </xsl:template>
    <!-- END: cei:zone -->

    <!-- START: surfaceGrp graphic -->
    <xsl:template match="cei:figure" mode="facsimile">
        <xsl:choose>
            <xsl:when test="./cei:graphic and ./cei:zone">
                <surfaceGrp>
                    <xsl:apply-templates select="*[not(self::cei:graphic)]"/>
                    <figure>
                        <xsl:apply-templates select="cei:graphic"/>
                    </figure>
                </surfaceGrp>
            </xsl:when>
            <xsl:when test="./cei:graphic and ./cei:figDesc">
                    <xsl:apply-templates select="cei:graphic" mode="graphDesc"/>
            </xsl:when>
            <xsl:when test="./cei:zone">
                <surfaceGrp>
                    <xsl:apply-templates/>
                </surfaceGrp>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="figure"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- END: surfaceGrp graphic -->

    <!-- START: figDesc -->
    <xsl:template match="cei:figDesc" mode="figure">
        <desc>
            <xsl:apply-templates/>
        </desc>
    </xsl:template>
    <!-- END: figureDesc -->

    <!-- START: graphic -->
    <xsl:template match="cei:graphic" mode="figure">
        <xsl:if test="./@url != ''">
            <graphic url="{./@url}">
                <xsl:call-template name="graphic"/>
            </graphic>
        </xsl:if>
    </xsl:template>
    <!-- END: graphic -->

    <!-- START: graphic -->
    <xsl:template match="cei:graphic" mode="graphDesc">
        <xsl:if test="./@url != ''">
            <graphic url="{./@url}">
                <xsl:call-template name="graphic"/>
                <desc><xsl:value-of select="../cei:figDesc"/></desc>
            </graphic>
        </xsl:if>
    </xsl:template>
    <!-- END: graphic -->

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
            <xsl:call-template name="rolenameDistinct"/>
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
            <xsl:choose>
                <xsl:when test="./cei:archIdentifier">
                    <xsl:apply-templates select="cei:archIdentifier" mode="witness"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </witness>
    </xsl:template>
    <!-- END: witness -->

    <!-- START: witness archIdentifier wrap -->
    <xsl:template match="cei:archIdentifier" mode="witness">
        <msDesc>
            <xsl:call-template name="msIdentifier"/>
            <xsl:apply-templates select="../cei:physicalDesc" mode="msDescPhysical"/>
            <xsl:if test="..//cei:traditioForm or ..//*[local-name() = 'rubrum'] or ..//*[local-name() = 'p']">
                <diploDesc>
                    <xsl:apply-templates
                            select="..//cei:traditioForm"
                            mode="copyStatusDiploDesc"/>
                    <xsl:apply-templates select="..//*[local-name() = 'rubrum']"/>
                    <xsl:apply-templates select="..//*[local-name() = 'p']"/>
                </diploDesc>
            </xsl:if>
            <xsl:if test="..//*[local-name() = 'auth']">
                <xsl:apply-templates
                        select="..//*[local-name() = 'auth']"
                        mode="auth"/>
            </xsl:if>
        </msDesc>
    </xsl:template>
    <!-- END: witness archIdentifier wrap-->

    <!-- START: witness archIdentifier -->
    <xsl:template name="msIdentifier">
        <xsl:if test="not(preceding-sibling::cei:archIdentifier)">
            <msIdentifier>
                <xsl:call-template name="msIdentifierP1"/>
                <xsl:if test="./following-sibling::cei:archIdentifier">
                    <xsl:apply-templates select="./following-sibling::cei:archIdentifier" mode="secondArch"/>
                </xsl:if>
                <xsl:call-template name="msIdentifierP2"/>
            </msIdentifier>
        </xsl:if>
    </xsl:template>
    <!-- END: witness archIdentifier -->

    <!-- START: secondArchId -->
    <xsl:template match="cei:archIdentifier" mode="secondArch">
        <altIdentifier type="secondLoc">
            <xsl:call-template name="msIdentifierP1"/>
            <xsl:call-template name="msIdentifierP2"/>
        </altIdentifier>
    </xsl:template>
    <!-- END: secondArchId -->

    <!-- START: msIdentifier first section
     to allow for multiple cei:archIdentifier elements -->
    <xsl:template name="msIdentifierP1">
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
        <xsl:choose>
            <xsl:when test="./cei:arch">
                <institution>
                    <xsl:value-of select="./cei:arch"/>
                </institution>
            </xsl:when>
            <xsl:when test="text()[normalize-space(.) != '']">
                <institution>
                    <xsl:value-of select="text()[normalize-space(.) != '']"/>
                </institution>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="./cei:repository">
            <repository>
                <xsl:value-of select="./cei:repository"/>
            </repository>
        </xsl:if>
        <xsl:if test="./cei:archFond">
            <collection>
                <xsl:value-of select="./cei:archFond"/>
            </collection>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="./cei:idno">
                <idno>
                    <xsl:value-of select="./cei:idno"/>
                </idno>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//*[local-name() = 'body']/*[local-name() = 'idno']"
                                     mode="msCharterId"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="./cei:altIdentifier">
            <altIdentifier>
                <xsl:if test="./cei:altIdentifier/@type">
                    <xsl:attribute name="type">
                        <xsl:value-of select="./cei:altIdentifier/@type"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:call-template name="altIdentifier"/>
            </altIdentifier>
        </xsl:if>
    </xsl:template>
    <!-- END: msIdentifier first section -->

    <!-- START: msIdentifier second section
     to allow for multiple cei:archIdentifier elements -->
    <xsl:template name="msIdentifierP2">
        <xsl:if test="./cei:scope">
            <note type="structural">
                <xsl:value-of select="./cei:scope"/>
            </note>
        </xsl:if>
    </xsl:template>
    <!-- END: msIdentifier second section -->

    <!-- START: altIdentifier -->
    <xsl:template name="altIdentifier">
        <xsl:if test="./cei:altIdentifier/cei:country">
            <country>
                <xsl:value-of select="./cei:altIdentifier/cei:country"/>
            </country>
        </xsl:if>
        <xsl:if test="./cei:altIdentifier/cei:region">
            <region>
                <xsl:value-of select="./cei:altIdentifier/cei:region"/>
            </region>
        </xsl:if>
        <xsl:if test="./cei:altIdentifier/cei:settlement">
            <settlement>
                <xsl:value-of select="./cei:altIdentifier/cei:settlement"/>
            </settlement>
        </xsl:if>
        <xsl:if test="./cei:altIdentifier/cei:arch">
            <institution>
                <xsl:value-of select="./cei:altIdentifier/cei:arch"/>
            </institution>
        </xsl:if>
        <xsl:if test="./cei:altIdentifier/cei:repository">
            <repository>
                <xsl:value-of select="./cei:altIdentifier/cei:repository"/>
            </repository>
        </xsl:if>
        <xsl:if test="./cei:altIdentifier/cei:archFond">
            <collection>
                <xsl:value-of select="./cei:altIdentifier/cei:archFond"/>
            </collection>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="./cei:altIdentifier/cei:idno">
                <idno>
                    <xsl:call-template name="type"/>
                    <xsl:value-of select="./cei:altIdentifier/cei:idno"/>
                </idno>
            </xsl:when>
            <xsl:when test="./cei:altIdentifier/cei:idno/@id">
                <idno>
                    <xsl:value-of select="./cei:altIdentifier/cei:idno/@id"/>
                </idno>
            </xsl:when>
            <xsl:otherwise>
                <idno>
                    <xsl:value-of select="./cei:altIdentifier/text()"/>
                </idno>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- END: altIdentifier -->


    <!-- START: witness archIdentifier -->
    <xsl:template name="contentIdent">
        <address>
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
            <xsl:if test="./cei:arch">
                <orgName n="arch">
                    <xsl:value-of select="./cei:arch"/>
                </orgName>
            </xsl:if>
            <xsl:if test="./cei:repository">
                <orgName n="repository">
                    <xsl:value-of select="./cei:repository"/>
                </orgName>
            </xsl:if>
            <xsl:if test="./cei:archFond">
                <name n="collection">
                    <xsl:value-of select="./cei:archFond"/>
                </name>
            </xsl:if>
            <xsl:if test="./cei:idno">
                <idno>
                    <xsl:value-of select="./cei:idno"/>
                </idno>
            </xsl:if>
            <xsl:if test="./cei:altIdentifier/cei:idno">
                <idno n="alt">
                    <xsl:value-of select="./cei:archIdentifier/cei:idno"/>
                </idno>
            </xsl:if>
            <xsl:if test="./cei:scope">
                <note type="structural">
                    <xsl:value-of select="./cei:scope"/>
                </note>
            </xsl:if>
        </address>
    </xsl:template>
    <!-- END: witness archIdentifier -->

    <!-- START: witness figure -->
    <xsl:template match="cei:figure" mode="witness">
        <xsl:if test="./cei:figure != ''">
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
        </xsl:if>
    </xsl:template>
    <!-- END: witness figure -->
    <!-- END: witnessList -->

    <!--     START: tenor -->
    <xsl:template match="cei:tenor">
        <xsl:choose>
            <xsl:when test="count(cei:p) > 0">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="cei:pTenor">
        <xsl:apply-templates/>
    </xsl:template>

    <!--     START: head -->
    <!-- Skip in tenor-->
    <xsl:template match="cei:head">
    </xsl:template>

    <xsl:template match="cei:head" mode="head">
        <xsl:apply-templates/>
    </xsl:template>

    <!--     END: tenor -->

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
        <xsl:if test="normalize-space(.) !=''">
            <choice>
                <xsl:choose>
                    <xsl:when test="./@abbr">
                        <abbr>
                            <xsl:value-of select="./@abbr"/>
                        </abbr>
                    </xsl:when>
                    <xsl:when test="./cei:abbr">
                        <xsl:apply-templates select="./cei:abbr"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="./cei:ex">
                        <xsl:apply-templates select="./cei:ex"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <expan>
                            <xsl:call-template name="expan"/>
                            <xsl:value-of select="."/>
                        </expan>
                    </xsl:otherwise>
                </xsl:choose>
            </choice>
        </xsl:if>
    </xsl:template>
    <!-- END: expan -->

    <!-- START: cei:ex -->
    <xsl:template match="cei:ex">
        <ex>
            <xsl:if test="./cei:abbr/@type">
                <xsl:attribute name="type">
                    <xsl:value-of select="./cei:abbr/@type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </ex>
    </xsl:template>
    <!-- END: cei:ex -->

    <!-- START: cei:abbr -->
    <xsl:template match="cei:abbr">
        <abbr>
            <xsl:if test="./@type">
                <xsl:attribute name="type">
                    <xsl:value-of select="./@type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </abbr>
    </xsl:template>
    <!-- END: cei:abbr -->

    <!-- START: app -->
    <xsl:template match="cei:app">
        <app>
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureApp"/>
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
                        <xsl:value-of select="normalize-space(./@type)"/>
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
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureApp"/>
            <xsl:apply-templates/>
        </figure>
    </xsl:template>
    <!-- END: figure -->

    <!-- START: figDesc -->
    <xsl:template match="cei:figDesc">
        <desc>
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureApp"/>
            <xsl:apply-templates/>
        </desc>
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
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureApp"/>
            <xsl:apply-templates/>
        </byline>
    </xsl:template>
    <!-- END: byline / rights -->

    <!-- START: zone -->
    <xsl:template match="cei:zone">
        <note sameAs="zone">
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureApp"/>
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    <!-- END: zone -->

    <!--START: AUTH -->
    <xsl:template match="cei:auth" mode="auth">
        <authDesc>
            <xsl:call-template name="authAttb"/>
            <xsl:apply-templates/>
            <!--            <xsl:apply-templates select="//*[local-name() = 'seal']" mode="auth"/>-->
        </authDesc>
    </xsl:template>
    <!-- START: notariusDesc -->
    <xsl:template match="cei:notariusDesc">
        <xsl:if test="normalize-space(.) != ''">
            <p copyOf="notariusDesc">
                <xsl:apply-templates/>
            </p>
        </xsl:if>
    </xsl:template>
    <!-- END: notariusDesc -->

    <!-- START: notariusDesc -->
    <xsl:template match="cei:notariusSub">
        <xsl:if test="normalize-space(.) != ''">
            <span copyOf="notariusSub">
                <xsl:apply-templates/>
            </span>
        </xsl:if>
    </xsl:template>
    <!-- END: notariusDesc -->

    <!-- START: sealDesc -->
    <xsl:template match="cei:sealDesc">
        <xsl:if test="normalize-space(.) != ''">
            <decoNote>
                <xsl:call-template name="sealDescConc"/>
                <xsl:choose>
                    <xsl:when test="./*">
                        <xsl:apply-templates select="*[not(self::cei:seal)]"/>
                    </xsl:when>
                    <xsl:when test="./text()">
                        <p>
                            <xsl:value-of select="."/>
                        </p>
                    </xsl:when>
                </xsl:choose>
            </decoNote>
            <xsl:apply-templates select="cei:seal"/>
        </xsl:if>
    </xsl:template>
    <!-- END: sealDesc -->

    <!-- START: seal -->
    <xsl:template match="cei:seal">
        <xsl:if test="normalize-space(.) != ''">
            <seal>
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
                <xsl:choose>
                    <xsl:when test="./node() and normalize-space(.) != ''">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <p>
                            <xsl:apply-templates/>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>

            </seal>
        </xsl:if>
    </xsl:template>
    <!-- END: seal -->

    <!-- START: sealCondition -->
    <xsl:template match="cei:sealCondition">
        <condition>
            <xsl:call-template name="sealDescConc"/>
            <xsl:apply-templates/>
        </condition>
    </xsl:template>
    <!-- END: sealCondition -->

    <!-- START: sealDimensions -->
    <xsl:template match="cei:sealDimensions">
        <measure>
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureApp"/>
            <xsl:apply-templates/>
        </measure>
    </xsl:template>
    <!-- END: sealDimensions -->

    <!-- START: sealMaterial -->
    <xsl:template match="cei:sealMaterial">
        <material>
            <xsl:apply-templates/>
        </material>
    </xsl:template>
    <!-- END: sealMaterial -->

    <!-- START: seal legend -->
    <xsl:template match="cei:legend">
        <legend>
            <xsl:call-template name="legend"/>
            <xsl:apply-templates/>
        </legend>

    </xsl:template>
    <!-- END: seal legend -->

    <!-- START: sigillant -->
    <xsl:template match="cei:sigillant">
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
        <xsl:if test="normalize-space(.) != ''">
            <listBibl>
                <xsl:apply-templates mode="sourceRegest"/>
            </listBibl>
        </xsl:if>
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

    <!-- START: diplomaticAnalysis listBiblRegest -->
    <xsl:template match="cei:diplomaticAnalysis/cei:listBiblRegest" mode="diplomaticAnalysis">
        <xsl:if test="normalize-space(.) != ''">
            <additional n="regest">
                <listBibl>
                    <xsl:apply-templates/>
                </listBibl>
            </additional>
        </xsl:if>
    </xsl:template>
    <!-- END: diplomaticAnalysis listBiblRegest -->

    <!-- START: diplomaticAnalysis listBiblFaksimile -->
    <xsl:template match="cei:diplomaticAnalysis/cei:listBiblFaksimile" mode="diplomaticAnalysis">
        <xsl:if test="normalize-space(.) != ''">
            <additional n="facs">
                <listBibl>
                    <xsl:apply-templates/>
                </listBibl>
            </additional>
        </xsl:if>
    </xsl:template>
    <!-- END: diplomaticAnalysis listBiblFaksimile -->

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

    <!-- START: diploDesc bibl -->
    <xsl:template match="cei:diplomaticAnalysis/cei:listBibl" mode="diplomaticAnalysis">
        <xsl:if test="normalize-space(.) != ''">
            <listBibl type="analysis">
                <xsl:apply-templates select="cei:bibl"/>
            </listBibl>
        </xsl:if>
    </xsl:template>
    <!-- END: diploDesc bibl -->

    <!-- START: diplomaticAnalysis p -->
    <xsl:template match="cei:p" mode="diplomaticAnalysis">
        <xsl:if test="normalize-space(.) != ''">
            <p>
                <xsl:apply-templates/>
            </p>
        </xsl:if>
    </xsl:template>
    <!-- END: diplomaticAnalysis p -->

    <!-- START: diplomaticAnalysis text content -->
    <xsl:template match="cei:diplomaticAnalysis/text()" mode="diplomaticAnalysis">
        <xsl:if test="normalize-space(.) != ''">
            <ab>
                <xsl:value-of select="."/>
            </ab>
        </xsl:if>
    </xsl:template>
    <!-- END: diplomaticAnalysis text content -->

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

    <!-- START: diplomaticAnalysis exclude nota -->
    <xsl:template match="cei:nota" mode="diplomaticAnalysis">
        <!-- Do nothing -->
    </xsl:template>
    <!-- END: diplomaticAnalysis exclude nota -->


    <!-- START: back -->

    <!-- START: divNotes -->
    <xsl:template match="cei:divNotes" mode="back">
        <xsl:if test="normalize-space(.) != ''">
            <div type="divNotes">
                <xsl:apply-templates/>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- END: divNotes -->

    <!-- START: deprecated notes -->
    <xsl:template match="cei:deprecatedNote" mode="back">
        <xsl:if test="normalize-space(.) != ''">
            <div type="deprecatedNote">
                <xsl:apply-templates/>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- END: deprecated notes -->

    <!-- Ignore text nodes and attributes in back mode -->
    <xsl:template match="text() | @*" mode="back">
        <!-- Do nothing in 'back' mode -->
    </xsl:template>

    <!--     START: back lists-->
    <!-- START: back placeName -->

    <xsl:template match="cei:back" mode="indices">
        <xsl:variable name="placeNames" select="./cei:placeName[normalize-space(.) != '']"/>
        <xsl:variable name="persNames" select="./cei:persName[normalize-space(.) != '']"/>
        <xsl:variable name="terms" select="./cei:index[normalize-space(.) != '']"/>
        <xsl:if test="$placeNames">
            <listPlace>
                <xsl:apply-templates select="$placeNames" mode="indices"/>
            </listPlace>
        </xsl:if>
        <xsl:if test="$persNames">
            <listPerson>
                <xsl:apply-templates select="$persNames" mode="indices"/>
            </listPerson>
        </xsl:if>
        <xsl:if test="$terms">
            <list>
                <xsl:apply-templates select="$terms" mode="indices"/>
            </list>
        </xsl:if>
    </xsl:template>

    <!-- START: placeName item -->
    <xsl:template match="cei:placeName" mode="indices">
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
    </xsl:template>
    <!--     END: placeName item -->

    <!-- START: persName item -->
    <xsl:template match="cei:persName" mode="indices">
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
    </xsl:template>
    <!-- END: persName item -->

    <!-- START: index item -->
    <xsl:template match="cei:index" mode="indices">
        <item>
            <index>
                <xsl:call-template name="listIndex"/>
                <term>
                    <xsl:if test="./@type">
                        <xsl:attribute name="next">
                            <xsl:value-of select="./@type"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(.)"/>
                </term>
            </index>
        </item>
    </xsl:template>
    <!-- END: index item -->

    <xsl:template match="cei:class" mode="class">
        <xsl:if test="normalize-space(.) != ''">
            <textClass>
                <keywords>
                    <term>
                        <xsl:choose>
                            <xsl:when test="./@type">
                                <xsl:value-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </term>
                </keywords>
            </textClass>
        </xsl:if>
    </xsl:template>


    <!-- END: back -->

    <!-- START: cei:text attributes -->
    <xsl:template match="cei:text" mode="textAttributes">
        <xsl:if test="./@id | ./@b_name | ./@n">
            <settingDesc>
                <setting>
                    <xsl:if test="normalize-space(./@id) != ''">
                        <xsl:attribute name="corresp">
                            <xsl:value-of select="./@id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="normalize-space(./@b_name) != ''">
                        <name type="bestand">
                            <xsl:value-of select="./@b_name"/>
                        </name>
                    </xsl:if>
                    <xsl:if test="normalize-space(./@n) != ''">
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

    <!-- START: index -->
    <xsl:template match="cei:index">
        <xsl:choose>
            <xsl:when test="parent::cei:p">
                <index>
                    <xsl:call-template name="listIndex"/>
                    <term>
                        <xsl:if test="./@type">
                            <xsl:attribute name="next">
                                <xsl:value-of select="./@type"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(.)"/>
                    </term>
                </index>
            </xsl:when>
            <xsl:when test="parent::cei:abstract">
                <index>
                    <xsl:call-template name="listIndex"/>
                    <term>
                        <xsl:if test="./@type">
                            <xsl:attribute name="next">
                                <xsl:value-of select="./@type"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(.)"/>
                    </term>
                </index>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <index>
                        <xsl:call-template name="listIndex"/>
                        <term>
                            <xsl:if test="./@type">
                                <xsl:attribute name="next">
                                    <xsl:value-of select="./@type"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="normalize-space(.)"/>
                        </term>
                    </index>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- END: index -->

    <!-- START: metamark -->
    <xsl:template match="cei:metamark">
        <metamark>
            <xsl:apply-templates/>
        </metamark>
    </xsl:template>
    <!-- END: metamark -->

    <!-- START: handShift -->
    <xsl:template match="cei:handShift">
        <handShift>
            <xsl:call-template name="handShift"/>
            <xsl:apply-templates/>
        </handShift>
    </xsl:template>
    <!-- START: cei:handShift -->

    <!-- START: cei:add -->
    <xsl:template match="cei:add">
        <add>
            <xsl:call-template name="pictAdd"/>
            <xsl:apply-templates/>
        </add>
    </xsl:template>
    <!-- END: cei:add -->

    <!-- START: cei:setPhrase -->
    <xsl:template match="cei:setPhrase">
        <distinct>
            <xsl:apply-templates/>
        </distinct>
    </xsl:template>
    <!-- END: cei:setPhrase -->

    <!-- START: cei:subscriptio -->
    <xsl:template match="cei:subscriptio">
        <span type="subscriptio">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:subscriptio -->

    <!-- START: cei:sanctio -->
    <xsl:template match="cei:sanctio">
        <span type="sanctio">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:sanctio -->

    <!-- START: cei:rogatio -->
    <xsl:template match="cei:rogatio">
        <span type="rogatio">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:rogatio -->

    <!-- START: cei:publicatio -->
    <xsl:template match="cei:publicatio">
        <span type="publicatio">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:publicatio -->

    <!-- START: cei:narratio -->
    <xsl:template match="cei:narratio">
        <span type="narratio">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:narratio -->

    <!-- START: cei:invocatio -->
    <xsl:template match="cei:invocatio">
        <span type="invocatio">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:invocatio -->

    <!-- START: cei:intitulatio -->
    <xsl:template match="cei:intitulatio">
        <span type="intitulatio">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:intitulatio -->

    <!-- START: cei:intercessio -->
    <xsl:template match="cei:intercessio">
        <span type="intercessio">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:intercessio -->

    <!-- START: cei:inscriptio -->
    <xsl:template match="cei:inscriptio">
        <span type="inscriptio">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:inscriptio -->

    <!-- START: cei:datatio -->
    <xsl:template match="cei:datatio">
        <span type="datatio">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:datatio -->

    <!-- START: cei:dispositio -->
    <xsl:template match="cei:dispositio">
        <span type="dispositio">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:dispositio -->

    <!-- START: cei:corroboratio -->
    <xsl:template match="cei:corroboratio">
        <span type="corroboratio">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:corroboratio -->

    <!-- START: cei:arenga -->
    <xsl:template match="cei:arenga">
        <span type="arenga">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- END: cei:arenga -->

    <!-- START: elongata -->
    <xsl:template match="Elongata">
        <p style="elongata">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <!-- END: elongata -->

    <!-- START: cei:dateR -->
    <xsl:template match="cei:dateR">
        <origDate>
            <xsl:call-template name="date"/>
            <xsl:value-of select="."/>
        </origDate>
    </xsl:template>
    <!-- END: cei:dateR -->

    <!-- START: cei:pict -->
    <xsl:template match="cei:pict">
        <xsl:if test="normalize-space(.) != ''">
            <figure>
                <xsl:if test="./@URL">
                    <graphic url="{./@URL}"/>
                </xsl:if>
                <desc>
                    <xsl:call-template name="pictAdd"/>
                    <xsl:value-of select="."/>
                </desc>
            </figure>
        </xsl:if>
    </xsl:template>
    <!-- END: cei:pict -->

    <!-- START: cei:scope -->
    <xsl:template match="cei:scope">
        <xsl:choose>
            <xsl:when test="./parent::cei:bibl">
                <biblScope>
                    <xsl:call-template name="imprintAuthor"/>
                    <xsl:apply-templates/>
                </biblScope>
            </xsl:when>
            <xsl:when test="./parent::cei:imprint">
                <biblScope>
                    <xsl:call-template name="imprintAuthor"/>
                    <xsl:apply-templates/>
                </biblScope>
            </xsl:when>
            <xsl:otherwise>
                <locus>
                    <xsl:call-template name="imprintAuthor"/>
                    <xsl:apply-templates/>
                </locus>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- END: cei:scope -->

    <!-- START: cei:surname -->
    <xsl:template match="cei:surname">
        <surname>
            <xsl:call-template name="name"/>
            <xsl:apply-templates/>
        </surname>
    </xsl:template>
    <!-- END: cei:surname -->

    <!-- START: cei:forename -->
    <xsl:template match="cei:forename">
        <forename>
            <xsl:call-template name="name"/>
            <xsl:apply-templates/>
        </forename>
    </xsl:template>
    <!-- END: cei:forename -->

    <!-- START: cei:publisher -->
    <xsl:template match="cei:publisher">
        <publisher>
            <xsl:apply-templates/>
        </publisher>
    </xsl:template>
    <!-- END: cei:publisher -->

    <!-- START: cei:pubPlace -->
    <xsl:template match="cei:pubPlace">
        <pubPlace>
            <xsl:call-template name="imprintAuthor"/>
            <xsl:apply-templates/>
        </pubPlace>
    </xsl:template>
    <!-- END: cei:pubPlace -->

    <!-- START: cei:title -->
    <xsl:template match="cei:title">
        <title>
            <xsl:call-template name="imprintAuthor"/>
            <xsl:apply-templates/>
        </title>
    </xsl:template>
    <!-- END: cei:title -->

    <!-- START: cei:imprint -->
    <xsl:template match="cei:imprint">
        <imprint>
            <xsl:call-template name="imprintAuthor"/>
            <xsl:apply-templates/>
        </imprint>
    </xsl:template>
    <!-- END: cei:imprint -->

    <!-- START: cei:author -->
    <xsl:template match="cei:author">
        <author>
            <xsl:call-template name="imprintAuthor"/>
            <xsl:apply-templates/>
        </author>
    </xsl:template>
    <!-- END: cei:author -->

    <!-- START: cei:corr -->
    <xsl:template match="cei:corr">
        <corr>
            <xsl:call-template name="corr"/>
            <xsl:apply-templates/>
        </corr>
    </xsl:template>
    <!-- END: cei:corr -->

    <!-- START: cei:damage -->
    <xsl:template match="cei:damage">
        <damage>
            <xsl:call-template name="damage"/>
            <xsl:apply-templates/>
        </damage>
    </xsl:template>
    <!-- END: cei:damage -->

    <!-- START: cei:nota -->
    <xsl:template match="cei:witnessOrig" mode="nota">
        <xsl:variable name="nota" select=".//cei:nota[normalize-space(.) != '']"/>
        <xsl:if test="$nota">
            <history copyOf="nota">
                <summary>
                    <xsl:apply-templates select="$nota"/>
                </summary>
            </history>
        </xsl:if>
    </xsl:template>

    <xsl:template match="cei:diplomaticAnalysis" mode="diplomaticAnalysisNota">
        <xsl:variable name="nota" select="./cei:nota[normalize-space(.) != '']"/>
        <xsl:if test="$nota">
            <history copyOf="nota">
                <summary>
                    <xsl:apply-templates select="$nota"/>
                </summary>
            </history>
        </xsl:if>
    </xsl:template>

    <xsl:template match="cei:nota">
        <p>
            <xsl:call-template name="nota"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- END: cei:nota -->

    <!-- START: del -->
    <xsl:template match="cei:del">
        <del>
            <xsl:apply-templates/>
        </del>
    </xsl:template>
    <!-- START: del -->

    <!-- START: unclear -->
    <xsl:template match="cei:unclear">
        <unclear>
            <xsl:call-template name="unclear"/>
            <xsl:apply-templates/>
        </unclear>
    </xsl:template>
    <!-- END: unclear -->

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
            <xsl:call-template name="rolenameDistinct"/>
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
            <xsl:call-template name="hiSealdimZoneRightsFigdescFigureApp"/>
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
        <date>
            <xsl:call-template name="date"/>
            <xsl:apply-templates/>
        </date>
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
    <!--                        <xsl:value-of select="normalize-space(./@type)"/>-->
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
        <xsl:choose>
            <xsl:when test="./cei:imprint and normalize-space(.) != ''">
                <biblStruct>
                    <xsl:call-template name="bibl"/>
                    <monogr>
                        <xsl:apply-templates select="cei:author"/>
                        <xsl:apply-templates select="cei:title"/>
                        <xsl:apply-templates select="cei:note"/>
                        <xsl:apply-templates select="cei:imprint"/>
                        <xsl:apply-templates select="cei:scope"/>
                    </monogr>
                </biblStruct>
            </xsl:when>
            <xsl:when test="normalize-space(.) != ''">
                <bibl>
                    <xsl:call-template name="bibl"/>
                    <xsl:apply-templates/>
                </bibl>
            </xsl:when>
        </xsl:choose>
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

    <!-- START: supplied -->
    <xsl:template match="cei:supplied">
        <supplied>
            <xsl:call-template name="supplied"/>
            <xsl:apply-templates/>
        </supplied>
    </xsl:template>
    <!-- END: supplied -->

    <!-- START: surplus -->
    <xsl:template match="cei:surplus">
        <surplus>
            <xsl:apply-templates/>
        </surplus>
    </xsl:template>
    <!-- END: surplus -->

    <!-- START: space -->
    <xsl:template match="cei:space">
        <space>
            <xsl:call-template name="space"/>
            <xsl:apply-templates/>
        </space>

    </xsl:template>
    <!-- END: space -->

    <!-- START: cei:addName -->
    <xsl:template match="cei:addName">
        <addName>
            <xsl:apply-templates/>
        </addName>
    </xsl:template>
    <!-- END: cei:addName -->

    <!-- START: cei:mod -->
    <xsl:template match="cei:mod">
        <expan>
            <xsl:if test="./@type">
                <xsl:attribute name="rendition">
                    <xsl:value-of select="./@type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </expan>
    </xsl:template>
    <!-- END: cei:mod -->

    <!-- START: cei:sic -->
    <xsl:template match="cei:sic">
        <sic>
            <xsl:if test="./@corr">
                <xsl:attribute name="rendition">
                    <xsl:value-of select="./@corr"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </sic>
    </xsl:template>
    <!-- END: cei:sic -->

    <!-- START: cei:a -->
    <xsl:template match="cei:a">
        <ref>
            <xsl:call-template name="refAttributes"/>
            <xsl:apply-templates/>
        </ref>
    </xsl:template>
    <!-- END: cei:a -->

    <!-- END: global elements -->

    <!-- START: global attribute templates -->

    <!-- START: type check -->
    <xsl:template name="type">
        <xsl:if test="./cei:idno/@type != ''">
            <xsl:attribute name="type">
                <xsl:value-of select="./cei:idno/@type"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- START: type check -->

    <!-- START: handShift attributes -->
    <xsl:template name="handShift">
        <xsl:if test="./@hand">
            <xsl:attribute name="scribe">
                <xsl:value-of select="normalize-space(./@hand)"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@certainty">
            <xsl:attribute name="cert">
                <xsl:value-of select="./@certainty"/>
            </xsl:attribute>
        </xsl:if>
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
    <!-- START: handShift attributes -->

    <!-- START: supplied attributes -->
    <xsl:template name="supplied">
        <xsl:if test="./@certainty">
            <xsl:attribute name="cert">
                <xsl:value-of select="./@certainty"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@reason">
            <xsl:attribute name="reason">
                <xsl:value-of select="./@reason"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@source">
            <xsl:attribute name="source">
                <xsl:value-of select="./@source"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@facs">
            <xsl:attribute name="facs">
                <xsl:value-of select="./@facs"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@hand">
            <xsl:attribute name="style">
                <xsl:value-of select="./@hand"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@n">
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@id">
            <xsl:attribute name="corresp">
                <xsl:value-of select="./@id"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@type">
            <xsl:attribute name="unit">
                <xsl:value-of select="./@type"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@resp">
            <xsl:attribute name="resp">
                <xsl:value-of select="./@resp"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@rend">
            <xsl:attribute name="rend">
                <xsl:value-of select="./@rend"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@lang">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="@lang"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- END: attribute supplied -->

    <!-- START: attribute space -->
    <xsl:template name="space">
        <xsl:if test="./@certainty">
            <xsl:attribute name="cert">
                <xsl:value-of select="./@certainty"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@dim">
            <xsl:attribute name="dim">
                <xsl:value-of select="./@dim"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@extent">
            <xsl:attribute name="extent">
                <xsl:value-of select="./@extent"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@facs">
            <xsl:attribute name="facs">
                <xsl:value-of select="./@facs"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@hand">
            <xsl:attribute name="source">
                <xsl:value-of select="./@hand"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@n">
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@id">
            <xsl:attribute name="corresp">
                <xsl:value-of select="./@id"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@type">
            <xsl:attribute name="type">
                <xsl:value-of select="./@type"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@resp">
            <xsl:attribute name="resp">
                <xsl:value-of select="./@resp"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@rend">
            <xsl:attribute name="rend">
                <xsl:value-of select="./@rend"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- END: attribute space -->

    <!-- START: attribute pict -->
    <xsl:template name="pictAdd">
        <xsl:if test="./@certainty">
            <xsl:attribute name="cert">
                <xsl:value-of select="./@certainty"/>
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
        <xsl:if test="./@hand">
            <xsl:attribute name="change">
                <xsl:value-of select="./@hand"/>
            </xsl:attribute>
        </xsl:if>
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
        <xsl:if test="./@type">
            <xsl:attribute name="n">
                <xsl:value-of select="./@type"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- END: attribute pict -->

    <!-- START: attribute author -->
    <xsl:template name="imprintAuthor">
        <xsl:if test="./@resp">
            <xsl:attribute name="resp">
                <xsl:value-of select="./@resp"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@rend">
            <xsl:attribute name="rend">
                <xsl:value-of select="./@rend"/>
            </xsl:attribute>
        </xsl:if>
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
        <xsl:if test="./@n">
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- END: attribute author -->

    <!-- START: attribute corr -->
    <xsl:template name="corr">
        <xsl:if test="./@resp">
            <xsl:attribute name="resp">
                <xsl:value-of select="./@resp"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@rend">
            <xsl:attribute name="rend">
                <xsl:value-of select="./@rend"/>
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
        <xsl:if test="./@hand">
            <xsl:attribute name="rendition">
                <xsl:value-of select="./@hand"/>
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
        <xsl:if test="./@n">
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@sic">
            <xsl:attribute name="source">
                <xsl:value-of select="./@sic"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@type">
            <xsl:attribute name="type">
                <xsl:value-of select="./@type"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- END: attribute corr -->

    <!-- START: attribute damage -->
    <xsl:template name="damage">
        <xsl:if test="./@agent and normalize-space(./@agent) != ''">
            <xsl:attribute name="agent">
                <xsl:value-of select="normalize-space(./@agent)"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@extent">
            <xsl:attribute name="extent">
                <xsl:value-of select="normalize-space(./@extent)"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@resp">
            <xsl:attribute name="resp">
                <xsl:value-of select="./@resp"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@rend">
            <xsl:attribute name="rend">
                <xsl:value-of select="./@rend"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@degree">
            <xsl:attribute name="degree">
                <xsl:value-of select="./@degree"/>
            </xsl:attribute>
        </xsl:if>
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
        <xsl:if test="./@n">
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- END: attribute damage -->

    <!-- START: attribute nota -->
    <xsl:template name="nota">
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
            <xsl:attribute name="prev">
                <xsl:value-of select="./@type"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@position">
            <xsl:attribute name="rendition">
                <xsl:value-of select="./@position"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@resp">
            <xsl:attribute name="resp">
                <xsl:value-of select="./@resp"/>
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
    </xsl:template>
    <!-- END: attribute nota -->

    <!-- START: attribute rubrum -->
    <xsl:template name="rubrum">
        <xsl:if test="./@type">
            <xsl:attribute name="n">
                <xsl:value-of select="./@type"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@position">
            <xsl:attribute name="style">
                <xsl:value-of select="./@position"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@facs">
            <xsl:attribute name="facs">
                <xsl:value-of select="./@facs"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- END: attribute rubrum -->

    <!-- START: attrubte unclear -->
    <xsl:template name="unclear">
        <xsl:if test="./@agent">
            <xsl:attribute name="agent">
                <xsl:value-of select="./@agent"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@certainty">
            <xsl:attribute name="cert">
                <xsl:value-of select="./@certainty"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@confidence">
            <xsl:attribute name="degree">
                <xsl:value-of select="./@confidence"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@extent">
            <xsl:attribute name="extent">
                <xsl:value-of select="./@extent"/>
            </xsl:attribute>
        </xsl:if>
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
        <xsl:if test="./@n">
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@reason">
            <xsl:attribute name="reason">
                <xsl:value-of select="./@reason"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@resp">
            <xsl:attribute name="resp">
                <xsl:value-of select="./@resp"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@rend">
            <xsl:attribute name="rend">
                <xsl:value-of select="./@rend"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <!-- END: attribute unclear -->

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
                <xsl:value-of select="normalize-space(./@type)"/>
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
        <xsl:if test="normalize-space(./@indexName) != ''">
            <xsl:attribute name="indexName">
                <xsl:value-of select="./@indexName"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@lemma">
            <xsl:attribute name="n">
                <xsl:value-of select="./@lemma"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@sublemma">
            <xsl:attribute name="next">
                <xsl:value-of select="./@sublemma"/>
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
                <xsl:value-of select="normalize-space(./@type)"/>
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
    <xsl:template name="rolenameDistinct">

        <xsl:if test="normalize-space(./@id) != ''">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="./@id"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@facs) != ''">
            <xsl:attribute name="facs">
                <xsl:value-of select="./@facs"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@lang) != ''">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="./@lang"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@n) != ''">
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@type) != ''">
            <xsl:attribute name="type">
                <xsl:value-of select="normalize-space(./@type)"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@rend) != ''">
            <xsl:attribute name="rend">
                <xsl:value-of select="./@rend"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@resp) != ''">
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
                <xsl:value-of select="normalize-space(./@type)"/>
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
    <xsl:template name="hiSealdimZoneRightsFigdescFigureApp">

        <xsl:if test="./@id">
            <xsl:attribute name="corresp">
                <xsl:value-of select="./@id"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@facs)">
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
    <!-- END: attribute hi sealDim zone rights figDesc figure app foreign -->

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
        <xsl:if test="./@certainty">
            <xsl:attribute name="cert">
                <xsl:value-of select="./@certainty"/>
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
        <xsl:if test="normalize-space(./@facs) != ''">
            <xsl:attribute name="facs">
                <xsl:value-of select="./@facs"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@key) != ''">
            <xsl:attribute name="corresp">
                <xsl:value-of select="./@key"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@lang) != ''">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="./@lang"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@n) != ''">
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@type) != ''">
            <xsl:attribute name="type">
                <xsl:value-of select="normalize-space(./@type)"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@rend) != ''">
            <xsl:attribute name="rend">
                <xsl:value-of select="./@rend"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@resp) != ''">
            <xsl:attribute name="resp">
                <xsl:value-of select="./@resp"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@status) != ''">
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
        <xsl:if test="normalize-space(./@id) != ''">
            <xsl:attribute name="corresp">
                <xsl:value-of select="./@id"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@facs) != ''">
            <xsl:attribute name="facs">
                <xsl:value-of select="./@facs"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@key) != ''">
            <xsl:attribute name="key">
                <xsl:value-of select="./@key"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@n) != ''">
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@type) != ''">
            <xsl:attribute name="type">
                <xsl:value-of select="normalize-space(./@type)"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@rend) != ''">
            <xsl:attribute name="rend">
                <xsl:value-of select="./@rend"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@resp) != ''">
            <xsl:attribute name="resp">
                <xsl:value-of select="./@resp"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@lang) != ''">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="./@lang"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@certainty) != ''">
            <xsl:attribute name="cert">
                <xsl:value-of select="./@certainty"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@existent) != ''">
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
            <xsl:attribute name="prev">
                <xsl:value-of select="normalize-space(./@type)"/>
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

        <xsl:if test="normalize-space(./@id) != ''">
            <xsl:attribute name="corresp">
                <xsl:value-of select="./@id"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@facs) != ''">
            <xsl:attribute name="facs">
                <xsl:value-of select="./@facs"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@lang) != ''">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="./@lang"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@n) != ''">
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@key) != ''">
            <xsl:attribute name="cRef">
                <xsl:value-of select="./@key"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@target) != ''">
            <xsl:attribute name="target">
                <xsl:value-of select="./@target"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@type) != ''">
            <xsl:attribute name="subtype">
                <xsl:value-of select="normalize-space(./@type)"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@rend) != ''">
            <xsl:attribute name="rend">
                <xsl:value-of select="./@rend"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space(./@resp) != ''">
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
                <xsl:value-of select="normalize-space(./@type)"/>
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
                <xsl:value-of select="normalize-space(./@type)"/>
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
                <xsl:value-of select="normalize-space(./@type)"/>
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
                <xsl:value-of select="normalize-space(./@type)"/>
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
        <xsl:if test="normalize-space(./@n) != ''">
            <xsl:attribute name="n">
                <xsl:value-of select="normalize-space(./@n)"/>
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
                <xsl:value-of select="normalize-space(./@type)"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="./@unit">
                <xsl:attribute name="unit">
                    <xsl:value-of select="./@unit"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="contains(., 'mm')">
                <xsl:attribute name="unit">
                    <xsl:text>mm</xsl:text>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
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
                <xsl:value-of select="normalize-space(./@type)"/>
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
    <!-- END: attributes num -->

    <!-- START: attributes measure -->
    <xsl:template name="measure">
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
        <xsl:if test="./@n">
            <xsl:attribute name="n">
                <xsl:value-of select="./@n"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="./@type">
            <xsl:attribute name="type">
                <xsl:value-of select="normalize-space(./@type)"/>
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
    </xsl:template>
    <!-- END: attributes measure -->

    <!-- END: attribute templates -->


</xsl:stylesheet>
