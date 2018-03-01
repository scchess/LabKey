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
				<div align="left">
					<font size="5">
						<font size="5">Xar.xml Editor: Edit Export Format </font>
					</font>
				</div>
				<div align="left"><input class="langFont" title="" type="button" value="Describe Run" xd:xctname="Button" xd:CtrlId="btnRunView" tabIndex="0"/>
				</div>
				<div align="left"> </div>
				<div><xsl:apply-templates select="exp:ExperimentRuns" mode="_21"/>
				</div>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="exp:ExperimentRuns" mode="_21">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 787px" align="left" xd:xctname="Section" xd:CtrlId="CTRL246" tabIndex="-1">
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
			<div><xsl:apply-templates select="exp:ExperimentRun" mode="_22"/>
				<div class="optionalPlaceholder" xd:xmlToEdit="ExperimentRun_12" tabIndex="0" xd:action="xCollection::insert" align="left" style="WIDTH: 100%">Insert item</div>
			</div>
			<div> </div>
			<div> </div>
			<div> </div>
			<div> </div>
			<div> </div>
		</div>
	</xsl:template>
	<xsl:template match="exp:ExperimentRun" mode="_22">
		<div class="xdRepeatingSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL304" tabIndex="-1">
			<div>Run:  <span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL314" xd:binding="exp:Name" style="WIDTH: 302px">
					<xsl:value-of select="exp:Name"/>
				</span>
			</div>
			<div> </div>
			<div>
				<table class="msoUcTable" style="TABLE-LAYOUT: fixed; WIDTH: 707px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1">
					<colgroup>
						<col style="WIDTH: 116px"></col>
						<col style="WIDTH: 235px"></col>
						<col style="WIDTH: 102px"></col>
						<col style="WIDTH: 254px"></col>
					</colgroup>
					<tbody>
						<tr style="MIN-HEIGHT: 25px">
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>ID</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL315" xd:binding="@rdf:about" style="WIDTH: 100%">
										<xsl:value-of select="@rdf:about"/>
									</span>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div> </div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><input class="xdBehavior_Boolean" title="" type="checkbox" tabIndex="0" xd:xctname="CheckBox" xd:CtrlId="CTRL317" xd:binding="@GenerateDataFromStepRecord" xd:onValue="true" xd:offValue="false" xd:boundProp="xd:value">
										<xsl:attribute name="xd:value">
											<xsl:value-of select="@GenerateDataFromStepRecord"/>
										</xsl:attribute>
										<xsl:if test="@GenerateDataFromStepRecord=&quot;true&quot;">
											<xsl:attribute name="CHECKED">CHECKED</xsl:attribute>
										</xsl:if>
									</input> Generate Data From Step Record</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 26px">
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>Run Protocol</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL316" xd:binding="exp:ProtocolLSID" style="WIDTH: 100%">
										<xsl:value-of select="exp:ProtocolLSID"/>
									</span>
								</div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div> </div>
							</td>
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><input class="xdBehavior_Boolean" title="" type="checkbox" tabIndex="0" xd:xctname="CheckBox" xd:CtrlId="CTRL318" xd:binding="@CreateNewIfDuplicate" xd:onValue="true" xd:offValue="false" xd:boundProp="xd:value">
										<xsl:attribute name="xd:value">
											<xsl:value-of select="@CreateNewIfDuplicate"/>
										</xsl:attribute>
										<xsl:if test="@CreateNewIfDuplicate=&quot;true&quot;">
											<xsl:attribute name="CHECKED">CHECKED</xsl:attribute>
										</xsl:if>
									</input> Create New If Duplicate</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 26px">
							<td style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div>Comments:</div>
							</td>
							<td colSpan="3" style="BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-BOTTOM-STYLE: none">
								<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL321" xd:binding="exp:Comments" style="WIDTH: 100%; HEIGHT: 83px">
										<xsl:value-of select="exp:Comments"/>
									</span>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div> </div>
			<div><xsl:apply-templates select="exp:Properties" mode="_23"/>
			</div>
			<div> </div>
			<div><xsl:apply-templates select="exp:ProtocolApplications" mode="_30"/>
			</div>
			<div> </div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Properties" mode="_23">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 749px; HEIGHT: 99px" align="left" xd:xctname="Section" xd:CtrlId="CTRL339" tabIndex="-1">
			<div>
				<em>
					<font size="3">ExperimentRun Properties</font>
				</em>
			</div>
			<div>
				<em>
					<font size="3"></font>
				</em> </div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 800px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL334">
					<colgroup>
						<col style="WIDTH: 300px"></col>
						<col style="WIDTH: 300px"></col>
						<col style="WIDTH: 100px"></col>
						<col style="WIDTH: 100px"></col>
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
								<td>
									<span class="xdHyperlink" hideFocus="1" title="" style="OVERFLOW: visible; WIDTH: 130px; TEXT-ALIGN: left" xd:xctname="Hyperlink">
										<a class="xdDataBindingUI" tabIndex="0" xd:CtrlId="CTRL341" xd:disableEditing="yes">
											<xsl:attribute name="href">
												<xsl:value-of select="@OntologyEntryURI"/>
											</xsl:attribute>
											<xsl:value-of select="@OntologyEntryURI"/>
										</a>
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
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_36" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 800px">Insert item</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:ProtocolApplications" mode="_30">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="Section" xd:CtrlId="CTRL415" tabIndex="-1">
			<div>
				<strong>
					<font size="4">Export format </font>
				</strong>
			</div>
			<div> </div>
			<div><xsl:apply-templates select="exp:ProtocolApplication" mode="_31"/>
				<div class="optionalPlaceholder" xd:xmlToEdit="ProtocolApplication_22" tabIndex="0" xd:action="xCollection::insert" align="left" style="WIDTH: 100%">Insert item</div>
			</div>
			<div> </div>
			<div> </div>
		</div>
	</xsl:template>
	<xsl:template match="exp:ProtocolApplication" mode="_31">
		<div class="xdRepeatingSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL480" tabIndex="-1">
			<div> </div>
			<div>
				<table class="xdLayout" style="BORDER-RIGHT: medium none; TABLE-LAYOUT: fixed; BORDER-TOP: medium none; BORDER-LEFT: medium none; WIDTH: 746px; BORDER-BOTTOM: medium none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word" borderColor="buttontext" border="1">
					<colgroup>
						<col style="WIDTH: 118px"></col>
						<col style="WIDTH: 628px"></col>
					</colgroup>
					<tbody vAlign="top">
						<tr>
							<td>
								<div>
									<font face="Verdana" size="2">Label</font>
								</div>
							</td>
							<td>
								<div>
									<font face="Verdana" size="2"><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL471" xd:binding="exp:Name" style="WIDTH: 100%">
											<xsl:value-of select="exp:Name"/>
										</span>
									</font>
								</div>
							</td>
						</tr>
						<tr>
							<td>
								<div>
									<font face="Verdana" size="2">Id:</font>
								</div>
							</td>
							<td>
								<div>
									<font face="Verdana" size="2"><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL473" xd:binding="@rdf:about" style="WIDTH: 100%">
											<xsl:value-of select="@rdf:about"/>
										</span>
									</font>
								</div>
							</td>
						</tr>
						<tr>
							<td>
								<div>
									<font face="Verdana" size="2">Type: </font>
								</div>
							</td>
							<td>
								<div>
									<font face="Verdana" size="2"><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL474" xd:binding="exp:CpasType" style="WIDTH: 100%">
											<xsl:value-of select="exp:CpasType"/>
										</span>
									</font>
								</div>
							</td>
						</tr>
						<tr>
							<td>
								<div>
									<font face="Verdana" size="2">
										<font face="Verdana" size="2">Protocol ID: </font>
									</font>
								</div>
							</td>
							<td>
								<div>
									<font face="Verdana" size="2"><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL476" xd:binding="exp:ProtocolLSID" style="WIDTH: 100%">
											<xsl:value-of select="exp:ProtocolLSID"/>
										</span>
									</font>
								</div>
							</td>
						</tr>
						<tr>
							<td>
								<div>
									<font face="Verdana" size="2">
										<font face="Verdana" size="2">
											<font face="Verdana" size="2">Action Sequence: </font>
										</font>
									</font>
								</div>
							</td>
							<td>
								<div>
									<font face="Verdana" size="2"><span class="xdTextBox xdBehavior_Formatting" hideFocus="1" title="" contentEditable="true" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL477" xd:binding="exp:ActionSequence" xd:boundProp="xd:num" xd:datafmt="&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;" style="WIDTH: 100%">
											<xsl:attribute name="xd:num">
												<xsl:value-of select="exp:ActionSequence"/>
											</xsl:attribute>
											<xsl:choose>
												<xsl:when test="function-available('xdFormatting:formatString')">
													<xsl:value-of select="xdFormatting:formatString(exp:ActionSequence,&quot;number&quot;,&quot;numDigits:0;negativeOrder:1;&quot;)"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="exp:ActionSequence"/>
												</xsl:otherwise>
											</xsl:choose>
										</span>
									</font>
								</div>
							</td>
						</tr>
						<tr>
							<td>
								<div>
									<font face="Verdana" size="2">
										<font face="Verdana" size="2">
											<font face="Verdana" size="2">Activity Date: </font>
										</font>
									</font>
								</div>
							</td>
							<td>
								<div>
									<font face="Verdana" size="2">
										<div class="xdDTPicker" title="" style="WIDTH: 100%" noWrap="1" xd:xctname="DTPicker" xd:CtrlId="CTRL478"><span class="xdDTText xdBehavior_FormattingNoBUI" hideFocus="1" contentEditable="true" tabIndex="0" xd:xctname="DTPicker_DTText" xd:binding="exp:ActivityDate" xd:boundProp="xd:num" xd:datafmt="&quot;date&quot;,&quot;dateFormat:Short Date;&quot;" xd:innerCtrl="_DTText">
												<xsl:attribute name="xd:num">
													<xsl:value-of select="exp:ActivityDate"/>
												</xsl:attribute>
												<xsl:choose>
													<xsl:when test="function-available('xdFormatting:formatString')">
														<xsl:value-of select="xdFormatting:formatString(exp:ActivityDate,&quot;date&quot;,&quot;dateFormat:Short Date;&quot;)"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="exp:ActivityDate"/>
													</xsl:otherwise>
												</xsl:choose>
											</span>
											<button class="xdDTButton" xd:xctname="DTPicker_DTButton" xd:innerCtrl="_DTButton" tabIndex="-1">
												<img src="res://infopath.exe/calendar.gif" Linked="true"/>
											</button>
										</div>
									</font>
								</div>
							</td>
						</tr>
						<tr style="MIN-HEIGHT: 26px">
							<td>
								<div>
									<font face="Verdana" size="2">
										<font face="Verdana" size="2">
											<font face="Verdana" size="2">Comments: </font>
										</font>
									</font>
								</div>
							</td>
							<td>
								<div>
									<font face="Verdana" size="2"><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL479" xd:binding="exp:Comments" style="WIDTH: 100%">
											<xsl:value-of select="exp:Comments"/>
										</span>
									</font>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div> </div>
			<div><xsl:apply-templates select="exp:InputRefs" mode="_32"/>
			</div>
			<div><xsl:apply-templates select="exp:ProtocolApplicationParameters" mode="_33"/>
			</div>
			<div><xsl:apply-templates select="exp:OutputMaterials" mode="_34"/>
			</div>
			<div> </div>
			<div> </div>
			<div><xsl:apply-templates select="exp:OutputDataObjects" mode="_37"/>
			</div>
			<div><xsl:apply-templates select="exp:Properties" mode="_40"/>
			</div>
			<div> </div>
		</div>
	</xsl:template>
	<xsl:template match="exp:InputRefs" mode="_32">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="Section" xd:CtrlId="CTRL481" tabIndex="-1">
			<div> </div>
			<div> </div>
			<div>
				<em>
					<font size="3">Inputs</font>
				</em>
			</div>
			<div> </div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 735px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL483">
					<colgroup>
						<col style="WIDTH: 271px"></col>
						<col style="WIDTH: 464px"></col>
					</colgroup>
					<tbody class="xdTableHeader">
						<tr>
							<td>
								<div>
									<strong>Cpas Type</strong>
								</div>
							</td>
							<td>
								<div>
									<strong>Material LSID</strong>
								</div>
							</td>
						</tr>
					</tbody><tbody xd:xctname="RepeatingTable">
						<xsl:for-each select="exp:MaterialLSID">
							<tr>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL484" xd:binding="@CpasType" style="WIDTH: 100%">
										<xsl:value-of select="@CpasType"/>
									</span>
								</td>
								<td>
									<span class="xdHyperlink" hideFocus="1" title="" style="OVERFLOW: visible; WIDTH: 130px; TEXT-ALIGN: left" xd:xctname="Hyperlink">
										<a class="xdDataBindingUI" tabIndex="0" xd:CtrlId="CTRL485" xd:disableEditing="yes">
											<xsl:attribute name="href">
												<xsl:value-of select="."/>
											</xsl:attribute>
											<xsl:value-of select="."/>
										</a>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="MaterialLSID_23" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 735px">Insert item</div>
			</div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 735px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL486">
					<colgroup>
						<col style="WIDTH: 190px"></col>
						<col style="WIDTH: 221px"></col>
						<col style="WIDTH: 324px"></col>
					</colgroup>
					<tbody class="xdTableHeader">
						<tr>
							<td>
								<div>
									<strong>Cpas Type</strong>
								</div>
							</td>
							<td>
								<div>
									<strong>Data File Url</strong>
								</div>
							</td>
							<td>
								<div>
									<strong>Data LSID</strong>
								</div>
							</td>
						</tr>
					</tbody><tbody xd:xctname="RepeatingTable">
						<xsl:for-each select="exp:DataLSID">
							<tr>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL487" xd:binding="@CpasType" style="WIDTH: 100%">
										<xsl:value-of select="@CpasType"/>
									</span>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL488" xd:binding="@DataFileUrl" style="WIDTH: 100%">
										<xsl:value-of select="@DataFileUrl"/>
									</span>
								</td>
								<td>
									<span class="xdHyperlink" hideFocus="1" title="" style="OVERFLOW: visible; WIDTH: 130px; TEXT-ALIGN: left" xd:xctname="Hyperlink">
										<a class="xdDataBindingUI" tabIndex="0" xd:CtrlId="CTRL489" xd:disableEditing="yes">
											<xsl:attribute name="href">
												<xsl:value-of select="."/>
											</xsl:attribute>
											<xsl:value-of select="."/>
										</a>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="DataLSID_24" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 735px">Insert item</div>
			</div>
			<div> </div>
		</div>
	</xsl:template>
	<xsl:template match="exp:ProtocolApplicationParameters" mode="_33">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="Section" xd:CtrlId="CTRL490" tabIndex="-1">
			<div>
				<em>
					<font size="3">Parameter Values</font>
				</em>
			</div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 735px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL496">
					<colgroup>
						<col style="WIDTH: 95px"></col>
						<col style="WIDTH: 296px"></col>
						<col style="WIDTH: 175px"></col>
						<col style="WIDTH: 169px"></col>
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
									<strong>Property ID</strong>
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
							<tr>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL497" xd:binding="@Name" style="WIDTH: 100%">
										<xsl:value-of select="@Name"/>
									</span>
								</td>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL501" xd:binding="@OntologyEntryURI" style="WIDTH: 100%">
										<xsl:value-of select="@OntologyEntryURI"/>
									</span>
								</td>
								<td><select class="xdComboBox xdBehavior_Select" title="" size="1" tabIndex="0" xd:xctname="DropDown" xd:CtrlId="CTRL499" xd:binding="@ValueType" xd:boundProp="value" style="WIDTH: 100%">
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
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL500" xd:binding="." style="WIDTH: 100%">
										<xsl:value-of select="."/>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_26" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 735px">Insert item</div>
			</div>
			<div> </div>
			<div> </div>
		</div>
	</xsl:template>
	<xsl:template match="exp:OutputMaterials" mode="_34">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="Section" xd:CtrlId="CTRL520" tabIndex="-1">
			<div>
				<em>
					<font size="3">Output Materials</font>
				</em>
			</div>
			<div> </div>
			<div><xsl:apply-templates select="exp:Material" mode="_35"/>
				<div class="optionalPlaceholder" xd:xmlToEdit="Material_27" tabIndex="0" xd:action="xCollection::insert" align="left" style="WIDTH: 100%">Insert item</div>
			</div>
			<div> </div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Material" mode="_35">
		<div class="xdRepeatingSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL560" tabIndex="-1">
			<div>About: <span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL17" xd:binding="@rdf:about" style="WIDTH: 130px">
					<xsl:value-of select="@rdf:about"/>
				</span>
			</div>
			<div>Name: <span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL562" xd:binding="exp:Name" style="WIDTH: 130px">
					<xsl:value-of select="exp:Name"/>
				</span>
			</div>
			<div>Cpas Type: <span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL563" xd:binding="exp:CpasType" style="WIDTH: 130px">
					<xsl:value-of select="exp:CpasType"/>
				</span>
			</div>
			<div>
				<span class="xdHyperlink" hideFocus="1" title="" style="OVERFLOW: visible; WIDTH: 130px; TEXT-ALIGN: left" xd:xctname="Hyperlink">
					<a class="xdDataBindingUI" tabIndex="0" xd:CtrlId="CTRL564" xd:disableEditing="yes">
						<xsl:attribute name="href">
							<xsl:value-of select="exp:SourceProtocolLSID"/>
						</xsl:attribute>
						<xsl:value-of select="exp:SourceProtocolLSID"/>
					</a>
				</span>
			</div>
			<div><xsl:apply-templates select="exp:Properties" mode="_36"/>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Properties" mode="_36">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="Section" xd:CtrlId="CTRL565" tabIndex="-1">
			<div> </div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 713px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL576">
					<colgroup>
						<col style="WIDTH: 92px"></col>
						<col style="WIDTH: 287px"></col>
						<col style="WIDTH: 170px"></col>
						<col style="WIDTH: 164px"></col>
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
									<strong>Ontology Entry URI</strong>
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
							<tr>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL577" xd:binding="@Name" style="WIDTH: 100%">
										<xsl:value-of select="@Name"/>
									</span>
								</td>
								<td>
									<span class="xdHyperlink" hideFocus="1" title="" style="OVERFLOW: visible; WIDTH: 130px; TEXT-ALIGN: left" xd:xctname="Hyperlink">
										<a class="xdDataBindingUI" tabIndex="0" xd:CtrlId="CTRL578" xd:disableEditing="yes">
											<xsl:attribute name="href">
												<xsl:value-of select="@OntologyEntryURI"/>
											</xsl:attribute>
											<xsl:value-of select="@OntologyEntryURI"/>
										</a>
									</span>
								</td>
								<td><select class="xdComboBox xdBehavior_Select" title="" size="1" tabIndex="0" xd:xctname="DropDown" xd:CtrlId="CTRL579" xd:binding="@ValueType" xd:boundProp="value" style="WIDTH: 100%">
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
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL580" xd:binding="." style="WIDTH: 100%">
										<xsl:value-of select="."/>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_29" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 713px">Insert item</div>
			</div>
			<div> </div>
		</div>
	</xsl:template>
	<xsl:template match="exp:OutputDataObjects" mode="_37">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="Section" xd:CtrlId="CTRL13" tabIndex="-1">
			<div>
				<em>
					<font size="3">Output Data</font>
				</em>
			</div>
			<div> </div>
			<div><xsl:apply-templates select="exp:Data" mode="_38"/>
				<div class="optionalPlaceholder" xd:xmlToEdit="Data_33" tabIndex="0" xd:action="xCollection::insert" align="left" style="WIDTH: 100%">Insert item</div>
			</div>
			<div> </div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Data" mode="_38">
		<div class="xdRepeatingSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="RepeatingSection" xd:CtrlId="CTRL14" tabIndex="-1">
			<div>About: <span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL16" xd:binding="@rdf:about" style="WIDTH: 130px">
					<xsl:value-of select="@rdf:about"/>
				</span>
			</div>
			<div>Name: <span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL15" xd:binding="exp:Name" style="WIDTH: 130px">
					<xsl:value-of select="exp:Name"/>
				</span>
			</div>
			<div>Cpas Type: <span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL18" xd:binding="exp:CpasType" style="WIDTH: 130px">
					<xsl:value-of select="exp:CpasType"/>
				</span>
			</div>
			<div>Source Protocol LSID: <span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL19" xd:binding="exp:SourceProtocolLSID" style="WIDTH: 130px">
					<xsl:value-of select="exp:SourceProtocolLSID"/>
				</span>
			</div>
			<div><xsl:apply-templates select="exp:Properties" mode="_39"/>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Properties" mode="_39">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="Section" xd:CtrlId="CTRL20" tabIndex="-1">
			<div> </div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 656px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL8">
					<colgroup>
						<col style="WIDTH: 164px"></col>
						<col style="WIDTH: 164px"></col>
						<col style="WIDTH: 164px"></col>
						<col style="WIDTH: 164px"></col>
					</colgroup>
					<tbody class="xdTableHeader">
						<tr>
							<td>
								<strong>Name</strong>
							</td>
							<td>
								<strong>Ontology Entry URI</strong>
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
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL21" xd:binding="@Name" style="WIDTH: 100%">
										<xsl:value-of select="@Name"/>
									</span>
								</td>
								<td>
									<span class="xdHyperlink" hideFocus="1" title="" style="OVERFLOW: visible; WIDTH: 130px; TEXT-ALIGN: left" xd:xctname="Hyperlink">
										<a class="xdDataBindingUI" tabIndex="0" xd:CtrlId="CTRL22" xd:disableEditing="yes">
											<xsl:attribute name="href">
												<xsl:value-of select="@OntologyEntryURI"/>
											</xsl:attribute>
											<xsl:value-of select="@OntologyEntryURI"/>
										</a>
									</span>
								</td>
								<td><select class="xdComboBox xdBehavior_Select" title="" size="1" tabIndex="0" xd:xctname="DropDown" xd:CtrlId="CTRL23" xd:binding="@ValueType" xd:boundProp="value" style="WIDTH: 100%">
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
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL24" xd:binding="." style="WIDTH: 100%">
										<xsl:value-of select="."/>
									</span>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_38" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 656px">Insert item</div>
			</div>
			<div> </div>
		</div>
	</xsl:template>
	<xsl:template match="exp:Properties" mode="_40">
		<div class="xdSection xdRepeating" title="" style="MARGIN-BOTTOM: 6px; WIDTH: 100%" align="left" xd:xctname="Section" xd:CtrlId="CTRL25" tabIndex="-1">
			<div> </div>
			<div>
				<em>
					<font size="3">Protocol Application Properties</font>
				</em>
			</div>
			<div> </div>
			<div> </div>
			<div>
				<table class="xdRepeatingTable msoUcTable" title="" style="TABLE-LAYOUT: fixed; WIDTH: 735px; BORDER-TOP-STYLE: none; BORDER-RIGHT-STYLE: none; BORDER-LEFT-STYLE: none; BORDER-COLLAPSE: collapse; WORD-WRAP: break-word; BORDER-BOTTOM-STYLE: none" border="1" xd:CtrlId="CTRL26">
					<colgroup>
						<col style="WIDTH: 95px"></col>
						<col style="WIDTH: 296px"></col>
						<col style="WIDTH: 175px"></col>
						<col style="WIDTH: 169px"></col>
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
									<strong>Ontology Entry URI</strong>
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
							<tr>
								<td><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL27" xd:binding="@Name" style="WIDTH: 100%">
										<xsl:value-of select="@Name"/>
									</span>
								</td>
								<td>
									<span class="xdHyperlink" hideFocus="1" title="" style="OVERFLOW: visible; WIDTH: 130px; TEXT-ALIGN: left" xd:xctname="Hyperlink">
										<a class="xdDataBindingUI" tabIndex="0" xd:CtrlId="CTRL28" xd:disableEditing="yes">
											<xsl:attribute name="href">
												<xsl:value-of select="@OntologyEntryURI"/>
											</xsl:attribute>
											<xsl:value-of select="@OntologyEntryURI"/>
										</a>
									</span>
								</td>
								<td><select class="xdComboBox xdBehavior_Select" title="" size="1" tabIndex="0" xd:xctname="DropDown" xd:CtrlId="CTRL29" xd:binding="@ValueType" xd:boundProp="value" style="WIDTH: 100%">
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
								<td>
									<div><span class="xdTextBox" hideFocus="1" title="" tabIndex="0" xd:xctname="PlainText" xd:CtrlId="CTRL30" xd:binding="." style="WIDTH: 100%">
											<xsl:value-of select="."/>
										</span>
									</div>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<div class="optionalPlaceholder" xd:xmlToEdit="SimpleVal_39" tabIndex="0" xd:action="xCollection::insert" style="WIDTH: 735px">Insert item</div>
			</div>
			<div> </div>
			<div> </div>
		</div>
	</xsl:template>
</xsl:stylesheet>
