namespace Client {

	class Client {
		
		static void main(string[] arrArguments){
			GLib.MainLoop objLoop = new GLib.MainLoop();
			IRClient objBot = new IRClient();
			objBot.readConfiguration();
			objLoop.run();
		}
		
	}
	
}
