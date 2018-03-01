<DOCFLEX_TEMPLATE VER='1.12'>
CREATED='2004-06-21 01:50:00'
LAST_UPDATE='2009-02-07 01:37:15'
DESIGNER_TOOL='DocFlex SDK 1.x'
DESIGNER_LICENSE_TYPE='Filigris Works Team'
APP_ID='docflex-xml-xsddoc2'
APP_NAME='DocFlex/XML XSDDoc'
APP_VER='2.1.0'
APP_AUTHOR='Copyright \u00a9 2005-2009 Filigris Works,\nLeonid Rudy Softwareprodukte. All rights reserved.'
TEMPLATE_TYPE='DocumentTemplate'
DSM_TYPE_ID='xsddoc'
ROOT_ET='#DOCUMENTS'
<TEMPLATE_PARAMS>
	PARAM={
		param.name='docTitle';
		param.title='Documentation Title';
		param.type='string';
	}
	PARAM={
		param.name='gen.doc';
		param.title='Include Details';
		param.title.style.bold='true';
		param.grouping='true';
	}
	PARAM={
		param.name='gen.doc.for.schemas';
		param.title='For Schemas';
		param.title.style.italic='true';
		param.grouping='true';
		param.grouping.defaultState='collapsed';
	}
	PARAM={
		param.name='gen.doc.for.schemas.initial';
		param.title='Initial';
		param.title.style.italic='true';
		param.type='boolean';
	}
	PARAM={
		param.name='gen.doc.for.schemas.imported';
		param.title='Imported';
		param.title.style.italic='true';
		param.type='boolean';
	}
	PARAM={
		param.name='gen.doc.for.schemas.included';
		param.title='Included';
		param.title.style.italic='true';
		param.type='boolean';
	}
	PARAM={
		param.name='gen.doc.for.schemas.redefined';
		param.title='Redefined';
		param.title.style.italic='true';
		param.type='boolean';
	}
	PARAM={
		param.name='gen.doc.namespace';
		param.title='Namespaces';
		param.type='boolean';
	}
	PARAM={
		param.name='gen.doc.schema';
		param.title='Schemas';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview';
		param.title='Overview Summary';
		param.title.style.bold='true';
		param.grouping='true';
	}
	PARAM={
		param.name='doc.overview.namespaces';
		param.title='Namespace Summary';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas';
		param.title='Schema Summary';
		param.title.style.bold='true';
		param.grouping='true';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.annotation';
		param.title='Annotation';
		param.type='enum';
		param.enum.values='first_sentence;full;none';
	}
	PARAM={
		param.name='doc.overview.schemas.profile';
		param.title='Schema Profile';
		param.grouping='true';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.profile.targetNamespace';
		param.title='Target Namespace';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.profile.version';
		param.title='Version';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.profile.components';
		param.title='Components';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.profile.formDefault';
		param.title='Default NS-Qualified Form';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.profile.blockDefault';
		param.title='Default Block Attribute';
		param.grouping='true';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.profile.blockDefault.value';
		param.title='Value';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.profile.blockDefault.meaning';
		param.title='Meaning';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.profile.finalDefault';
		param.title='Default Final Attribute';
		param.grouping='true';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.profile.finalDefault.value';
		param.title='Value';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.profile.finalDefault.meaning';
		param.title='Meaning';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.profile.location';
		param.title='Schema Location';
		param.type='boolean';
	}
	PARAM={
		param.name='doc.overview.schemas.profile.relatedSchemas';
		param.title='Related Schemas';
		param.type='boolean';
	}
	PARAM={
		param.name='show';
		param.title='Show';
		param.title.style.bold='true';
		param.grouping='true';
	}
	PARAM={
		param.name='show.about';
		param.title='About (footer)';
		param.type='enum';
		param.enum.values='full;short;none';
	}
	PARAM={
		param.name='fmt.page';
		param.title='Pagination';
		param.title.style.bold='true';
		param.grouping='true';
	}
	PARAM={
		param.name='fmt.page.columns';
		param.title='Generate page columns';
		param.type='boolean';
	}
</TEMPLATE_PARAMS>
<HTARGET>
	HKEYS={
		'"overview-summary"';
	}
