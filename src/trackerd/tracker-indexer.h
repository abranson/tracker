/* Tracker - indexer and metadata database engine
 * Copyright (C) 2006, Mr Jamie McCracken (jamiemcc@gnome.org)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 */



#ifndef _TRACKER_INDEXER_H
#define _TRACKER_INDEXER_H


#include <stdlib.h>
#include <glib.h>

#include "tracker-db-sqlite.h"
#include "tracker-utils.h"

typedef struct {                         	 
	guint32 	service_id;              /* Service ID of the document */
	guint32 	service_type_id;         /* Service type ID of the document */
	guint32 	score;            	 /* Ranking score */
} SearchHit;


typedef enum {
	WordNormal,
	WordWildCard,
	WordExactPhrase
} WordType;


typedef struct {                        
	gchar	 	*word;    
	gint		hit_count;
	gfloat		idf;
	WordType	word_type;
} SearchWord;

typedef struct {                        
	DBConnection 	*db_con;
	DBConnection 	*db_con_email;
	gint 		*service_array;    
	gint 		service_array_count;
	gint 		hit_count;
	GSList	        *hits;
	GSList		*words;
	GSList		*duds;
	gint		offset;
	gint		limit;
} SearchQuery;


typedef enum {
	BoolAnd,
	BoolOr,
	BoolNot
} BoolOp;

SearchQuery * 	tracker_create_query 			(DBConnection *db_con, gint *service_array, gint service_array_count, gint offset, gint limit);
void		tracker_free_query 			(SearchQuery *query);

void		tracker_add_query_word 			(SearchQuery *query, const gchar *word, WordType word_type);

guint32		tracker_indexer_calc_amalgamated 	(gint service, gint score);
void		tracker_index_free_hit_list		(GSList *hit_list);

DBConnection * 	tracker_indexer_open 			(const gchar *name);
void		tracker_indexer_close 			(DBConnection *db_con);
void		tracker_indexer_free 			(DBConnection *db_con, gboolean remove_file);
guint32		tracker_indexer_size 			(DBConnection *db_con);
gboolean	tracker_indexer_optimize		(DBConnection *db_con);
void		tracker_indexer_sync 			(DBConnection *db_con);

void		tracker_indexer_merge_index 		(DBConnection *db_con, gboolean update);

/* Indexing api */
gboolean	tracker_indexer_append_word 		(DBConnection *db_con, const gchar *word, guint32 id, gint service, gint score);
gboolean	tracker_indexer_append_word_chunk 	(DBConnection *db_con, const gchar *word, WordDetails *details, gint word_detail_count);
gint		tracker_indexer_append_word_lists 	(DBConnection *db_con, const gchar *word, GSList *list1, GSList *list2);

gboolean	tracker_indexer_update_word 		(DBConnection *db_con, const gchar *word, guint32 id, gint service, gint score, gboolean remove_word);
GSList *	tracker_indexer_update_word_chunk	(DBConnection *db_con, const gchar *word, WordDetails *details, gint word_detail_count);
GSList *	tracker_indexer_update_word_list 	(DBConnection *db_con, const gchar *word, GSList *update_list);


gboolean	tracker_indexer_get_hits 		(SearchQuery *query);
gchar ***	tracker_get_hit_counts 			(SearchQuery *query);
gint		tracker_get_hit_count 			(SearchQuery *query);

gchar ***	tracker_get_words_starting_with 	(DBConnection *db_con, const gchar *word);


#endif
