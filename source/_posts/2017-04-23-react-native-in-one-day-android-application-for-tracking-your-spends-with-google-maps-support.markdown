---
layout: post
title: "React Native in one day: Android Application for tracking your spends with Google Maps Support"
date: 2017-04-23 00:32:26 +0200
comments: true
categories: "reactjs, javascript, react-native, google-maps, android, sample, example, first-application"
---

{% img center /images/react_maps/title_image.png %}

Usually I travel a lot by my car and make blog posts about it. And usually readers ask me about the mileage, gas consumption and other useful information. So I have decided to create a simple application, where I would be able to save all this information just in few clicks, without any registrations, advertisements and big tracking applications. I’ve never written any Android application and I wanted to take a look at the React library, so react-native was the best choice for me.

## BASIC SETUPS

I don’t want to write another guide about how to set up react-native and Android studio. All the information about the installation steps is described [here](https://facebook.github.io/react-native/docs/getting-started.html "React-Native Docs"). Just don’t forget to turn on `KVM` in bios, if your system supports it.

Let’s create a new project with
``` plain
react-native init project_name
react-native init gas_counter_map
```

And `cd` into it:

``` plain
cd gas_counter_map
```
Now we have an empty project that we can build and test on our virtual mobile.
First, we need to run a virtual device.

If you haven’t copied the path to your emulator yet, you need to open an Android studio and run the virtual devise from there. As soon as you do it, you shall copy string that runs the emulator from console at the bottom of the Android-studio. Later you can use this copied command to run your device.
``` plain
/home/YOUR USER NAME/Android/Sdk/tools/emulator -netdelay none -netspeed full -avd Xperia
```
Then, if you haven’t launched React Native yet, let’s do it.
``` plain
react-native start
```
And finally, we need to build our application’s code.
``` plain
react-native run-android
```

If everything is OK, you should see an Android screen with the initial text on it.
Let’s modify our code now.

##CONFIGURING AND USING REACT-NATIVE-MAPS

Before taking the next steps, I suggest you to initialize a git repository and commit your code.
``` plain
git init
git add .
git commit -m “Initial commit”
```
It will save your progress and later you will be able to undo your changes at any time.
I use [react-native-maps](https://github.com/lelandrichardson/react-native-maps/) package because it has been suggested as a stable map package for android applications by react-native developers. The guide to set-up a package is here.
Let’s add a component to our view.

``` js
<MapView  />
```

And let’s add some style to it.

``` js
<MapView
  style={styles.map}
/>
```

And in styles section of `index.android.js`

``` css
map: {
  height: 150,
  alignSelf: 'stretch',
},
```

##LET’S TRY IT!

``` plain
react-native run-android
```
At this step we should see a working map on our virtual device’s screen.

{% img center /images/react_maps/Screenshot_20160613-155504-576x1024.png 300 %}

If at this stage you see a black grey space with “Google” label, than you’ve missed some Google key configurations.
Now you may commit your changes.

## GETTING CURRENT USER’S LOCATION

At first, we need to request a permission in `AndroidManifest.xml`

``` xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Let’s define our variables in `index.android.js` under a class definition.

``` js
constructor(props) {
   super(props);
   this.state = {
     initialCoords: 'unknown', //<- Our coords
     gotGpsData: false,
   };
 }
```
`counstructor()` initializes the state with our given variables and their values.
For our GPS data we need to use a `navigator.getCurrentPosition` and `navigator.watchCurrentPosition` methods
``` js
getGpsData(){
   navigator.geolocation.getCurrentPosition(
     (position) => {
       this.setState({initialCoords: position.coords});
       this.setState({gotGpsData: true});
     },
     (error) => alert(error),
     {enableHighAccuracy: true, timeout: 20000, maximumAge: 1000}
   );

   navigator.geolocation.watchPosition(
     (position) => {
       var lastPosition = JSON.stringify(position);
       this.setState({initialCoords: position.coords});
       this.setState({gotGpsData: true});
       this.render();
     },
     (error) => {}
   );
 }
```
First, we are getting our user’s location, and then we are creating watcher for the changes of his location. If a user has changed his location, we are rendering view again with an updated map. If there were no errors, we are setting our `gotGpsData` boolean to true.
Let’s update our `render()` action with the new opportunities!
``` js
render() {
   if (!this.state.gotGpsData) {
     this.getGpsData();
     return this.renderLoadingView();
   }
   return (
     <View style={styles.container}>
       <MapView
         style={styles.map}
         region={ {
           longitude: this.state.initialCoords.longitude,
           latitude: this.state.initialCoords.latitude,
           latitudeDelta: 0.5,
           longitudeDelta: 0.5,
         }}
       />
       <Text style={styles.instructions}>
         {this.state.initialCoords.latitude}
       </Text>
     </View>
   );
 }
}
```

What are we doing in this part of the code?

If the user hasn’t given an access to his GPS coords or coords are not yet received, we are trying to get them again and calling `renderLoadingView`. We will talk about it later.
If we have got user’s coordinates, we are creating a map widget with user’s location.
Under the map we will see user’s `initialLatitude`, so we will be able to check our watchers and other code.
`latitudeDelta` (the vertical distance represented by the region), and `longitudeDelta` (the horizontal distance represented by the region) can be set at 0.001 or as per your need. The larger number is – the bigger view distance from the place.
What about `renderLoadingView`?
Let’s update our boring view a bit and add `ProgressBarAndroid` to the `import{}` section.
Now we can write a nice “loader” that the user will see until we receive any coordinates.
``` js
renderLoadingView(){
   return (
     <View style={styles.container}>
       <ProgressBarAndroid />
       <Text style={styles.instructions}>
         Receiving GPS information...
       </Text>
     </View>
   );
 }
```

{% img center /images/react_maps/Screenshot_20160609-151657-576x1024.png 300 %}

Now you may want to commit your changes.

## INPUTS FOR PRICES AND MILEAGE

So, we are writing an application about prices, mileage and gas consumption, right? Then we need inputs for these data.
At first we need to add a `TextInput` component to the `import{}` section of our application.
To create a basic input we can use a code like this:
``` js
<TextInput style={ {height: 40, borderColor: 'gray', borderWidth: 1}}  />
```
But how will we assign this data to a variable?
Let’s add some new variables to our constructor
``` js
constructor(props) {
   super(props);
   this.state = {
     initialCoords: 'unknown',
     gotGpsData: false,
     spentMoney: 0, // <- NEW
     filledLiters:0, // <- NEW
     droveMileage: 0, // <- NEW
     gotCoords: 'unknown',
   };
 }
```
And a callback on the input field change.
``` js
<TextInput
  style={ {height: 40, borderColor: 'gray', borderWidth: 1}}
  onChangeText={(spentMoney) => this.setState({spentMoney})}
  value={this.state.text}
/>
```
At each change of the input, we will update our local variable and use it in our input. Good? Not yet!

{% img center /images/react_maps/Screenshot_20160701-1636212-576x1024.png 300 %}

All our data are digital. For a better UI we can update our inputs, so that they show a numeric keyboard on each click by setting a `keyboardType` property:
``` js
<TextInput
  style={ {height: 40, borderColor: 'gray', borderWidth: 1}}
  onChangeText={(spentMoney) => this.setState({spentMoney})}
  value={this.state.text}
  keyboardType={'numeric'}
/>
```
Let’s update our view with other inputs and captions.
``` js
render() {
    if (!this.state.gotGpsData) {
      this.getGpsData();
      return this.renderLoadingView();
    }
    return (
      <View style={styles.container}>
        <MapView
          style={styles.map}
          region={ {
            longitude: this.state.initialCoords.longitude,
            latitude: this.state.initialCoords.latitude,
            latitudeDelta: 0.01,
            longitudeDelta: 0.01,
          }}
        />
        <Text style={styles.instructions}>
          Spent money
        </Text>
        <TextInput
          style={ {height: 40, borderColor: 'gray', borderWidth: 1}}
          onChangeText={(spentMoney) => this.setState({spentMoney})}
          value={this.state.text}
          keyboardType={'numeric'}
        />
        <Text style={styles.instructions}>
          Filled-in liters
        </Text>
        <TextInput
          style={ {height: 40, borderColor: 'gray', borderWidth: 1}}
          onChangeText={(filledLiters) => this.setState({filledLiters})}
          value={this.state.text}
          keyboardType={'numeric'}
        />
        <Text style={styles.instructions}>
          Mileage from the last point
        </Text>
        <TextInput
          style={ {height: 40, borderColor: 'gray', borderWidth: 1}}
          onChangeText={(droveMileage) => this.setState({droveMileage})}
          value={this.state.text}
          keyboardType={'numeric'}
        />
        <Text style={styles.instructions}>
          {this.state.initialCoords.latitude}
        </Text>
      </View>
    );
  }
}
```

{% img center /images/react_maps/Screenshot_20160701-163623-1-576x1024.png 300 %}

Now we can modify our map.
You may want to commit your changes and test them, so we can proceed to the next step.
## ADDING PRICE MARKERS

Google Maps have a great tool called “markers” to point out location. I suggest to use this tool to point out current user’s place. `react-native-maps` have a “price marker” with which we will show our user how much he has spent and where.
First, we need to download a `PriceMarker` sample in our project’s folder, so that we could use it in our map.

https://github.com/DiatomEnterprises/react-native-maps/blob/master/example/examples/PriceMarker.js


Next – we need to add it in our main project
``` js
import PriceMarker from './PriceMarker';
```
Then we can add this marker to our map and show the value of Spent Money variable. In order to do this you need to put this code inside `<MapView style=”…”..>` </MapView> tag:
``` js
<MapView style=”...”...>
   <MapView.Marker
      coordinate={this.state.initialCoords}
      draggable
   >
      <PriceMarker amount={this.state.spentMoney} />
   </MapView.Marker>
