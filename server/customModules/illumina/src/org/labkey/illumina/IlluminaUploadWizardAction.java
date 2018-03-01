/*
 * Copyright (c) 2010-2016 LabKey Corporation
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
package org.labkey.illumina;

import org.labkey.api.exp.api.ExpMaterial;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.InsertPermission;
import org.labkey.api.study.actions.AssayRunUploadForm;
import org.labkey.api.study.actions.UploadWizardAction;
import org.labkey.api.study.assay.SampleChooserDisplayColumn;
import org.labkey.api.view.InsertView;

import java.util.Collections;

/**
 * User: jeckels
 * Date: Sep 7, 2010
 */
@RequiresPermission(InsertPermission.class)
public class IlluminaUploadWizardAction extends UploadWizardAction<AssayRunUploadForm<IlluminaAssayProvider>, IlluminaAssayProvider>
{
    public static final int MIN_SAMPLES = 1;
    public static final int MAX_SAMPLES = 20;

    @Override
    protected void addSampleInputColumns(AssayRunUploadForm<IlluminaAssayProvider> form, InsertView insertView)
    {
        super.addSampleInputColumns(form, insertView);

        insertView.getDataRegion().addDisplayColumn(new SampleChooserDisplayColumn(MIN_SAMPLES, MAX_SAMPLES, Collections.emptyList(), 8));
    }
}
