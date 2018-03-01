<%
/*
 * Copyright (c) 2015-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
%>
<%@ page import="org.labkey.api.view.ViewContext" %>
<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%@ taglib prefix="labkey" uri="http://www.labkey.org/taglib" %>
<%!
    @Override
    public void addClientDependencies(ClientDependencies dependencies)
    {
        dependencies.add("Ext4");
        dependencies.add("survey");
        dependencies.add("mpower/mpower.css");
    }
%>
<%
    ViewContext ctx = getViewContext();
%>

<script type="text/javascript">
    Ext4.onReady(function(){

        var formPanel = Ext4.create('Ext.form.Panel', {
            frame: false,
            renderTo    : 'mpower-div',
            bodyPadding: 10,
            fieldDefaults: {
                labelWidth: 175,
                width   : 650,
                boxLabelAttrTpl : "style='width: 450px; padding: 0 3px 3px 3px;'",
                allowBlank: false
            },
            items: [{
                xtype   : 'textfield',
                name    : 'firstName',
                fieldLabel  : 'First Name'
            },{
                xtype   : 'textfield',
                name    : 'middleName',
                allowBlank  : true,
                fieldLabel  : 'Middle Name'
            },{
                xtype   : 'textfield',
                name    : 'lastName',
                fieldLabel  : 'Last Name'
            },{
                xtype   : 'textfield',
                name    : 'email',
                vtype   : 'email',
                allowBlank  : true,
                fieldLabel  : 'Email Address'
            },{
                xtype : 'lkdatepicker',
                name  : 'birthDate',
                width : 400,
                fieldLabel  : 'Date of Birth'
            },{
                xtype   : 'checkbox',
                name    : 'arm1Consent',
                fieldLabel  : 'ARM1 Consent',
                boxLabel    : 'Do you agree to participate in the self-report  questionnaire (titled ARM 1 above)?'
            },{
                xtype   : 'checkbox',
                name    : 'arm2Consent',
                fieldLabel  : 'ARM2 Consent',
                boxLabel    : 'Do you agree to participate in the optional Sub Study (titled ARM 2 above) involving linkage to medical record and insurance claim data?'
            },{
                xtype   : 'checkbox',
                name    : 'futureResearchConsent',
                fieldLabel  : 'Research Participation',
                boxLabel    : 'Is it OK if someone contacts you  to invite you to participate in future research?'
            },{
                xtype : 'textfield',
                allowBlank  : false,
                name        : 'signature',
                fieldLabel  : 'Signature'
            },{
                xtype : 'displayfield',
                labelSeparator  : '',
                fieldLabel      : ' ',
                value           : 'Please type your name to serve as your electronic signature.'
            }],
            buttons     : [{
                text : 'Next',
                formBind: true,
                handler : function(btn)
                {
                    formPanel.submit({
                        url : LABKEY.ActionURL.buildURL('mpower', 'createUserToken.api'),
                        success : function(form, action){
                            if (action && action.result.redirectURL){
                                window.location = action.result.redirectURL;
                            }
                        },
                        failure : function(form, action){
                            console.log(action);
                            var message = LABKEY.Utils.getMsgFromError(action.response) || 'An error occurred.';
                            Ext4.Msg.show({title: "Error", msg: message, buttons: Ext4.MessageBox.OK, icon: Ext4.MessageBox.ERROR});
                        }
                    });
                },
                scope   : this
            },{
                text : 'Cancel',
                handler : function(btn) {
                    window.history.back();
                }
            }]
        });
    });
</script>

<div class="mpower-consent-panel">
    <div align="center"><span>Fred Hutchinson Cancer Research Center</span></div>
    <p><div align="center"><span><strong>Consent to take part in a research study:</strong></span></div>
    <p><div align="center"><span><strong>The Mpower Project</strong></span></div>
    <p><div align="center"><span><strong>Prostate Cancer Patients</strong></span></div><p>

    <span><i>Principal Investigators:</i> Peter Nelson MD Fred Hutchinson Cancer Research Center</span><br/>
    <span>Scott Ramsey, MD PhD Fred Hutchinson Cancer Research Center</span><br/>

    <p><span><strong>We would like you to join this research study.</strong></span></p>
    <div>As a patient who has been diagnosed with prostate cancer, you are being asked to contribute to this research to improve healthcare.
        The Mpower Project is a collaborative research program run by the Fred Hutchinson Cancer Research Center (Fred Hutch)
        The Washington State Prostate Cancer Coalition, and urologists across the state to help find better ways to treat
        prostate cancer. We would like to invite you to participate. A benefit of being in this research is that your information
        may help other men with prostate cancer.
    </div>
    <p><div>Choosing to participate in  research is voluntary, and you can always say no.  Your medical care will
        be the same whether or not you sign this form or  drop out after joining and there are no penalties or loss of
        benefits for either of these decisions.
    </div>

    <p><span><strong>Why are we doing this study?</strong></span></p>
    <div>The goal of this project is to establish a registry of all men diagnosed with prostate cancer in Washington State.
        We want to find better ways to treat prostate cancer by understanding issues such as prostate cancer care outcomes,
        costs of prostate cancer care, and quality of life of prostate cancer patients. In this study, we want to learn
        what effects various treatment options have on people with prostate cancer. We will track the outcomes and quality
        of life of patients across Washington State and measure the trends we see. Using this information, we can inform
        prostate cancer patients about the treatment options and side effects. We also hope that our research findings will
        expand knowledge of prostate cancer risk prediction, diagnostic trends, treatment patterns, outcomes and quality of life.
    </div>

    <p><div>With the information you provide, we will collaborate with other researchers and share only your de- identified
        information with:
    </div>

    <ul>
        <li>Other prostate cancer patients comparing treatment options for their prostate cancer</li>
        <li>Other patients looking to learn about treatment side effects, quality of life and clinical outcomes associated
            with of different treatment options after removing identifying information</li>
        <li>Researchers at the Hutchinson Institute for Cancer Outcomes Research (HICOR) at Fred Hutch studying
            the economics of cancer care and methods to improve clinical outcomes  for patients</li>
        <li>Researchers studying the outcomes of cancer care</li>
        <li>Clinicians looking for the most effective treatments available for prostate cancer</li>
        <li>Clinicians interested in the potential side effects of different cancer treatments</li>
        <li>Health insurers and professional guideline groups seeking to develop evidence-based health policy</li>
        <li>Government agencies, review boards, and others who watch over the safety, effectiveness and conduct of the research</li>
        <li>Others, if the law requires.</li>
    </ul>
    <p><span><strong>What will the study involve?</strong></span></p>
    <div>There are two arms of this study.  You will have the opportunity to consent to participate in both arms of the
        study in this form.
    </div>

    <p><div><span style="text-decoration:underline"><strong>ARM 1:</strong></span> The first is The Mpower Prostate Cancer
        Registry arm of the study which involves the collection and use of self-reported
        information from prostate cancer patients like you.  The self-reported information will be collected online through a
        patient portal. We will ask you to fill out 1 online questionnaire. Some of the questions may be sensitive. If a
        question makes you feel uncomfortable, you may choose not to answer.
    </div><p>

    <div>The Registry will be used as a resource by other researchers who are not at Fred Hutch or affiliated with
        Fred Hutch but who are interested in the study of prostate cancer care.  If you agree to participate in the Registry
        arm of the study, the de-identified information you provide will be shared with these other researchers. If you agree,
        you will be contacted with information about future studies that you may be interested in.
    </div>

    <p><div><span style="text-decoration:underline"><strong>ARM 2:</strong></span> The second arm of the study (also called the "Substudy")
        involves the analysis of prostate cancer insurance claims data and other health information about prostate cancer
        patients. The Substudy will provide an opportunity for researchers to gain a more complete understanding of
        prostate cancer outcomes and trends.
    </div><p>

    <div>If you agree to participate in the Substudy, after you complete your questionnaire, we will use the information
        you give us to get information about the reimbursements made by your health insurer to calculate the cost of your
        procedures. In addition, we will link to information about your various procedures and population-based data to
        connect information about your cancer treatment. Confidentiality will be maintained using standard data security
        procedures including data encryption, and network and password protection.
    </div><p>

    <div>We may contact you periodically to see if your information has changed.</div><p>

    <div>The goals of the Substudy include sharing this important information with other researchers who submit research
        proposals to Fred Hutch for approval. After a thorough review, projects that demonstrate merit and that meet the
        goals of The Mpower Project may be approved.  If approved by Fred Hutch and by an institutional review board, also
        called an "IRB" (an oversight committee responsible by law to oversee research involving people) researchers may be
        given access to de-identified Registry information about you and your cancer care.
    </div><p>

    <div><span><strong>What health information about me is needed for the Substudy?</strong></span></div><p>

    <div>You don't have to agree to participate in the Substudy but if you do, the researchers listed at the top of this
        form will need your permission (authorization) to obtain health information from your health care providers and
        health insurance companies relating to your cancer care and coverage.    Once this health information (also called
        protected health information or PHI) is obtained, it will become a part of the Registry along with the information
        that you self-reported.  It could be shared with other researchers and others as described in this consent form.
    </div><p>

    <div>If you agree to participate in the Substudy, your health information will be shared with Fred Hutchinson Cancer
        Research Center, its staff, and others who work with them. All these people together are called "Researchers."
    </div><p>

    <div>The Researchers will use the health information only for the purposes described in this form.</div><p>

    <div><span><strong>1. What "health information" includes and what may be used or disclosed</strong></span></div>
    <ul>
        <li>All health information about your cancer care and coverage.</li>
    </ul>

    <div><span><strong>2. How the Researchers protect health information</strong></span></div>
    <div>The Researchers will follow the limits in this form. If they publish the research, they will not identify you
        unless you allow it in writing. These limitations continue even if you take back this permission.
    </div><p>

    <div><span><strong>3. After the Researchers learn health information</strong></span></div>
    <div>The limits in this section come from a federal law called the Health Insurance Portability and Accountability Act.
        This law applies to your doctors and other health care providers, not to the Researchers.
    </div><p>

    <div>Once the Researchers get your health information, this law may no longer apply. But other privacy protections will still apply.</div><p>

    <div><span><strong>4. Storing your health information</strong></span></div>
    <div> Your health information will become part of the Registry described in this consent form. This permission will
        expire when the purposes of the study have all been met and the Registry has been destroyed.
    </div><p>

    <div><span><strong>How long will I be in this study?</strong></span></div>
    <div>This Registry will continue indefinitely. The Researchers will continue to use your information to help us better understand prostate cancer.</div><p>
    <div>If you leave the study, the information that has already been collected will not be removed from the Registry.  However, no further contact will be made to you.</div><p>

    <div><span><strong>What are the risks to you from participation in this study?</strong></span></div>
    <div>There is a risk of invasion of your privacy and a breach of the confidentiality of your information since the
        Registry asks that you provide personal information about your prostate cancer treatment history, quality of life,
        treatment side effects, and medical treatment information. There is always the possibility that the measures that the
        Registry puts in place to protect your confidential health information could fail.   To protect you against these risks,
        <strong>we will label your health information and responses with a number</strong>, not your name.  The researchers in this study
        will not have access to your name or other personal information, only the random number you are assigned. Thus the
        risk of someone connecting any study information with you as an individual is unlikely.
    </div><p>

    <div><span><strong>What is my alternative to being in this study?</strong></span></div><p>
    <div>As this is not a treatment study, your alternative is simply not to participate.</div><p>

    <div><span><strong>What are the benefits?</strong></span></div><p>
    <div>This study will not benefit you, but we hope the information we learn will help people with prostate cancer in the future.</div><p>
    <div>Some of the goals of this project are to: </div>

    <ul>
        <li>Improve the quality and outcomes of prostate cancer care</li>
        <li>improve the evidence base to support decision-making,</li>
        <li>reduce costs of care,</li>
        <li>increase patient access to information,</li>
        <li>serve as an advocacy hub</li>
    </ul><p>

    <div><span><strong>Protecting your Privacy as an Individual and the Confidentiality of Your Personal Information</strong></span></div><p>

    <div>Some people or organizations may need to look at your research records for quality assurance or data analysis. They include:</div>
    <ul>
        <li>Researchers involved with this study</li>
        <li>Fred Hutchinson Cancer Research Center, University of Washington, , and Seattle Cancer Care Alliance</li>
        <li>Office of Human Research Protections (OHRP)</li>
        <li>NIH/ NCI</li>
        <li>Institutional Review Boards (IRB), including the Fred Hutchinson Cancer Research Center IRB and the Washington State IRB.
            An IRB is a group that reviews the study to protect your rights as a research participant</li>
    </ul><p>

    <div>We will do our best to keep your personal information confidential. But we cannot guarantee total
        confidentiality. Your personal information may be given out if required by law. For example, a court may order
        study information to be disclosed. Such cases are rare.
    </div><p>

    <div>We will not use your personal identifiable information in any reports about this study, such as journal articles
        or presentations at scientific meetings.
    </div><p>

    <div><span><strong>Will you pay me to be in this study?</strong></span></div><p>
    <div>There is no payment for being in this study.</div><p>

    <div><span><strong>How much will this study cost me?</strong></span></div><p>
    <div>There are no extra costs for being in this study.</div><p>

    <div><span><strong>Your rights</strong></span></div><p>
    <ul>
        <li>You do not have to join this study. You are free to say yes or no. Your regular medical care will not change.</li>
        <li>If you join this study, you do not have to stay in it. You may stop at any time (even before you start). There is no
            penalty or loss of benefits for stopping.</li>
        <li>During the study, we may learn new information you need to know. For example, some information may affect
            your health or well-being. Other information may make you change your mind about being in this study.
            If we learn these kinds of information, we will tell you.</li>
        <li>You may change your mind and want to take back your permission, you may do so at any time. To take back your
            permission, write to: Nola Klemfuss, at nklemfus@seattlecca.org.  If you do this, you may no longer be allowed
            to be in the Substudy. If we have health information by then, it may stay in the Study record.</li>
    </ul><p>

    <div><span><strong>Signature</strong></span></div><p>
    <ul>
        <li>You do not have to give permission for the Researchers to have access to your PHI. If you do not, you
            will not be allowed to join the Substudy but you can still participate in the Registry arm of the study.</li>
        <li>I agree to let my doctors and other health care providers use, create, and share health information that
            identifies me with the Researchers. Type your name in the signature form below.</li>
    </ul><p>

    <table style="border: 1px solid grey; padding: 5px;">
        <tr>
            <td><span><strong>If you have questions about:</strong></span></td>
            <td><span><strong>Call:</strong></span></td>
        </tr>
        <tr>
            <td><div>This study (including complaints and requests for information)</div></td>
            <td><div>206-667-3377 (Dr. Peter Nelson)<br>
                206-667-7846 (Dr. Scott Ramsey)<br>
                206-667-3042 (Nola Klemfuss, Project Manager)<br>
                206-667-4867 (Karen Hansen, Director of Institutional Review Office, Fred Hutchinson Cancer Research Center)
            </div></td>
        </tr>
        <tr>
            <td><div>Your rights as a research participant or to offer input about the study</div></td>
            <td><div>206-667-4867 (Karen Hansen, Director of Institutional Review Office, Fred Hutchinson Cancer Research Center)
            </div></td>
        </tr>
        <tr>
            <td><div>If you get sick or hurt in this study</div></td>
            <td><div>206-667-3377 (Dr. Peter Nelson)</div></td>
        </tr>
    </table><p>

    <p><span>If you agree to participate, please enter in your information below:</span></p>
    <div id="mpower-div"></div><p>

</div>
