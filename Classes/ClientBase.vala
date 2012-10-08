namespace Client {
	
	using Client;
	
	abstract class ClientBase : GLib.Object {
		private GLib.Resolver objResolver = GLib.Resolver.get_default();
		protected Gee.HashMap<string, Gee.HashMap<string, string>> hmpNetworks;
		protected Gee.HashMap<string, GLib.SocketConnection> hmpConnections;
		protected Gee.HashMap<string, DataInputStream> hmpInputStreams;
		protected GLib.KeyFile objKeyFile;
		
		public bool addNetwork(string strNetwork, string strAddress, int intPort, bool blnSSL = false){
			var objNetwork = new Gee.HashMap<string, string>();
			objNetwork["Address"] = strAddress;
			objNetwork["Port"] = intPort.to_string();
			objNetwork["SSL"] = blnSSL ? "true" : "false";
			try {
				this.objKeyFile.load_from_file("Settings.ini", GLib.KeyFileFlags.NONE);
				objNetwork["Nick"] = this.objKeyFile.get_value(strNetwork, "Nick");
				objNetwork["User"] = this.objKeyFile.get_value(strNetwork, "User");
				objNetwork["Real"] = this.objKeyFile.get_value(strNetwork, "Real");
			} catch(GLib.Error objError){
				stdout.printf("Error: %s", objError.message);
				return false;
			}
			this.hmpNetworks[strNetwork] = objNetwork;
			return true;
		}
		
		public bool joinNetwork(string[] arrArguments){
			string strNetwork = arrArguments[0];
			if(this.hmpNetworks.has_key(strNetwork)){
				try {
					var objAddresses = objResolver.lookup_by_name(this.hmpNetworks[strNetwork]["Address"]);
					var strAddress = objAddresses.nth_data(0);
					var objAddress = new GLib.InetSocketAddress(strAddress, (uint16)int.parse(this.hmpNetworks[strNetwork]["Port"]));
					SocketClient objClient = new SocketClient();
					// Booleans can't be used here due to the hashmap's structure, no big deal
					if(this.hmpNetworks[strNetwork]["SSL"] == "true"){
						objClient.set_tls(true);
						objClient.set_tls_validation_flags(0);
					}
					this.hmpConnections[strNetwork] = objClient.connect(objAddress);
					this.hmpInputStreams[strNetwork] = new DataInputStream(this.hmpConnections[strNetwork].input_stream);
					this.recvData(strNetwork);
					this.sendData(strNetwork, "NICK " + this.hmpNetworks[strNetwork]["Nick"]);
					this.sendData(strNetwork, "USER " + this.hmpNetworks[strNetwork]["Nick"] + " " + this.hmpNetworks[strNetwork]["User"] + " " + this.hmpNetworks[strNetwork]["User"] + ": " + this.hmpNetworks[strNetwork]["Real"]);
					for(int intChannel = 1; intChannel <= arrArguments.length; intChannel++){
						this.joinChannel(strNetwork, arrArguments[intChannel]);
					}
					this.loopFunction(strNetwork);
				} catch(GLib.Error objError){
					stdout.printf("Error: %s", objError.message);
					return false;
				}
				return true;
			}
			return false;
		}
		
		/* This is TODO as in, not finished! */
		public bool joinChannel(string strNetwork, string strChannel){
			this.sendData(strNetwork, "JOIN " + strChannel);
			return false;
		}
		
		/* This must be overridden in a subclass! */
		public virtual void loopFunction(string strNetwork){}
		
		public string recvData(string strNetwork){
			string strData = "";
			try {
				strData = this.hmpInputStreams[strNetwork].read_line(null).chomp();
			} catch(GLib.IOError objError){
				stdout.printf("Error: %s", objError.message);
			}
			if(strData != "" || strData != null){
				stdout.printf("%s%c", strData, 10);
				return strData;
			}
			return "";
		}
		
		public void sendData(string strNetwork, string strPacket){
			var strData = @strPacket + "\r\n";
			try {
				this.hmpConnections[strNetwork].output_stream.write(strData.data);
			} catch(GLib.IOError objError){
				stdout.printf("Error: %s", objError.message);
			}
		}

	}
	
}
