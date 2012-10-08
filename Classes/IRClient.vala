namespace Client {
	
	using Client;
	
	class IRClient : ClientBase {
		
		construct {
			this.hmpNetworks = new Gee.HashMap<string, Gee.HashMap<string, string>>();
			this.hmpConnections = new Gee.HashMap<string, GLib.SocketConnection>();
			this.hmpInputStreams = new Gee.HashMap<string, DataInputStream>();
			this.addNetwork("IRCx", "i.r.cx", 6697, true);
			this.objKeyFile = new GLib.KeyFile();
			this.joinNetwork("IRCx", "#brows");
		}
		
		public override void loopFunction(string strNetwork){
			while(true){
				this.recvData(strNetwork);
			}
		}
		
	}
	
}
