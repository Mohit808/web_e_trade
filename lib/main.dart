import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_e_trade/welcome.dart';
import 'package:http/http.dart' as http;


class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}
late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  HttpOverrides.global = MyHttpOverrides();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.high,
  );
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirebaseAuth.instance.currentUser==null?WelcomePage():MyHomePage(),
      // home: FirebaseAuth.instance.currentUser!=null?WelcomePage():MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var index=0;


  @override
  void initState() {
    FirebaseMessaging.instance.getToken().then((value) => {
      print('Token-- $value')
    });
    subss();
  }
  subss() async {
    final prefs = await SharedPreferences.getInstance();
    var subs=prefs.getString("subs");
    print('subssssssssss $subs');
    if(subs==null){
      FirebaseMessaging.instance.subscribeToTopic("web_e_trade");
      prefs.setString('subs', 'yes');
    }
  }

  @override
  Widget build(BuildContext context) {

    print(FirebaseAuth.instance.currentUser!.uid);
    return Scaffold(

      appBar:
      AppBar(backgroundColor: Colors.red,centerTitle: true,title: const Text("Web-E-Trade"),leading: Padding(
        padding: const EdgeInsets.only(left: 18.0),
        child: Image.network('https://cdn-icons-png.flaticon.com/512/6378/6378754.png'),),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.notifications)),
          // Padding(
          //   padding: const EdgeInsets.only(top: 16.0,bottom: 16.0,right: 16.0,left: 16.0),
          //   child: RaisedButton(onPressed: (){},child: const Text('subscriber'),),
          // ),
        ],
      ),
      body: Stack(children: [
        Offstage(
          offstage: index != 0,
          child: TickerMode(
            enabled: index == 0,
            child: MaterialApp(debugShowCheckedModeBanner: false,home: HomeTab()),
          ),
        ),
        Offstage(
          offstage: index != 1,
          child: TickerMode(
            enabled: index == 1,
            child: MaterialApp(debugShowCheckedModeBanner: false,home: HistoryPage()),
          ),
        ),
        Offstage(
          offstage: index != 2,
          child: TickerMode(
            enabled: index == 2,
            child: MaterialApp(debugShowCheckedModeBanner: false,home: LiveChatPage()),
          ),
        ),
        Offstage(
          offstage: index != 3,
          child: TickerMode(
            enabled: index == 3,
            child: MaterialApp(debugShowCheckedModeBanner: false,home: SupportPage()),
          ),
        ),
        Offstage(
          offstage: index != 4,
          child: TickerMode(
            enabled: index == 4,
            child: MaterialApp(debugShowCheckedModeBanner: false,home: MyAccountPage()),
          ),
        ),
        Offstage(
          offstage: index != 5,
          child: TickerMode(
            enabled: index == 5,
            child: MaterialApp(debugShowCheckedModeBanner: false,home: NewsPage()),
          ),
        ),
        Offstage(
          offstage: index != 6,
          child: TickerMode(
            enabled: index == 6,
            child: MaterialApp(debugShowCheckedModeBanner: false,home: UpdatePage()),
          ),
        ),
      ],),
      bottomNavigationBar:  BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        onTap: (int index){
          setState(() {
            this.index=index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history),label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.chat),label: "Live Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent),label: "Support"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle),label: "My Account"),
          BottomNavigationBarItem(icon: Icon(Icons.new_releases_sharp),label: "News"),
          BottomNavigationBarItem(icon: Icon(Icons.system_update_tv),label: "Update"),
        ],),
    );
  }
}


class HomeTab extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return HomeTabState();
  }
}
class HomeTabState extends State<HomeTab>{

