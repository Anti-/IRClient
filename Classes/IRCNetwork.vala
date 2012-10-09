namespace Client {
	
	class IRCNetwork : GLib.Object {
	
		protected Gee.HashMap<string, IRChannel> hmpChannels;
		public GLib.SocketConnection objConnection;
		public DataInputStream objStream;
		public string strAddress;
		public string intPort;
		public string strNick;
		public string strUser;
		public string strReal;
		public string blnAutojoin;
		public string blnSSL;
		
		public async void setConnection(GLib.SocketConnection objConnection){
			this.objConnection = objConnection;
		}
		
		public async void setInputStream(DataInputStream objStream){
			this.objStream = objStream;
		}
		
		public async GLib.SocketConnection getConnection(){
			return this.objConnection;
		}
		
		public async DataInputStream getStream(){
			return this.objStream;
		}
		
		
	}
	
}
