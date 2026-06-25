function fn() {
  // Read the system property passed from your Java test class
  var serverPort = karate.properties['server.port'];
  
  // Fallback to a default port if running the feature file directly
  if (!serverPort) {
    serverPort = '8080'; 
  }
  
  var config = {
    // Dynamically construct your urlBase variable
    urlBase: 'http://localhost:' + serverPort
  };
  
  return config;
}

// function fn() {
//     var serverPort = karate.properties['server.port'];
//     return {
//         urlBase: 'http://localhost:' + serverPort
//     };
// }