</MapView>
```
After building your project you should see something like this:
{% img center /images/react_maps/Screenshot_20160701-163403-576x1024.png 300 %}

Now we are ready to save our data.
You may want to commit your changes and test them, so we can go to the next step.
## SAVING CURRENT DATA

To save our current data, we will use `AsyncStorage`. It’s a simple, asynchronous, persistent, key-value storage system that is global to the app.
At first we need to add `AsycStorage` to the import section
``` js
import {
 AsyncStorage,
…
}
```
Next – let’s update our state. We need a variable that will save records count from the database to work with IDs. Also, we need a `lastRecords` variable that will contain our previous records. And finally, we need a method that will synchronize our storage with the application on startup.
``` js
constructor(props) {
  super(props);
  this.state = {
    ...
    recordCount: 0,
    lastRecords: [],
    ...
  }
  this.syncStorage();
}
```
`syncStorage()` method will be called on startup and will synchronize the current records and their count with the state.
``` js
syncStorage() {
  AsyncStorage.getAllKeys((err, keys) => {
    AsyncStorage.multiGet(keys, (err, stores) => {
      this.setState({recordCount: stores.length});
      this.setState({lastRecords: stores});
    });
  });
}
```
In this part of code, at first, we are getting all of the keys that `AsyncStorage` contains.
Then, we are getting all records by these keys.
Next, we need to create a method to save our data in a storage
``` js
saveData() {
  var saveData = {
    "longitude": this.state.initialCoords.longitude,
    "latitude": this.state.initialCoords.latitude,
    "spentMoney": this.state.spentMoney,
    "filledLiters": this.state.filledLiters,
    "droveMileage": this.state.filledLiters,
    "timestamp": Math.round(new Date().getTime() / 1000),
  };
  AsyncStorage.setItem("record_"+this.state.record_count+1, JSON.stringify(saveData)).then(
    this.setState({message: "Saved record #"+this.state.record_count+1})
  ).then(this.sync_storage()).done(
    this.render()
  );
}
```
`AsyncStorage.setItem()` Sets value for key and calls callback on completion
I’ve added a `timestamp` in milliseconds, thus, we can get an information about when we have done this record.
Now, let’s update our views:
``` js
<View style={styles.container}>
  <MapView>
    <MapView.Marker ...    > ...  </MapView.Marker>
    {
      this.state.lastRecords.map(function(item, index){
        item = JSON.parse(item[1])
        coords = { latitude: item.latitude, longitude: item.longitude }
        return (
          <MapView.Marker
            coordinate = { coords }
            draggable
          >
            <PriceMarker amount={item.spentMoney} />
          </MapView.Marker>
        )
      }.bind(this))
    }
  </MapView>
  …
  <TouchableHighlight
   activeOpacity={0.6}
   underlayColor={'white'}
   onPress={() => this.saveData()}>
    <Text style={styles.button}>Save</Text>
  </TouchableHighlight>
  <Text style={styles.instructions}>
    {this.state.message}
  </Text>
  <Text style={styles.instructions}>
    Your fuel consumption on this {this.state.droveMileage} km is {Math.round(this.state.filledLiters * 100 / this.state.droveMileage *100)/100} l/100km
  </Text>