</HTARGET>
FMT={
	doc.lengthUnits='pt';
	doc.hlink.style.link='cs2';
}
<STYLES>
	CHAR_STYLE={
		style.name='Default Paragraph Font';
		style.id='cs1';
		style.default='true';
	}
	PAR_STYLE={
		style.name='Detail Heading 1';
		style.id='s1';
		text.font.size='12';
		text.font.style.bold='true';
		par.bkgr.opaque='true';
		par.bkgr.color='#CCCCFF';
		par.border.style='solid';
		par.border.color='#666666';
		par.margin.top='14';
		par.margin.bottom='10';
		par.padding.left='3';
		par.padding.right='3';
		par.padding.top='2';
		par.padding.bottom='2';
		par.page.keepWithNext='true';
	}
	CHAR_STYLE={
		style.name='Hyperlink';
		style.id='cs2';
		text.decor.underline='true';
		text.color.foreground='#0000FF';
	}
	PAR_STYLE={
		style.name='Normal';
		style.id='s2';
		style.default='true';
	}
	CHAR_STYLE={
		style.name='Normal Smaller';
		style.id='cs3';
		text.font.name='Arial';
		text.font.size='9';
	}
	PAR_STYLE={
		style.name='Overview Heading';
		style.id='s3';
		text.font.name='Verdana';
		text.font.size='13';
		text.font.style.bold='true';
		text.color.foreground='#4477AA';
		par.bkgr.opaque='true';
		par.bkgr.color='#EEEEEE';
		par.border.style='solid';
		par.border.color='#4477AA';
		par.margin.top='0';
		par.margin.bottom='1.7';
		par.padding.left='4';
		par.padding.right='4';
		par.padding.top='3';
		par.padding.bottom='3';
	}
	CHAR_STYLE={
		style.name='Page Number';
		style.id='cs4';
		text.font.size='9';
		text.font.style.italic='true';
	}
	CHAR_STYLE={
		style.name='Summary Heading Font';
		style.id='cs5';
		text.font.size='12';
		text.font.style.bold='true';
	}
