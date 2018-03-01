<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:exp="http://cpas.fhcrc.org/exp/xml" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-11-05T06:56:29" xmlns:xd="http://schemas.microsoft.com/office/infopath/2003" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:xdExtension="http://schemas.microsoft.com/office/infopath/2003/xslt/extension" xmlns:xdXDocument="http://schemas.microsoft.com/office/infopath/2003/xslt/xDocument" xmlns:xdSolution="http://schemas.microsoft.com/office/infopath/2003/xslt/solution" xmlns:xdFormatting="http://schemas.microsoft.com/office/infopath/2003/xslt/formatting" xmlns:xdImage="http://schemas.microsoft.com/office/infopath/2003/xslt/xImage" xmlns:xdUtil="http://schemas.microsoft.com/office/infopath/2003/xslt/Util" xmlns:xdMath="http://schemas.microsoft.com/office/infopath/2003/xslt/Math" xmlns:xdDate="http://schemas.microsoft.com/office/infopath/2003/xslt/Date" xmlns:sig="http://www.w3.org/2000/09/xmldsig#" xmlns:xdSignatureProperties="http://schemas.microsoft.com/office/infopath/2003/SignatureProperties">
	<xsl:output method="html" indent="no"/>
	<xsl:template match="exp:ExperimentArchive">
		<html xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<head>
				<meta http-equiv="Content-Type" content="text/html"></meta>
				<style controlStyle="controlStyle">@media screen 			{ 			BODY{margin-left:21px;background-position:21px 0px;} 			} 		BODY{color:windowtext;background-color:window;layout-grid:none;} 		.xdListItem {display:inline-block;width:100%;vertical-align:text-top;} 		.xdListBox,.xdComboBox{margin:1px;} 		.xdInlinePicture{margin:1px; BEHAVIOR: url(#default#urn::xdPicture) } 		.xdLinkedPicture{margin:1px; BEHAVIOR: url(#default#urn::xdPicture) url(#default#urn::controls/Binder) } 		.xdSection{border:1pt solid #FFFFFF;margin:6px 0px 6px 0px;padding:1px 1px 1px 5px;} 		.xdRepeatingSection{border:1pt solid #FFFFFF;margin:6px 0px 6px 0px;padding:1px 1px 1px 5px;} 		.xdBehavior_Formatting {BEHAVIOR: url(#default#urn::controls/Binder) url(#default#Formatting);} 	 .xdBehavior_FormattingNoBUI{BEHAVIOR: url(#default#CalPopup) url(#default#urn::controls/Binder) url(#default#Formatting);} 	.xdExpressionBox{margin: 1px;padding:1px;word-wrap: break-word;text-overflow: ellipsis;overflow-x:hidden;}.xdBehavior_GhostedText,.xdBehavior_GhostedTextNoBUI{BEHAVIOR: url(#default#urn::controls/Binder) url(#default#TextField) url(#default#GhostedText);}	.xdBehavior_GTFormatting{BEHAVIOR: url(#default#urn::controls/Binder) url(#default#Formatting) url(#default#GhostedText);}	.xdBehavior_GTFormattingNoBUI{BEHAVIOR: url(#default#CalPopup) url(#default#urn::controls/Binder) url(#default#Formatting) url(#default#GhostedText);}	.xdBehavior_Boolean{BEHAVIOR: url(#default#urn::controls/Binder) url(#default#BooleanHelper);}	.xdBehavior_Select{BEHAVIOR: url(#default#urn::controls/Binder) url(#default#SelectHelper);}	.xdRepeatingTable{BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word;}.xdScrollableRegion{BEHAVIOR: url(#default#ScrollableRegion);} 		.xdMaster{BEHAVIOR: url(#default#MasterHelper);} 		.xdActiveX{margin:1px; BEHAVIOR: url(#default#ActiveX);} 		.xdFileAttachment{display:inline-block;margin:1px;BEHAVIOR:url(#default#urn::xdFileAttachment);} 		.xdPageBreak{display: none;}BODY{margin-right:21px;} 		.xdTextBoxRTL{display:inline-block;white-space:nowrap;text-overflow:ellipsis;;padding:1px;margin:1px;border: 1pt solid #dcdcdc;color:windowtext;background-color:window;overflow:hidden;text-align:right;} 		.xdRichTextBoxRTL{display:inline-block;;padding:1px;margin:1px;border: 1pt solid #dcdcdc;color:windowtext;background-color:window;overflow-x:hidden;word-wrap:break-word;text-overflow:ellipsis;text-align:right;font-weight:normal;font-style:normal;text-decoration:none;vertical-align:baseline;} 		.xdDTTextRTL{height:100%;width:100%;margin-left:22px;overflow:hidden;padding:0px;white-space:nowrap;} 		.xdDTButtonRTL{margin-right:-21px;height:18px;width:20px;behavior: url(#default#DTPicker);}.xdTextBox{display:inline-block;white-space:nowrap;text-overflow:ellipsis;;padding:1px;margin:1px;border: 1pt solid #dcdcdc;color:windowtext;background-color:window;overflow:hidden;text-align:left;} 		.xdRichTextBox{display:inline-block;;padding:1px;margin:1px;border: 1pt solid #dcdcdc;color:windowtext;background-color:window;overflow-x:hidden;word-wrap:break-word;text-overflow:ellipsis;text-align:left;font-weight:normal;font-style:normal;text-decoration:none;vertical-align:baseline;} 		.xdDTPicker{;display:inline;margin:1px;margin-bottom: 2px;border: 1pt solid #dcdcdc;color:windowtext;background-color:window;overflow:hidden;} 		.xdDTText{height:100%;width:100%;margin-right:22px;overflow:hidden;padding:0px;white-space:nowrap;} 		.xdDTButton{margin-left:-21px;height:18px;width:20px;behavior: url(#default#DTPicker);} 		.xdRepeatingTable TD {VERTICAL-ALIGN: top;}</style>
				<style tableEditor="TableStyleRulesID">TABLE.xdLayout TD {
	BORDER-RIGHT: medium none; BORDER-TOP: medium none; BORDER-LEFT: medium none; BORDER-BOTTOM: medium none
}
TABLE.msoUcTable TD {
	BORDER-RIGHT: 1pt solid; BORDER-TOP: 1pt solid; BORDER-LEFT: 1pt solid; BORDER-BOTTOM: 1pt solid
}
TABLE {
	BEHAVIOR: url (#default#urn::tables/NDTable)
}
</style>
				<style languageStyle="languageStyle">BODY {
	FONT-SIZE: 10pt; FONT-FAMILY: Verdana
}
TABLE {
	FONT-SIZE: 10pt; FONT-FAMILY: Verdana
}
SELECT {
	FONT-SIZE: 10pt; FONT-FAMILY: Verdana
}
.optionalPlaceholder {
	PADDING-LEFT: 20px; FONT-WEIGHT: normal; FONT-SIZE: xx-small; BEHAVIOR: url(#default#xOptional); COLOR: #333333; FONT-STYLE: normal; FONT-FAMILY: Verdana; TEXT-DECORATION: none
}
.langFont {
	FONT-FAMILY: Verdana
}
.defaultInDocUI {
	FONT-SIZE: xx-small; FONT-FAMILY: Verdana
}
.optionalPlaceholder {
	PADDING-RIGHT: 20px
}
</style>
			</head>
			<body>
				<div>
					<font size="5">Xar.xml Editor:  Describe Experiment and Run</font>
				</div>
				<div>
					<font size="5"><input class="langFont" title="" type="button" value="Define Protocols" xd:xctname="Button" xd:CtrlId="btnProtocols" tabIndex="0"/>
					</font>
				</div>
				<div> </div>
				<div>
					<table class="msoUcTable" style="TABLE-LAYOUT: fixed; WIDTH: 763px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1">
						<colgroup>
							<col style="WIDTH: 187px"></col>
							<col style="WIDTH: 576px"></col>
						</colgroup>
						<tbody>
							<tr>
								<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
									<div>
										<strong>Experiment Name</strong>
									</div>
								</td>
								<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
									<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL2" xd:binding="exp:Experiment/exp:Name" style="WIDTH: 100%">
											<xsl:value-of select="exp:Experiment/exp:Name"/>
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
									<div>
										<strong>ID</strong>
									</div>
								</td>
								<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
									<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL348" xd:binding="exp:Experiment/@rdf:about" style="WIDTH: 100%">
											<xsl:value-of select="exp:Experiment/@rdf:about"/>
										</span>
									</div>
								</td>
							</tr>
							<tr style="MIN-HEIGHT: 25px">
								<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
									<div>Experiment Description URL</div>
								</td>
								<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
									<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL4" xd:binding="exp:Experiment/exp:ExperimentDescriptionURL" style="WIDTH: 100%">
											<xsl:value-of select="exp:Experiment/exp:ExperimentDescriptionURL"/>
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
									<div>Hypothesis</div>
								</td>
								<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
									<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL3" xd:binding="exp:Experiment/exp:Hypothesis" xd:datafmt="&quot;string&quot;,&quot;plainMultiline&quot;" style="WIDTH: 100%; WHITE-SPACE: normal; HEIGHT: 50px">
											<xsl:choose>
												<xsl:when test="function-available('xdFormatting:formatString')">
													<xsl:value-of select="xdFormatting:formatString(exp:Experiment/exp:Hypothesis,&quot;string&quot;,&quot;plainMultiline&quot;)" disable-output-escaping="yes"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="exp:Experiment/exp:Hypothesis" disable-output-escaping="yes"/>
												</xsl:otherwise>
											</xsl:choose>
										</span>
									</div>
								</td>
							</tr>
							<tr>
								<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
									<div>Comments</div>
								</td>
								<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
									<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL5" xd:binding="exp:Experiment/exp:Comments" xd:datafmt="&quot;string&quot;,&quot;plainMultiline&quot;" style="WIDTH: 100%; WHITE-SPACE: normal; HEIGHT: 50px">
											<xsl:choose>
												<xsl:when test="function-available('xdFormatting:formatString')">
													<xsl:value-of select="xdFormatting:formatString(exp:Experiment/exp:Comments,&quot;string&quot;,&quot;plainMultiline&quot;)" disable-output-escaping="yes"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="exp:Experiment/exp:Comments" disable-output-escaping="yes"/>
												</xsl:otherwise>
											</xsl:choose>
										</span>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div> </div>
				<div><xsl:choose>
						<xsl:when test="exp:Experiment/exp:Properties">
							<xsl:apply-templates select="exp:Experiment/exp:Properties" mode="_60"/>
						</xsl:when>
						<xsl:otherwise>
							<div class="optionalPlaceholder" xd:xmlToEdit="Properties_112" tabIndex="0" align="left" style="WIDTH: 774px">Add custom experiment properties</div>
						</xsl:otherwise>
					</xsl:choose>
				</div>
				<div/>
				<div> </div>
				<div/>
				<div><xsl:apply-templates select="exp:StartingInputDefinitions" mode="_30"/>
				</div>
				<div><xsl:apply-templates select="exp:ExperimentRuns" mode="_39"/>
				</div>
				<div> </div>
				<div> </div>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="exp:Properties" mode="_60">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 774px" align="left" xd:xctname="Section" xd:CtrlId="CTRL362" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<em>
					<font size="3">Experiment Properties</font>
				</em>
			</div>
			<div>
				<em>
					<font size="3"></font>
				</em> </div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 750px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL357">
					<colgroup>
						<col style="WIDTH: 150px"></col>
						<col style="WIDTH: 300px"></col>
						<col style="WIDTH: 100px"></col>
						<col style="WIDTH: 200px"></col>
					</colgroup>
					<tbody class="xdTableHeader">
						<tr style="MIN-HEIGHT: 19px">
							<td>
								<strong>Name (label)</strong>
							</td>
							<td>
								<strong>Property ID</strong>
							</td>
							<td>
								<strong>Value Type</strong>
							</td>
							<td>
								<strong>Simple Val</strong>
							</td>
						</tr>
					</tbody><tbody xd:xctname="repeatingtable">
						<xsl:for-each select="exp:SimpleVal">
							<tr>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL363" xd:binding="@Name" style="WIDTH: 100%">
										<xsl:value-of select="@Name"/>
									</span>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL367" xd:binding="@OntologyEntryURI" style="WIDTH: 100%">
										<xsl:value-of select="@OntologyEntryURI"/>
									</span>
								</td>
								<td><select class="xdComboBox xdBehavior_Select" title="" size="1" tabIndex="0" xd:xctname="DropDown" xd:CtrlId="CTRL365" xd:binding="@ValueType" xd:boundProp="value" style="WIDTH: 100%">
										<xsl:attribute name="value">
											<xsl:value-of select="@ValueType"/>
										</xsl:attribute>
										<option value="">
											<xsl:if test="@ValueType=&quot;&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Select...</option>
										<option value="String">
											<xsl:if test="@ValueType=&quot;String&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>String</option>
										<option value="PropertyURI">
											<xsl:if test="@ValueType=&quot;PropertyURI&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>PropertyURI</option>
										<option value="Integer">
											<xsl:if test="@ValueType=&quot;Integer&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Integer</option>
										<option value="FileLink">
											<xsl:if test="@ValueType=&quot;FileLink&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>FileLink</option>
										<option value="DateTime">
											<xsl:if test="@ValueType=&quot;DateTime&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>DateTime</option>
										<option value="Double">
											<xsl:if test="@ValueType=&quot;Double&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Double</option>
									</select>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL366" xd:binding="." style="WIDTH: 100%">
										<xsl:value-of select="."/>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_79" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 750px">Add property</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:StartingInputDefinitions" mode="_30">
		<div class="xdSection xdRepeating" title="" style="BORDER-RIGHT: #000000 1pt solid; BORDER-TOP: #000000 1pt solid; MARGIN-BOTTOM: 6px; BORDER-LEFT: #000000 1pt solid; WIDTH: 826px; BORDER-BOTTOM: #000000 1pt solid" align="left" xd:xctname="Section" xd:CtrlId="CTRL180" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<strong>
					<font size="3">Starting Inputs:  Samples</font>
				</strong>
			</div>
			<div><xsl:apply-templates select="exp:Material" mode="_31"/>
				<div class="optionalPlaceholder" xd:xmlToEdit="Material_35" tabIndex="0" xd:action="xCollection::insert" align="left" style="WIDTH: 100%">Add sample</div>
			</div>
			<div>
				<strong>
					<font size="3"></font>
				</strong> </div>
			<div><xsl:apply-templates select="exp:Data" mode="_37"/>
				<div class="optionalPlaceholder" xd:xmlToEdit="Data_44" tabIndex="0" xd:action="xCollection::insert" align="left" style="WIDTH: 769px">Add starting data input</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Material" mode="_31">
		<div class="xdRepeatingSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL181" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<table class="msoUcTable" style="TABLE-LAYOUT: fixed; WIDTH: 679px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1">
					<colgroup>
						<col style="WIDTH: 116px"></col>
						<col style="WIDTH: 563px"></col>
					</colgroup>
					<tbody>
						<tr>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong>Name (label)</strong>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL199" xd:binding="exp:Name" style="WIDTH: 100%">
										<xsl:value-of select="exp:Name"/>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong>LSID</strong>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL202" xd:binding="@rdf:about" style="WIDTH: 100%">
										<xsl:value-of select="@rdf:about"/>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>Type</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL200" xd:binding="exp:CpasType" style="WIDTH: 100%">
										<xsl:value-of select="exp:CpasType"/>
									</span>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div> </div>
			<div><xsl:choose>
					<xsl:when test="exp:Properties">
						<xsl:apply-templates select="exp:Properties" mode="_36"/>
					</xsl:when>
					<xsl:otherwise>
						<div class="optionalPlaceholder" xd:xmlToEdit="Properties_113" tabIndex="0" align="left" style="WIDTH: 2.45%">Add custom material properties</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Properties" mode="_36">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 2.45%; HEIGHT: 102px" align="left" xd:xctname="Section" xd:CtrlId="CTRL209" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<em>
					<font size="3">Properties     </font>
				</em>
			</div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 753px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL204">
					<colgroup>
						<col style="WIDTH: 168px"></col>
						<col style="WIDTH: 306px"></col>
						<col style="WIDTH: 122px"></col>
						<col style="WIDTH: 157px"></col>
					</colgroup>
					<tbody class="xdTableHeader">
						<tr style="MIN-HEIGHT: 19px">
							<td>
								<strong>Name (label)</strong>
							</td>
							<td>
								<strong>Property ID</strong>
							</td>
							<td>
								<strong>Value Type</strong>
							</td>
							<td>
								<strong>Value</strong>
							</td>
						</tr>
					</tbody><tbody xd:xctname="repeatingtable">
						<xsl:for-each select="exp:SimpleVal">
							<tr>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL210" xd:binding="@Name" style="WIDTH: 100%">
										<xsl:value-of select="@Name"/>
									</span>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL214" xd:binding="@OntologyEntryURI" style="WIDTH: 100%">
										<xsl:value-of select="@OntologyEntryURI"/>
									</span>
								</td>
								<td><select class="xdComboBox xdBehavior_Select" title="" size="1" tabIndex="0" xd:xctname="DropDown" xd:CtrlId="CTRL212" xd:binding="@ValueType" xd:boundProp="value" style="WIDTH: 100%">
										<xsl:attribute name="value">
											<xsl:value-of select="@ValueType"/>
										</xsl:attribute>
										<option value="">
											<xsl:if test="@ValueType=&quot;&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Select...</option>
										<option value="String">
											<xsl:if test="@ValueType=&quot;String&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>String</option>
										<option value="PropertyURI">
											<xsl:if test="@ValueType=&quot;PropertyURI&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>PropertyURI</option>
										<option value="Integer">
											<xsl:if test="@ValueType=&quot;Integer&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Integer</option>
										<option value="FileLink">
											<xsl:if test="@ValueType=&quot;FileLink&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>FileLink</option>
										<option value="DateTime">
											<xsl:if test="@ValueType=&quot;DateTime&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>DateTime</option>
										<option value="Double">
											<xsl:if test="@ValueType=&quot;Double&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Double</option>
									</select>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL213" xd:binding="." style="WIDTH: 100%">
										<xsl:value-of select="."/>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_38" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 753px">Add property</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Data" mode="_37">
		<div class="xdRepeatingSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 769px; HEIGHT: 220px" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL235" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<strong>
					<font size="3">Starting Inputs:  Data</font>
				</strong>
			</div>
			<div> </div>
			<div>
				<table class="msoUcTable" style="TABLE-LAYOUT: fixed; WIDTH: 697px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1">
					<colgroup>
						<col style="WIDTH: 116px"></col>
						<col style="WIDTH: 581px"></col>
					</colgroup>
					<tbody>
						<tr>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong>Name (label)</strong>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL237" xd:binding="exp:Name" style="WIDTH: 100%">
										<xsl:value-of select="exp:Name"/>
									</span>
								</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 25px">
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong>LSID</strong>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL236" xd:binding="@rdf:about" style="WIDTH: 100%">
										<xsl:value-of select="@rdf:about"/>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>Type</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL238" xd:binding="exp:CpasType" style="WIDTH: 100%">
										<xsl:value-of select="exp:CpasType"/>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>Data File Url: </div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL368" xd:binding="exp:DataFileUrl" style="WIDTH: 100%">
										<xsl:value-of select="exp:DataFileUrl"/>
									</span>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div> </div>
			<div><xsl:choose>
					<xsl:when test="exp:Properties">
						<xsl:apply-templates select="exp:Properties" mode="_38"/>
					</xsl:when>
					<xsl:otherwise>
						<div class="optionalPlaceholder" xd:xmlToEdit="Properties_45" tabIndex="0" align="left" style="WIDTH: 749px">Add custom data properties</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Properties" mode="_38">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 749px; HEIGHT: 99px" align="left" xd:xctname="Section" xd:CtrlId="CTRL239" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<em>
					<font size="3">Properties</font>
				</em>
			</div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 757px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL230">
					<colgroup>
						<col style="WIDTH: 193px"></col>
						<col style="WIDTH: 313px"></col>
						<col style="WIDTH: 123px"></col>
						<col style="WIDTH: 128px"></col>
					</colgroup>
					<tbody class="xdTableHeader">
						<tr style="MIN-HEIGHT: 18px">
							<td>
								<strong>Name (label)</strong>
							</td>
							<td>
								<strong>Property ID</strong>
							</td>
							<td>
								<strong>Value Type</strong>
							</td>
							<td>
								<strong>Value</strong>
							</td>
						</tr>
					</tbody><tbody xd:xctname="repeatingtable">
						<xsl:for-each select="exp:SimpleVal">
							<tr>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL240" xd:binding="@Name" style="WIDTH: 100%">
										<xsl:value-of select="@Name"/>
									</span>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL245" xd:binding="@OntologyEntryURI" style="WIDTH: 100%">
										<xsl:value-of select="@OntologyEntryURI"/>
									</span>
								</td>
								<td><select class="xdComboBox xdBehavior_Select" title="" size="1" tabIndex="0" xd:xctname="DropDown" xd:CtrlId="CTRL242" xd:binding="@ValueType" xd:boundProp="value" style="WIDTH: 115px">
										<xsl:attribute name="value">
											<xsl:value-of select="@ValueType"/>
										</xsl:attribute>
										<option value="">
											<xsl:if test="@ValueType=&quot;&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Select...</option>
										<option value="String">
											<xsl:if test="@ValueType=&quot;String&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>String</option>
										<option value="PropertyURI">
											<xsl:if test="@ValueType=&quot;PropertyURI&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>PropertyURI</option>
										<option value="Integer">
											<xsl:if test="@ValueType=&quot;Integer&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Integer</option>
										<option value="FileLink">
											<xsl:if test="@ValueType=&quot;FileLink&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>FileLink</option>
										<option value="DateTime">
											<xsl:if test="@ValueType=&quot;DateTime&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>DateTime</option>
										<option value="Double">
											<xsl:if test="@ValueType=&quot;Double&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Double</option>
									</select>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL243" xd:binding="." style="WIDTH: 100%">
										<xsl:value-of select="."/>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_48" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 757px">Add property</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:ExperimentRuns" mode="_39">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 787px" align="left" xd:xctname="Section" xd:CtrlId="CTRL246" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<strong>
					<font size="3"></font>
				</strong> </div>
			<div>
				<strong>
					<font size="3">Experiment Runs</font>
				</strong>
			</div>
			<div>
				<strong>
					<font size="3"></font>
				</strong> </div>
			<div><xsl:apply-templates select="exp:ExperimentRun" mode="_55"/>
				<div class="optionalPlaceholder" xd:xmlToEdit="ExperimentRun_59" tabIndex="0" xd:action="xCollection::insert" align="left" style="WIDTH: 100%">Add Experiment Run</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:ExperimentRun" mode="_55">
		<div class="xdRepeatingSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL304" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div/>
			<div>
				<table class="msoUcTable" style="TABLE-LAYOUT: fixed; WIDTH: 707px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1">
					<colgroup>
						<col style="WIDTH: 116px"></col>
						<col style="WIDTH: 591px"></col>
					</colgroup>
					<tbody>
						<tr style="MIN-HEIGHT: 25px">
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong>Name</strong>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL314" xd:binding="exp:Name" style="WIDTH: 100%">
										<xsl:value-of select="exp:Name"/>
									</span>
								</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 25px">
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong>ID</strong>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL315" xd:binding="@rdf:about" style="WIDTH: 100%">
										<xsl:value-of select="@rdf:about"/>
									</span>
								</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 29px">
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>Run Protocol</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL316" xd:binding="exp:ProtocolLSID" style="WIDTH: 100%">
										<xsl:value-of select="exp:ProtocolLSID"/>
									</span>
								</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 26px">
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div align="right"><input class="xdBehavior_Boolean" title="" type="checkbox" tabIndex="0" xd:xctname="CheckBox" xd:CtrlId="CTRL317" xd:binding="@GenerateDataFromStepRecord" xd:boundProp="xd:value" xd:onValue="true" xd:offValue="false">
										<xsl:attribute name="xd:value">
											<xsl:value-of select="@GenerateDataFromStepRecord"/>
										</xsl:attribute>
										<xsl:if test="@GenerateDataFromStepRecord=&quot;true&quot;">
											<xsl:attribute name="CHECKED">CHECKED</xsl:attribute>
										</xsl:if>
									</input>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div> Generate Data From Step Record</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 26px">
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div align="right"><input class="xdBehavior_Boolean" title="" type="checkbox" tabIndex="0" xd:xctname="CheckBox" xd:CtrlId="CTRL318" xd:binding="@CreateNewIfDuplicate" xd:boundProp="xd:value" xd:onValue="true" xd:offValue="false">
										<xsl:attribute name="xd:value">
											<xsl:value-of select="@CreateNewIfDuplicate"/>
										</xsl:attribute>
										<xsl:if test="@CreateNewIfDuplicate=&quot;true&quot;">
											<xsl:attribute name="CHECKED">CHECKED</xsl:attribute>
										</xsl:if>
									</input>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div> Create New If Duplicate</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 26px">
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>Comments:</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL321" xd:binding="exp:Comments" xd:datafmt="&quot;string&quot;,&quot;plainMultiline&quot;" style="WIDTH: 100%; WHITE-SPACE: normal; HEIGHT: 83px">
										<xsl:choose>
											<xsl:when test="function-available('xdFormatting:formatString')">
												<xsl:value-of select="xdFormatting:formatString(exp:Comments,&quot;string&quot;,&quot;plainMultiline&quot;)" disable-output-escaping="yes"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="exp:Comments" disable-output-escaping="yes"/>
											</xsl:otherwise>
										</xsl:choose>
									</span>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div> </div>
			<div><xsl:choose>
					<xsl:when test="exp:Properties">
						<xsl:apply-templates select="exp:Properties" mode="_59"/>
					</xsl:when>
					<xsl:otherwise>
						<div class="optionalPlaceholder" xd:xmlToEdit="Properties_58" tabIndex="0" align="left" style="WIDTH: 792px">Add Custom Properties</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div> </div>
			<div><xsl:apply-templates select="exp:ExperimentLog" mode="_61"/>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Properties" mode="_59">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 792px; HEIGHT: 102px" align="left" xd:xctname="Section" xd:CtrlId="CTRL339" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<em>
					<font size="3">Experiment Run Properties</font>
				</em>
			</div>
			<div>
				<em>
					<font size="3"></font>
				</em> </div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 800px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL334">
					<colgroup>
						<col style="WIDTH: 140px"></col>
						<col style="WIDTH: 359px"></col>
						<col style="WIDTH: 138px"></col>
						<col style="WIDTH: 163px"></col>
					</colgroup>
					<tbody class="xdTableHeader">
						<tr style="MIN-HEIGHT: 18px">
							<td>
								<strong>Name</strong>
							</td>
							<td>
								<strong>PropertyId</strong>
							</td>
							<td>
								<strong>Value Type</strong>
							</td>
							<td>
								<strong>Simple Val</strong>
							</td>
						</tr>
					</tbody><tbody xd:xctname="repeatingtable">
						<xsl:for-each select="exp:SimpleVal">
							<tr>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL340" xd:binding="@Name" style="WIDTH: 100%">
										<xsl:value-of select="@Name"/>
									</span>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL601" xd:binding="@OntologyEntryURI" style="WIDTH: 100%">
										<xsl:value-of select="@OntologyEntryURI"/>
									</span>
								</td>
								<td><select class="xdComboBox xdBehavior_Select" title="" size="1" tabIndex="0" xd:xctname="DropDown" xd:CtrlId="CTRL342" xd:binding="@ValueType" xd:boundProp="value" style="WIDTH: 100%">
										<xsl:attribute name="value">
											<xsl:value-of select="@ValueType"/>
										</xsl:attribute>
										<option value="">
											<xsl:if test="@ValueType=&quot;&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Select...</option>
										<option value="String">
											<xsl:if test="@ValueType=&quot;String&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>String</option>
										<option value="PropertyURI">
											<xsl:if test="@ValueType=&quot;PropertyURI&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>PropertyURI</option>
										<option value="Integer">
											<xsl:if test="@ValueType=&quot;Integer&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Integer</option>
										<option value="FileLink">
											<xsl:if test="@ValueType=&quot;FileLink&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>FileLink</option>
										<option value="DateTime">
											<xsl:if test="@ValueType=&quot;DateTime&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>DateTime</option>
										<option value="Double">
											<xsl:if test="@ValueType=&quot;Double&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Double</option>
									</select>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL343" xd:binding="." style="WIDTH: 100%">
										<xsl:value-of select="."/>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_60" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 800px">Insert item</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:ExperimentLog" mode="_61">
		<div class="xdSection xdRepeating" title="" style="BORDER-TOP: #ffffff 1pt; MARGIN-BOTTOM: 6px; WIDTH: 802px" align="left" xd:xctname="Section" xd:CtrlId="CTRL370" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<strong>
					<font size="4">
						<em>Experiment Log</em>
					</font>
				</strong>
			</div>
			<div> </div>
			<div><xsl:apply-templates select="exp:ExperimentLogEntry" mode="_62"/>
				<div class="optionalPlaceholder" xd:xmlToEdit="ExperimentLogEntry_80" tabIndex="0" xd:action="xCollection::insert" align="left" style="WIDTH: 100%">Insert item</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:ExperimentLogEntry" mode="_62">
		<div class="xdRepeatingSection xdRepeating" title="" style="BORDER-RIGHT: #000000 1pt solid; BORDER-TOP: #000000 1pt solid; MARGIN-BOTTOM: 6px; BORDER-LEFT: #000000 1pt solid; WIDTH: 100%; BORDER-BOTTOM: #000000 1pt solid" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL371" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<table class="xdLayout" style="BORDER-RIGHT: medium none; TABLE-LAYOUT: fixed; BORDER-TOP: medium none; BORDER-LEFT: medium none; WIDTH: 482px; BORDER-BOTTOM: medium none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word" borderColor="buttontext" border="1">
					<colgroup>
						<col style="WIDTH: 164px"></col>
						<col style="WIDTH: 122px"></col>
						<col style="WIDTH: 196px"></col>
					</colgroup>
					<tbody vAlign="top">
						<tr>
							<td>
								<div align="left">
									<font face="Verdana" size="3">
										<strong>Action Sequence:</strong>
									</font>
								</div>
							</td>
							<td>
								<font face="Verdana" size="2">
									<div><span class="xdTextBox xdBehavior_Formatting" hideFocus="1" title="" contentEditable="true" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL374" xd:binding="@ActionSequenceRef" xd:datafmt="&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;" xd:boundProp="xd:num" style="WIDTH: 100%">
											<xsl:attribute name="xd:num">
												<xsl:value-of select="@ActionSequenceRef"/>
											</xsl:attribute>
											<xsl:choose>
												<xsl:when test="function-available('xdFormatting:formatString')">
													<xsl:value-of select="xdFormatting:formatString(@ActionSequenceRef,&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;)"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="@ActionSequenceRef"/>
												</xsl:otherwise>
											</xsl:choose>
										</span>
									</div>
								</font>
							</td>
							<td>
								<font face="Verdana" size="2">
									<div> </div>
								</font>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div> </div>
			<div><xsl:choose>
					<xsl:when test="exp:CommonParametersApplied">
						<xsl:apply-templates select="exp:CommonParametersApplied" mode="_63"/>
					</xsl:when>
					<xsl:otherwise>
						<div class="optionalPlaceholder" xd:xmlToEdit="CommonParametersApplied_114" tabIndex="0" align="left" style="WIDTH: 100%">Parameters applied to all instances</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div> </div>
			<div><xsl:choose>
					<xsl:when test="exp:ApplicationInstanceCollection">
						<xsl:apply-templates select="exp:ApplicationInstanceCollection" mode="_64"/>
					</xsl:when>
					<xsl:otherwise>
						<div class="optionalPlaceholder" xd:xmlToEdit="ApplicationInstanceCollection_115" tabIndex="0" align="left" style="WIDTH: 100%">Describe specific instances</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:CommonParametersApplied" mode="_63">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%; HEIGHT: 118px" align="left" xd:xctname="Section" xd:CtrlId="CTRL381" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<font size="3">
					<em>Parameters applied to all instances</em>
				</font>
			</div>
			<div> </div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 750px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL376">
					<colgroup>
						<col style="WIDTH: 150px"></col>
						<col style="WIDTH: 250px"></col>
						<col style="WIDTH: 100px"></col>
						<col style="WIDTH: 250px"></col>
					</colgroup>
					<tbody class="xdTableHeader">
						<tr style="MIN-HEIGHT: 19px">
							<td>
								<strong>Name</strong>
							</td>
							<td>
								<strong>Property ID</strong>
							</td>
							<td>
								<strong>Value Type</strong>
							</td>
							<td>
								<strong>Simple Val</strong>
							</td>
						</tr>
					</tbody><tbody xd:xctname="repeatingtable">
						<xsl:for-each select="exp:SimpleVal">
							<tr style="MIN-HEIGHT: 27px">
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL382" xd:binding="@Name" style="WIDTH: 100%">
										<xsl:value-of select="@Name"/>
									</span>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL386" xd:binding="@OntologyEntryURI" style="WIDTH: 100%">
										<xsl:value-of select="@OntologyEntryURI"/>
									</span>
								</td>
								<td><select class="xdComboBox xdBehavior_Select" title="" size="1" tabIndex="0" xd:xctname="DropDown" xd:CtrlId="CTRL384" xd:binding="@ValueType" xd:boundProp="value" style="WIDTH: 100%">
										<xsl:attribute name="value">
											<xsl:value-of select="@ValueType"/>
										</xsl:attribute>
										<option value="">
											<xsl:if test="@ValueType=&quot;&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Select...</option>
										<option value="String">
											<xsl:if test="@ValueType=&quot;String&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>String</option>
										<option value="PropertyURI">
											<xsl:if test="@ValueType=&quot;PropertyURI&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>PropertyURI</option>
										<option value="Integer">
											<xsl:if test="@ValueType=&quot;Integer&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Integer</option>
										<option value="FileLink">
											<xsl:if test="@ValueType=&quot;FileLink&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>FileLink</option>
										<option value="DateTime">
											<xsl:if test="@ValueType=&quot;DateTime&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>DateTime</option>
										<option value="Double">
											<xsl:if test="@ValueType=&quot;Double&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Double</option>
									</select>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL385" xd:binding="." style="WIDTH: 100%">
										<xsl:value-of select="."/>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_93" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 750px">Insert item</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:ApplicationInstanceCollection" mode="_64">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="Section" xd:CtrlId="CTRL387" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<font size="3">
					<em>Instance nstance details</em>
				</font>
			</div>
			<div> </div>
			<div><xsl:apply-templates select="exp:InstanceDetails" mode="_65"/>
				<div class="optionalPlaceholder" xd:xmlToEdit="InstanceDetails_99" tabIndex="0" xd:action="xCollection::insert" align="left" style="WIDTH: 100%">Add instance</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:InstanceDetails" mode="_65">
		<div class="xdRepeatingSection xdRepeating" title="" style="BORDER-RIGHT: #000000 1pt dashed; BORDER-TOP: #000000 1pt dashed; MARGIN-BOTTOM: 6px; BORDER-LEFT: #000000 1pt dashed; WIDTH: 100%; BORDER-BOTTOM: #000000 1pt dashed" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL389" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<table class="xdLayout" style="BORDER-RIGHT: medium none; TABLE-LAYOUT: fixed; BORDER-TOP: medium none; BORDER-LEFT: medium none; WIDTH: 213px; BORDER-BOTTOM: medium none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word" borderColor="buttontext" border="1">
					<colgroup>
						<col style="WIDTH: 123px"></col>
						<col style="WIDTH: 90px"></col>
					</colgroup>
					<tbody vAlign="top">
						<tr style="MIN-HEIGHT: 35px">
							<td style="PADDING-RIGHT: 1px; PADDING-LEFT: 1px; PADDING-BOTTOM: 1px; VERTICAL-ALIGN: middle; PADDING-TOP: 1px">
								<div>
									<font face="Verdana" size="+0">
										<font size="3">
											<strong>Instance #</strong>
										</font>
									</font>
								</div>
							</td>
							<td style="PADDING-RIGHT: 1px; PADDING-LEFT: 1px; PADDING-BOTTOM: 1px; VERTICAL-ALIGN: middle; PADDING-TOP: 1px">
								<div>
									<em>
										<u>
											<font face="Verdana" size="+0"><span class="xdExpressionBox xdDataBindingUI" title="" tabIndex="-1" xd:xctname="ExpressionBox" xd:CtrlId="CTRL599" xd:disableEditing="yes" style="WIDTH: 79px">
													<xsl:value-of select="position()"/>
												</span>
											</font>
										</u>
									</em>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div>
				<font size="3">
					<em>
						<u>Named inputs</u>
					</em>
				</font>
			</div>
			<div><xsl:apply-templates select="exp:InstanceInputs/exp:MaterialLSID" mode="_115"/>
				<div class="optionalPlaceholder" xd:xmlToEdit="MaterialLSID_121" tabIndex="0" xd:action="xCollection::insert" align="left" style="WIDTH: 100.1%">Material Input</div>
			</div>
			<div/>
			<div/>
			<div><xsl:apply-templates select="exp:InstanceInputs/exp:DataLSID" mode="_117"/>
				<div class="optionalPlaceholder" xd:xmlToEdit="DataLSID_125" tabIndex="0" xd:action="xCollection::insert" align="left" style="WIDTH: 100%">Data Input</div>
			</div>
			<div><xsl:choose>
					<xsl:when test="exp:InstanceParametersApplied">
						<xsl:apply-templates select="exp:InstanceParametersApplied" mode="_66"/>
					</xsl:when>
					<xsl:otherwise>
						<div class="optionalPlaceholder" xd:xmlToEdit="InstanceParametersApplied_116" tabIndex="0" align="left" style="WIDTH: 100%">Instance-specific parameters</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:MaterialLSID" mode="_115">
		<div class="xdRepeatingSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100.1%; HEIGHT: 38px" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL591" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<table class="xdLayout" style="BORDER-RIGHT: medium none; TABLE-LAYOUT: fixed; BORDER-TOP: medium none; BORDER-LEFT: medium none; WIDTH: 750px; BORDER-BOTTOM: medium none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word" borderColor="buttontext" border="1">
					<colgroup>
						<col style="WIDTH: 223px"></col>
						<col style="WIDTH: 527px"></col>
					</colgroup>
					<tbody vAlign="top">
						<tr style="MIN-HEIGHT: 26px">
							<td>
								<div>
									<font face="Verdana" size="2">
										<font face="Verdana" size="2">
											<strong>Input Material ID: </strong>
										</font>
									</font>
								</div>
							</td>
							<td>
								<div>
									<font face="Verdana" size="2"><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL592" xd:binding="." style="WIDTH: 100%">
											<xsl:value-of select="."/>
										</span>
									</font>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:DataLSID" mode="_117">
		<div class="xdRepeatingSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL595" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<table class="xdLayout" style="BORDER-RIGHT: medium none; TABLE-LAYOUT: fixed; BORDER-TOP: medium none; BORDER-LEFT: medium none; WIDTH: 750px; BORDER-BOTTOM: medium none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word" borderColor="buttontext" border="1">
					<colgroup>
						<col style="WIDTH: 223px"></col>
						<col style="WIDTH: 527px"></col>
					</colgroup>
					<tbody vAlign="top">
						<tr style="MIN-HEIGHT: 26px">
							<td>
								<div>
									<font face="Verdana" size="2">
										<font face="Verdana" size="2">
											<strong>Input Data ID: </strong>
										</font>
									</font>
								</div>
							</td>
							<td>
								<div>
									<font face="Verdana" size="2"><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL597" xd:binding="." style="WIDTH: 100%">
											<xsl:value-of select="."/>
										</span>
									</font>
								</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 26px">
							<td>
								<div>
									<font face="Verdana" size="2">
										<font face="Verdana" size="2"> <em>or</em>
											<strong>Data File</strong>
										</font>
									</font>
								</div>
							</td>
							<td>
								<div>
									<font face="Verdana" size="2"><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL598" xd:binding="@DataFileUrl" style="WIDTH: 100%">
											<xsl:value-of select="@DataFileUrl"/>
										</span>
									</font>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div> </div>
		</div>
	</xsl:template>
	<xsl:template match="exp:InstanceParametersApplied" mode="_66">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="Section" xd:CtrlId="CTRL407" tabIndex="-1" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">
			<div>
				<em>
					<u>
						<font size="3">Instance-specific parameter values</font>
					</u>
				</em>
			</div>
			<div> </div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 750px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL408">
					<colgroup>
						<col style="WIDTH: 98px"></col>
						<col style="WIDTH: 302px"></col>
						<col style="WIDTH: 178px"></col>
						<col style="WIDTH: 172px"></col>
					</colgroup>
					<tbody class="xdTableHeader">
						<tr>
							<td>
								<div>
									<strong>Name</strong>
								</div>
							</td>
							<td>
								<div>
									<strong>Paarameter ID</strong>
								</div>
							</td>
							<td>
								<div>
									<strong>Value Type</strong>
								</div>
							</td>
							<td>
								<div>
									<strong>Simple Val</strong>
								</div>
							</td>
						</tr>
					</tbody><tbody xd:xctname="RepeatingTable">
						<xsl:for-each select="exp:SimpleVal">
							<tr style="MIN-HEIGHT: 28px">
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL409" xd:binding="@Name" style="WIDTH: 100%">
										<xsl:value-of select="@Name"/>
									</span>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL414" xd:binding="@OntologyEntryURI" style="WIDTH: 100%">
										<xsl:value-of select="@OntologyEntryURI"/>
									</span>
								</td>
								<td><select class="xdComboBox xdBehavior_Select" title="" size="1" tabIndex="0" xd:xctname="DropDown" xd:CtrlId="CTRL411" xd:binding="@ValueType" xd:boundProp="value" style="WIDTH: 100%">
										<xsl:attribute name="value">
											<xsl:value-of select="@ValueType"/>
										</xsl:attribute>
										<option value="">
											<xsl:if test="@ValueType=&quot;&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Select...</option>
										<option value="String">
											<xsl:if test="@ValueType=&quot;String&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>String</option>
										<option value="PropertyURI">
											<xsl:if test="@ValueType=&quot;PropertyURI&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>PropertyURI</option>
										<option value="Integer">
											<xsl:if test="@ValueType=&quot;Integer&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Integer</option>
										<option value="FileLink">
											<xsl:if test="@ValueType=&quot;FileLink&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>FileLink</option>
										<option value="DateTime">
											<xsl:if test="@ValueType=&quot;DateTime&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>DateTime</option>
										<option value="Double">
											<xsl:if test="@ValueType=&quot;Double&quot;">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>Double</option>
									</select>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL412" xd:binding="." style="WIDTH: 100%">
										<xsl:value-of select="."/>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_102" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 750px">Insert item</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
