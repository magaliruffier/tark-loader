#!/usr/bin/env python

"""
.. See the NOTICE file distributed with this work for additional information
   regarding copyright ownership.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
"""

from __future__ import print_function

import argparse
import json
import mysql.connector
from mysql.connector import errorcode


class tark_query:
    """
    Class related to handling the functions for interacting directly with the
    HDF5 files. All required information should be passed to this class.
    """

    def __init__(self,
                 host='localhost', port=3306, user='test', db='',
                 source_name='Ensembl'):
        """
        Intialisation function for the tark datasets class

        Parameters
        ----------
        host : str
        port : int
        user : str
        db : str
        scource_name : str
            Source shortname used in the Tark DB release_source table
        """

        self.source_name = source_name

        # Open database connection
        self.dbc = mysql.connector.connect(
            user=user,
            host=host,
            port=port,
            database=db)

    def get_set_names(self):
        """
        Get the list of release_set shortnames for the defined source

        Returns
        -------
        shortnames : list of tuples
        """
        cursor = self.dbc.cursor()
        sql = """
            SELECT
                rs.shortname
            FROM
                release_set AS rs
                JOIN release_source AS rst ON (rs.source_id=rst.source_id)
            WHERE
                rst.shortname=%s;
        """

        try:
            cursor.execute(sql, (self.source_name,))
            return cursor.fetchall()
        except mysql.connector.Error as err:
            print('MySQL Error: ' + str(err))

        return False

    def feature_count(self, feature, set_name):
        """
        Get the counts for a feature with a given set shortnamename

        Parameters
        ----------
        feature : str
            This should be Gene|Transcript|Exon|Translation
        set_name : str

        Returns
        -------
        count : int
        """

        cursor = self.dbc.cursor()
        sql = """
            SELECT
                COUNT(DISTINCT #FEATURE#.#FEATURE#_id)
            FROM
                #FEATURE#
                JOIN #FEATURE#_release_tag AS f_tag ON (#FEATURE#.#FEATURE#_id=f_tag.feature_id)
                JOIN release_set AS rs ON (f_tag.release_id=rs.release_id)
                JOIN release_source AS rst ON (rs.source_id=rst.source_id)
            WHERE
                rst.shortname=%s AND
                rs.shortname=%s;
        """

        try:
            sql = sql.replace('#FEATURE#', feature)
            cursor.execute(sql, (self.source_name, set_name,))
            result = cursor.fetchall()
            return result[0][0]
        except mysql.connector.Error as err:
            print('MySQL Error: ' + str(err))

        return False

    def feature_diff(self, feature, version, direction):
        """
        Get a count of the feature for a given release (addition, deletion or
        change)

        Parameters
        ----------
        feature : str
        version : int
        direction : str
            One of gained|removed|changed

        Returns
        -------
        count : int
        """

        cursor = self.dbc.cursor()

        sql = """
            SELECT
                COUNT(*)
            FROM
                (
                    SELECT
                        #FEATURE#.stable_id,
                        #FEATURE#.stable_id_version,
                        f_tag.feature_id,
                        rs.shortname,
                        rs.description,
                        rs.assembly_id
                    FROM
                        #FEATURE#
                        JOIN #FEATURE#_release_tag AS f_tag ON (#FEATURE#.#FEATURE#_id=f_tag.feature_id)
                        JOIN release_set AS rs ON (f_tag.release_id=rs.release_id)
                        JOIN release_source AS rst ON (rs.source_id=rst.source_id)
                    WHERE
                        rs.shortname=%s AND
                        rst.shortname=%s
                ) AS v0
                #DIRECTION# JOIN (
                    SELECT
                        #FEATURE#.stable_id,
                        #FEATURE#.stable_id_version,
                        f_tag.feature_id,
                        rs.shortname,
                        rs.description,
                        rs.assembly_id
                    FROM
                        #FEATURE#
                        JOIN #FEATURE#_release_tag AS f_tag ON (#FEATURE#.#FEATURE#_id=f_tag.feature_id)
                        JOIN release_set AS rs ON (f_tag.release_id=rs.release_id)
                        JOIN release_source AS rst ON (rs.source_id=rst.source_id)
                    WHERE
                        rs.shortname=%s AND
                        rst.shortname=%s
                ) AS v1 ON (v0.stable_id=v1.stable_id)
            WHERE
                #OUTER_WHERE#;
        """

        sql = sql.replace('#FEATURE#', feature)
        if direction == 'removed':
            sql = sql.replace('#DIRECTION#', 'LEFT')
            sql = sql.replace('#OUTER_WHERE#', 'v1.stable_id IS NULL')
        elif direction == 'gained':
            sql = sql.replace('#DIRECTION#', 'RIGHT')
            sql = sql.replace('#OUTER_WHERE#', 'v0.stable_id IS NULL')
        else:
            sql = sql.replace('#DIRECTION#', '')
            sql = sql.replace(
                '#OUTER_WHERE#',
                'v0.stable_id_version!=v1.stable_id_version'
            )

        try:
            cursor.execute(
                sql,
                (
                    str(int(version)-1),
                    self.source_name,
                    str(version),
                    self.source_name,
                )
            )
            results = cursor.fetchall()
            return results[0][0]
        except mysql.connector.Error as err:
            print('MySQL Error: ' + str(err))

        return False

    def generate_stats(self):
        """
        Generate the JSON blobs for stats between all releases for the source
        defined in the object creation.

        Returns
        -------
        list_of_dicts : list
            Each dict object contains the summary stats for a given release
        """

        set_names = self.get_set_names()

        stats_list = []
        for set_name in set_names:
            feature_stats = {
                'release': {
                    'previous': int(set_name[0])-1,
                    'current': int(set_name[0])
                }
            }
            for feature in ['gene', 'transcript', 'exon', 'translation']:
                f_count = self.feature_count(feature, set_name[0])

                f_removed = self.feature_diff(feature, set_name[0], 'removed')
                f_gained = self.feature_diff(feature, set_name[0], 'gained')
                f_changed = self.feature_diff(feature, set_name[0], 'changed')

                feature_stats[feature] = {
                    'tark_release': f_count,
                    'removed': f_removed,
                    'gained': f_gained,
                    'changed': f_changed
                }

                print(feature, set_name[0], feature_stats[feature])

            stats_list.append(feature_stats)

        return stats_list