</STYLES>
<ROOT>
	<AREA_SEC>
		<AREA>
			<CTRL_GROUP>
				FMT={
					txtfl.delimiter.type='none';
					par.style='s3';
				}
				<CTRLS>
					<DATA_CTRL>
						FMT={
							text.font.style.bold='true';
							txtfl.option.renderEmbeddedHTML='true';
						}
						FORMULA='getStringParam("docTitle")'
					</DATA_CTRL>
				</CTRLS>
			</CTRL_GROUP>
			<CTRL_GROUP>
				FMT={
					trow.align.vert='Top';
				}
				<CTRLS>
					<DATA_CTRL>
						FMT={
							text.font.size='9';
							text.option.nbsps='true';
						}
						FORMULA='dateTime ("MEDIUM")'
					</DATA_CTRL>
				</CTRLS>
			</CTRL_GROUP>
		</AREA>
	</AREA_SEC>
	<ELEMENT_ITER>
		COND='getBooleanParam("doc.overview.namespaces")'
		FMT={
			table.sizing='Relative';
			table.cellpadding.both='3';
		}
		TARGET_ET='#CUSTOM'
		SCOPE='custom'
		ELEMENT_ENUM_EXPR='CustomElements (getElementMapKeys("namespaces"))'
		SORTING='by-value'
		SORTING_KEY={lpath='.',ascending}
		<BODY>
			<AREA_SEC>
				FMT={
					sec.outputStyle='table';
					sec.spacing.before='8';
					sec.spacing.after='8';
					table.sizing='Relative';
					table.cellpadding.both='3';
				}
				<AREA>
					<CTRL_GROUP>
						FMT={
							trow.bkgr.color='#EEEEFF';
						}
						<CTRLS>
							<DATA_CTRL>
								FMT={
									ctrl.size.width='466.5';
									ctrl.size.height='17.3';
									tcell.sizing='Relative';
									text.font.style.bold='true';
								}
								<DOC_HLINK>
									HKEYS={
										'contextElement.value';
										'"detail"';
									}
								</DOC_HLINK>
								FORMULA='contextElement.value != "" ? contextElement.value : "{global namespace}"'
							</DATA_CTRL>
							<LABEL>
								COND='output.format.supportsPagination &&\ngetBooleanParam("fmt.page.columns") &&\ngetBooleanParam("gen.doc.namespace")'
								FMT={
									ctrl.size.width='33';
									ctrl.size.height='17.3';
									tcell.align.horz='Center';
									text.style='cs4';
									text.font.style.bold='true';
								}
								TEXT='Page'
							</LABEL>
						</CTRLS>
					</CTRL_GROUP>
					<CTRL_GROUP>
						<CTRLS>
							<TEMPLATE_CALL_CTRL>
								FMT={
									ctrl.size.width='466.5';
									ctrl.size.height='17.3';
									tcell.sizing='Relative';
									tcell.padding.extra.top='2';
								}
								TEMPLATE_FILE='namespace/namespaceProfile.tpl'
								PASSED_PARAMS={
									'nsURI','contextElement.value';
								}
								PASSED_ROOT_ELEMENT_EXPR='rootElement'
							</TEMPLATE_CALL_CTRL>
							<DATA_CTRL>
								COND='output.format.supportsPagination &&\ngetBooleanParam("fmt.page.columns") &&\ngetBooleanParam("gen.doc.namespace")'
								FMT={
									ctrl.size.width='33';
									ctrl.size.height='17.3';
									ctrl.option.noHLinkFmt='true';
									tcell.align.horz='Center';
									tcell.align.vert='Top';
									text.style='cs4';
									text.hlink.fmt='none';
								}
								<DOC_HLINK>
									HKEYS={
										'contextElement.value';
										'"detail"';
									}
								</DOC_HLINK>
								DOCFIELD='page-htarget'
							</DATA_CTRL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
		</BODY>
		<HEADER>
			<AREA_SEC>
				FMT={
					par.style='s1';
				}
				<AREA>
					<CTRL_GROUP>
						FMT={
							trow.bkgr.color='#CCCCFF';
						}
						<CTRLS>
							<LABEL>
								FMT={
									tcell.sizing='Relative';
								}
								TEXT='Namespace Summary'
							</LABEL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
		</HEADER>
	</ELEMENT_ITER>
	<ELEMENT_ITER>
		COND='getBooleanParam("doc.overview.schemas")'
		FMT={
			sec.outputStyle='table';
			table.sizing='Relative';
			table.cellpadding.both='3';
		}
		TARGET_ET='xs:schema'
		SCOPE='advanced-location-rules'
		RULES={
			'* -> #DOCUMENT[hasAttr ("initial") &&\ngetBooleanParam("gen.doc.for.schemas.initial")\n||\nhasAttr ("imported") &&\ngetBooleanParam("gen.doc.for.schemas.imported")\n||\nhasAttr ("included") &&\ngetBooleanParam("gen.doc.for.schemas.included")\n||\nhasAttr ("redefined") &&\ngetBooleanParam("gen.doc.for.schemas.redefined")]/xs:schema';
		}
		SORTING='by-expr'
		SORTING_KEY={expr='getXMLDocument().getAttrStringValue("xmlName")',ascending}
		<BODY>
			<AREA_SEC>
				<AREA>
					<CTRL_GROUP>
						<CTRLS>
							<DATA_CTRL>
								FMT={
									ctrl.size.width='120';
									ctrl.size.height='17.3';
									tcell.align.vert='Top';
									text.font.style.bold='true';
								}
								<DOC_HLINK>
									HKEYS={
										'contextElement.id';
										'"detail"';
									}
								</DOC_HLINK>
								FORMULA='getXMLDocument().getAttrStringValue("xmlName")'
							</DATA_CTRL>
							<SS_CALL_CTRL>
								FMT={
									ctrl.size.width='346.5';
									ctrl.size.height='17.3';
									tcell.sizing='Relative';
								}
								SS_NAME='Schema'
							</SS_CALL_CTRL>
							<DATA_CTRL>
								COND='output.format.supportsPagination &&\ngetBooleanParam("fmt.page.columns") &&\ngetBooleanParam("gen.doc.schema")'
								FMT={
									ctrl.size.width='33';
									ctrl.size.height='17.3';
									ctrl.option.noHLinkFmt='true';
									tcell.align.horz='Center';
									tcell.align.vert='Top';
									text.style='cs4';
									text.hlink.fmt='none';
								}
								<DOC_HLINK>
									HKEYS={
										'contextElement.id';
										'"detail"';
									}
								</DOC_HLINK>
								DOCFIELD='page-htarget'
							</DATA_CTRL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
		</BODY>
		<HEADER>
			<AREA_SEC>
				<AREA>
					<SPACER>
						FMT={
							spacer.height='14';
						}
					</SPACER>
					<CTRL_GROUP>
						FMT={
							trow.bkgr.color='#CCCCFF';
						}
						<CTRLS>
							<LABEL>
								FMT={
									ctrl.size.width='465';
									ctrl.size.height='17.3';
									tcell.sizing='Relative';
									text.style='cs5';
								}
								TEXT='Schema Summary'
							</LABEL>
							<LABEL>
								COND='output.format.supportsPagination &&\ngetBooleanParam("fmt.page.columns") &&\ngetBooleanParam("gen.doc.schema")'
								FMT={
									ctrl.size.width='34.5';
									ctrl.size.height='17.3';
									tcell.align.horz='Center';
									text.style='cs4';
									text.font.style.bold='true';
								}
								TEXT='Page'
							</LABEL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
		</HEADER>
	</ELEMENT_ITER>
	<TEMPLATE_CALL>
		DESCR='Bottom Message'
		COND='output.type == "document" && \n! hasParamValue("show.about", "none")'
		TEMPLATE_FILE='about.tpl'
	</TEMPLATE_CALL>
