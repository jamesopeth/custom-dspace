<?xml version="1.0" encoding="UTF-8"?>
<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--
    TODO: Describe this XSL file
    Author: Alexey Maslov

-->

<!DOCTYPE stylesheet [
<!ENTITY ntilde
"<xsl:text disable-output-escaping='yes'>&amp;ntilde;</xsl:text>">
]>

<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
        xmlns:dri="http://di.tamu.edu/DRI/1.0/"
        xmlns:mets="http://www.loc.gov/METS/"
        xmlns:xlink="http://www.w3.org/TR/xlink/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
        xmlns:xhtml="http://www.w3.org/1999/xhtml"
        xmlns:mods="http://www.loc.gov/mods/v3"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns="http://www.w3.org/1999/xhtml"
        exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">

    <xsl:import href="../ri-javeriana/template.xsl"/>
    <xsl:output indent="yes"/>

   <!-- Dibuja los encabezados de los divs en el body-->	
    <xsl:template match="dri:div/dri:head" priority="3">
        <xsl:variable name="head_count" select="count(ancestor::dri:div)"/>
        <!-- with the help of the font-sizing variable, the font-size of our header text is made continuously variable based on the character count -->
        <xsl:variable name="font-sizing" select="365 - $head_count * 80 - string-length(current())"></xsl:variable>
        <xsl:element name="h{$head_count}">
            <!-- in case the chosen size is less than 120%, don't let it go below. Shrinking stops at 120% -->
            <xsl:choose>
                <xsl:when test="$font-sizing &lt; 120">
                    <xsl:attribute name="style">font-size: 120%;</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="style">font-size: <xsl:value-of select="$font-sizing"/>%;</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ds-div-head</xsl:with-param>
            </xsl:call-template>

            <xsl:choose>
		<!-- En el caso que sea la página principal de comhistoria, no se imprime titulo-->
		<xsl:when test="$request-uri='handle/123456789/1292' and $head_count = 1">
			<i18n:text>&#160;</i18n:text>
		</xsl:when>
                <xsl:when test="string-length(./node()) &lt; 1">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

	
	<!-- Dibuja la imagen más grande entre los bitstream del recurso -->
	<xsl:template name="itemSummaryView-DIM-Paint-Largest-Image">
	
		<xsl:variable name="maxServiceImageSize">
		  <xsl:value-of select="'1048576'"/>
		</xsl:variable>
		
		<xsl:for-each select="//mets:fileGrp[@USE='CONTENT']/mets:file[@MIMETYPE='image/jpeg' and $maxServiceImageSize &gt; @SIZE]">
			<xsl:sort select="./@SIZE" data-type="number" order="descending"/>
			<xsl:if test="position() = 1">
				<xsl:if test=" ./@SIZE &gt; 0">
					<div id="ds-image-preview">
						<div class="easyzoom easyzoom--overlay">
							<a>
															<xsl:attribute name="href">
																	<xsl:value-of select="mets:FLocat/@xlink:href"/>
															</xsl:attribute>

								<img alt="zoomable image" width="300">
									<xsl:attribute name="src">
										<xsl:value-of select="mets:FLocat/@xlink:href"/>
									</xsl:attribute>
									<xsl:attribute name="title">
										<xsl:value-of select="mets:FLocat/@xlink:title"/>
									</xsl:attribute>
								</img>
							</a>
						</div>	
					</div>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
		
	</xsl:template>

    <!-- An item rendered in the summaryView pattern. This is the default way to view a DSpace item in Manakin. -->
    <xsl:template name="itemSummaryView-DIM">
		
		<!-- Genera la imagen que precede los metadatos cuando se muestra la vista sencilla de los recursos de comhistoria -->
		<xsl:call-template name="itemSummaryView-DIM-Paint-Largest-Image"/>
	
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                    <xsl:with-param name="context" select="."/>
                    <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                </xsl:apply-templates>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']"/>
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']"/>

    </xsl:template>



    <xsl:template name="itemSummaryView-DIM-fields">
      <xsl:param name="clause" select="'1'"/>
      <xsl:param name="phase" select="'even'"/>
      <xsl:variable name="otherPhase">
            <xsl:choose>
              <xsl:when test="$phase = 'even'">
                <xsl:text>odd</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>even</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
      </xsl:variable>

	  <xsl:choose>

            <!--  artifact?
            <tr class="ds-table-row odd">
                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-preview</i18n:text>:</span></td>
                <td>
                    <xsl:choose>
                        <xsl:when test="mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                            <a class="image-link">
                                <xsl:attribute name="href"><xsl:value-of select="@OBJID"/></xsl:attribute>
                                <img alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                            mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-preview</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>-->
			

          <!-- Title row -->
          <xsl:when test="$clause = 1">
            <tr class="ds-table-row {$phase}">
                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-title</i18n:text>: </span></td>
                <td>
                    <xsl:choose>
                        <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                            <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                                   <xsl:value-of select="./node()"/>
                                   <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                            <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
            <xsl:call-template name="itemSummaryView-DIM-fields">
              <xsl:with-param name="clause" select="($clause + 1)"/>
              <xsl:with-param name="phase" select="$otherPhase"/>
            </xsl:call-template>
          </xsl:when>
		  
          <!-- Author(s) row -->
          <xsl:when test="$clause = 2 and (dim:field[@element='contributor'][@qualifier='author'] or dim:field[@element='creator' and not(@qualifier)] or dim:field[@element='contributor'])">
                    <tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text>:</span></td>
	                <td>
	                    <xsl:choose>
							<xsl:when test="dim:field[@element='creator' and not(@qualifier)]">
	                            <xsl:for-each select="dim:field[@element='creator' and not(@qualifier)]">
	                                <xsl:copy-of select="node()"/>
	                                <xsl:if test="count(following-sibling::dim:field[@element='creator' and not(@qualifier)]) != 0">
	                                    <xsl:text>; </xsl:text>
	                                </xsl:if>
	                            </xsl:for-each>
	                        </xsl:when>
							<xsl:when test="dim:field[@element='contributor']">
	                            <xsl:for-each select="dim:field[@element='contributor']">
	                                <xsl:copy-of select="node()"/>
	                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
	                                    <xsl:text>; </xsl:text>
	                                </xsl:if>
	                            </xsl:for-each>
	                        </xsl:when>
	                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
	                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                        <span>
                                          <xsl:if test="@authority">
                                            <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                          </xsl:if>
	                                <xsl:copy-of select="node()"/>
                                        </span>
	                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
	                                    <xsl:text>; </xsl:text>
	                                </xsl:if>
	                            </xsl:for-each>
	                        </xsl:when>
	                        <xsl:otherwise>
	                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
	                        </xsl:otherwise>
	                    </xsl:choose>
	                </td>
	            </tr>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when>

          <!-- Description row -->
          <xsl:when test="$clause = 3 and (dim:field[@element='description' and not(@qualifier)])">
                    <tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-description</i18n:text>:</span></td>
	                <td>
	                <xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1 and not(count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1)">
	                	<hr class="metadata-separator"/>
	                </xsl:if>
	                <xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
		                <xsl:copy-of select="./node()"/>
		                <xsl:if test="count(following-sibling::dim:field[@element='description' and not(@qualifier)]) != 0">
	                    	<hr class="metadata-separator"/>
	                    </xsl:if>
	               	</xsl:for-each>
	               	<xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1">
	                	<hr class="metadata-separator"/>
	                </xsl:if>
	                </td>
	            </tr>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when> 
		  
		  <!-- identifier.uri row -->
          <xsl:when test="$clause = 4 and (dim:field[@element='identifier' and @qualifier='uri'])">
                    <tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text>:</span></td>
	                <td>
	                	<xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
		                    <a>
		                        <xsl:attribute name="href">
		                            <xsl:copy-of select="./node()"/>
		                        </xsl:attribute>
		                        <xsl:copy-of select="./node()"/>
		                    </a>
		                    <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
		                    	<br/>
		                    </xsl:if>
	                    </xsl:for-each>
	                </td>
	            </tr>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when> 
		  
		  <!-- Fecha publicacion row -->
          <xsl:when test="$clause = 5 and (dim:field[@element='date' and not(@qualifier)])">
                    <tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>:</span></td>
	                <td>
		                <xsl:for-each select="dim:field[@element='date' and not(@qualifier)]">
		                	<xsl:copy-of select="node()"/>
		                	<xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
								<br/>
							</xsl:if>
		                </xsl:for-each>
	                </td>
	            </tr>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when> 
		  
		  <!-- Periodico row  -->
          <xsl:when test="$clause = 6 and (dim:field[@element='source' and not(@qualifier)])">
                    <tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-newspaper</i18n:text>:</span></td>
	                <td>
		                <xsl:for-each select="dim:field[@element='source' and not(@qualifier)]">
		                	<xsl:copy-of select="node()"/>
		                	<xsl:if test="count(following-sibling::dim:field[@element='source' and not(@qualifier)]) != 0">
								<xsl:text>, </xsl:text>
							</xsl:if>
		                </xsl:for-each>
	                </td>
	            </tr>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when>

		  <!-- Departamento row  -->
          <xsl:when test="$clause = 7 and (dim:field[@element='pubplace' and @qualifier = 'state'])">
                    <tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-pubplace-state</i18n:text>:</span></td>
	                <td>
		                <xsl:for-each select="dim:field[@element='pubplace' and @qualifier = 'state']">
		                	<xsl:copy-of select="node()"/>
		                	<xsl:if test="count(following-sibling::dim:field[@element='pubplace' and @qualifier = 'state']) != 0">
								<xsl:text>, </xsl:text>
							</xsl:if>
		                </xsl:for-each>
	                </td>
	            </tr>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when>
		  
		  <!-- Ciudad row  -->
          <xsl:when test="$clause = 8 and (dim:field[@element='pubplace' and @qualifier = 'city'])">
                    <tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-pubplace-city</i18n:text>:</span></td>
	                <td>
		                <xsl:for-each select="dim:field[@element='pubplace' and @qualifier = 'city']">
		                	<xsl:copy-of select="node()"/>
		                	<xsl:if test="count(following-sibling::dim:field[@element='pubplace' and @qualifier = 'city']) != 0">
								<xsl:text>, </xsl:text>
							</xsl:if>
		                </xsl:for-each>
	                </td>
	            </tr>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when>


          <!-- Palabras clave row  -->
          <xsl:when test="$clause = 9 and (dim:field[@element='subject' and not(@qualifier)])">
                    <tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-subject</i18n:text>:</span></td>
	                <td>
		                <xsl:for-each select="dim:field[@element='subject' and not(@qualifier)]">
		                	<xsl:copy-of select="node()"/>
		                	<xsl:if test="count(following-sibling::dim:field[@element='subject' and not(@qualifier)]) != 0">
								<xsl:text>, </xsl:text>
							</xsl:if>
		                </xsl:for-each>
	                </td>
	            </tr>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when>
		  
		  <!-- Citation row -->
          <xsl:when test="$clause = 10 and (dim:field[@element='identifier' and @qualifier='citation'])">
					<xsl:variable name="handleUri">
							<xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
								<a>
									<xsl:attribute name="href">
										<xsl:copy-of select="./node()"/>
									</xsl:attribute>
									<xsl:copy-of select="./node()"/>
								</a>
								<xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:for-each>
					</xsl:variable>
                    <tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-citation</i18n:text>:</span></td>
	                <td>
		                <xsl:for-each select="dim:field[@element='identifier' and @qualifier='citation']">
		                	<xsl:copy-of select="node()"/>
							<xsl:if test="$handleUri">
								<xsl:text> Tomado de (</xsl:text>
								<xsl:value-of select="$handleUri"/>
								<xsl:text>). </xsl:text>
							</xsl:if>
		                	<xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='citation']) != 0">
								<br/>
							</xsl:if>
		                </xsl:for-each>
	                </td>
	            </tr>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when> 

          <!-- recurse without changing phase if we didn't output anything -->
          <xsl:otherwise>
            <!-- IMPORTANT: This test should be updated if clauses are added! -->
            <xsl:if test="$clause &lt; 10">
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$phase"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      
    </xsl:template>

</xsl:stylesheet>

