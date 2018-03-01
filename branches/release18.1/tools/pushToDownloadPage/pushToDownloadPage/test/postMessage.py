#
# Copyright (c) 2011 LabKey Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#! /usr/local/lib/python

"""
Test the postMessage API

"""
import os
import random
import labkeyApi
reload(labkeyApi)

mTitle = 'This is my message title ' + str(random.random())
mBody = 'The message body is not as important as you would think.'
myresults = labkeyApi.postMessage(
    baseUrl = 'https://www.labkey.org',
    containerPath = 'Internal/Staff/bconn/downloads',
    messageTitle = mTitle,
    messageBody = mBody, 
    renderAs = 'HTML')

print myresults 