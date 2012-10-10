namespace Client {
	
	class IRClient : ClientBase {
		
		construct {
			this.hmpNetworks = new Gee.HashMap<string, IRCNetwork>();
			this.objKeyFile = new GLib.KeyFile();
		}
		
		public void readConfiguration(){
			string strNetwork = "";
			string strAddress = "";
			string intPort = ""; 
			string strNick = "";
			string strUser = "";
			string strReal = "";
			string blnAutojoin = "false";
			string blnSSL = "false";
			string strChannels;
			try {
				this.objKeyFile.load_from_file("Settings.ini", GLib.KeyFileFlags.NONE);
				foreach(string strNetworks in this.objKeyFile.get_groups()){
					strNetwork = strNetworks;
					strAddress = this.objKeyFile.get_value(strNetwork, "Address");
					intPort = this.objKeyFile.get_value(strNetwork, "Port").to_string();
					strNick = this.objKeyFile.get_value(strNetwork, "Nick");
					strUser = this.objKeyFile.get_value(strNetwork, "User");
					strReal = this.objKeyFile.get_value(strNetwork, "Real");
					blnAutojoin = this.objKeyFile.get_value(strNetwork, "Autojoin");
					blnSSL = this.objKeyFile.get_value(strNetwork, "SSL");
					strChannels = this.objKeyFile.get_value(strNetwork, "Channels");
					this.addNetwork({strNetwork, strAddress, intPort, strNick, strUser, strReal, blnAutojoin, blnSSL});
				}
			} catch(GLib.Error objError){
				stdout.printf("Error: %s%c", objError.message, 10);
			}
		}
		
		public async override void loopFunction(string strNetwork){
			string strData;
			string strSend;
			while(true){
				strData = this.recvData(strNetwork);
				if(strData.index_of(":End of message of the day.") > -1){
					string[] arrChannel;
					foreach(string strChannelVal in this.hmpNetworks[strNetwork].arrChannels){
						arrChannel = strChannelVal.split("/", 2);
						if(arrChannel[1] == "true"){
							this.joinChannel(strNetwork, arrChannel[0]);
						}
					}
				} else {
					if(strData.index_of("PING") > -1){
						strSend = strData.replace("PING", "PONG");
						this.sendData(strNetwork, strSend);
					}
				}
			}
		}
		
	}
	
}
