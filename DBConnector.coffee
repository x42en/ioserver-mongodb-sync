# Copyright [2017] 
# @Email: x42en (at) users (dot) noreply (dot) github (dot) com
# @Author: Ben Mz

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Mongo = require 'mongo-sync'
Fiber = require 'fibers'

# Compile file using:
# coffee -o bin/ -w --bare --no-header -c src/*.coffee
# Run using:
# ./bin.main.js
module.exports = class DBConnector
    constructor: ({host,port,user,pwd,db,authMethod}={}) ->
        host = host || '127.0.0.1'
        try
            port = Number(port) || 27017
        catch e
            throw 'Invalid port.'
        
        unless db
            throw 'Database not set.'
        
        user = user || false
        pwd = pwd || false
        authMethod = authMethod || 'SCRAM-SHA-1'

        try
            @_server = new Mongo.Server "#{host}:#{port}"

            Fiber(=>
                @_database = @_server.db db
                if user and pwd
                    @_database.auth user, pwd, {authMechanism: authMethod}
            ).run()
        catch e
            throw e
    
    _close: -> @_server.close()

    collection: (name) -> @_database.getCollection name
    