/*-
 * Copyright (c) 2011-2012           Scott Ringwelski <sgringwe@mtu.edu>
 *
 * Originally Written by Scott Ringwelski for BeatBox Music Player
 * BeatBox Music Player: http://www.launchpad.net/beat-box
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

using Gtk;
using Gee;
using GLib;

public class BeatBox.RadioTreeModel : BaseTreeModel {
	LibraryManager lm;
	GLib.Icon _playing;
	public bool is_current;
	
	
	/* treesortable stuff */
	bool removing_medias;
	
	/* custom signals for custom treeview. for speed */
	public signal void rows_changed(LinkedList<TreePath> paths, LinkedList<TreeIter?> iters);
	public signal void rows_deleted (LinkedList<TreePath> paths);
	public signal void rows_inserted (LinkedList<TreePath> paths, LinkedList<TreeIter?> iters);
	
	/** Initialize data storage, columns, etc. **/
	public RadioTreeModel(LibraryManager lm, LinkedList<string> column_types) {
		this.lm = lm;
		_columns = column_types;
		_playing = Icons.MEDIA_PLAY_SYMBOLIC.get_gicon ();
		removing_medias = false;

		rows = new Sequence<int>();
	
		sort_column_id = -2;
		sort_direction = SortType.ASCENDING;
		column_sorts = new HashMap<int, CompareFuncHolder>();
	
		stamp = (int)GLib.Random.next_int();
	}

	/** Initializes and sets value to that at column. **/
	public override void get_value_impl (TreeIter iter, int column, out Value val) {
		val = Value(get_column_type(column));
		if(iter.stamp != this.stamp || column < 0 || column >= _columns.size || removing_medias)
			return;
		
		if(!((SequenceIter<ValueArray>)iter.user_data).is_end()) {
			Media s = lm.media_from_id(rows.get(((SequenceIter<int>)iter.user_data)));
			if(s == null)
				return;
			
			if(column == 0)
				val = (int)s.rowid;
			else if(column == 1) {
				if(lm.media_info.media != null && lm.media_info.media.rowid == s.rowid && is_current)
					val = _playing;
				else if(s.unique_status_image != null)
					val = s.unique_status_image;
				else
					val = Value(typeof(GLib.Icon));
			}
			else if(column == 2)
				val = s.album_artist;
			else if(column == 3)
				val = s.genre;
			else if(column == 4)
				val = (int)s.rating;
			else if(column == 5)
				val = (int)s.pulseProgress;
		}
	}

	/** Some actual functions to use this model **/
	public TreeIter? getIterFromRowid(int id) {
		SequenceIter s_iter = rows.get_begin_iter();
		
		for(int index = 0; index < rows.get_length(); ++index) {
			s_iter = rows.get_iter_at_pos(index);
			
			if(id == rows.get(s_iter)) {
				TreeIter iter = TreeIter();
				iter.stamp = this.stamp;
				iter.user_data = s_iter;
				
				return iter;
			}
		}
		
		return null;
	}
	
	public int getRowidFromIter(TreeIter iter) {
		if(iter.stamp != this.stamp || ((SequenceIter)iter.user_data).is_end())
			return 0;
		
		return rows.get(((SequenceIter<int>)iter.user_data));
	}
	
	public int getRowidFromPath(string path) {
		if(int.parse(path) < 0 || int.parse(path) >= rows.get_length())
			return 0;
		
		SequenceIter s_iter = rows.get_iter_at_pos(int.parse(path));
		
		if(s_iter.is_end())
			return 0;
		
		return rows.get(s_iter);
	}
	
	/** simply adds iter to the model **/
	public void append(out TreeIter iter) {
	    iter = TreeIter ();
		SequenceIter<int> added = rows.append(0);
		iter.stamp = this.stamp;
		iter.user_data = added;
	}
	
	/** convenience method to insert medias into the model. No iters returned. **/
	public void append_medias(Collection<int> medias, bool emit) {
		foreach(int id in medias) {
			SequenceIter<int> added = rows.append(id);
			
			if(emit) {
				TreePath path = new TreePath.from_string(added.get_position().to_string());
			
				TreeIter iter = TreeIter();
				iter.stamp = this.stamp;
				iter.user_data = added;
				
				row_inserted(path, iter);
			}
		}
	}
	
	public void turnOffPixbuf(int id) {
		SequenceIter s_iter = rows.get_begin_iter();
		
		for(int index = 0; index < rows.get_length(); ++index) {
			s_iter = rows.get_iter_at_pos(index);
			
			if(id == rows.get(s_iter)) {
				TreePath path = new TreePath.from_string(s_iter.get_position().to_string());
				
				TreeIter iter = TreeIter();
				iter.stamp = this.stamp;
				iter.user_data = s_iter;
				
				row_changed(path, iter);
				return;
			}
		}
	}
	
	// just a convenience function
	public void updateMedia(int id, bool is_current) {
		ArrayList<int> temp = new ArrayList<int>();
		temp.add(id);
		updateMedias(temp, is_current);
	}
	
	public void updateMedias(owned Collection<int> rowids, bool is_current) {
		SequenceIter s_iter = rows.get_begin_iter();
		
		for(int index = 0; index < rows.get_length(); ++index) {
			s_iter = rows.get_iter_at_pos(index);
			
			if(rowids.contains(rows.get(s_iter))) {
				TreePath path = new TreePath.from_string(s_iter.get_position().to_string());
			
				TreeIter iter = TreeIter();
				iter.stamp = this.stamp;
				iter.user_data = s_iter;
				
				row_changed(path, iter);
				
				// can't do this. rowids must be read only
				//rowids.remove(rows.get(s_iter));
			}
			
			if(rowids.size <= 0)
				return;
		}
	}
	
	public new void set(TreeIter iter, ...) {
		if(iter.stamp != this.stamp)
			return;
		
		var args = va_list(); // now call args.arg() to poll
		
		while(true) {
			int col = args.arg();
			if(col < 0 || col >= _columns.size)
				return;
			
			/*else if(_columns[col] == " ") {
				debug("set oh hi3\n");
				Gdk.Pixbuf val = args.arg();
				((SequenceIter<ValueArray>)iter.user_data).get().get_nth(col).set_object(val);
			}
			else if(_columns[col] == "Title" || _columns[col] == "Artist" || _columns[col] == "Album" || _columns[col] == "Genre") {
				debug("set oh hi2\n");
				string val = args.arg();
				((SequenceIter<ValueArray>)iter.user_data).get().get_nth(col).set_string(val);
			}
			else {
				debug("set oh hi\n");
				int val = args.arg();
				((SequenceIter<Media>)iter.user_data).get().get_nth(col).set_int(val);
			}*/
		}
	}
	
	public void remove(TreeIter iter) {
		if(iter.stamp != this.stamp)
			return;
			
		var path = new TreePath.from_string(((SequenceIter)iter.user_data).get_position().to_string());
		rows.remove((SequenceIter<int>)iter.user_data);
		row_deleted(path);
	}
	
	public void removeMedias(Collection<int> rowids) {
		removing_medias = true;
		
		SequenceIter s_iter = rows.get_begin_iter();
		
		for(int index = 0; index < rows.get_length(); ++index) {
			s_iter = rows.get_iter_at_pos(index);
			
			if(rowids.contains(rows.get(s_iter))) {
				int rowid = rows.get(s_iter);
				TreePath path = new TreePath.from_string(s_iter.get_position().to_string());
					
				rows.remove(s_iter);
					
				row_deleted(path);
				rowids.remove(rowid);
				--index;
			}
			
			if(rowids.size <= 0) {
				removing_medias = false;
				return;
			}
		}
		
		removing_medias = false;
	}
	
	public LinkedList<int> getOrderedMedias() {
		var rv = new LinkedList<int>();
		SequenceIter s_iter = rows.get_begin_iter();
		
		for(int index = 0; index < rows.get_length(); ++index) {
			s_iter = rows.get_iter_at_pos(index);
			
			int rowid = rows.get(s_iter);
			
			rv.add(rowid);
		}
		
		return rv;
	}

	/** Custom function to use built in sort in GLib.Sequence to our advantage **/
	public override int sequence_iter_compare_func (SequenceIter<int> a, SequenceIter<int> b) {
		int rv;
		
		if(sort_column_id < 0)
			return 0;
		
		Media a_media = lm.media_from_id(rows.get(a));
		Media b_media = lm.media_from_id(rows.get(b));
		
		if(_columns.get(sort_column_id) == "Station") {
			if(a_media.album_artist.down() == b_media.album_artist.down()) {
				rv = advanced_string_compare(b_media.uri, a_media.uri);
			}
			else
				rv = advanced_string_compare(a_media.album_artist.down(), b_media.album_artist.down());
		}
		else if(_columns.get(sort_column_id) == "Genre") {
			if(a_media.genre.down() == b_media.genre.down()) {
				if(a_media.album_artist.down() == b_media.album_artist.down()) {
					rv = advanced_string_compare(b_media.uri, a_media.uri);
				}
				else {
					rv = advanced_string_compare(a_media.album_artist.down(), b_media.album_artist.down());
				}
			}
			else
				rv = advanced_string_compare(a_media.genre.down(), b_media.genre.down());
		}
		
		else if(_columns.get(sort_column_id) == "Rating") {
			rv = (int)(a_media.rating - b_media.rating);
		}
		else {
			rv = 1;
		}
		
		if(sort_direction == SortType.DESCENDING)
			rv = (rv > 0) ? -1 : 1;
		
		return rv;
	}
	
	private int advanced_string_compare(string a, string b) {
		if(a == "" && b != "")
			return 1;
		else if(a != "" && b == "")
			return -1;
		
		return (a > b) ? 1 : -1;
	}
}
