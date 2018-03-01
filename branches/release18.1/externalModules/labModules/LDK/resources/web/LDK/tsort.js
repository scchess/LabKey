/**
 * General topological sort
 * @param Array<Array> edges : list of edges. each edge forms Array<ID,ID> e.g. [12 , 3]
 * @returns Array : topological sorted list of IDs
 *
 * Adapted from: https://gist.github.com/shinout/1232505
 *
 * Copyright 2012 Shin Suzuki<shinout310@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
Ext4.ns('LDK.Utils');

LDK.Utils.tsort = function(edges){
    var nodes   = {}, // hash: stringified id of the node => { id: id, afters: lisf of ids }
        sorted  = [], // sorted list of IDs ( returned value )
        visited = {}; // hash: id of already visited node => true

    var Node = function(id) {
        this.id = id;
        this.afters = [];
    }

    // 1. build data structures
    Ext4.Array.forEach(edges, function(v) {
        var from = v[0], to = v[1];
        if (!nodes[from]) nodes[from] = new Node(from);
        if (!nodes[to]) nodes[to]     = new Node(to);
        nodes[from].afters.push(to);
    });

    // 2. topological sort
    Ext4.Array.forEach(Ext4.Object.getKeys(nodes), function visit(idstr, ancestors) {
        var node = nodes[idstr],
            id   = node.id;

        // if already exists, do nothing
        if (visited[idstr]) return;

        if (!Ext4.isArray(ancestors)) ancestors = [];

        ancestors.push(id);

        visited[idstr] = true;

        Ext4.Array.forEach(node.afters, function(afterID) {
            if (ancestors.indexOf(afterID) >= 0)  // if already in ancestors, a closed chain exists.
                throw new Error('closed chain : ' +  afterID + ' is in ' + id);

            visit(afterID.toString(), ancestors.map(function(v) { return v })); // recursive call
        });

        sorted.unshift(id);
    });

    return sorted;
};