class ensembl_query:
    """
    Class related to handling the functions for interacting directly with the
    HDF5 files. All required information should be passed to this class.
    """

    def __init__(self, host='localhost', port=3306, user='test', db='',
                 include='', exclude=''):
        """
        Intialisation function for accessing the ensembl databases

        Parameters
        ----------
        host : str
        port : int
        user : str
        db : str
        """

        # Open database connection
        self.dbc = mysql.connector.connect(
            user=user,
            host=host,
            port=port)

        self.include = include
        self.exclude = exclude

    def feature_counts(self, db_name):
        """
        Get a random list of names to iterate through
        """
        cursor = self.dbc.cursor()

        cursor.execute('USE ' + db_name)

        f_counts = {}
        for feature in ['gene', 'transcript', 'exon', 'translation']:
            sql = """
                SELECT
                    COUNT(DISTINCT #FEATURE#.stable_id)
                FROM
                    #FROM#
                #WHERE#;
            """

            params = []

            where = ''
            if self.include:
                inc_list = self.include.split(',')
                where = 'WHERE gene.source IN ( %s' + ', %s'*(len(inc_list)-1) + ' )'
                params += inc_list
            elif self.exclude:
                exc_list = self.exclude.split(',')
                where = 'WHERE gene.source NOT IN ( %s' + ', %s'*(len(exc_list)-1) + ' )'
                params += exc_list

            tables = feature
            current_feature = feature
            if feature == 'exon':
                tables = """
                    exon AS feature
                    JOIN exon_transcript ON feature.exon_id=exon_transcript.exon_id
                    JOIN transcript ON exon_transcript.transcript_id=transcript.transcript_id
                    JOIN gene ON transcript.gene_id=gene.gene_id
                """
                current_feature = 'feature'
            elif feature == 'transcript':
                tables = """
                    transcript AS feature
                    JOIN gene ON feature.gene_id=gene.gene_id
                """
                current_feature = 'feature'
            elif feature == 'translation':
                tables = """
                    translation AS feature
                    JOIN transcript ON feature.transcript_id=transcript.transcript_id
                    JOIN gene ON transcript.gene_id=gene.gene_id
                """
                current_feature = 'feature'

            sql = sql.replace('#FEATURE#', current_feature)
            sql = sql.replace('#FROM#', tables)
            sql = sql.replace('#WHERE#', where)

            try:
                cursor.execute(sql, tuple(params))
                f_counts[feature] = cursor.fetchall()
            except mysql.connector.Error as err:
                print('MySQL Error: ' + str(err))

        return f_counts

    def add_ensembl_counts(self, species, json_list):
        """
        """
        cursor = self.dbc.cursor()

        out_json = []

        for json_obj in json_list:
            try:
                cursor.execute(
                    'USE ensembl_production_' + str(
                        json_obj['release']['current']
                    )
                )
                sql = """
                    SELECT
                        full_db_name
                    FROM
                        db_list
                    WHERE
                        full_db_name LIKE '#SPECIES#_core\_%'
                    ORDER BY db_id DESC
                    LIMIT 1;
                """
                sql = sql.replace('#SPECIES#', species)
                cursor.execute(sql)
                dbs = cursor.fetchall()

                print(dbs[0][0])
                f_counts = self.feature_counts(dbs[0][0])

                json_obj['gene']['core'] = f_counts['gene'][0][0]
                json_obj['transcript']['core'] = f_counts['transcript'][0][0]
                json_obj['exon']['core'] = f_counts['exon'][0][0]
                json_obj['translation']['core'] = f_counts['translation'][0][0]
            except mysql.connector.Error as err:
                print(dbs[0][0])
                print('MySQL Error: ' + str(err))

            out_json.append(json_obj)

        return out_json


