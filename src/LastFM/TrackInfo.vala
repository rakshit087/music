using Xml;

public class LastFM.TrackInfo : Object {
	static const string api = "a40ea1720028bd40c66b17d7146b3f3b";
	
	private int _id;
	private string _name;
	private string _artist;
	private string _url;
	private int _duration;
	private int _streamable;
	private int _listeners;
	private int _playcount;
	
	private string _summary;
	private string _content;
	
	private Gee.ArrayList<LastFM.Tag> _tags;
	private LastFM.Tag tagToAdd;
	
	//public signal void track_info_retrieved(LastFM.TrackInfo info);
	
	public TrackInfo.basic() {
		_name = "Unknown Track";
		_tags = new Gee.ArrayList<LastFM.Tag>();
	}
	
	public TrackInfo.with_info(string artist, string track) {
		string track_fixed = LastFM.Core.fix_for_url(track);
		string artist_fixed = LastFM.Core.fix_for_url(artist);
		
		string url = "http://ws.audioscrobbler.com/2.0/?method=track.getinfo&api_key=" + api + "&artist=" + artist_fixed + "&track=" + track_fixed;
		
		stdout.printf("Parsing track info.\n");
		Xml.Doc* doc = Parser.parse_file (url);
		TrackInfo.with_doc(doc);
	}
	
	
	public TrackInfo.with_doc(Xml.Doc* doc) {
		TrackInfo.basic();
		
		tagToAdd = null;
        if (doc == null) {
            stderr.printf ("Could not get Track info. \n");
            return;
        }

        // Get the root node. notice the dereferencing operator -> instead of .
        Xml.Node* root = doc->get_root_element ();
        if (root == null) {
            // Free the document manually before returning
            delete doc;
            stderr.printf ("The xml file is empty. \n");
            return;
        }
        
        // Let's parse those nodes
        parse_node (root, "");

        // Free the document
        delete doc;
	}
	
	/** recursively parses the nodes in a xml doc and also calls parse_properties
	 * @param node The node to parse
	 * @param parent the parent node
	 */
	private void parse_node (Xml.Node* node, string parent) {
        // Loop over the passed node's children
        for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
            // Spaces between tags are also nodes, discard them
            if (iter->type != ElementType.ELEMENT_NODE) {
                continue;
            }

            string node_name = iter->name;
            string node_content = iter->get_content ();
                       
            if(parent == "track") {
				if(node_name == "name")
					_name = node_content;
				else if(node_name == "id")
					_id = int.parse(node_content);
				else if(node_name == "url")
					_url = node_content;
				else if(node_name == "duration")
					_duration = int.parse(node_content);
				else if(node_name == "streamable")
					_streamable = int.parse(node_content);
				else if(node_name == "playcount")
					_playcount = int.parse(node_content);
				else if(node_name == "listeners")
					_listeners = int.parse(node_content);
			}
			else if(parent == "trackartist") {
				if(node_name == "name")
					_artist = node_content;
			}
			else if(parent == "trackwiki") {
				if(node_name == "summary")
					_summary = node_content;
				else if(node_name == "content")
					_content = node_content;
			}
			else if(parent == "tracktoptagstag") {
				if(node_name == "name") {
					if(tagToAdd != null)
						_tags.add(tagToAdd);
					
					tagToAdd = new LastFM.Tag();
					tagToAdd.tag = node_content;
				}
				else if(node_name == "url")
					tagToAdd.url = node_content;
			}

            // Followed by its children nodes
            parse_node (iter, parent + node_name);
        }
    }
    
    public int id {
		get { return _id; }
		set { _id = value; }
	}
	
	public string name {
		get { return _name; }
		set { _name = value; }
	}
	
	public string artist {
		get { return _artist; }
		set { _artist = value; }
	}
	
	public string url {
		get { return _url; }
		set { _url = value; }
	}
	
	public int duration {
		get { return _duration; }
		set { _duration = value; }
	}
	
	public int streamable {
		get { return _streamable; }
		set { _streamable = value; }
	}
	
	public int playcount {
		get { return _playcount; }
		set { _playcount = value; }
	}
	
	public int listeners {
		get { return _listeners; }
		set { _listeners = value; }
	}
	
	public string summary {
		get { return _summary; }
		set { _summary = value; }
	}
	
	public string content {
		get { return _content; }
		set { _content = value; }
	}
	
	public void addTag(Tag t) {
		_tags.add(t);
	}
	
	public void addTagString(string t) {
		_tags.add(new LastFM.Tag.with_string(t));
	}
	
	public Gee.ArrayList<LastFM.Tag> tags() {
		return _tags;
	}
	
	public Gee.ArrayList<string> tagStrings() {
		var tags = new Gee.ArrayList<string>();
		
		foreach(LastFM.Tag t in _tags) {
			tags.add(t.tag);
		}
		
		return tags;
	}
    
}
