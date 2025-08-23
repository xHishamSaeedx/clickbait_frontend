const os = require("os");

function getLocalIPAddress() {
  const interfaces = os.networkInterfaces();

  for (const name of Object.keys(interfaces)) {
    for (const interface of interfaces[name]) {
      // Skip over non-IPv4 and internal (i.e. 127.0.0.1) addresses
      if (interface.family === "IPv4" && !interface.internal) {
        return interface.address;
      }
    }
  }

  return null;
}

const ipAddress = getLocalIPAddress();

if (ipAddress) {
  console.log("🌐 Your local IP address is:", ipAddress);
  console.log("📝 Update this in: lib/core/constants/api_constants.dart");
  console.log(`🔗 Backend URL should be: http://${ipAddress}:3000`);
} else {
  console.log("❌ Could not find local IP address");
  console.log("💡 Make sure you are connected to a network");
}
