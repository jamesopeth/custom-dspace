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

			
			<!-- Titulo Alternativo -->
		  <xsl:when test="$clause = 2 and (dim:field[@element='title' and @qualifier='alternative'])">
			<tr class="ds-table-row {$phase}">
				<td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-title-alternative</i18n:text>:</span></td>
				<td>
					<xsl:for-each select="dim:field[@element='title' and @qualifier='alternative']">
						<xsl:copy-of select="node()"/>
						<xsl:if test="count(following-sibling::dim:field[@element='title' and @qualifier='alternative']) != 0">
							<xsl:text>; </xsl:text>
						</xsl:if>
					</xsl:for-each>
					
				</td>
			</tr>
			<xsl:call-template name="itemSummaryView-DIM-fields">
              <xsl:with-param name="clause" select="($clause + 1)"/>
              <xsl:with-param name="phase" select="$otherPhase"/>
            </xsl:call-template>
		  </xsl:when> 
		  
          <!-- Author(s) row -->
          <xsl:when test="$clause = 3 and (dim:field[@element='contributor'][@qualifier='author'] or dim:field[@element='creator' and not(@qualifier)] or dim:field[@element='contributor'])">
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

		  <!-- Correos(s) row -->
          <xsl:when test="$clause = 4 and (dim:field[@element='creator'][@qualifier='email'])">
				<tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author-email</i18n:text>:</span></td>
	                <td>
	                    <xsl:choose>
	                        <xsl:when test="dim:field[@element='creator'][@qualifier='email']">
	                            <xsl:for-each select="dim:field[@element='creator'][@qualifier='email']">
                                        <xsl:copy-of select="node()"/>
										<xsl:if test="count(following-sibling::dim:field[@element='creator'][@qualifier='email']) != 0">
											<xsl:text>; </xsl:text>
										</xsl:if>
	                            </xsl:for-each>
	                        </xsl:when>
	                    </xsl:choose>
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
		  
		  <!-- identifier.uri row -->
          <xsl:when test="$clause = 6 and (dim:field[@element='identifier' and @qualifier='uri'])">
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

          <!-- Abstract row -->
          <xsl:when test="$clause = 7 and (dim:field[@element='description' and @qualifier='abstract'])">
                    <tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text>:</span></td>
	                <td>
	                <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
	                	<hr class="metadata-separator"/>
	                </xsl:if>
	                <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
		                <xsl:copy-of select="./node()"/>
		                <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
	                    	<hr class="metadata-separator"/>
	                    </xsl:if>
	              	</xsl:for-each>
	              	<xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
	                	<hr class="metadata-separator"/>
	                </xsl:if>
	                </td>
	            </tr>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when> 

          <!-- Description row -->
          <xsl:when test="$clause = 8 and (dim:field[@element='description' and not(@qualifier)])">
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

          <!-- Tipo de documento row -->
          <xsl:when test="$clause = 10 and (dim:field[@element='type' and @qualifier = 'spa'])">
                    <tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-type</i18n:text>:</span></td>
	                <td>
		                <xsl:for-each select="dim:field[@element='type' and @qualifier = 'spa']">
		                	<xsl:copy-of select="node()"/>
		                	<xsl:if test="count(following-sibling::dim:field[@element='type' and @qualifier = 'spa']) != 0">
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
		  
		  <!-- Relación row -->
          <xsl:when test="$clause = 11 and (dim:field[@element='relation' and @qualifier = 'ispartof'])">
                    <tr class="ds-table-row {$phase}">
	                <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-relation</i18n:text>:</span></td>
	                <td>
		                <xsl:for-each select="dim:field[@element='relation' and @qualifier = 'ispartof']">
		                	<xsl:copy-of select="node()"/>
		                	<xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier = 'ispartof']) != 0">
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
		  
		  <!-- Citation row -->
          <xsl:when test="$clause = 12 and (dim:field[@element='identifier' and @qualifier='citation'])">
					
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
		  
		  <!-- URIs en Revista row -->
          <xsl:when test="$clause = 13 and (dim:field[@element='relation'])">
                    <tr class="ds-table-row {$phase}">
                        <td><span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text>:</span></td>
                        <td>
							<xsl:for-each select="dim:field[@element='relation']">
								<a>
									<xsl:attribute name="href">
										<xsl:copy-of select="./node()"/>
									</xsl:attribute>
									<xsl:copy-of select="./node()"/>
								</a>
								<xsl:if test="count(following-sibling::dim:field[@element='relation']) != 0">
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
            <xsl:if test="$clause &lt; 13">
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$phase"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:otherwise>

          

          
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>

