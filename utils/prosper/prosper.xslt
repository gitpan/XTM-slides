<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:s="http://topicmaps.bond.edu.au/SlideML/" 
                version="1.0">

<xsl:output method="text"/>

<xsl:template match="/s:slides">
\documentclass[pdf,<xsl:value-of select="$style"/>,slideColor,colorBG,total]{prosper}
 
<xsl:apply-templates select="s:title|s:author|s:caption|s:institution|s:email"/>

 
\DefaultTransition{Blinds}

\begin{document} 
\maketitle

<xsl:apply-templates select="s:slide"/>

\end{document}
 
%%% Local Variables:
%%% mode: latex
%%% TeX-master: t
%%% End:
</xsl:template>

<xsl:template match="s:title">
\title{<xsl:value-of select="."/>}
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

<xsl:template match="s:slide">
\begin{slide}{<xsl:value-of select="@title"/>}
\PDFtransition{Blinds}

<xsl:apply-templates select="s:text"/>
 
\begin{itemize}<xsl:apply-templates select="s:item/s:description|s:item"/>\end{itemize}

\end{slide}
</xsl:template>

<xsl:template match="s:item">
  \item <xsl:value-of select="./text()"/>
</xsl:template>

<xsl:template match="s:item/s:description">
  \\ <xsl:value-of select="./text()"/>
</xsl:template>


</xsl:stylesheet>
