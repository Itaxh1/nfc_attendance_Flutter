import 'package:device_info/device_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Functions {
  final DeviceInfoPlugin deviceinfo = DeviceInfoPlugin();
  final FirebaseFirestore store = FirebaseFirestore.instance;

  deviceAdd(id) async {
    AndroidDeviceInfo info = await deviceinfo.androidInfo;
    store.collection('users').doc(id).update({'device': info.androidId});
  }

  deviceCheck(id) async {
    final user = store.collection('users');
    dynamic deets;
    try {
      await user.doc(id).get().then((value) {
        deets = value.data();
      });
      if (deets['device'] == null) {
        print('work');
        await deviceAdd(id);
      } else {
        return deets['device'];
      }
    } catch (e) {}
  }

  userdeets(id) async {
    dynamic deets;
    try {
      await store.collection('users').doc(id).get().then((value) {
        deets = value.data();
      });
      return deets['name'];
    } catch (e) {}
  }

  userattendance(id) {
    return store.collection('users').doc(id).snapshots();
  }

  mark(id, clas) async {
    await store
        .collection('users')
        .doc(id)
        .update({'attendance.' + clas.toString() + '.marked': true});
  }
}
