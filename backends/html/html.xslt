<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="http://topicmaps.bond.edu.au/SlideML/"
                xmlns:m='http://topicmaps.bond.edu.au/smile/1.0/'
		xmlns:h="http://www.w3.org/TR/html4/"
                version="1.0">

<xsl:output method="html" encoding="ISO-8859-1" indent="yes"/>

<xsl:template match="text()">
   <xsl:call-template name="break"/>
</xsl:template>

<xsl:template name="break">
   <xsl:param name="text" select="."/>
   <xsl:choose>
   <xsl:when test="contains($text, '&#xa;')">
      <xsl:value-of select="substring-before($text, '&#xa;')"/>
      <br/>
      <xsl:call-template name="break">
          <xsl:with-param name="text" select="substring-after($text,'&#xa;')"/>
      </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
        <xsl:value-of select="$text"/>
   </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template match="/s:slides">
<h:meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
<h:html>
<h:head>
<!-- <xsl:apply-templates select="s:item"/> -->
<!--   <h:title><xsl:value-of select="/s:slides/@name"/></h:title> -->
   <h:title><xsl:value-of select="/s:slides/@name"/></h:title>
   <xsl:element name="link">
     <xsl:attribute name="href"><xsl:value-of select="$style"/></xsl:attribute>
     <xsl:attribute name="rel">stylesheet</xsl:attribute>
     <xsl:attribute name="type">text/css</xsl:attribute>
   </xsl:element>
</h:head>
<h:body>

<h:div class="header">
<xsl:apply-templates select="s:title"/>
<xsl:apply-templates select="s:author"/>
<xsl:apply-templates select="s:institution"/>
</h:div>

<h:div class="slides">
<h:table>
<xsl:apply-templates select="m:slide"/>
</h:table>
</h:div>

</h:body>
</h:html>
</xsl:template>

<xsl:template match="s:title">
<h:h2><xsl:call-template name="break"/></h:h2>
</xsl:template>

<xsl:template match="s:author">
<xsl:value-of select="text()"/>
<xsl:apply-templates select="s:email"/>
</xsl:template>

<xsl:template match="s:institution">
<h:h4><xsl:value-of select="."/></h:h4>
</xsl:template>

<xsl:template match="s:email">
  <xsl:variable name="mymail"><xsl:value-of select="."/></xsl:variable>
  <xsl:element name="a">
    <xsl:attribute name="href">mailto:<xsl:value-of select="$mymail"/></xsl:attribute>
    <xsl:value-of select="$mymail"/>
  </xsl:element>
</xsl:template>

<xsl:template match="s:caption">
<h:h3><xsl:value-of select="."/></h:h3>
</xsl:template>

<xsl:template match="s:text">
<h:blockquote class="blocktext"><xsl:value-of select="."/></h:blockquote>
</xsl:template>

<xsl:template match="m:slide">
<h:tr>
<h:td class="slide">
  <h:div h:class="slideheader"><xsl:value-of select="m:title"/>
  <xsl:if test="@m:continue">
    <xsl:text>(cont'd)</xsl:text>
  </xsl:if>
  </h:div>
</h:td></h:tr>

<h:tr>
  <h:td>
   <h:ul>
     <xsl:apply-templates select="m:types|m:inlines|m:instances"/>
   </h:ul>
  </h:td>
</h:tr>

<h:tr>
   <h:td h:class="slideseparator">References
   <h:ul>
     <xsl:apply-templates select="m:references"/>
   </h:ul>
   </h:td>
</h:tr>
</xsl:template>

<xsl:template match="m:types">
<h:li>
  is some sort of <xsl:value-of select="./text()"/>
  <xsl:apply-templates select="m:type"/>
</h:li>
</xsl:template>

<xsl:template match="m:type">
<xsl:value-of select="./text()"/>
</xsl:template>

<xsl:template match="m:inlines">
<h:li>
   <xsl:choose>
      <xsl:when test="./text()"><xsl:value-of select="./text()"/></xsl:when>
      <xsl:otherwise>instances</xsl:otherwise>
   </xsl:choose>
   <h:ul><xsl:apply-templates select="m:inline"/></h:ul>
</h:li>
</xsl:template>

<xsl:template match="m:inline">
<h:li><xsl:value-of select="./text()"/></h:li>
</xsl:template>

<xsl:template match="m:instances">
<h:li>
   <xsl:choose>
      <xsl:when test="./text()"><xsl:value-of select="./text()"/></xsl:when>
      <xsl:otherwise>instances</xsl:otherwise>
   </xsl:choose>
  <h:ul><xsl:apply-templates select="m:instance"/></h:ul>
</h:li>
</xsl:template>

<xsl:template match="m:instance">
<h:li><xsl:value-of select="./text()"/>
<h:ul>
  <xsl:apply-templates select="s:description"/>
</h:ul>
</h:li>
</xsl:template>

<xsl:template match="m:description">
  <h:li><h:span class="bullettext"><xsl:value-of select="./text()"/></h:span></h:li>
</xsl:template>

<xsl:template match="m:references">
<xsl:apply-templates select="m:reference"/>
</xsl:template>

<xsl:template match="m:reference">
  <h:li>
  <xsl:variable name="myref"><xsl:value-of select="@href"/></xsl:variable>
  <xsl:element name="a">
    <xsl:attribute name="href"><xsl:value-of select="$myref"/></xsl:attribute>
    <xsl:attribute name="target">alien</xsl:attribute>
    <xsl:value-of select="$myref"/>
  </xsl:element>
  </h:li>
</xsl:template>

<xsl:template match="m:instance/m:description">
  <h:li><h:span class="bullettext"><xsl:value-of select="./text()"/></h:span></h:li>
</xsl:template>


</xsl:stylesheet>