  List listSlider= [];
  List map= [];
  List mapTabs= [];
  // List<Widget> list=[];
  // late TabController _tabController;
  int selectedIndex=0;
  // bool processing=true;
  @override
  void initState() {
    super.initState();
    var currentUser=FirebaseAuth.instance.currentUser;
    checkUserLoginRequest();
    getSliderImages();
    getTabs();
    sendRequest(selectedIndex);

    var currentTime = DateTime.now().millisecondsSinceEpoch/1000;
    const oneSec = const Duration(seconds: 20);
    Timer _timer = Timer.periodic(oneSec, (Timer timer) {
      print('sadasdasda ');
      sendRequest(selectedIndex);
    },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      sendRequest(selectedIndex);
      print('MESSAGE LISTENNNNNNNNNNNNNNNNNNNNNNN ${message.notification}');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }
  tokennnn() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((event) {
      print('tokennn  ${event}');
    });
  }

  checkUserLoginRequest() async {
    var url = Uri.parse('https://algostart.in/api/check_user_login?mobile=${mAuth.currentUser!.phoneNumber.toString().substring(3)}');
    var response = await http.post(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    print(mAuth.currentUser);
    var data=response.body;
    var value=jsonDecode(data);
    if(value['success']==false){
      // print('Falseeeee');
      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=> WelcomePage()));
    }else{
      if(value['data']['is_plan_expired']=='0'){
        print(value['data']['is_plan_expired']);
        // Navigator.of(context).push(MaterialPageRoute(builder: (context)=> MyHomePage()));

      }else{
        // print(value['data']['is_plan_expired']);
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=> WelcomePage()));
        Fluttertoast.showToast(msg: 'Free trial has expired, subscribe now');
      }
    }

    // print(await http.read(Uri.parse('https://example.com/foobar.txt')));
  }

  getTabs() async {
    var url = Uri.parse('https://algostart.in/api/get_tabs');
    var response = await http.get(url);
    String data=response.body;
    mapTabs =jsonDecode(data);
    setState(() {
      mapTabs;
    });

    // list.add(Tab(text: "hello",));
    //
    // print('Listvvv ${list.length}');
    // print('Listvvv ${list}');
  }
  getSliderImages() async {
    var url = Uri.parse('https://algostart.in/api/get_all_slider_images');
    var response = await http.get(url);
    String data=response.body;
    listSlider =jsonDecode(data);
    setState(() {
      listSlider;
    });
  }
  sendRequest(selectedIndex) async {
    print("selectedIndexBeforeCall $selectedIndex");
    var url = Uri.parse('https://algostart.in/api/get_all_records');
    Map<String, dynamic> body = {'tab_id': '${selectedIndex+1}'};
    var response = await http.post(url,body: body);
    String data=response.body;
    var value=jsonDecode(data);
    var mapx =value['records'];
    print("whatBody $mapx");
    print('updatedMap ${mapx[0]}');
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    print('date ${date.toString().split(" ")[0].replaceAll('3', '1')}');

    map.clear();
    var myDate=date.toString().split(" ")[0];
    for(int i=0;i<mapx.length;i++){
      if(mapx[i]['date']==myDate){
        map.add(mapx[i]);
        print('Sammmmmmmmeeeeeeeeeeeee');
      }
      if(mapx[i]['date']!=myDate && mapx[i]['result']=='ONGOING'){
        map.add(mapx[i]);
      }
    }
    setState(() {
      map;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(child: Container(
        color: Colors.grey[300],
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(),
            child: Container(color: Colors.white,
              child: SizedBox(height: 50,child:
              ListView.builder(primary: false,shrinkWrap: true,itemCount: mapTabs.length,scrollDirection: Axis.horizontal,itemBuilder: (BuildContext context,int index){
                // return Container(margin: EdgeInsets.all(8),child: Text(mapTabs[index]['tab']),);
                return InkWell(onTap: (){
                  setState(() {
                    selectedIndex=index;
                    print("selectedIndex $selectedIndex");
                    sendRequest(selectedIndex);
                  });
                },
                  child: Column(
                    children: [
                      Container(width: MediaQuery.of(context).size.width/4,child: Tab(child: Text(mapTabs[index]['tab']),)),
                      selectedIndex==index?Container(width: MediaQuery.of(context).size.width/4,height: 1,color: Colors.cyan,):Container()
                    ],
                  ),
                );
              }),),
            ),
          ),
          const SizedBox(height: 16,),
          SizedBox(height: 150,width: MediaQuery.of(context).size.width,child:
          ListView.builder(primary: false,shrinkWrap: true,itemCount: listSlider.length,scrollDirection: Axis.horizontal,itemBuilder: (BuildContext context,int index){
            return Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image:
                  NetworkImage(
                      'https://algostart.in/img_carousel_image/'+listSlider[index]['image']),
                  // NetworkImage(
                  //     'https://media.istockphoto.com/photos/financial-and-technical-data-analysis-graph-picture-id1145882183?k=20&m=1145882183&s=612x612&w=0&h=H30_SGkGv7vsUYaFxzh_uW3_7TaQlqavfaegpKMGl20='),
                  fit: BoxFit.fill,
                ),

                // NetworkImage(
                //     'https://algostart.in/img_carousel_image/'+listSlider[index]['image']),
              ),
            );
          }),),
          map.isEmpty?Container(margin: EdgeInsets.only(top: 30),child: Image.network('https://i.pinimg.com/originals/49/e5/8d/49e58d5922019b8ec4642a2e2b9291c2.png')):ListView.builder(primary: false,shrinkWrap: true,itemCount: map.length,itemBuilder: (BuildContext context,int index){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(padding: EdgeInsets.only(top: 16,bottom: 16),color: Colors.white,child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
                Column(children: [
                  SizedBox(width: 30,height: 30,child: Image.network('https://s2.coinmarketcap.com/static/img/coins/200x200/1.png')),
                  Text(map[index]['entry_price'])
                ],),
                Column(children: [
                  SizedBox(width: 70,height: 20,child: Text(map[index]['stock_name'],style: TextStyle(fontSize: 16),)),
                  Wrap(children: [
                    Text(map[index]['current_price'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.red)),
                    Icon(Icons.arrow_drop_down),
                  ],),
                ],),

                Container(height: 50,width: 1,color: Colors.grey,),
                Wrap(direction: Axis.vertical,spacing: 8,children: [
                  Wrap(spacing: 8,
                    children: [
                      Text('SL'),
                      Text(map[index]['sl'].toString(),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red))
                    ],),
                  Wrap(spacing: 8,
                    children: [
                      Text('TP'),
                      Text(map[index]['tp'],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red))
                    ],),
                ],),

                Container(height: 50,width: 1,color: Colors.grey,),

                // Wrap(direction: Axis.vertical,spacing: 8,children: const [
                //   Text('CANDLE'),
                //   Text('DAILY',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                // ],),

                Column(
                  // direction: Axis.vertical,spacing: 8,
                  children: [
                    Text('P&L'),
                    SizedBox(height: 8,),
                    Text(map[index]['p_and_l'],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                  ],),

                Image.network('https://algostart.in/img_stock/'+map[index]['image'],height: 40,width: 30,)
                // Stack(children: [
                //   Wrap(direction: Axis.vertical,spacing: 8,children: [
                //     Text('TYPE'),
                //     Text(map[index]['type'],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                //   ],),
                //   // SizedBox(height: 40,width: 100,child: Image.network('https://assets.avatrademarketing.com/wp-content/images/blog/inverted-hammer.png'),)
                //
                // ],),

              ],),),
            );
          }),
        ],),
      ),
      ),
    );

  }

}


class HistoryPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return HistoryPageState();
  }
}
class HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin{

  List map= [];
  List mapTabs= [];
  int selectedIndex=0;
  @override
  void initState() {
    super.initState();
    getTabs();
    sendRequest(selectedIndex);
  }

  getTabs() async {
    var url = Uri.parse('https://algostart.in/api/get_tabs');
    var response = await http.get(url);
    String data=response.body;
    mapTabs =jsonDecode(data);
    setState(() {
      mapTabs;
    });
  }
  sendRequest(selectedIndex) async {
    print("selectedIndexBeforeCall $selectedIndex");
    var url = Uri.parse('https://algostart.in/api/get_all_records');
    Map<String, dynamic> body = {'tab_id': '${selectedIndex+1}'};
    var response = await http.post(url,body: body);
    String data=response.body;
    var value=jsonDecode(data);
    var mapx =value['records'];
    // print("whatBody $mapx");
    // print('updatedMap ${mapx[0]}');
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    print('date ${date.toString().split(" ")[0].replaceAll('3', '1')}');
    print("mapxxxxx $mapx");
    var myDate=date.toString().split(" ")[0];

    map.clear();
    for(int i=0;i<mapx.length;i++){
      print('inforloop ${mapx[i]['date']}  ${myDate}');
      print('inforloop ${mapx[i]['date']!=myDate}');
      if(mapx[i]['date']!=myDate){
        if(mapx[i]['result']=='SUCCESS' || mapx[i]['result']=='FAILURE'){
          map.add(mapx[i]);
        }
        print('Sammmmmmmmeeeeeeeeeeeee');
      }
    }
    setState(() {
      map;
    });

    print("mmmmmmmmm ${mapx.length}");
    print("mmmmmmmmm ${map.length}");
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(child: Container(
        color: Colors.grey[300],
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(),
            child: Container(color: Colors.white,
              child: SizedBox(height: 50,child:
              ListView.builder(primary: false,shrinkWrap: true,itemCount: mapTabs.length,scrollDirection: Axis.horizontal,itemBuilder: (BuildContext context,int index){
                // return Container(margin: EdgeInsets.all(8),child: Text(mapTabs[index]['tab']),);
                return InkWell(onTap: (){
                  setState(() {
                    selectedIndex=index;
                    print("selectedIndex $selectedIndex");
                    sendRequest(selectedIndex);
                  });
                },
                  child: Column(
                    children: [
                      Container(width: MediaQuery.of(context).size.width/4,child: Tab(child: Text(mapTabs[index]['tab']),)),
                      selectedIndex==index?Container(width: MediaQuery.of(context).size.width/4,height: 1,color: Colors.cyan,):Container()
                    ],
                  ),
                );
              }),),
            ),
          ),
          const SizedBox(height: 16,),
          map.isEmpty?Container(margin: EdgeInsets.only(top: 30),child: Image.network('https://i.pinimg.com/originals/49/e5/8d/49e58d5922019b8ec4642a2e2b9291c2.png')):ListView.builder(primary: false,shrinkWrap: true,itemCount: map.length,itemBuilder: (BuildContext context,int index){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(padding: EdgeInsets.only(top: 16,bottom: 16),color: Colors.white,child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
                Column(children: [
                  SizedBox(width: 30,height: 30,child: Image.network('https://s2.coinmarketcap.com/static/img/coins/200x200/1.png')),
                  Text(map[index]['entry_price'])
                ],),
                Column(children: [
                  SizedBox(width: 70,height: 20,child: Text(map[index]['stock_name'],style: TextStyle(fontSize: 16),)),
                  Wrap(children: [
                    Text(map[index]['current_price'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.red)),
                    Icon(Icons.arrow_drop_down),
                  ],),
                ],),

                Container(height: 50,width: 1,color: Colors.grey,),
                Wrap(direction: Axis.vertical,spacing: 8,children: [
                  Wrap(spacing: 8,
                    children: [
                      Text('SL'),
                      Text(map[index]['sl'].toString(),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red))
                    ],),
                  Wrap(spacing: 8,
                    children: [
                      Text('TP'),
                      Text(map[index]['tp'],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red))
                    ],),
                ],),

                Container(height: 50,width: 1,color: Colors.grey,),

                // Wrap(direction: Axis.vertical,spacing: 8,children: const [
                //   Text('CANDLE'),
                //   Text('DAILY',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                // ],),

                Column(
                  // direction: Axis.vertical,spacing: 8,
                  children: [
                    Text('P&L'),
                    SizedBox(height: 8,),
                    Text(map[index]['p_and_l'],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                  ],),

                Container(height: 50,width: 1,color: Colors.grey,),

                Column(
                  // direction: Axis.vertical,spacing: 8,
                  children: [
                    Text('STATUS'),
                    SizedBox(height: 8,),
                    Text(map[index]['result'],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                  ],)
                // Image.network('https://algostart.in/img_stock/'+map[index]['image'],height: 40,width: 30,)
                // Stack(children: [
                //   Wrap(direction: Axis.vertical,spacing: 8,children: [
                //     Text('TYPE'),
                //     Text(map[index]['type'],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                //   ],),
                //   // SizedBox(height: 40,width: 100,child: Image.network('https://assets.avatrademarketing.com/wp-content/images/blog/inverted-hammer.png'),)
                //
                // ],),

              ],),),
            );
          }),
        ],),
      ),
      ),
    );

  }
}


class LiveChatPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return LiveChatPageState();
  }
}
class LiveChatPageState extends State<LiveChatPage>{

  List list=[];


  @override
  void initState() {
    super.initState();
    list.add({'sender':'company','data':'Hello'});
    list.add({'sender':'company','data':'Im here to help you! Ask me a question.'});
  }

  @override
  Widget build(BuildContext context) {

    TextEditingController controller=TextEditingController();
    return  Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height/1.35,
              child:
              ListView.builder(itemCount: list.length,itemBuilder: (BuildContext context,int index){return Padding(
                padding: const EdgeInsets.only(left: 16.0,top: 16,right: 16),
                child: Row(mainAxisAlignment: list[index]['sender']=="company"? MainAxisAlignment.start:MainAxisAlignment.end,children: [
                  Text(list[index]['data'])
                ],),
              );}),
            ),
            Wrap(spacing: 8,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width/1.4,
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[800]),
                        hintText: "Type in your text",
                        fillColor: Colors.white70),
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    setState(() {
                      list.add({'sender':'user','data':controller.text});
                    });
                    controller.text='';
                  },
                  elevation: 2.0,
                  fillColor: Colors.red,
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  shape: const CircleBorder(),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SupportPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return SupportPageState();
  }
}
class SupportPageState extends State<SupportPage>{
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 24),
        child:
        Wrap(direction: Axis.vertical,spacing: 24,children: [
          Wrap(alignment: WrapAlignment.spaceEvenly,
            children :[
              Container(color: Colors.grey[200],child: SizedBox(width:MediaQuery.of(context).size.width,height: 150.0,child: Icon(Icons.support_agent,size: 100,))),
            ],
          ),
          Container(width: MediaQuery.of(context).size.width,color: Colors.grey[400],
            child: Container(margin: EdgeInsets.only(left: 24,top: 5,bottom: 5),
              child: const
              Text('Help And Support!',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Wrap(spacing: 16,
              children: const [
                Icon(Icons.question_answer_rounded),
                Text('FAQ',style: TextStyle(fontSize: 20),),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Wrap(spacing: 16,
              children: const [
                Icon(Icons.call_end_rounded),
                Text('Call',style: TextStyle(fontSize: 20),),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Wrap(alignment: WrapAlignment.center,spacing: 16,
              children: const [
                Icon(Icons.email_rounded),
                Text('Email',style: TextStyle(fontSize: 20),),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Wrap(alignment: WrapAlignment.center,spacing: 16,
              children: const [
                Icon(Icons.info),
                Text('About us',style: TextStyle(fontSize: 20),),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Wrap(alignment: WrapAlignment.center,spacing: 16,
              children: const [
                Icon(Icons.account_tree_rounded),
                Text('Terms and conditions',style: TextStyle(fontSize: 20),),
              ],
            ),
          ),
        ],),
      ),

      // appBar: AppBar(title: Text("Suppprt"),),
    );
  }
}

class MyAccountPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return MyAccountPageState();
  }
}
class MyAccountPageState extends State<MyAccountPage>{

  @override
  Widget build(BuildContext context) {

    var user=FirebaseAuth.instance.currentUser;
    var myName=FirebaseAuth.instance.currentUser!.displayName.toString();
    var myEmail=FirebaseAuth.instance.currentUser!.email;
    var myPhone=FirebaseAuth.instance.currentUser!.phoneNumber;

    return  Scaffold(
      // appBar: AppBar(title: Text("My Account"),),
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0,top: 24),
        child: Wrap(direction: Axis.vertical,spacing: 24,children: [


          SizedBox(width: MediaQuery.of(context).size.width/1.1,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(direction: Axis.vertical,children: [
                  user==null?Text('Welcome!',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),):
                  Text('',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
                  // Text(myName,style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
                  myEmail!=null?myEmail==null?Text('Login in to view your profile!'):Text(myEmail):
                  myPhone==null?Text('Login in to view your profile!'):Text(myPhone),

                ],),
                user==null?RaisedButton(onPressed: (){},child: Text('LOGIN',style: TextStyle(color: Colors.white),),color: Colors.red,):Text('')
              ],
            ),
          ),

          Wrap(spacing: 16,
            children: const [
              Icon(Icons.star_rate_rounded),
              Text('rate us'),
            ],
          ),
          Wrap(spacing: 16,
            children: const [
              Icon(Icons.share),
              Text('Share'),
            ],
          ),
          Wrap(alignment: WrapAlignment.center,spacing: 16,
            children: const [
              Icon(Icons.info),
              Text('About us'),
            ],
          ),
          Wrap(alignment: WrapAlignment.center,spacing: 16,
            children: const [
              Icon(Icons.info),
              Text('Privacy policy'),
            ],
          ),
          Wrap(alignment: WrapAlignment.center,spacing: 16,
            children: const [
              Icon(Icons.account_tree_rounded),
              Text('Terms and conditions'),
            ],
          ),
          GestureDetector(onTap: (){
            FirebaseAuth.instance.signOut();
            GoogleSignIn().signOut();
            SystemNavigator.pop();
          },
            child: user!=null?Wrap(alignment: WrapAlignment.center,spacing: 16,
              children: const [
                Icon(Icons.logout),
                Text('Logout'),
              ],
            ):Text(''),
          ),
        ],),
      ),
    );
  }
}

class NewsPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return NewsPageState();
  }
}
class NewsPageState extends State<NewsPage>{
  List list=[];

  @override
  void initState() {
    list.add({'title':'Some text here','desc':'small description here. ','image':'Hello','dp':'dp'});
    list.add({'title':'Some text here','desc':'small description here. ','image':'Hello','dp':'dp'});
    list.add({'title':'Some text here','desc':'small description here. ','image':'Hello','dp':'dp'});
    list.add({'title':'qwertyu','desc':'Hello  ','image':'Hello','dp':'dp'});
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      // appBar: AppBar(title: Text("News"),),
      body:
      SizedBox(height: MediaQuery.of(context).size.height/1.1,
        child:
        ListView.builder(itemCount: list.length,itemBuilder: (BuildContext context,int index){return Padding(
          padding: const EdgeInsets.only(left: 16.0,top: 16,right: 16,bottom: 16),
          child: Wrap(spacing: 8,direction: Axis.vertical,children: [
            Text(list[index]['title'],maxLines:2,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            Text(list[index]['desc'],),
            Container(
              height: 150,
              width: MediaQuery.of(context).size.width/1.1,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://media.istockphoto.com/photos/financial-and-technical-data-analysis-graph-picture-id1145882183?k=20&m=1145882183&s=612x612&w=0&h=H30_SGkGv7vsUYaFxzh_uW3_7TaQlqavfaegpKMGl20='),
                  fit: BoxFit.fill,
                ),

              ),
            )
          ],),
        );}),
      ),
    );
  }
}

class UpdatePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return UpdatePageState();
  }
}
class UpdatePageState extends State<UpdatePage>{
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      // appBar: AppBar(title: Text("Update"),),
      body: Center(child: Text('No update Available',style: TextStyle(fontSize: 30),),),
    );
  }
}






