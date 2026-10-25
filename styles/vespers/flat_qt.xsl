<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svg="http://www.w3.org/2000/svg">
  <xsl:output method="xml" encoding="UTF-8"/>
  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>
  <xsl:template match="svg:svg">
    <xsl:copy>
      <xsl:apply-templates select="@*[name() != 'shape-rendering']"/>
      <xsl:attribute name="shape-rendering">crispEdges</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="svg:stop">
    <xsl:copy>
      <xsl:apply-templates select="@*[name() != 'style' and name() != 'stop-color' and name() != 'stop-opacity']"/>
      <xsl:copy-of select="../svg:stop[1]/@style | ../svg:stop[1]/@stop-color | ../svg:stop[1]/@stop-opacity"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="svg:rect/@rx | svg:rect/@ry | svg:*/@filter"/>
</xsl:stylesheet>
