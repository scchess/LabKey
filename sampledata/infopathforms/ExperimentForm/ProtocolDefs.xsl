<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:exp="http://cpas.fhcrc.org/exp/xml" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-11-05T06:56:29" xmlns:xd="http://schemas.microsoft.com/office/infopath/2003" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:xdExtension="http://schemas.microsoft.com/office/infopath/2003/xslt/extension" xmlns:xdXDocument="http://schemas.microsoft.com/office/infopath/2003/xslt/xDocument" xmlns:xdSolution="http://schemas.microsoft.com/office/infopath/2003/xslt/solution" xmlns:xdFormatting="http://schemas.microsoft.com/office/infopath/2003/xslt/formatting" xmlns:xdImage="http://schemas.microsoft.com/office/infopath/2003/xslt/xImage" xmlns:xdUtil="http://schemas.microsoft.com/office/infopath/2003/xslt/Util" xmlns:xdMath="http://schemas.microsoft.com/office/infopath/2003/xslt/Math" xmlns:xdDate="http://schemas.microsoft.com/office/infopath/2003/xslt/Date" xmlns:sig="http://www.w3.org/2000/09/xmldsig#" xmlns:xdSignatureProperties="http://schemas.microsoft.com/office/infopath/2003/SignatureProperties">
	<xsl:output method="html" indent="no"/>
	<xsl:template match="exp:ExperimentArchive">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html"></meta>
				<style controlStyle="controlStyle">@media screen 			{ 			BODY{margin-left:21px;background-position:21px 0px;} 			} 		BODY{color:windowtext;background-color:window;layout-grid:none;} 		.xdListItem {display:inline-block;width:100%;vertical-align:text-top;} 		.xdListBox,.xdComboBox{margin:1px;} 		.xdInlinePicture{margin:1px; BEHAVIOR: url(#default#urn::xdPicture) } 		.xdLinkedPicture{margin:1px; BEHAVIOR: url(#default#urn::xdPicture) url(#default#urn::controls/Binder) } 		.xdSection{border:1pt solid #FFFFFF;margin:6px 0px 6px 0px;padding:1px 1px 1px 5px;} 		.xdRepeatingSection{border:1pt solid #FFFFFF;margin:6px 0px 6px 0px;padding:1px 1px 1px 5px;} 		.xdBehavior_Formatting {BEHAVIOR: url(#default#urn::controls/Binder) url(#default#Formatting);} 	 .xdBehavior_FormattingNoBUI{BEHAVIOR: url(#default#CalPopup) url(#default#urn::controls/Binder) url(#default#Formatting);} 	.xdExpressionBox{margin: 1px;padding:1px;word-wrap: break-word;text-overflow: ellipsis;overflow-x:hidden;}.xdBehavior_GhostedText,.xdBehavior_GhostedTextNoBUI{BEHAVIOR: url(#default#urn::controls/Binder) url(#default#TextField) url(#default#GhostedText);}	.xdBehavior_GTFormatting{BEHAVIOR: url(#default#urn::controls/Binder) url(#default#Formatting) url(#default#GhostedText);}	.xdBehavior_GTFormattingNoBUI{BEHAVIOR: url(#default#CalPopup) url(#default#urn::controls/Binder) url(#default#Formatting) url(#default#GhostedText);}	.xdBehavior_Boolean{BEHAVIOR: url(#default#urn::controls/Binder) url(#default#BooleanHelper);}	.xdBehavior_Select{BEHAVIOR: url(#default#urn::controls/Binder) url(#default#SelectHelper);}	.xdRepeatingTable{BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word;}.xdScrollableRegion{BEHAVIOR: url(#default#ScrollableRegion);} 		.xdMaster{BEHAVIOR: url(#default#MasterHelper);} 		.xdActiveX{margin:1px; BEHAVIOR: url(#default#ActiveX);} 		.xdFileAttachment{display:inline-block;margin:1px;BEHAVIOR:url(#default#urn::xdFileAttachment);} 		.xdPageBreak{display: none;}BODY{margin-right:21px;} 		.xdTextBoxRTL{display:inline-block;white-space:nowrap;text-overflow:ellipsis;;padding:1px;margin:1px;border: 1pt solid #dcdcdc;color:windowtext;background-color:window;overflow:hidden;text-align:right;} 		.xdRichTextBoxRTL{display:inline-block;;padding:1px;margin:1px;border: 1pt solid #dcdcdc;color:windowtext;background-color:window;overflow-x:hidden;word-wrap:break-word;text-overflow:ellipsis;text-align:right;font-weight:normal;font-style:normal;text-decoration:none;vertical-align:baseline;} 		.xdDTTextRTL{height:100%;width:100%;margin-left:22px;overflow:hidden;padding:0px;white-space:nowrap;} 		.xdDTButtonRTL{margin-right:-21px;height:18px;width:20px;behavior: url(#default#DTPicker);}.xdTextBox{display:inline-block;white-space:nowrap;text-overflow:ellipsis;;padding:1px;margin:1px;border: 1pt solid #dcdcdc;color:windowtext;background-color:window;overflow:hidden;text-align:left;} 		.xdRichTextBox{display:inline-block;;padding:1px;margin:1px;border: 1pt solid #dcdcdc;color:windowtext;background-color:window;overflow-x:hidden;word-wrap:break-word;text-overflow:ellipsis;text-align:left;font-weight:normal;font-style:normal;text-decoration:none;vertical-align:baseline;} 		.xdDTPicker{;display:inline;margin:1px;margin-bottom: 2px;border: 1pt solid #dcdcdc;color:windowtext;background-color:window;overflow:hidden;} 		.xdDTText{height:100%;width:100%;margin-right:22px;overflow:hidden;padding:0px;white-space:nowrap;} 		.xdDTButton{margin-left:-21px;height:18px;width:20px;behavior: url(#default#DTPicker);} 		.xdRepeatingTable TD {VERTICAL-ALIGN: top;}</style>
				<style tableEditor="TableStyleRulesID" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">TABLE.xdLayout TD {
	BORDER-RIGHT: medium none; BORDER-TOP: medium none; BORDER-LEFT: medium none; BORDER-BOTTOM: medium none
}
TABLE.msoUcTable TD {
	BORDER-RIGHT: 1pt solid; BORDER-TOP: 1pt solid; BORDER-LEFT: 1pt solid; BORDER-BOTTOM: 1pt solid
}
TABLE {
	BEHAVIOR: url (#default#urn::tables/NDTable)
}
</style>
				<style languageStyle="languageStyle" xmlns:my="http://schemas.microsoft.com/office/infopath/2003/myXSD/2005-10-13T17:36:32">BODY {
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
					<font size="5">Xar.xml Editor:  </font>
					<font size="5">Define Protocols </font>
				</div>
				<div>
					<font size="5"><input class="langFont" title="" type="button" value="Describe Run" xd:xctname="Button" xd:CtrlId="btnRunView" tabIndex="0"/>
					</font>
				</div>
				<div>
					<font size="5"></font> </div>
				<font size="5"></font>
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
						</tbody>
					</table>
				</div>
				<div> </div>
				<div><xsl:apply-templates select="exp:ProtocolDefinitions" mode="_1"/>
				</div>
				<div><xsl:apply-templates select="exp:ProtocolActionDefinitions" mode="_5"/>
				</div>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="exp:ProtocolDefinitions" mode="_1">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 833px; HEIGHT: 620px" align="left" xd:xctname="Section" xd:CtrlId="CTRL110" tabIndex="-1">
			<div> </div>
			<div><xsl:apply-templates select="exp:Protocol" mode="_2"/>
				<div class="optionalPlaceholder" xd:xmlToEdit="Protocol_1" tabIndex="0" xd:action="xCollection::insert" align="left" style="WIDTH: 100%">Insert item</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Protocol" mode="_2">
		<div class="xdRepeatingSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL111" tabIndex="-1">
			<div>
				<font size="3">
					<em>Protocol</em>
				</font>
			</div>
			<div> </div>
			<div>
				<table class="msoUcTable" style="TABLE-LAYOUT: fixed; WIDTH: 760px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1">
					<colgroup>
						<col style="WIDTH: 108px"></col>
						<col style="WIDTH: 108px"></col>
						<col style="WIDTH: 241px"></col>
						<col style="WIDTH: 303px"></col>
					</colgroup>
					<tbody>
						<tr>
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong>Name</strong>
								</div>
							</td>
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL1" xd:binding="exp:Name" style="WIDTH: 100%">
										<xsl:value-of select="exp:Name"/>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong>LSID</strong>
								</div>
							</td>
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL138" xd:binding="@rdf:about" style="WIDTH: 100%">
										<xsl:value-of select="@rdf:about"/>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>Application Type</div>
							</td>
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL55" xd:binding="../exp:Protocol[1]/exp:ApplicationType" style="WIDTH: 100%">
										<xsl:value-of select="../exp:Protocol[1]/exp:ApplicationType"/>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div> </div>
							</td>
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div> </div>
							</td>
						</tr>
						<tr>
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none"></td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong> Material</strong>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong>Data</strong>
								</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 24px">
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong>Inputs </strong>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div># per instance</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox xdBehavior_Formatting" hideFocus="1" title="" contentEditable="true" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL56" xd:binding="../exp:Protocol[1]/exp:MaxInputMaterialPerInstance" xd:datafmt="&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;" xd:boundProp="xd:num" style="WIDTH: 50px">
										<xsl:attribute name="xd:num">
											<xsl:value-of select="../exp:Protocol[1]/exp:MaxInputMaterialPerInstance"/>
										</xsl:attribute>
										<xsl:choose>
											<xsl:when test="function-available('xdFormatting:formatString')">
												<xsl:value-of select="xdFormatting:formatString(../exp:Protocol[1]/exp:MaxInputMaterialPerInstance,&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;)"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="../exp:Protocol[1]/exp:MaxInputMaterialPerInstance"/>
											</xsl:otherwise>
										</xsl:choose>
									</span>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox xdBehavior_Formatting" hideFocus="1" title="" contentEditable="true" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL57" xd:binding="../exp:Protocol[1]/exp:MaxInputDataPerInstance" xd:datafmt="&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;" xd:boundProp="xd:num" style="WIDTH: 50px">
										<xsl:attribute name="xd:num">
											<xsl:value-of select="../exp:Protocol[1]/exp:MaxInputDataPerInstance"/>
										</xsl:attribute>
										<xsl:choose>
											<xsl:when test="function-available('xdFormatting:formatString')">
												<xsl:value-of select="xdFormatting:formatString(../exp:Protocol[1]/exp:MaxInputDataPerInstance,&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;)"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="../exp:Protocol[1]/exp:MaxInputDataPerInstance"/>
											</xsl:otherwise>
										</xsl:choose>
									</span>
								</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 25px">
							<td rowSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong>Outputs</strong>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div># per instance</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox xdBehavior_Formatting" hideFocus="1" title="" contentEditable="true" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL58" xd:binding="../exp:Protocol[1]/exp:OutputMaterialPerInstance" xd:datafmt="&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;" xd:boundProp="xd:num" style="WIDTH: 50px">
										<xsl:attribute name="xd:num">
											<xsl:value-of select="../exp:Protocol[1]/exp:OutputMaterialPerInstance"/>
										</xsl:attribute>
										<xsl:choose>
											<xsl:when test="function-available('xdFormatting:formatString')">
												<xsl:value-of select="xdFormatting:formatString(../exp:Protocol[1]/exp:OutputMaterialPerInstance,&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;)"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="../exp:Protocol[1]/exp:OutputMaterialPerInstance"/>
											</xsl:otherwise>
										</xsl:choose>
									</span>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox xdBehavior_Formatting" hideFocus="1" title="" contentEditable="true" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL59" xd:binding="../exp:Protocol[1]/exp:OutputDataPerInstance" xd:datafmt="&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;" xd:boundProp="xd:num" style="WIDTH: 50px">
										<xsl:attribute name="xd:num">
											<xsl:value-of select="../exp:Protocol[1]/exp:OutputDataPerInstance"/>
										</xsl:attribute>
										<xsl:choose>
											<xsl:when test="function-available('xdFormatting:formatString')">
												<xsl:value-of select="xdFormatting:formatString(../exp:Protocol[1]/exp:OutputDataPerInstance,&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;)"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="../exp:Protocol[1]/exp:OutputDataPerInstance"/>
											</xsl:otherwise>
										</xsl:choose>
									</span>
								</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 25px">
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>Type</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL60" xd:binding="../exp:Protocol[1]/exp:OutputMaterialType" style="WIDTH: 100%">
										<xsl:value-of select="../exp:Protocol[1]/exp:OutputMaterialType"/>
									</span>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL61" xd:binding="../exp:Protocol[1]/exp:OutputDataType" style="WIDTH: 100%">
										<xsl:value-of select="../exp:Protocol[1]/exp:OutputDataType"/>
									</span>
								</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 25px">
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>
									<strong/> </div>
							</td>
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div> </div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 25px">
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>Protocol Description: </div>
							</td>
							<td colSpan="2" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL160" xd:binding="exp:ProtocolDescription" xd:datafmt="&quot;string&quot;,&quot;plainMultiline&quot;" style="WIDTH: 100%; WHITE-SPACE: normal; HEIGHT: 60px">
										<xsl:choose>
											<xsl:when test="function-available('xdFormatting:formatString')">
												<xsl:value-of select="xdFormatting:formatString(exp:ProtocolDescription,&quot;string&quot;,&quot;plainMultiline&quot;)" disable-output-escaping="yes"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="exp:ProtocolDescription" disable-output-escaping="yes"/>
											</xsl:otherwise>
										</xsl:choose>
									</span>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div><xsl:apply-templates select="exp:ParameterDeclarations" mode="_3"/>
			</div>
			<div><xsl:choose>
					<xsl:when test="exp:Properties">
						<xsl:apply-templates select="exp:Properties" mode="_4"/>
					</xsl:when>
					<xsl:otherwise>
						<div class="optionalPlaceholder" xd:xmlToEdit="Properties_3" tabIndex="0" align="left" style="WIDTH: 100%">Add custom protocol properties</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:ParameterDeclarations" mode="_3">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%; HEIGHT: 91px" align="left" xd:xctname="Section" xd:CtrlId="CTRL139" tabIndex="-1">
			<div>
				<font size="3">
					<em>Parameters</em>
				</font>
			</div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 800px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL159">
					<colgroup>
						<col style="WIDTH: 150px"></col>
						<col style="WIDTH: 300px"></col>
						<col style="WIDTH: 100px"></col>
						<col style="WIDTH: 250px"></col>
					</colgroup>
					<tbody class="xdTableHeader">
						<tr style="MIN-HEIGHT: 19px">
							<td>
								<div>
									<strong>Label</strong>
								</div>
							</td>
							<td>
								<div>
									<strong>Parameter ID</strong>
								</div>
							</td>
							<td>
								<div>
									<strong>Value Type</strong>
								</div>
							</td>
							<td>
								<strong>Default Value</strong>
							</td>
						</tr>
					</tbody><tbody xd:xctname="repeatingtable">
						<xsl:for-each select="exp:SimpleVal">
							<tr style="MIN-HEIGHT: 27px">
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL345" xd:binding="@Name" style="WIDTH: 100%">
										<xsl:value-of select="@Name"/>
									</span>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL145" xd:binding="@OntologyEntryURI" style="WIDTH: 100%">
										<xsl:value-of select="@OntologyEntryURI"/>
									</span>
								</td>
								<td><select class="xdComboBox xdBehavior_Select" title="" size="1" tabIndex="0" xd:xctname="DropDown" xd:CtrlId="CTRL143" xd:binding="@ValueType" xd:boundProp="value" style="WIDTH: 100%">
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
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL158" xd:binding="." style="WIDTH: 100%">
										<xsl:value-of select="."/>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_5" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 800px">Insert item</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Properties" mode="_4">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="Section" xd:CtrlId="CTRL146" tabIndex="-1">
			<div>
				<em>
					<font size="3">Properties</font>
				</em>
			</div>
			<div>
				<em>
					<font size="3"></font>
				</em> </div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 724px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL156">
					<colgroup>
						<col style="WIDTH: 181px"></col>
						<col style="WIDTH: 181px"></col>
						<col style="WIDTH: 125px"></col>
						<col style="WIDTH: 237px"></col>
					</colgroup>
					<tbody class="xdTableHeader">
						<tr>
							<td>
								<strong>Label</strong>
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
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL152" xd:binding="@Name" style="WIDTH: 100%">
										<xsl:value-of select="@Name"/>
									</span>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL347" xd:binding="@OntologyEntryURI" style="WIDTH: 100%">
										<xsl:value-of select="@OntologyEntryURI"/>
									</span>
								</td>
								<td><select class="xdComboBox xdBehavior_Select" title="" size="1" tabIndex="0" xd:xctname="DropDown" xd:CtrlId="CTRL154" xd:binding="@ValueType" xd:boundProp="value" style="WIDTH: 100%">
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
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL155" xd:binding="." style="WIDTH: 100%">
										<xsl:value-of select="."/>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_6" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 724px">Insert item</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:ProtocolActionDefinitions" mode="_5">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 729px" align="left" xd:xctname="Section" xd:CtrlId="CTRL3">
			<div>
				<strong>
					<font size="3">Protocol Actions</font>
				</strong>
			</div>
			<div><xsl:apply-templates select="exp:ProtocolActionSet" mode="_6"/>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:ProtocolActionSet" mode="_6">
		<div class="xdRepeatingSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL4">
			<div>
				<font size="3">Run Protocol: </font>  <select class="xdComboBox xdBehavior_Select" title="" style="WIDTH: 390px" size="1" xd:xctname="DropDown" xd:CtrlId="CTRL5" xd:binding="@ParentProtocolLSID" xd:boundProp="value" value="">
					<xsl:attribute name="value">
						<xsl:value-of select="@ParentProtocolLSID"/>
					</xsl:attribute>
					<xsl:choose>
						<xsl:when test="function-available('xdXDocument:GetDOM')">
							<option/>
							<xsl:variable name="val" select="@ParentProtocolLSID"/>
							<xsl:if test="not(../../exp:ProtocolDefinitions/exp:Protocol[@rdf:about=$val] or $val='')">
								<option selected="selected">
									<xsl:attribute name="value">
										<xsl:value-of select="$val"/>
									</xsl:attribute>
									<xsl:value-of select="$val"/>
								</option>
							</xsl:if>
							<xsl:for-each select="../../exp:ProtocolDefinitions/exp:Protocol">
								<option>
									<xsl:attribute name="value">
										<xsl:value-of select="@rdf:about"/>
									</xsl:attribute>
									<xsl:if test="$val=@rdf:about">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="exp:Name"/>
								</option>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<option>
								<xsl:value-of select="@ParentProtocolLSID"/>
							</option>
						</xsl:otherwise>
					</xsl:choose>
				</select>
			</div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 795px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL173">
					<colgroup>
						<col style="WIDTH: 316px"></col>
						<col style="WIDTH: 148px"></col>
						<col style="WIDTH: 331px"></col>
					</colgroup>
					<tbody class="xdTableHeader">
						<tr>
							<td>
								<strong>Child Protocol LSID</strong>
							</td>
							<td>
								<strong>Action Sequence</strong>
							</td>
							<td>
								<strong>Predecessor Action</strong>
							</td>
						</tr>
					</tbody><tbody xd:xctname="repeatingtable">
						<xsl:for-each select="exp:ProtocolAction">
							<tr>
								<td>
									<select class="xdComboBox xdBehavior_Select" title="" style="WIDTH: 100%" size="1" xd:xctname="DropDown" xd:CtrlId="CTRL10" xd:binding="@ChildProtocolLSID" xd:boundProp="value" value="" tabIndex="0">
										<xsl:attribute name="value">
											<xsl:value-of select="@ChildProtocolLSID"/>
										</xsl:attribute>
										<xsl:choose>
											<xsl:when test="function-available('xdXDocument:GetDOM')">
												<option/>
												<xsl:variable name="val" select="@ChildProtocolLSID"/>
												<xsl:if test="not(../../../exp:ProtocolDefinitions/exp:Protocol[@rdf:about=$val] or $val='')">
													<option selected="selected">
														<xsl:attribute name="value">
															<xsl:value-of select="$val"/>
														</xsl:attribute>
														<xsl:value-of select="$val"/>
													</option>
												</xsl:if>
												<xsl:for-each select="../../../exp:ProtocolDefinitions/exp:Protocol">
													<option>
														<xsl:attribute name="value">
															<xsl:value-of select="@rdf:about"/>
														</xsl:attribute>
														<xsl:if test="$val=@rdf:about">
															<xsl:attribute name="selected">selected</xsl:attribute>
														</xsl:if>
														<xsl:value-of select="exp:Name"/>
													</option>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<option>
													<xsl:value-of select="@ChildProtocolLSID"/>
												</option>
											</xsl:otherwise>
										</xsl:choose>
									</select>
								</td>
								<td><span class="xdTextBox xdBehavior_Formatting" hideFocus="1" title="" contentEditable="true" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL7" xd:binding="@ActionSequence" xd:datafmt="&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;" xd:boundProp="xd:num" style="WIDTH: 180px">
										<xsl:attribute name="xd:num">
											<xsl:value-of select="@ActionSequence"/>
										</xsl:attribute>
										<xsl:choose>
											<xsl:when test="function-available('xdFormatting:formatString')">
												<xsl:value-of select="xdFormatting:formatString(@ActionSequence,&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;)"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="@ActionSequence"/>
											</xsl:otherwise>
										</xsl:choose>
									</span>
								</td>
								<td>
									<div>
										<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 263px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL8">
											<colgroup>
												<col style="WIDTH: 263px"></col>
											</colgroup>
											<tbody class="xdTableHeader">
												<tr>
													<td/>
												</tr>
											</tbody><tbody xd:xctname="RepeatingTable">
												<xsl:for-each select="exp:PredecessorAction">
													<tr>
														<td><span class="xdTextBox xdBehavior_Formatting" hideFocus="1" title="" contentEditable="true" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL9" xd:binding="@ActionSequenceRef" xd:datafmt="&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;" xd:boundProp="xd:num" style="WIDTH: 100%">
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
														</td>
													</tr>
												</xsl:for-each>
											</tbody>
										</table>
										<div class="optionalPlaceholder" xd:xmlToEdit="PredecessorAction_10" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 263px">Insert item</div>
									</div>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
