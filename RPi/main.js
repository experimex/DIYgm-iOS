var bleno = require('../..');

var BlenoPrimaryService = bleno.PrimaryService;

var EchoCharacteristic = require('./characteristic');

var name = "";

console.log('Running DIYgm-iOS node.js script.');

bleno.on('stateChange', function(state) {
  if (state === 'poweredOn') {
    var number = "000" + Math.floor(Math.random() * 10000);
    number = number.substr(number.length - 4);
    name = "diygm" + number;
    exports.name = name;
    console.log("Name: " + name);
    bleno.startAdvertising(name, ['e3754285-8072-458b-a45b-94a0dab368ef']);
  } else {
    bleno.stopAdvertising();
  }
});

bleno.on('advertisingStart', function(error) {
  if (!error) {
    console.log("This Raspberry Pi is now discoverable.");
    console.log("Select \"" + name + "\" in the DIYgm-iOS app to connect to it.");
    bleno.setServices([
      new BlenoPrimaryService({
        uuid: 'e3754285-8072-458b-a45b-94a0dab368ef',
        characteristics: [
          new EchoCharacteristic()
        ]
      })
    ]);
  }
  else {
    console.log("error: " + error);
  };
});
