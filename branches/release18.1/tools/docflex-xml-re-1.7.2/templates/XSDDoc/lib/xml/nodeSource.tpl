<DOCFLEX_TEMPLATE VER='1.12'>
CREATED='2005-01-18 01:00:00'
LAST_UPDATE='2009-02-07 01:37:16'
DESIGNER_TOOL='DocFlex SDK 1.x'
DESIGNER_LICENSE_TYPE='Filigris Works Team'
APP_ID='docflex-xml-xsddoc2'
APP_NAME='DocFlex/XML XSDDoc'
APP_VER='2.1.0'
APP_AUTHOR='Copyright \u00a9 2005-2009 Filigris Works,\nLeonid Rudy Softwareprodukte. All rights reserved.'
TEMPLATE_TYPE='DocumentTemplate'
DSM_TYPE_ID='xsddoc'
ROOT_ET='<ANY>'
<TEMPLATE_PARAMS>
	PARAM={
		param.name='bookmark.xmlns';
		param.type='boolean';
	}
	PARAM={
		param.name='bookmark.elements';
		param.type='boolean';
	}
	PARAM={
		param.name='remove.anns';
		param.type='boolean';
	}
</TEMPLATE_PARAMS>
FMT={
	doc.lengthUnits='pt';
}
<STYLES>
	CHAR_STYLE={
		style.name='Comment';
		style.id='cs1';
		text.font.name='Courier New';
		text.color.foreground='#4D4D4D';
	}
	CHAR_STYLE={
		style.name='Default Paragraph Font';
		style.id='cs2';
		style.default='true';
	}
	CHAR_STYLE={
		style.name='Hyperlink';
		style.id='cs3';
		text.decor.underline='true';
		text.color.foreground='#0000FF';
	}
	CHAR_STYLE={
		style.name='Internal Subset';
		style.id='cs4';
		text.font.name='Courier New';
		text.color.foreground='#0000FF';
	}
	CHAR_STYLE={
		style.name='Name Highlight';
		style.id='cs5';
		text.color.foreground='#FF0000';
	}
	PAR_STYLE={
		style.name='Normal';
		style.id='s1';
		style.default='true';
	}
	CHAR_STYLE={
		style.name='Underline';
		style.id='cs6';
		text.decor.underline='true';
	}
	CHAR_STYLE={
		style.name='Value';
		style.id='cs7';
		text.font.size='7';
		text.font.style.bold='true';
		text.color.foreground='#000000';
	}
	CHAR_STYLE={
		style.name='Value Highlight';
		style.id='cs8';
		text.font.size='7';
		text.font.style.bold='true';
		text.color.foreground='#FF0000';
	}
	CHAR_STYLE={
		style.name='XML Markup';
		style.id='cs9';
		text.color.foreground='#0000FF';
	}
	CHAR_STYLE={
		style.name='XML Name';
		style.id='cs10';
		text.color.foreground='#990000';
	}
	CHAR_STYLE={
		style.name='XML Source';
		style.id='cs11';
		text.font.name='Verdana';
		text.font.size='8';
	}
</STYLES>
<ROOT>
	<SS_CALL>
		FMT={
			text.style='cs11';
		}
		SS_NAME='Node'
	</SS_CALL>
