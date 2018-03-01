/*
 * Copyright (c) 2013-2017 LabKey Corporation
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

package org.labkey.api.iterator;

import java.io.IOException;
import java.util.Iterator;

/**
 * Convenience class that turns a normal Iterator into a CloseableIterator, with a no-op close()
 * User: adam
 * Date: Feb 16, 2013
*/
public class WrappingCloseableIterator<T> implements CloseableIterator<T>
{
    private final Iterator<T> _iter;

    public WrappingCloseableIterator(Iterator<T> iter)
    {
        _iter = iter;
    }

    @Override
    public boolean hasNext()
    {
        return _iter.hasNext();
    }

    @Override
    public T next()
    {
        return _iter.next();
    }

    @Override
    public void remove()
    {
        _iter.remove();
    }

    @Override
    public void close() throws IOException
    {
    }
}
