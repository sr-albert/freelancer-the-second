import 'package:fluttertoast/fluttertoast.dart';
import 'package:the_second/index.dart';

void main(){
  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  binding.renderView.automaticSystemUiAdjustment = false;

  return runApp(MyApp());
}
Widget getErrorWidget(FlutterErrorDetails error) {
  return Center(
    child: Text("Error appeared."),
  );
}
class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = getErrorWidget;
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  final String targetAddress = "98:D3:71:F9:74:BF";

  VideoPlayerController _videoController;
  num counter = 0;
  bool isReset = false;

  /// round = 0: start app
  /// round = 1: init bottle
  /// round = 2 : push up
  /// round = 3 : push down
  double round = 0;
  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }
  bleHandler() async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(targetAddress);
      print('Connected to the device');
      showToast("Connected");
      connection.input.listen((Uint8List data) {
        handleData(ascii.decode(data));
        connection.output.add(data); // Sen
        // ding data
        if (ascii.decode(data).contains('!')) {
          connection.finish(); // Closing connection
          showToast("Disconnecting by local host");
        }
      }).onDone(() {
        showToast("Disconnected by remote request");
      });
    } catch (exception) {
      showToast("Cannot connect, exception occured");
      print(exception);
    }
  }

  handleData(data) {
//    print('Data incoming: $data');
    if (data.contains('OK') || data.contains('NG')) {
      counter++;
      if (counter == 5) {
//        print('Data incoming: $data');
//        print('Data counter: $counter');
//        print('Data round: $round');
        counter = 0;
        isReset=false;
        if (round == 0) {
          round = 1;
          setVideo(video1, true);
        }

        if (round == 1 && data.contains('NG')) {
          // bottle pushed on and user push up it
          round = 2;
          setVideo(video2, true);
        }

        if (round == 2 && data.contains('OK')) {
          // bottle pushed on and user push up it
          round = 3;
          setVideo(video3, false);
          isReset = true;
        }

        if (round == 3 && data.contains('NG')) {
          // bottle pushed on and user push up it
          round = 2;
          setVideo(video2, true);
        }
      }
    }
  }

  setVideo(_dataSource, isLoop) {
    try{
//    print("Initied : ${_videoController.value.initialized}");
      try{
        _videoController.dispose();
      }catch(ex){

      }
      _videoController = VideoPlayerController.asset(_dataSource);
      _videoController.addListener(() {
        if (!_videoController.value.isPlaying && isReset && round == 3) {
          isReset = false;
          setVideo(video1, true);
        }
        setState(() {});
      });
      _videoController.setLooping(isLoop);
      _videoController.setVolume(0);
      _videoController.initialize().then((_) => setState(() {}));
      _videoController.play();
    } catch (exception) {
      print(exception);
    }
  }

  @override
  void initState() {
    super.initState();
    setOrientation();
    bleHandler();
    // Setup video controller\
    setVideo(video1, true);
    WidgetsBinding.instance.renderView.automaticSystemUiAdjustment=false;  //<--
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.blue.shade700,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    disposeOrientation();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(

      body: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FlatButton(
          child: Stack(
            children: <Widget>[
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),],
          ),
        ),
      ),
    );
  }
}