</ROOT>
<STOCK_SECTIONS>
	<FOLDER>
		MATCHING_ET='xs:schema'
		SS_NAME='Schema'
		<BODY>
			<TEMPLATE_CALL>
				COND='hasParamValue("doc.overview.schemas.annotation", "full")'
				OUTPUT_CHECKER_EXPR='getValuesByLPath(\n  "xs:annotation/xs:documentation//(#TEXT | #CDATA)"\n).isBlank() ? -1 : 1'
				FMT={
					text.style='cs3';
				}
				TEMPLATE_FILE='ann/annotation.tpl'
			</TEMPLATE_CALL>
			<TEMPLATE_CALL>
				COND='hasParamValue("doc.overview.schemas.annotation", "first_sentence")'
				OUTPUT_CHECKER_EXPR='getValuesByLPath(\n  "xs:annotation/xs:documentation//(#TEXT | #CDATA)"\n).isBlank() ? -1 : 1'
				FMT={
					text.style='cs3';
				}
				TEMPLATE_FILE='ann/firstSentence.tpl'
			</TEMPLATE_CALL>
			<TEMPLATE_CALL>
				COND='getBooleanParam("doc.overview.schemas.profile")'
				FMT={
					sec.spacing.before='8';
				}
				TEMPLATE_FILE='schema/schemaProfile.tpl'
				PASSED_PARAMS={
					'doc.schema.profile.targetNamespace','getBooleanParam("doc.overview.schemas.profile.targetNamespace")';
					'doc.schema.profile.version','getBooleanParam("doc.overview.schemas.profile.version")';
					'doc.schema.profile.components','getBooleanParam("doc.overview.schemas.profile.components")';
					'doc.schema.profile.formDefault','getBooleanParam("doc.overview.schemas.profile.formDefault")';
					'doc.schema.profile.blockDefault','getBooleanParam("doc.overview.schemas.profile.blockDefault")';
					'doc.schema.profile.blockDefault.value','getBooleanParam("doc.overview.schemas.profile.blockDefault.value")';
					'doc.schema.profile.blockDefault.meaning','getBooleanParam("doc.overview.schemas.profile.blockDefault.meaning")';
					'doc.schema.profile.finalDefault','getBooleanParam("doc.overview.schemas.profile.finalDefault")';
					'doc.schema.profile.finalDefault.value','getBooleanParam("doc.overview.schemas.profile.finalDefault.value")';
					'doc.schema.profile.finalDefault.meaning','getBooleanParam("doc.overview.schemas.profile.finalDefault.meaning")';
					'doc.schema.profile.location','getBooleanParam("doc.overview.schemas.profile.location")';
					'doc.schema.profile.relatedSchemas','getBooleanParam("doc.overview.schemas.profile.relatedSchemas")';
				}
			</TEMPLATE_CALL>
		</BODY>
	</FOLDER>
</STOCK_SECTIONS>
CHECKSUM='Jskem5?yUuvZvn4g?oxEkX87D6Ex6pcmgYL9UNZ1Yl0'
</DOCFLEX_TEMPLATE>