# ------------------------------------------------------------------------------

if __name__ == "__main__":

    # Set up the command line parameters
    PARSER = argparse.ArgumentParser(description="Generate release statistics")
    PARSER.add_argument(
        "--host", help="Host")
    PARSER.add_argument(
        "--port", help="Port")
    PARSER.add_argument(
        "--user", help="Read Only username")
    PARSER.add_argument(
        "--db", help="Database")
    PARSER.add_argument(
        "--source",
        help="Name of the source to generate stats for",
        default=10)
    PARSER.add_argument(
        "--ehost", help="Ensembl Host")
    PARSER.add_argument(
        "--eport", help="Ensembl Port")
    PARSER.add_argument(
        "--euser", help="Read Only username")
    PARSER.add_argument(
        "--species", help="Ensembl species (eg homo_sapiens)")
    PARSER.add_argument(
        "--include",
        help="Ensembl Include Sources",
        default=None)
    PARSER.add_argument(
        "--exclude",
        help="Ensembl Exclude Sources",
        default=None)
    PARSER.add_argument(
        "--output",
        help="Location of the outpout JSON file")

    # Get the matching parameters from the command line
    ARGS = PARSER.parse_args()

    TARK_QUERY = tark_query(
        host=ARGS.host,
        port=ARGS.port,
        user=ARGS.user,
        db=ARGS.db,
        source_name=ARGS.source
    )

    OUTPUT_JSON = TARK_QUERY.generate_stats()

    ENSEMBL_QUERY = ensembl_query(
        host=ARGS.ehost,
        port=ARGS.eport,
        user=ARGS.euser,
        include=ARGS.include,
        exclude=ARGS.exclude,
    )

    OUTPUT_JSON = ENSEMBL_QUERY.add_ensembl_counts(
        species=ARGS.species,
        json_list=OUTPUT_JSON
    )

    with open(ARGS.output, 'w') as f_out:
        f_out.write(json.dumps(OUTPUT_JSON))
