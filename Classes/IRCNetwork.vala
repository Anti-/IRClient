namespace Client {
	
	class IRCNetwork : GLib.Object {
	
		public Gee.HashMap<string, IRChannel> hmpChannels;
		public GLib.SocketConnection objConnection;
		public DataInputStream objStream;
		public string[] arrChannels;
		public string strAddress;
		public string intPort;
		public string strNick;
		public string strUser;
		public string strReal;
		public string blnAutojoin;
		public string blnSSL;
		
	}
	
}
