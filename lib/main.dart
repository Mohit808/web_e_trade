import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:web_e_trade/welcome.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  Widget build(BuildContext context) {
    print(',m,m');
    print(FirebaseAuth.instance.currentUser!.uid);
    return Scaffold(

      appBar:
      AppBar(backgroundColor: Colors.red,centerTitle: true,title: const Text("Web-E-Trade"),leading: Padding(
        padding: const EdgeInsets.only(left: 18.0),
        child: Image.network('https://cdn-icons-png.flaticon.com/512/6378/6378754.png'),),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.notifications)),
          Padding(
            padding: const EdgeInsets.only(top: 16.0,bottom: 16.0,right: 16.0,left: 16.0),
            child: RaisedButton(onPressed: (){},child: const Text('subscriber'),),
          ),
        ],
      ),
      body: Stack(children: [
        Offstage(
          offstage: index != 0,
          child: TickerMode(
            enabled: index == 0,
            child: MaterialApp(debugShowCheckedModeBanner: false,home: HistoryPage()),
          ),
        ),
        Offstage(
          offstage: index != 1,
          child: TickerMode(
            enabled: index == 1,
            child: MaterialApp(debugShowCheckedModeBanner: false,home: LiveChatPage()),
          ),
        ),
        Offstage(
          offstage: index != 2,
          child: TickerMode(
            enabled: index == 2,
            child: MaterialApp(debugShowCheckedModeBanner: false,home: SupportPage()),
          ),
        ),
        Offstage(
          offstage: index != 3,
          child: TickerMode(
            enabled: index == 3,
            child: MaterialApp(debugShowCheckedModeBanner: false,home: MyAccountPage()),
          ),
        ),
        Offstage(
          offstage: index != 4,
          child: TickerMode(
            enabled: index == 4,
            child: MaterialApp(debugShowCheckedModeBanner: false,home: NewsPage()),
          ),
        ),
        Offstage(
          offstage: index != 5,
          child: TickerMode(
            enabled: index == 5,
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





class HistoryPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return HistoryPageState();
  }
}
class HistoryPageState extends State<HistoryPage>{

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(child: Container(
            color: Colors.grey[100],
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
              Text('NSE',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue)),
              Text('CRYPTO',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue)),
              Text('MCX',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue)),
              Text('FOREX',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue)),
              Text('Update &\nnew Ticker',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.redAccent)),
              RaisedButton(color: Colors.red,onPressed: (){},child: Text('subscribe',style: TextStyle(color: Colors.white)),),
            ],),
            SizedBox(height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,child:
            ListView.builder(itemBuilder: (BuildContext context,int index){
              return index==0?
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://media.istockphoto.com/photos/financial-and-technical-data-analysis-graph-picture-id1145882183?k=20&m=1145882183&s=612x612&w=0&h=H30_SGkGv7vsUYaFxzh_uW3_7TaQlqavfaegpKMGl20='),
                      fit: BoxFit.fill,
                    ),

                  ),
                ),
              ):
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(padding: EdgeInsets.only(top: 16,bottom: 16),color: Colors.white,child:Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                  Wrap(direction: Axis.vertical,children: [
                    SizedBox(width: 50,height: 50,child: Image.network('https://s2.coinmarketcap.com/static/img/coins/200x200/1.png')),
                    Text('6885')
                  ],),
                  Column(children: [
                    const Text('Titan',style: TextStyle(fontSize: 20),),
                    Wrap(children: const [
                      Text('7050',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.red)),
                      Icon(Icons.arrow_drop_down),
                    ],),
                  ],),

                  Wrap(direction: Axis.vertical,spacing: 8,children: [
                    Wrap(spacing: 8,children: const [
                      Text('SL'),
                      Text('6885',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red))
                    ],),
                    Wrap(spacing: 8,children: const [
                      Text('TP'),
                      Text('6885',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red))
                    ],),
                  ],),

                  Wrap(direction: Axis.vertical,spacing: 8,children: const [
                    Text('CANDLE'),
                    Text('DAILY',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                  ],),

                  Wrap(direction: Axis.vertical,spacing: 8,children: const [
                    Text('P&L'),
                    Text('+65',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                  ],),

                  Stack(children: [
                    Wrap(direction: Axis.vertical,spacing: 8,children: const [
                      Text('TYPE'),
                      Text('REV',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                    ],),
                    // SizedBox(height: 40,width: 100,child: Image.network('https://assets.avatrademarketing.com/wp-content/images/blog/inverted-hammer.png'),)

                  ],),

                ],),),
              );
            }),
            ),
          ],),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    var currentUser=FirebaseAuth.instance.currentUser;
    print('currentUserrrrr .... $currentUser');
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
