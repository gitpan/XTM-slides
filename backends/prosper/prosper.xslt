<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:m='http://topicmaps.bond.edu.au/smile/1.0/'
                xmlns:s="http://topicmaps.bond.edu.au/SlideML/" 
                version="1.0">

<xsl:output method="text"/>

<xsl:template match="text()">
   <xsl:call-template name="break"/>
</xsl:template>


<xsl:template name="break">
   <xsl:param name="text" select="."/>
   <xsl:choose>
   <xsl:when test="contains($text, '&#xa;')">
      <xsl:value-of select="substring-before($text, '&#xa;')"/>
      \\
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
\documentclass[pdf,<xsl:value-of select="$style"/>,slideColor,colorBG,total]{prosper}
 
<xsl:apply-templates select="s:title|s:author|s:caption|s:institution|s:email"/>

 
\DefaultTransition{Blinds}

\begin{document} 
\maketitle

<xsl:apply-templates select="m:slide"/>

\end{document}
 </xsl:template>

<xsl:template match="s:title">
\title{<xsl:call-template name="break"/>}
</xsl:template>

<xsl:template match="s:author">
\author{<xsl:value-of select="."/>}
</xsl:template>

<xsl:template match="s:institution">
\institution{<xsl:value-of select="."/>}
</xsl:template>

<xsl:template match="s:email">
\email{<xsl:value-of select="."/>}
</xsl:template>

<xsl:template match="s:caption">
\slideCaption{<xsl:value-of select="."/>}
</xsl:template>

<xsl:template match="s:text">
<xsl:value-of select="."/>\\
</xsl:template>

<xsl:template match="m:slide">
\begin{slide}{<xsl:value-of select="m:title"/><xsl:if test="@m:continue"><xsl:text>(cont'd)</xsl:text></xsl:if>}
\PDFtransition{Blinds}

\begin{itemize}<xsl:apply-templates select="m:types|m:inlines|m:instances"/>\end{itemize}

<xsl:apply-templates select="m:references"/>
\end{slide}
</xsl:template>

<xsl:template match="m:types">
  \item is some sort of <xsl:value-of select="./text()"/>
  <xsl:apply-templates select="m:type"/>
</xsl:template>

<xsl:template match="m:type">
<xsl:value-of select="./text()"/>
</xsl:template>

<xsl:template match="m:inlines">
  \item <xsl:choose><xsl:when test="./text()"><xsl:value-of select="./text()"/></xsl:when>
                    <xsl:otherwise>instances</xsl:otherwise>
        </xsl:choose>
  \begin{itemize}<xsl:apply-templates select="m:inline"/>\end{itemize}
</xsl:template>

<xsl:template match="m:inline">
\item <xsl:value-of select="./text()"/>
</xsl:template>

<xsl:template match="m:instances">
  \item <xsl:choose><xsl:when test="./text()"><xsl:value-of select="./text()"/></xsl:when>
                    <xsl:otherwise>instances</xsl:otherwise>
        </xsl:choose>
  \begin{itemize}<xsl:apply-templates select="m:instance"/>\end{itemize}
</xsl:template>

<xsl:template match="m:instance">
 \item <xsl:value-of select="./text()"/>
  \begin{itemize}<xsl:apply-templates select="m:description"/>\end{itemize}
</xsl:template>

<xsl:template match="m:description">
  \item {\em <xsl:value-of select="./text()"/>}
</xsl:template>



<xsl:template match="s:item">
  \item <xsl:value-of select="./text()"/>
</xsl:template>

<xsl:template match="s:item/s:description"> \\ <xsl:value-of select="./text()"/>
</xsl:template>

<xsl:template match="m:references">
\texttt{ <xsl:apply-templates select="m:reference"/> }
</xsl:template>

<xsl:template match="m:reference">
 \\ <xsl:value-of select="@href"/>
</xsl:template>

</xsl:stylesheet>
