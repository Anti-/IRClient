namespace Client {
	
	abstract class ClientBase : GLib.Object {
		private GLib.Resolver objResolver = GLib.Resolver.get_default();
		protected Gee.HashMap<string, IRCNetwork> hmpNetworks;
		protected GLib.KeyFile objKeyFile;
		
		public async void addNetwork(string[] arrArguments){
			IRCNetwork objNetwork = new IRCNetwork();
			string strNetwork = arrArguments[0];
			objNetwork.strAddress = arrArguments[1];
			objNetwork.intPort = arrArguments[2];
			objNetwork.strNick = arrArguments[3];
			objNetwork.strUser = arrArguments[4];
			objNetwork.strReal = arrArguments[5];
			objNetwork.blnAutojoin = arrArguments[6];
			objNetwork.blnSSL = arrArguments[7];
			objNetwork.arrChannels = arrArguments[8].split(" ");
			this.hmpNetworks[strNetwork] = objNetwork;
			if(objNetwork.blnAutojoin == "true"){
				this.joinNetwork(strNetwork);
			}
		}
		
		public async bool joinNetwork(string strNetwork){
			if(this.hmpNetworks.has_key(strNetwork)){
				try {
					var objAddresses = yield objResolver.lookup_by_name_async(this.hmpNetworks[strNetwork].strAddress);
					var strAddress = objAddresses.nth_data(0);
					var objAddress = new GLib.InetSocketAddress(strAddress, (uint16)int.parse(this.hmpNetworks[strNetwork].intPort));
					GLib.SocketClient objClient = new SocketClient();
					if(this.hmpNetworks[strNetwork].blnSSL == "true"){
						objClient.set_tls(true);
						objClient.set_tls_validation_flags(0);
					}
					GLib.SocketConnection objConnection = this.hmpNetworks[strNetwork].objConnection = yield objClient.connect_async(objAddress);
					this.hmpNetworks[strNetwork].objStream = new DataInputStream(objConnection.input_stream);
					this.recvData(strNetwork);
					this.sendData(strNetwork, "NICK " + this.hmpNetworks[strNetwork].strNick);
					this.sendData(strNetwork, "USER " + this.hmpNetworks[strNetwork].strNick + " " + this.hmpNetworks[strNetwork].strUser + " " + this.hmpNetworks[strNetwork].strUser + ": " + this.hmpNetworks[strNetwork].strReal);
					this.loopFunction(strNetwork);
				} catch(GLib.Error objError){
					stdout.printf("Error: %s%c", objError.message, 10);
					return false;
				}
				return true;
			}
			return false;
		}
		
		/* This is TODO as in, not finished! */
		public async bool joinChannel(string strNetwork, string strChannel){
			this.sendData(strNetwork, "JOIN " + strChannel);
			return false;
		}
		
		/* This must be overridden in a subclass! */
		public async virtual void loopFunction(string strNetwork){}
		
		public string recvData(string strNetwork){
			string? strData = "";
			try {
				strData = this.hmpNetworks[strNetwork].objStream.read_line(null);
			} catch(GLib.IOError objError){
				stdout.printf("Error: %s%c", objError.message, 10);
			}
			if(strData != null){
				stdout.printf("%s%c", strData, 10);
				return strData;
			}
			return "";
		}
		
		public void sendData(string strNetwork, string strPacket){
			var strData = @strPacket + "\r\n";
			try {
				this.hmpNetworks[strNetwork].objConnection.output_stream.write(strData.data);
				this.hmpNetworks[strNetwork].objConnection.output_stream.flush();
			} catch(GLib.Error objError){
				stdout.printf("Error: %s%c", objError.message, 10);
			}
		}

	}
	
}
