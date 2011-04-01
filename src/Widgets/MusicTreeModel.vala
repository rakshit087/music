/** A TreeModel implemented to support list-only sorting and filtering.
 * TreeIter data holds:
 *      stamp - index of row in rows
 *      user_data - visibility?
 * 
 */

using Gtk;
using Gee;
using GLib;

private class BeatBox.RowData : GLib.Object {
    int real_index; // as opposed to the always changing index in rows from sorting
    
    Value[] data; // data for each column
    int visible; // for search/filtering
}

public class BeatBox.MusicTreeModel : GLib.Object, TreeModel, TreeSortable {
    /* data storage variables */
    LinkedList<RowData> rows; // A GLib.Value is vala equivelant void*, but pretty.
    
    Type[] _columns; // an array of the column types
    int visible_column;
    
    /* custom signals for custom treeview. for speed */
    public signal void rows_changed(LinkedList<TreePath> paths, LinkedList<TreeIter?> iters);
    public signal void rows_deleted (LinkedList<TreePath> paths);
	public signal void rows_inserted (LinkedList<TreePath> paths, LinkedList<TreeIter?> iters);
	
	/** Initialize data storage, columns, etc. **/
	public MusicTreeModel(Type[] column_types) {
		_columns = column_types;
        column_count = _columns.size;
        
        rows = new HashMap<int, Value[]>();
	}
	
	/** calls func on each node in model in a depth-first fashion **/
	public void foreach(TreeModelForeachFunc func) {
		
	}

	/** Sets params of each id-value pair of the value of that iter **/
	public void get (TreeIter iter, ...) {
	
	}

	/** Returns Type of column at index_ **/
	public Type get_column_type (int index_) {
		return _columns[index_];
	}

	/** Returns a set of flags supported by this interface **/
	public TreeModelFlags get_flags () {
		return TreeModelFlags.LIST_ONLY;
	}

	/** Sets iter to a valid iterator pointing to path **/
	public bool get_iter (out TreeIter iter, TreePath path) {
        
        
		return false;
	}

	/** Initializes iter with the first iterator in the tree (the one at the path "0") and returns true. **/
	public bool get_iter_first (out TreeIter iter) {
		
		return false;
	}

	/** Sets iter to a valid iterator pointing to path_string, if it exists. **/
	public bool get_iter_from_string (out TreeIter iter, string path_string) {
		
		return false;
	}

	/** Returns the number of columns supported by tree_model. **/
	public int get_n_columns () {
		return _columns.size;
	}

	/** Returns a newly-created Gtk.TreePath referenced by iter. **/
	public TreePath get_path (TreeIter iter) {
		
		return new TreePath();
	}

	/** Generates a string representation of the iter. **/
	public string get_string_from_iter (TreeIter iter) {
		
		return "";
	}

	/**   **/
	public void get_valist (TreeIter iter, void* var_args) {
	
	}

	/** Initializes and sets value to that at column. **/
	public void get_value (TreeIter iter, int column, out Value value) {
	
	}

	/** Sets iter to point to the first child of parent. **/
	public bool iter_children (out TreeIter iter, TreeIter? parent) {
		
		return false;
	}

	/** Returns true if iter has children, false otherwise. **/
	public bool iter_has_child (TreeIter iter) {
		
		return false;
	}

	/** Returns the number of children that iter has. **/
	public int iter_n_children (TreeIter? iter) {
		
		return 0;
	}

	/** Sets iter to point to the node following it at the current level. **/
	public bool iter_next (ref TreeIter iter) {
		
		return false;
	}

	/** Sets iter to be the child of parent, using the given index. **/
	public bool iter_nth_child (out TreeIter iter, TreeIter? parent, int n) {
		
		return false;
	}

	/** Sets iter to be the parent of child. **/
	public bool iter_parent (out TreeIter iter, TreeIter child) {
		
		return false;
	}

	/** Lets the tree ref the node. **/
	public void ref_node (TreeIter iter) {
		
	}

	/** Lets the tree unref the node. **/
	public void unref_node (TreeIter iter) {
		
	}
    
    /** TreeSortable Interface. **/
    
    /** Fills in sort_column_id and order with the current sort column and the order. **/
    public bool get_sort_column_id (out int sort_column_id, out SortType order) {
        sort_column_id = 0;
        order = SortType.ASCENDING;
        
        return false;
    }
    
    /**  Returns true if the model has a default sort function. **/
    public bool has_default_sort_func () {
        
        return false;
    }
    
    /** Sets the default comparison function used when sorting to be sort_func. **/
    public void set_default_sort_func (owned TreeIterCompareFunc sort_func) {
        
        return false;
    }
    
    /** Sets the current sort column to be sort_column_id. **/
    public void set_sort_column_id (int sort_column_id, SortType order) {
        
        return false;
    }
    
    /** Sets the comparison function used when sorting to be sort_func. **/
    public void set_sort_func (int sort_column_id, owned TreeIterCompareFunc sort_func) {
        
        return false;
    }
    
    /** This is for filtering. Same approach as TreeModelFilter for the most part
     * set_visible_column: sets the index of the column to use for filtering
     * get_real_iter() : returns an iter that is relative to ALL iters, not just filtered ones
     * filter() : The model is not filtered on visible_column_change, it is filtered on filter()
     */
    
    /* Sets the column that is checked for whether or not the row is visible */
    public void set_visible_column(int index) {
        visible_column = index;
    }
    
    /* Gets the visible column */
    public int get_visible_column() {
        return visible_column;
    }
    
    /* If you give it an iter of filtered rows, it will return an iter of all rows */
    public void get_overall_iter(out TreeIter real_iter, TreeIter filtered_iter) {
        
    }
    
    /* This does all the filtering. I am not sure how this works yet. */
    public void filter() {
        
    }
}
