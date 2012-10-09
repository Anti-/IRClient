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
			this.hmpNetworks[strNetwork] = objNetwork;
			if(objNetwork.blnAutojoin == "true"){
				this.joinNetwork({strNetwork, "#brows"});
			}
		}
		
		public async bool joinNetwork(string[] arrArguments){
			string strNetwork = arrArguments[0];
			if(this.hmpNetworks.has_key(strNetwork)){
				try {
					var objAddresses = yield objResolver.lookup_by_name_async(this.hmpNetworks[strNetwork].strAddress);
					var strAddress = objAddresses.nth_data(0);
					var objAddress = new GLib.InetSocketAddress(strAddress, (uint16)int.parse(this.hmpNetworks[strNetwork].intPort));
					SocketClient objClient = new SocketClient();
					// Booleans can't be used here due to the hashmap's structure, no big deal
					if(this.hmpNetworks[strNetwork].blnSSL == "true"){
						objClient.set_tls(true);
						objClient.set_tls_validation_flags(0);
					}
					this.hmpNetworks[strNetwork].setConnection(yield objClient.connect_async(objAddress));
					GLib.SocketConnection objConnection = yield this.hmpNetworks[strNetwork].getConnection();
					this.hmpNetworks[strNetwork].setInputStream(new DataInputStream(objConnection.input_stream));
					objConnection.socket.set_blocking(true);
					this.recvData(strNetwork);
					this.sendData(strNetwork, "NICK " + this.hmpNetworks[strNetwork].strNick);
					this.sendData(strNetwork, "USER " + this.hmpNetworks[strNetwork].strNick + " " + this.hmpNetworks[strNetwork].strUser + " " + this.hmpNetworks[strNetwork].strUser + ": " + this.hmpNetworks[strNetwork].strReal);
					string strChannel;
					for(int intChannel = 1; intChannel <= arrArguments.length; intChannel++){
						strChannel = arrArguments[intChannel];
						if(strChannel == null) break;
						this.joinChannel(strNetwork, arrArguments[intChannel]);
					}
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
		
		public async string recvData(string strNetwork){
			string strData = "";
			try {
				strData = yield this.hmpNetworks[strNetwork].objStream.read_line_async();
			} catch(GLib.IOError objError){
				stdout.printf("Error: %s%c", objError.message, 10);
			}
			if(strData != "" || strData != null){
				stdout.printf("%s%c", strData, 10);
				return strData;
			}
			return "";
		}
		
		public async void sendData(string strNetwork, string strPacket){
			var strData = @strPacket + "\r\n";
			try {
				this.hmpNetworks[strNetwork].objConnection.output_stream.write_async(strData.data);
			} catch(GLib.IOError objError){
				stdout.printf("Error: %s%c", objError.message, 10);
			}
		}

	}
	
}