</View>
```
We have added a cycle for generating markers inside the `<MapView>` tag. This part of code maps all previous records and creates markers on map from them.
`<TouchableHighlight>`  is a wrapper for making views respond properly to touch.  The main part is `onPress` event that calls `this.saveData()` method.
`this.state.message` returns a message about successful save.
Finally, we calculate fuel consumption basing on the mileage driven. We assume that the previous time user filled up his car and check how much fuel he has spent until now. Then we take the driven mileage and calculate his fuel consumption.
I think that my drive to Riga could look like this:

{% img center /images/react_maps/Screenshot_20160701-163737-576x1024.png 300 %}
{% img center /images/react_maps/Screenshot_20160701-163833-576x1024.png 300 %}
{% img center /images/react_maps/Screenshot_20160701-164036-576x1024.png 300 %}

That’s it! Finally, don’t forget to commit your changes.
You can manipulate with the saved data in any way: calculate all user’s expenses, mileage driven, average fuel consumption or create a swarm-like application.
Link to the GitHub [source](https://github.com/AKovtunov/gas_counter_map)
Just for case if you are not sure what is difference between [ReactJS](http://www.diatomenterprises.com/technologies/reactjs-specifics/) and React Native.
React Native is a mobile framework that compiles to native app components.
It allows you to build native mobile applications (iOS, Android, and Windows) in JavaScript.
[ReactJS](http://www.diatomenterprises.com/technologies/reactjs-specifics/) is full JS library which is easy to use on your web.
Both are open sourced by Facebook.