</ROOT>
<STOCK_SECTIONS>
	<ATTR_ITER>
		DESCR='generates list of the element\'s attributes'
		FMT={
			sec.outputStyle='text-par';
			txtfl.delimiter.type='none';
		}
		SCOPE='enumerated-attrs'
		EXCL_PASSED=false
		SS_NAME='AttrList'
		<BODY>
			<AREA_SEC>
				COND='iterator.attr.name.startsWith ("xml") && {\n  name = iterator.attr.name;\n  name.startsWith ("xml:") || name == "xmlns" ||\n  name.startsWith ("xmlns:")\n}'
				BREAK_PARENT_BLOCK='when-executed'
				<AREA>
					<CTRL_GROUP>
						<CTRLS>
							<DELIMITER>
							</DELIMITER>
							<DATA_CTRL>
								FMT={
									text.style='cs5';
								}
								FORMULA='iterator.attr.dsmAttr.qName'
							</DATA_CTRL>
							<LABEL>
								FMT={
									text.style='cs9';
								}
								TEXT='="'
							</LABEL>
							<DATA_CTRL>
								FMT={
									text.style='cs8';
								}
								FORMULA='iterator.attr.value'
							</DATA_CTRL>
							<LABEL>
								FMT={
									text.style='cs9';
								}
								TEXT='"'
							</LABEL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
			<AREA_SEC>
				<AREA>
					<CTRL_GROUP>
						<CTRLS>
							<DELIMITER>
							</DELIMITER>
							<DATA_CTRL>
								FMT={
									text.style='cs10';
								}
								FORMULA='iterator.attr.dsmAttr.qName'
							</DATA_CTRL>
							<LABEL>
								FMT={
									text.style='cs9';
								}
								TEXT='="'
							</LABEL>
							<SS_CALL_CTRL>
								FMT={
									text.style='cs7';
									text.hlink.fmt='style';
									text.hlink.style='cs6';
								}
								SS_NAME='AttrValue'
							</SS_CALL_CTRL>
							<LABEL>
								FMT={
									text.style='cs9';
								}
								TEXT='"'
							</LABEL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
		</BODY>
	</ATTR_ITER>
	<FOLDER>
		FMT={
			sec.outputStyle='text-par';
		}
		SS_NAME='AttrValue'
		<BODY>
			<AREA_SEC>
				DESCR='case of single value'
				COND='! iterator.attr.multiValued'
				BREAK_PARENT_BLOCK='when-executed'
				<AREA>
					<CTRL_GROUP>
						<CTRLS>
							<DATA_CTRL>
								FMT={
									text.hlink.fmt='style';
									text.hlink.style='cs6';
								}
								<DOC_HLINK>
									COND='name = iterator.attr.name;\nname == "base" && instanceOf ("xs:%extensionType | xs:restriction | xs:%restrictionType") ||\nname == "type" && instanceOf ("xs:%element | xs:%attribute") ||\nname == "itemType" && instanceOf ("xs:list")'
									ALT_HLINK
									HKEYS={
										'findElementByKey ("types", toQName (iterator.attr.value)).id';
										'"detail"';
									}
								</DOC_HLINK>
								<DOC_HLINK>
									COND='iterator.attr.name == "ref"'
									ALT_HLINK
									HKEYS={
										'qName = toQName(iterator.attr.value);\n\ninstanceOf ("xs:%element") ?\n  findElementByKey ("global-elements", qName).id :\ninstanceOf ("xs:%attribute") ?\n  findElementByKey ("global-attributes", qName).id :\ninstanceOf ("xs:%groupRef") ?\n  findElementByKey ("groups", qName).id :\ninstanceOf ("xs:%attributeGroupRef") ?\n  findElementByKey ("attributeGroups", qName).id;';
										'"detail"';
									}
								</DOC_HLINK>
								<DOC_HLINK>
									COND='// case of element or attribute name\niterator.attr.name == "name" && instanceOf ("xs:%element | xs:%attribute")'
									ALT_HLINK
									HKEYS={
										'contextElement.id';
										'"def"';
									}
								</DOC_HLINK>
								<DOC_HLINK>
									COND='// case of component name\n\niterator.attr.name == "name" &&\ninstanceOf ("xs:%element | xs:complexType | xs:simpleType | \n            xs:group | xs:attributeGroup")'
									ALT_HLINK
									HKEYS={
										'contextElement.id';
										'"detail"';
									}
								</DOC_HLINK>
								<DOC_HLINK>
									COND='iterator.attr.name == "substitutionGroup" && instanceOf ("xs:element")'
									ALT_HLINK
									HKEYS={
										'findElementByKey ("global-elements", toQName (iterator.attr.value)).id';
										'"detail"';
									}
								</DOC_HLINK>
								<DOC_HLINK>
									COND='iterator.attr.name == "targetNamespace" && instanceOf ("xs:schema")'
									ALT_HLINK
									HKEYS={
										'iterator.attr.value.toString()';
										'"detail"';
									}
								</DOC_HLINK>
								<DOC_HLINK>
									COND='attrName = iterator.attr.name;\nattrName == "schemaLocation" && \n  instanceOf ("xs:import | xs:include | xs:redefine")\n||\nattrName == "source" && instanceOf ("xs:documentation")'
									ALT_HLINK
									HKEYS={
										'uri = resolveURI (\n  iterator.attr.value.toString(),\n  getXMLDocument().getAttrStringValue("xmlURI")\n);\n\nfindXMLDocument(uri)->findChild("xs:schema")->id';
										'"detail"';
									}
								</DOC_HLINK>
								<URL_HLINK>
									COND='iterator.attr.physicalType == "xs:anyURI" &&\niterator.attr.value.toString().isURL()'
									ALT_HLINK
									TARGET_FRAME_EXPR='"_blank"'
									URL_EXPR='iterator.attr.value.toString()'
								</URL_HLINK>
								FORMULA='encodeXMLChars (\n  iterator.value.toString(),\n  true, true, true, false\n)'
							</DATA_CTRL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
			<ATTR_ITER>
				DESCR='case of list value'
				FMT={
					txtfl.delimiter.type='space';
				}
				SCOPE='current-attr-values'
				<BODY>
					<AREA_SEC>
						<AREA>
							<CTRL_GROUP>
								<CTRLS>
									<DATA_CTRL>
										FMT={
											text.hlink.fmt='style';
											text.hlink.style='cs6';
										}
										<DOC_HLINK>
											COND='name = iterator.attr.name;\nname == "memberTypes" && instanceOf ("xs:union")'
											HKEYS={
												'findElementByKey ("types", toQName (iterator.value)).id';
												'"detail"';
											}
										</DOC_HLINK>
										FORMULA='encodeXMLChars (\n  iterator.value.toString(),\n  true, true, true, false\n)'
									</DATA_CTRL>
								</CTRLS>
							</CTRL_GROUP>
						</AREA>
					</AREA_SEC>
				</BODY>
			</ATTR_ITER>
		</BODY>
	</FOLDER>
	<FOLDER>
		DESCR='This stock-section processes a node which may contain similar nodes within itself'
		SS_NAME='Node'
		<BODY>
			<FOLDER>
				DESCR='case of element node'
				COND='! contextElement.dsmElement.pseudoElement'
				<HTARGET>
					COND='getBooleanParam("bookmark.xmlns") && hasChild("#NAMESPACE")'
					HKEYS={
						'contextElement.id';
						'"xmlns"';
					}
				</HTARGET>
				<HTARGET>
					COND='getBooleanParam("bookmark.elements") && \ninstanceOf ("xs:import | xs:include | xs:redefine | \n  xs:%element | xs:%attribute | xs:complexType | \n  xs:simpleType | xs:group | xs:attributeGroup | \n  xs:any | xs:anyAttribute")'
					HKEYS={
						'contextElement.id';
						'"xml-source-location"';
					}
				</HTARGET>
				BREAK_PARENT_BLOCK='when-executed'
				<BODY>
					<AREA_SEC>
						DESCR='this is executed only when the element contains a short text (in order to produce a single-line output)'
						COND='countChildren ("*") == 1 &&\n(text = getValueByLPath ("#TEXT")) != null && {\n  s = text.toString();\n  s.len() < 50 && ! s.contains ("\\n")\n}'
						BREAK_PARENT_BLOCK='when-executed'
						<AREA>
							<CTRL_GROUP>
								FMT={
									txtfl.delimiter.type='none';
								}
								<CTRLS>
									<LABEL>
										FMT={
											text.style='cs9';
										}
										TEXT='<'
									</LABEL>
									<DATA_CTRL>
										FMT={
											text.style='cs10';
										}
										FORMULA='contextElement.dsmElement.qName'
									</DATA_CTRL>
									<SS_CALL_CTRL>
										SS_NAME='AttrList'
									</SS_CALL_CTRL>
									<LABEL>
										FMT={
											text.style='cs9';
										}
										TEXT='>'
									</LABEL>
									<DATA_CTRL>
										FMT={
											ctrl.option.text.collapseSpaces='true';
											ctrl.option.text.trimSpaces='true';
											text.style='cs7';
										}
										FORMULA='encodeXMLChars (\n  getValueByLPath ("#TEXT").toString()\n)'
									</DATA_CTRL>
									<LABEL>
										FMT={
											text.style='cs9';
										}
										TEXT='</'
									</LABEL>
									<DATA_CTRL>
										FMT={
											text.style='cs10';
										}
										FORMULA='contextElement.dsmElement.qName'
									</DATA_CTRL>
									<LABEL>
										FMT={
											text.style='cs9';
										}
										TEXT='>'
									</LABEL>
								</CTRLS>
							</CTRL_GROUP>
						</AREA>
					</AREA_SEC>
					<ELEMENT_ITER>
						DESCR='iterates by the element\'s child nodes -- the case of a complex element'
						TARGET_ET='<ANY>'
						SCOPE='simple-location-rules'
						RULES={
							'* -> *';
						}
						FILTER='! (instanceOf("xs:annotation") && getBooleanParam("remove.anns"))'
						BREAK_PARENT_BLOCK='when-output'
						<BODY>
							<SS_CALL>
								DESCR='calls this stock-section recursively'
								FMT={
									sec.indent.left='10';
								}
								SS_NAME='Node'
							</SS_CALL>
						</BODY>
						<HEADER>
							<AREA_SEC>
								<AREA>
									<CTRL_GROUP>
										FMT={
											txtfl.delimiter.type='none';
										}
										<CTRLS>
											<LABEL>
												FMT={
													text.style='cs9';
												}
												TEXT='<'
											</LABEL>
											<DATA_CTRL>
												FMT={
													text.style='cs10';
												}
												FORMULA='contextElement.dsmElement.qName'
											</DATA_CTRL>
											<SS_CALL_CTRL>
												SS_NAME='AttrList'
											</SS_CALL_CTRL>
											<LABEL>
												FMT={
													text.style='cs9';
												}
												TEXT='>'
											</LABEL>
										</CTRLS>
									</CTRL_GROUP>
								</AREA>
							</AREA_SEC>
						</HEADER>
						<FOOTER>
							<AREA_SEC>
								<AREA>
									<CTRL_GROUP>
										FMT={
											txtfl.delimiter.type='none';
										}
										<CTRLS>
											<LABEL>
												FMT={
													text.style='cs9';
												}
												TEXT='</'
											</LABEL>
											<DATA_CTRL>
												FMT={
													text.style='cs10';
												}
												FORMULA='contextElement.dsmElement.qName'
											</DATA_CTRL>
											<LABEL>
												FMT={
													text.style='cs9';
												}
												TEXT='>'
											</LABEL>
										</CTRLS>
									</CTRL_GROUP>
								</AREA>
							</AREA_SEC>
						</FOOTER>
					</ELEMENT_ITER>
					<AREA_SEC>
						DESCR='this is executed when no child nodes encountered -- the case of a simple element'
						<AREA>
							<CTRL_GROUP>
								FMT={
									txtfl.delimiter.type='none';
								}
								<CTRLS>
									<LABEL>
										FMT={
											text.style='cs9';
										}
										TEXT='<'
									</LABEL>
									<DATA_CTRL>
										FMT={
											text.style='cs10';
										}
										FORMULA='contextElement.dsmElement.qName'
									</DATA_CTRL>
									<SS_CALL_CTRL>
										SS_NAME='AttrList'
									</SS_CALL_CTRL>
									<LABEL>
										FMT={
											text.style='cs9';
										}
										TEXT='/>'
									</LABEL>
								</CTRLS>
							</CTRL_GROUP>
						</AREA>
					</AREA_SEC>
				</BODY>
			</FOLDER>
			<AREA_SEC>
				DESCR='TEXT node'
				MATCHING_ET='#TEXT'
				BREAK_PARENT_BLOCK='when-executed'
				<AREA>
					<CTRL_GROUP>
						<CTRLS>
							<DATA_CTRL>
								FMT={
									ctrl.option.text.collapseSpaces='true';
									ctrl.option.text.trimSpaces='true';
									ctrl.option.text.noEmptyOutput='true';
									text.style='cs7';
									text.option.renderNLs='true';
								}
								FORMULA='encodeXMLChars (contextElement.value.toString())'
							</DATA_CTRL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
			<AREA_SEC>
				DESCR='COMMENT node'
				MATCHING_ET='#COMMENT'
				BREAK_PARENT_BLOCK='when-executed'
				<AREA>
					<CTRL_GROUP>
						FMT={
							txtfl.delimiter.type='none';
						}
						<CTRLS>
							<LABEL>
								FMT={
									text.style='cs9';
								}
								TEXT='<!--'
							</LABEL>
							<DATA_CTRL>
								FMT={
									ctrl.option.text.collapseSpaces='true';
									text.style='cs1';
									text.option.renderNLs='true';
								}
								ELEMENT_VALUE
							</DATA_CTRL>
							<LABEL>
								FMT={
									text.style='cs9';
								}
								TEXT='-->'
							</LABEL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
			<AREA_SEC>
				DESCR='CDATA node'
				MATCHING_ET='#CDATA'
				BREAK_PARENT_BLOCK='when-executed'
				<AREA>
					<CTRL_GROUP>
						<CTRLS>
							<LABEL>
								FMT={
									text.style='cs9';
								}
								TEXT='<![CDATA['
							</LABEL>
						</CTRLS>
					</CTRL_GROUP>
					<CTRL_GROUP>
						FMT={
							par.margin.left='10';
						}
						<CTRLS>
							<DATA_CTRL>
								FMT={
									ctrl.option.text.collapseSpaces='true';
									ctrl.option.text.trimSpaces='true';
									text.style='cs7';
									text.option.renderNLs='true';
								}
								ELEMENT_VALUE
							</DATA_CTRL>
						</CTRLS>
					</CTRL_GROUP>
					<CTRL_GROUP>
						<CTRLS>
							<LABEL>
								FMT={
									text.style='cs9';
								}
								TEXT=']]>'
							</LABEL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
			<AREA_SEC>
				DESCR='Processing Instruction node'
				MATCHING_ET='#PI'
				<AREA>
					<CTRL_GROUP>
						FMT={
							txtfl.delimiter.type='none';
						}
						<CTRLS>
							<LABEL>
								FMT={
									text.style='cs9';
								}
								TEXT='<?'
							</LABEL>
							<DATA_CTRL>
								FMT={
									text.style='cs9';
								}
								ATTR='target'
							</DATA_CTRL>
							<DELIMITER>
							</DELIMITER>
							<DATA_CTRL>
								FMT={
									text.style='cs9';
								}
								ELEMENT_VALUE
							</DATA_CTRL>
							<LABEL>
								FMT={
									text.style='cs9';
								}
								TEXT='?>'
							</LABEL>
						</CTRLS>
					</CTRL_GROUP>
				</AREA>
			</AREA_SEC>
		</BODY>
	</FOLDER>
</STOCK_SECTIONS>
CHECKSUM='r?NYL70wNc4I6A8OOZRBuSGTVQKMl+?LJAruQzRov+k'
</DOCFLEX_TEMPLATE>