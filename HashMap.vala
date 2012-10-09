public class Key {
	public string key1;
	public string key2;

	public Key (string key1, string key2) {
		this.key1 = key1;
		this.key2 = key2;
	}
}

/*
public static int main (string[] args) {
	GLib.HashFunc<Key> hash_func = (a) => {
		HashFunc func = Gee.Functions.get_hash_func_for (typeof (string));
		return func (a.key1) ^ func (a.key2);
	};

	GLib.EqualFunc<Key> equal_func = (a, b) => {
		return a.key1 == b.key1 && a.key2 == b.key2;
	};

	Gee.HashMap<Key, string> map = new Gee.HashMap<Key, string> (hash_func, equal_func);
	map.set (new Key ("aa", "bb"), "1");
	map.set (new Key ("aa", "cc"), "2");

	message ("%s", map.get (new Key ("aa", "bb")));
	message ("%s", map.get (new Key ("aa", "cc")));
	message ("%s", map.get (new Key ("aa", "dd")));

	return 0;
}
*/
